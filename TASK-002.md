# TASK-002 database.type 利用状況確認

## 目的

database.type がどこで利用されているかを特定し、
設定駆動アーキテクチャとして完成しているかを評価する。

---

# 調査対象

## Config

- apps/api/src/config/Config.ts
- apps/api/src/config/loadConfig.ts

## 起動処理

- apps/api/src/main.ts

## DI構築

- apps/api/src/app/createContainer.ts

## Database

- apps/api/src/database/createDatabase.ts
- apps/api/src/database/Database.ts
- apps/api/src/database/InMemoryDatabase.ts
- apps/api/src/database/DrizzleDatabase.ts
- apps/api/src/database/PostgreSqlDatabase.ts
- apps/api/src/database/SqlServerDatabase.ts

---

# 調査結果

## database.type 定義

Config.ts

```ts
export interface DatabaseConfig {
    type: 'memory' | 'postgres' | 'sqlserver';
    connectionString?: string;
}
```

database.type は以下の3種類を許可している。

```text
memory
postgres
sqlserver
```

---

## 設定ロード

loadConfig.ts

```ts
export async function loadConfig(): Promise<Config> {
    const json = await readFile('./config/development.json', 'utf8');

    return JSON.parse(json) as Config;
}
```

設定ロード経路

```text
development.json
↓
loadConfig()
↓
Config
```

database.type は JSON から読み込まれる。

---

## 起動処理

main.ts

```ts
const config = await loadConfig();

const container = await createContainer(config);

const app = createApp(container);
```

main.ts 自体は database.type を参照していない。

責務は

```text
設定ロード
↓
DIコンテナ生成
↓
アプリ生成
```

のみである。

---

## createContainer の確認

createContainer.ts

```ts
const database = await createDatabase(config.database);
```

ここで初めて database 設定が DatabaseFactory に渡される。

重要な点として、

```text
database.type
```

の利用は createContainer より下層へ閉じ込められている。

Repository や Service は Config を参照しない。

---

## database.type の実利用箇所

createDatabase.ts

```ts
switch (config.type)
```

調査した範囲では、

database.type の直接利用箇所はここだけである。

---

# 実装切替内容

## memory

```ts
case 'memory':
    return new InMemoryDatabase();
```

依存関係

```text
database.type=memory
↓
InMemoryDatabase
```

---

## postgres

```ts
case 'postgres':
    return new DrizzleDatabase(
        config.connectionString ?? ''
    );
```

依存関係

```text
database.type=postgres
↓
DrizzleDatabase
↓
pg.Pool
↓
PostgreSQL
```

---

## sqlserver

```ts
case 'sqlserver':
    throw new Error(
        'SQL Server not implemented'
    );
```

依存関係

```text
database.type=sqlserver
↓
起動失敗
```

設定値は存在するが実装は存在しない。

---

# Database Interface

Database.ts

```ts
export interface Database {
    query<T>();
    execute();
    beginTransaction();
    commit();
    rollback();
}
```

DatabaseFactory は必ず Database Interface を返却する。

そのため利用側は

```text
InMemoryDatabase
DrizzleDatabase
```

を知らない。

---

# createContainer の役割

createContainer はアプリケーションの Composition Root である。

```ts
const database = await createDatabase(config.database);

const userRepository = new UserRepositoryImpl(database);

const userService = new UserService(userRepository);

const authenticationService = new AuthenticationService(userService, jwtService);
```

依存関係

```text
Database
↓
UserRepository
↓
UserService
↓
AuthenticationService
```

database.type の影響は DatabaseFactory までであり、
それ以降の層へ設定知識は漏れていない。

---

# 実際の設定伝播

```text
development.json
↓
loadConfig()
↓
Config
↓
createContainer(config)
↓
createDatabase(config.database)
↓
database.type
 ├─ memory
 │   └─ InMemoryDatabase
 │
 ├─ postgres
 │   └─ DrizzleDatabase
 │
 └─ sqlserver
     └─ Error
↓
Database Interface
↓
UserRepositoryImpl
↓
UserService
↓
AuthenticationService
```

---

# 発見事項

## PostgreSqlDatabase.ts が未使用

存在

```text
apps/api/src/database/PostgreSqlDatabase.ts
```

createDatabase.ts から参照されていない。

```text
importなし
newなし
```

実行経路に存在しない。

Dead Code候補。

---

## SqlServerDatabase.ts が未使用

存在

```text
apps/api/src/database/SqlServerDatabase.ts
```

createDatabase.ts から参照されていない。

実行経路に存在しない。

Dead Code候補。

---

## sqlserver は設定だけ存在

Config

```ts
type:
  | 'memory'
  | 'postgres'
  | 'sqlserver';
```

Factory

```ts
case 'sqlserver':
    throw new Error(...)
```

状態

```text
設定可能
≠
利用可能
```

---

## Repository層に database.type 判定が存在しない

確認できた範囲では

```ts
if (config.database.type === ...)
```

のようなコードは存在しない。

Factoryへ責務が集約されている。

これは設定駆動アーキテクチャとして望ましい。

---

## Database層の設定駆動化はほぼ完了

今回の調査で判明した最も重要な事項。

当初は database.type の利用状況調査が目的だったが、

結果として

```text
Config
↓
Factory
↓
Interface
↓
Repository
↓
Service
```

が成立していることが確認できた。

Database層は想定以上に設定駆動化されている。

---

## 調査中に見つかった次の課題

createContainer.ts

```ts
const jwtService = new JwtService(config.authentication.secret ?? 'change-this-secret');
```

authentication.type の参照が存在しない。

database.type よりも、

```text
authentication.type
```

の方が未完成である可能性が高い。

---

# 設定駆動化完成度評価

## 設定定義

評価: 100%

理由

```text
DatabaseConfig存在
Union Type利用
```

---

## 設定ロード

評価: 100%

理由

```text
JSON → Config
```

が成立。

---

## Factory切替

評価: 100%

理由

```ts
createDatabase();
```

で実装が切り替わる。

---

## Interface化

評価: 100%

理由

利用側は Database Interface のみを参照する。

---

## 実装完成度

```text
memory      完成
postgres    完成
sqlserver   未実装
```

評価: 67%

---

# 総合評価

```text
設定定義       100%
設定ロード     100%
DI投入         100%
Factory切替    100%
Interface化    100%
実装完成度      67%

総合            95%
```

---

# 結論

database.type に関しては、設定駆動化アーキテクチャはほぼ完成している。

実際の構造は

```text
Config
↓
Factory
↓
Database Interface
↓
Repository
↓
Service
```

となっており、Database実装の切り替え責務は createDatabase() に集約されている。

残課題は以下。

```text
sqlserver実装
Dead Code整理
実行時設定バリデーション
```

また、本調査により次の重点調査対象は

```text
authentication.type
```

であることが判明した。
