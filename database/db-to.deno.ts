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
): Promise<string[]> {
  return await [];
}

async function sqlToDb(sql: SqlGroup, target: CouldExcute) {
  
}
async function readSqlFiles(path: string): Promise<SqlGroup> {
  const stat = await Deno.stat(path);
  const readFile = async (p: string): Promise<[Schema, RowSql[]]> => {
    const sqls = await Deno.readTextFile(p);
    
    return ["", sqls.split("\n")];
  }
  if (stat.isFile) {
    const pair = await readFile(path);
    return {
      [pair[0]]: pair[1],
    };
  } else if (stat.isDirectory) {
    console.log(path);
    for await (const dirEntry of Deno.readDir(path)) {
      if (dirEntry.isFile) {
        readFile(dirEntry.name);
      }
    }
  } 
  return {};
}
async function saveSqlToDir(sqls: string[], to: string) {
  
}

const res = await readSqlFiles("sql/test.sql");
console.log(res);

// main
const { from, to } = syncConfig;
if (typeof from === "string") {
  if (typeof to === "string") {
    throw new Error("不支持sql to sql模式");
  }
  const sourceSqls = await readSqlFiles(from);
  const client = await new Client().connect(to);
  client.transaction(async conn => {
    await sqlToDb(sourceSqls, conn);
  });
} else {
  const sourceClient = await new Client().connect(from);
  if (typeof to === "string") {
    const sqls = await dbToSql(sourceClient);
    await saveSqlToDir(sqls, to);
  } else {
    const targetClient = await new Client().connect(to);
    targetClient.transaction(async conn => {
      await dbToSql(sourceClient, {
        cb: async (sql) => {
          await sqlToDb(sql, conn);
        },
      });
    });
  }
}
