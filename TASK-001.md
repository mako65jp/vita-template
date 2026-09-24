# TASK-001 設定構造調査

## 目的

設定駆動アーキテクチャ完成に向けて、

- 設定がどこで定義されているか
- 設定がどこから読み込まれるか
- 設定がアプリケーションへどのように伝播するか

を確認する。

---

# 調査対象

## 設定関連

- apps/api/src/config/Config.ts
- apps/api/src/config/loadConfig.ts
- apps/api/src/config/saveConfig.ts

## 起動処理

- apps/api/src/main.ts

---

# 調査結果

## Config構造

設定は Config をルートとした構造になっている。

```ts
export interface Config {
    database: DatabaseConfig;
    authentication: AuthenticationConfig;
    frontend: FrontendConfig;
}
```

構成図

```text
Config
├─ database
├─ authentication
└─ frontend
```

設定値を個別に管理するのではなく、
1つの Config に集約する設計になっている。

---

## DatabaseConfig

```ts
export interface DatabaseConfig {
    type: 'memory' | 'postgres' | 'sqlserver';
    connectionString?: string;
}
```

利用可能な設定値

```text
memory
postgres
sqlserver
```

役割

```text
利用するDatabase実装の選択
接続文字列設定
```

---

## AuthenticationConfig

```ts
export interface AuthenticationConfig {
    type: 'none' | 'jwt' | 'oidc' | 'ldap';
    secret?: string;
}
```

利用可能な設定値

```text
none
jwt
oidc
ldap
```

役割

```text
認証方式選択
認証設定管理
```

---

## FrontendConfig

```ts
export interface FrontendConfig {
    type: 'react' | 'vue';
}
```

利用可能な設定値

```text
react
vue
```

役割

```text
利用するフロントエンド選択
```

---

# Config設計評価

## 良い点

### 設定カテゴリが整理されている

以下の責務で分類されている。

```text
database
authentication
frontend
```

設定の追加や拡張がしやすい。

---

### TypeScript型で管理されている

例

```ts
type: 'memory' | 'postgres' | 'sqlserver';
```

設定値の候補がコード上で明示されている。

---

### Union Typeが利用されている

例えば

```ts
database.type = 'oracle';
```

はコンパイルエラーになる。

設定ミスを減らせる。

---

# 設定ロード処理

## loadConfig()

```ts
export async function loadConfig(): Promise<Config> {
    const json = await readFile('./config/development.json', 'utf8');

    return JSON.parse(json) as Config;
}
```

設定取得フロー

```text
development.json
↓
readFile()
↓
JSON.parse()
↓
Config
```

---

## 設定ソース

現在確認できる設定ソースは

```text
./config/development.json
```

のみ。

環境変数や外部設定サービスは利用していない。

---

## 設定ロード評価

### 良い点

構造が非常に単純。

```text
JSON
↓
Config
```

で理解しやすい。

---

### 問題点

実行時バリデーションが存在しない。

現在は

```ts
JSON.parse(json) as Config;
```

のみ。

---

例

```json
{
    "database": {
        "type": "oracle"
    }
}
```

でもロードできる。

理由

```text
TypeScript型は実行時には存在しないため
```

---

## 推奨改善

将来的には以下のいずれかを導入したい。

```text
zod
ajv
valibot
```

例

```text
JSON
↓
Schema Validation
↓
Config
```

---

# 設定保存処理

## saveConfig()

```ts
export async function saveConfig() {
    throw new Error('Not implemented.');
}
```

未実装。

---

## 現状評価

```text
設定読込あり
設定保存なし
```

状態になっている。

---

## 将来的な利用イメージ

```text
管理画面
↓
saveConfig()
↓
development.json
↓
再起動
```

または

```text
管理画面
↓
saveConfig()
↓
設定ストア
↓
即時反映
```

---

# アプリケーション起動処理

## main.ts

```ts
const config = await loadConfig();

const container = await createContainer(config);

const app = createApp(container);

serve({
    fetch: app.fetch,
    port: 3000,
});
```

---

## 起動シーケンス

```text
main.ts

↓

loadConfig()

↓

Config

↓

createContainer(config)

↓

createApp(container)

↓

Hono Server

↓

HTTP待受開始
```

---

## main.ts の責務

main.ts 自体は

```text
database.type
authentication.type
frontend.type
```

を利用していない。

責務は

```text
設定ロード

DIコンテナ生成

アプリ生成

サーバ起動
```

のみ。

---

## アーキテクチャ上の役割

main.ts は起動エントリである。

```text
Entry Point
```

として機能している。

---

# 設定伝播の全体像

今回確認できた範囲では以下。

```text
development.json
        ↓
loadConfig()
        ↓
Config
 ├─ database
 ├─ authentication
 └─ frontend
        ↓
main.ts
        ↓
createContainer(config)
        ↓
各Factory
        ↓
各Service
```

---

# 発見事項

## Config構造は既に整理されている

database

authentication

frontend

が独立している。

設定駆動化の前提設計は完了している。

---

## アプリケーション全体でConfigを利用する設計

```ts
createContainer(config);
```

となっている。

設定を個別に渡すのではなく、

Config全体を受け渡す構造になっている。

---

## 設定駆動アーキテクチャを意識した構造

Configには

```text
database.type
authentication.type
frontend.type
```

が存在する。

いずれも

```text
実装切替
```

を目的とした設定に見える。

---

## saveConfig未実装

設定駆動化の完成には

```text
設定変更
↓
保存
```

の仕組みが必要。

現状は未実装である。

---

## 実行時設定検証が未実装

設定ファイル破損時の保護機能が存在しない。

運用開始前に対応したい。

---

# 設定駆動化完成度評価

## Config定義

評価

```text
100%
```

理由

```text
構造整理済み
型定義済み
設定分類済み
```

---

## Configロード

評価

```text
90%
```

理由

```text
JSONロード可能
Config生成可能
```

未実装

```text
実行時検証
```

---

## Config保存

評価

```text
0%
```

理由

```text
saveConfig未実装
```

---

## 設定モデル全体

評価

```text
80%
```

---

# 結論

Config基盤は既に存在している。

現在の構造は

```text
development.json
↓
loadConfig()
↓
Config
↓
createContainer()
↓
Application
```

となっており、

設定をアプリケーションへ伝播する仕組みは完成している。

一方で、

```text
実行時設定検証

設定保存
```

は未実装である。

また、

```text
database.type
authentication.type
frontend.type
```

が実際にどこで利用されているかの個別調査が必要である。

---

# 次工程

## TASK-002

```text
database.type 利用状況確認
```

目的

```text
Database実装切替が
設定駆動化されているか確認する
```

調査対象

```text
apps/api/src/database/*
apps/api/src/app/createContainer.ts
```
