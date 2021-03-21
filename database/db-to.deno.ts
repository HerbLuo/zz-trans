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

async function dbToSql(
  client: Client, 
  pipConfig?: {
    bufferSize?: number;
    cb: (sql: string[]) => void | Promise<void>;
  },
): Promise<string[]> {
  
}
async function sqlToDb(sql: string[], target: Client) {
  
}
async function readSqlFiles(path: string): Promise<string[]> {

}
async function saveSqlToDir(sqls: string[], to: string) {
  
}

// main
const { from, to } = syncConfig;
if (typeof from === "string") {
  if (typeof to === "string") {
    throw new Error("不支持sql to sql模式");
  }
  const sourceSqls = await readSqlFiles(from);
  const targetClient = await new Client().connect(to);
  await sqlToDb(sourceSqls, targetClient);
} else {
  const sourceClient = await new Client().connect(from);
  if (typeof to === "string") {
    const sqls = await dbToSql(sourceClient);
    await saveSqlToDir(sqls, to);
  } else {
    const targetClient = await new Client().connect(to);
    await dbToSql(sourceClient, {
      cb: async (sql) => {
        await sqlToDb(sql, targetClient);
      } 
    });
  }
}
