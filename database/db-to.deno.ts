import { Client, ClientConfig } from "https://deno.land/x/mysql/mod.ts";

const syncConfig: SyncConfig = {
  from: { // 可配置为链接，也可配置为文件夹路径(从配置的路径中读取所有sql文件，然后在目标数据库执行)
    hostname: "127.0.0.1",
    username: "root",
    db: "words",
    password: "123456",
  },
  to: "sql", // 可配置为链接，也可配置为文件夹路径(会将生成的sql文件保存至目标文件夹)
  tables: "*", // 可以为*或数组
  mode: "drop-create", // 目前仅支持该模式
};

interface SyncConfig {
  mode: "drop-create";
  from: string | ClientConfig;
  to: string | ClientConfig;
  tables: "*" | string[];
}

type CouldExcute = Pick<Client, "execute">;

type Schema = string;
type RowSql = string;
type SqlGroup = Record<Schema, RowSql[]>;

async function dbToSql(
  client: CouldExcute, 
  pipConfig?: {
    bufferSize?: number;
    cb: (sql: SqlGroup) => void | Promise<void>;
  },
): Promise<SqlGroup> {
  const shouldSyncTables = syncConfig.tables === "*"
    ? await client.execute(
      "SELECT TABLE_NAME FROM information_schema.TABLES WHERE table_type = 'BASE TABLE' AND table_schema = DATABASE()"
    ).then(r => r.rows?.map(r => r["TABLE_NAME"] as string) || [])
    : syncConfig.tables;
  const bufferSize = pipConfig?.bufferSize || 1000;  
  const pipCb = pipConfig?.cb;

  let rowSize = 0;
  let bufferedSqlGroup: SqlGroup = {};
  const executes: Array<Promise<void> | void> = [];
  for (const table of shouldSyncTables) {
    let i = 0;
    while(true) {
      const res = await client.execute(`SELECT * FROM ${table} LIMIT ${i*1000}, 1000`);
      const rows = res.rows || [];
      console.log(res.fields);

      bufferedSqlGroup[table] = rows.map(row => {
        const keys = Object.keys(row);
        const values = Object.values(row);
        return `INSERT INTO ${table} (${keys.join(",")}) VALUES (${values.map(v => {
          if (typeof v === "number") {
            return v;
          }
          if (typeof v === "string") {
            return `'${v}'`;
          }
          console.log(v)
          return v;
        }).join(",")})`;
      });
      rowSize = rowSize + rows.length;

      if (pipCb && rowSize > bufferSize) {
        executes.push(pipCb(bufferedSqlGroup));
        bufferedSqlGroup = {};
      }

      if (rows.length < 1000) {
        break;
      }
      i++;
    }
  }
  
  if (pipCb) {
    await Promise.all(executes);
    await pipCb(bufferedSqlGroup);
    return {};
  } else {
    return bufferedSqlGroup;
  }
}

async function sqlToDb(sql: SqlGroup, target: CouldExcute) {
  
}

const spearator = Deno.build.os === "windows" ? "\\" : "/";

const filenameNoExt = (path: string) => {
  const name = path.split(spearator).pop()!;
  const lastIndexOfDot = name.lastIndexOf(".");
  return lastIndexOfDot > 0 ? name.substring(0, lastIndexOfDot) : name;
}
const join = (dir: string, file: string) => dir.endsWith(spearator)
  ? dir + file
  : dir + spearator + file;

async function readSqlFiles(path: string): Promise<SqlGroup> {
  const stat = await Deno.stat(path);
  const readFile = async (filepath: string): Promise<[Schema, RowSql[]]> => {
    const sqlFilenameNoExt = filenameNoExt(filepath);
    const sqls = await Deno.readTextFile(filepath);
    return [sqlFilenameNoExt, sqls.split("\n")];
  }
  if (stat.isFile) {
    const pair = await readFile(path);
    return {
      [pair[0]]: pair[1],
    };
  }  
  if (stat.isDirectory) {
    const result: SqlGroup = {};
    for await (const dirEntry of Deno.readDir(path)) {
      if (dirEntry.isFile) {
        const pair = await readFile(join(path, dirEntry.name));
        result[pair[0]] = pair[1];
      }
    }
    return result;
  } 
  throw new Error("unsupport path: " + path);
}

async function saveSqlToDir(sqlGroup: SqlGroup, to: string) {
  for (const [filename, sqls] of Object.entries(sqlGroup)) {
    const filepath = join(to, filename + ".sql");
    await Deno.writeTextFile(filepath, sqls.join("\n"));
  }
}

// main
const { from, to } = syncConfig;
if (typeof from === "string") {
  if (typeof to === "string") {
    throw new Error("不支持sql to sql模式");
  }
  const sourceSqls = await readSqlFiles(from);
  const client = await new Client().connect(to);
  await client.transaction(async conn => {
    await sqlToDb(sourceSqls, conn);
  });
  await client.close();
} else {
  const sourceClient = await new Client().connect(from);
  if (typeof to === "string") {
    const sqlGroup = await dbToSql(sourceClient);
    await saveSqlToDir(sqlGroup, to);
  } else {
    const targetClient = await new Client().connect(to);
    await targetClient.transaction(async conn => {
      await dbToSql(sourceClient, {
        cb: async (sql) => {
          await sqlToDb(sql, conn);
        },
      });
    });
    await targetClient.close();
  }
  await sourceClient.close();
}
