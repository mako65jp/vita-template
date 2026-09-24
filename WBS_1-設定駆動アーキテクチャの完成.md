# 設定駆動アーキテクチャ完成 WBS

## Epic

設定駆動アーキテクチャ完成

---

# Feature: Configuration 現状把握と統一

## CFG-001 設定項目棚卸し

### 目的

システムが持つ設定の全体像を把握する。

### 対象ファイル

```text
config/development.json
config/staging.json
config/production.json

apps/api/src/config/*
apps/web/ApplicationConfiguration.ts
packages/types/Config.ts
```

### 作業方法

#### 調査

- 全設定項目を抽出する
- 環境ごとの差分を確認する
- API側とWeb側で重複定義がないか確認する

#### 整理

以下の形式で一覧化する

```text
設定名
型
デフォルト値
利用箇所
備考
```

### 確認方法

以下が説明できること

```text
database.type
↓
どこで定義されるか
↓
どこで利用されるか

authentication.type
↓
どこで定義されるか
↓
どこで利用されるか
```

### 成果物

```text
Configuration Catalog
```

### 完了条件

- [ ] 全設定項目が一覧化されている
- [ ] 未使用設定がわかる

---

## CFG-002 設定利用マトリクス作成

### 目的

設定が実際に利用されているか確認する。

### 作業方法

各設定値を全文検索する。

例

```bash
grep -r "database.type" .
grep -r "authentication.type" .
grep -r "frontend.type" .
```

利用箇所を分類する。

```text
設定読込

Factory

DI登録

Feature登録

Route登録

画面表示
```

### 確認方法

設定ごとに

```text
利用箇所あり
未使用
部分利用
```

を判定する。

### 成果物

```text
Configuration Usage Matrix
```

### 完了条件

- [ ] 全設定の利用箇所が判明している
- [ ] 設定未適用箇所が判明している

---

## CFG-003 設定型統一

### 目的

設定モデルを単一契約に統一する。

### 作業方法

比較対象

```text
packages/types/Config.ts

apps/web/ApplicationConfiguration.ts

apps/api/src/config/Config.ts
```

確認事項

```text
重複定義

名称違い

型違い

責務違い
```

共通契約へ統合する。

### 確認方法

以下が存在しない。

```text
ApplicationConfiguration

FrontendConfiguration

BackendConfiguration
```

の独自定義。

### 成果物

```text
Unified Config Model
```

### 完了条件

- [ ] 設定型定義が1箇所

---

## CFG-004 Configuration Validation導入

### 目的

不正設定での起動を防止する。

### 作業方法

検証対象定義

```text
database.type

authentication.type

frontend.type
```

許可値を定義する。

例

```text
database.type

postgres
sqlserver
inmemory
```

起動前に検証する。

### 確認方法

以下で起動失敗すること。

```json
{
    "database": {
        "type": "aaa"
    }
}
```

### 完了条件

- [ ] 不正設定で起動しない

---

# Feature: Database 設定駆動化

## DB-001 Database構造調査

### 目的

Database切替構造を理解する。

### 対象

```text
Database.ts
createDatabase.ts
PostgreSqlDatabase.ts
SqlServerDatabase.ts
InMemoryDatabase.ts
DrizzleDatabase.ts
```

### 作業方法

調査項目

```text
生成責務

接続責務

DI登録責務

利用側責務
```

生成フロー図を作成する。

### 確認方法

以下が説明できる。

```text
Config
↓
createDatabase
↓
Database実装
↓
DI登録
↓
Repository利用
```

### 完了条件

- [ ] DB生成経路が把握できている

---

## DB-002 DB生成経路統一

### 目的

DB生成をcreateDatabaseへ集約する。

### 作業方法

検索

```bash
grep -r "new PostgreSqlDatabase" .
grep -r "new SqlServerDatabase" .
grep -r "new InMemoryDatabase" .
```

createDatabase以外の生成を除去する。

### 修正対象

```text
apps/api/src/**
```

### 確認方法

createDatabase.ts以外で

```text
PostgreSqlDatabase
SqlServerDatabase
InMemoryDatabase
```

が生成されていない。

### 完了条件

- [ ] Database生成箇所が1箇所

---

## DB-003 database.type完全適用

### 目的

設定のみでDB切替できる状態にする。

### 作業方法

以下を確認。

```json
{
    "database": {
        "type": "postgres"
    }
}
```

↓

PostgreSqlDatabase

---

```json
{
    "database": {
        "type": "sqlserver"
    }
}
```

↓

SqlServerDatabase

---

```json
{
    "database": {
        "type": "inmemory"
    }
}
```

↓

InMemoryDatabase

### 確認方法

設定変更のみで切り替わる。

### 完了条件

- [ ] DB切替成功

---

## DB-004 Database DI登録統一

### 目的

DIがDB実装を知らない状態にする。

### 対象

```text
createContainer.ts
DependencyContainer.ts
```

### 作業方法

変更前

```ts
register(PostgreSqlDatabase);
```

変更後

```ts
register(database);
```

### 確認方法

DIコードから

```text
PostgreSqlDatabase

SqlServerDatabase

InMemoryDatabase
```

が消えている。

### 完了条件

- [ ] DIがDB実装に依存しない

---

# Feature: Authentication 設定駆動化

## AUT-001 Authentication構造調査

### 目的

認証生成箇所を特定する。

### 対象

```text
apps/api/src/features/authentication
```

### 作業方法

検索

```bash
grep -r "Jwt" .
grep -r "Authentication" .
```

調査

```text
生成箇所

DI登録箇所

利用箇所
```

### 完了条件

- [ ] 認証生成経路が説明できる

---

## AUT-002 認証契約統一

### 目的

認証実装の共通契約を定義する。

### 作業方法

整理対象

```text
JwtAuthentication

LocalAuthentication
```

利用側が共通契約だけを参照するよう修正する。

### 確認方法

Application層から具体実装が見えない。

### 完了条件

- [ ] 認証利用側が実装非依存

---

## AUT-003 createAuthentication導入

### 目的

認証生成を1箇所へ集約する。

### 作業方法

作成

```text
createAuthentication.ts
```

入力

```ts
config.authentication.type;
```

出力

```text
JwtAuthentication
LocalAuthentication
```

### 確認方法

検索

```bash
grep -r "new Jwt" .
```

でFactory外生成が存在しない。

### 完了条件

- [ ] 認証生成箇所が1箇所

---

## AUT-004 Authentication DI登録統一

### 目的

DIが認証実装を知らない状態にする。

### 作業方法

変更前

```ts
register(JwtAuthentication);
```

変更後

```ts
register(authentication);
```

### 確認方法

DIコードがJWT実装名を参照しない。

### 完了条件

- [ ] DIが認証実装に依存しない

---

# Feature: Feature管理

## FTR-001 Feature構造調査

### 対象

```text
features/user
features/authentication
features/authorization
features/administration
```

### 作業方法

調査

```text
Route登録

Service登録

Repository登録
```

### 完了条件

- [ ] Feature登録箇所が特定できている

---

## FTR-002 User Feature ON/OFF対応

### 目的

設定で機能を切り替える。

### 作業方法

確認

```json
{
    "features": {
        "user": true
    }
}
```

---

確認

```json
{
    "features": {
        "user": false
    }
}
```

### 確認方法

OFF時

```text
Route未登録

Service未登録

Repository未登録
```

### 完了条件

- [ ] 設定だけで有効無効切替

---

## FTR-003 Feature Registry導入

### 目的

Feature登録処理を集約する。

### 作業方法

現在の登録箇所を集約する。

目標

```text
registerFeatures(config)
```

### 確認方法

新Feature追加時に修正箇所が限定される。

### 完了条件

- [ ] Feature登録箇所が集約されている

---

# Feature: Administration

## ADM-001 Administration分析

### 作業方法

調査

```text
administration.enabled

administration.authentication.type
```

利用箇所特定。

### 完了条件

- [ ] 管理機能の境界が明確

---

## ADM-002 Administration Feature化

### 作業方法

管理機能を独立Featureとして扱う。

登録

```text
registerAdministrationFeature()
```

へ集約。

### 完了条件

- [ ] Administrationが独立Feature

---

## ADM-003 Administration設定適用

### 作業方法

確認

```json
{
    "administration": {
        "enabled": false
    }
}
```

### 確認方法

管理機能が登録されない。

### 完了条件

- [ ] 管理機能の有効無効切替可能

---

# Feature: Bootstrap

## BST-001 起動シーケンス分析

### 対象

```text
main.ts
createApp.ts
createContainer.ts
```

### 作業方法

処理順を整理する。

現状フローを図示する。

### 完了条件

- [ ] 起動フロー図作成

---

## BST-002 起動順序標準化

### 目標

```text
Load Config
↓
Validate Config
↓
Create Database
↓
Create Authentication
↓
Register Features
↓
Build Container
↓
Create App
↓
Start App
```

### 作業方法

差異を洗い出し修正する。

### 確認方法

初期化責務が重複していない。

### 完了条件

- [ ] 起動フロー統一

---

# Feature: Verification

## TST-001 Database切替確認

### 作業方法

設定変更

```json
"database.type": "postgres"
```

起動確認

---

```json
"database.type": "sqlserver"
```

起動確認

---

```json
"database.type": "inmemory"
```

起動確認

### 完了条件

- [ ] 全DBで起動成功

---

## TST-002 Authentication切替確認

### 作業方法

```json
"authentication.type": "jwt"
```

確認

---

```json
"authentication.type": "local"
```

確認

### 完了条件

- [ ] 認証切替成功

---

## TST-003 Feature切替確認

### 作業方法

```json
"features.user": true
```

確認

---

```json
"features.user": false
```

確認

### 完了条件

- [ ] Feature切替成功

---

# Definition of Done

- [ ] 設定項目が全て把握されている
- [ ] 設定モデルが統一されている
- [ ] 設定利用状況が可視化されている
- [ ] Databaseが設定のみで切替可能
- [ ] Authenticationが設定のみで切替可能
- [ ] DI登録が設定駆動になっている
- [ ] Feature登録が設定駆動になっている
- [ ] Administrationが設定駆動になっている
- [ ] 起動シーケンスが標準化されている
- [ ] アプリケーション層が具体実装へ依存していない
- [ ] Config変更だけでシステム構成を変更できる

# 設定駆動アーキテクチャ完成 WBS

## 目的

現在存在する設定が実際にシステム動作へ反映される状態を実現する。

最終的には、

```json
{
    "database": {
        "type": "postgres"
    },
    "authentication": {
        "type": "jwt"
    },
    "features": {
        "user": true
    },
    "administration": {
        "enabled": true
    }
}
```

のような設定変更のみで、システム構成や動作を切り替えられる状態を目指す。

---

# Phase 1 現状把握

目的：

- 現在の設定がどこで使われているか確認する
- 設定が存在するだけなのか、本当に利用されているのか確認する
- 設定駆動化の完成度を把握する

---

## TASK-001 設定一覧作成

### 目的

現在管理している設定を一覧化する。

### 対象

```text
config/development.json
config/staging.json
config/production.json
```

### 作業方法

設定ファイルから設定項目を抽出する。

分類する。

```text
backend
database
authentication
administration
features
frontend
```

### 確認方法

以下が一覧化されていること。

```text
backend.protocol
backend.host
backend.port
backend.applicationRoot

database.type
database.connectionString

authentication.type
authentication.secret

administration.enabled
administration.authentication.type

features.user

frontend.type
```

### 成果物

```text
設定一覧
```

### 完了条件

- 設定項目が把握できている

---

## TASK-002 database.type 利用状況確認

### 目的

database.type が実際にDB選択へ利用されているか確認する。

### 対象

```text
apps/api/src/database/createDatabase.ts
apps/api/src/database/Database.ts
apps/api/src/database/PostgreSqlDatabase.ts
apps/api/src/database/SqlServerDatabase.ts
apps/api/src/database/InMemoryDatabase.ts
```

### 作業方法

#### 1

createDatabase.ts を確認する。

#### 2

database.type を参照しているか確認する。

#### 3

以下を確認する。

```text
postgres
↓
PostgreSqlDatabase

sqlserver
↓
SqlServerDatabase

inmemory
↓
InMemoryDatabase
```

#### 4

createDatabase.ts 以外にDB生成箇所が存在しないか調査する。

検索例

```bash
grep -R "new PostgreSqlDatabase" .
grep -R "new SqlServerDatabase" .
grep -R "new InMemoryDatabase" .
```

### 確認方法

以下が説明できる。

```text
database.type
↓
createDatabase
↓
DB選択
↓
利用開始
```

### 成果物

```text
Database利用状況レポート
```

### 完了条件

- database.type の利用箇所が分かっている
- DB選択方式が説明できる

---

## TASK-003 authentication.type 利用状況確認

### 目的

authentication.type が実際に認証方式の決定に使われているか確認する。

### 対象

```text
apps/api/src/features/authentication
```

### 作業方法

#### 1

認証関連ファイルを確認する。

#### 2

authentication.type の参照箇所を検索する。

検索例

```bash
grep -R "authentication.type" .
```

#### 3

JWT認証生成箇所を確認する。

検索例

```bash
grep -R "Jwt" .
```

#### 4

認証方式の切替処理の有無を確認する。

### 確認方法

以下が説明できる。

```text
authentication.type
↓
認証実装選択
↓
DI登録
↓
利用
```

### 成果物

```text
Authentication利用状況レポート
```

### 完了条件

- authentication.type の利用箇所が分かっている
- 認証生成方式が説明できる

---

## TASK-004 frontend.type 利用状況確認

### 目的

frontend.type が実際に利用されているか確認する。

### 対象

```text
apps/web

Application.ts
ApplicationConfiguration.ts
FrontendConfigurationService.ts
RuntimeConfigurationProvider.ts

apps/web/react
apps/web/vue
```

### 作業方法

#### 1

frontend.type の参照箇所を検索する。

#### 2

ReactとVueの起動方式を確認する。

#### 3

frontend.type が切替に利用されているか確認する。

### 確認方法

以下が説明できる。

```text
frontend.type
↓
React
または
Vue
```

### 成果物

```text
Frontend利用状況レポート
```

### 完了条件

- frontend.type の利用箇所が分かっている

---

## TASK-005 administration.enabled 利用状況確認

### 目的

Administration機能が設定によって制御されているか確認する。

### 対象

```text
apps/api/src/features/administration
```

### 作業方法

#### 1

administration.enabled の利用箇所を検索する。

#### 2

Route登録箇所を確認する。

#### 3

機能登録箇所を確認する。

### 確認方法

以下が説明できる。

```text
administration.enabled=false
↓
何が停止するか
```

### 成果物

```text
Administration利用状況レポート
```

### 完了条件

- administration.enabled の効果が説明できる

---

## TASK-006 features.user 利用状況確認

### 目的

User機能が設定によって制御されているか確認する。

### 対象

```text
apps/api/src/features/user
```

### 作業方法

#### 1

features.user の利用箇所を検索する。

#### 2

Route登録箇所を確認する。

#### 3

Service登録箇所を確認する。

### 確認方法

以下が説明できる。

```text
features.user=false
↓
何が無効化されるか
```

### 成果物

```text
User Feature利用状況レポート
```

### 完了条件

- features.user の効果が説明できる

---

# Phase 2 問題点洗い出し

目的：

- 設定が存在するだけで使われていない箇所を発見する
- ハードコーディング箇所を発見する

---

## TASK-007 未使用設定の特定

### 目的

利用されていない設定を発見する。

### 作業方法

Phase 1 の結果を整理する。

分類する。

```text
利用中

部分利用

未使用
```

### 成果物

```text
未使用設定一覧
```

### 完了条件

- 未使用設定が特定されている

---

## TASK-008 ハードコーディング調査

### 目的

設定で切り替えるべき箇所を発見する。

### 作業方法

検索する。

```text
postgres
sqlserver
inmemory

jwt
local

react
vue

localhost
3000
/api
```

### 確認方法

設定から取得できる値なのに固定値で記述されている箇所を抽出する。

### 成果物

```text
Hard Coding Report
```

### 完了条件

- 設定化候補が一覧化されている

---

# Phase 3 設定適用

目的：

- 設定値に応じて動作が変わる状態を実現する

---

## TASK-009 database.type 完全適用

### 実施条件

TASK-002で未完成と判定された場合

### 作業方法

database.type に応じてDB実装を選択する。

### 確認方法

```json
{
    "database": {
        "type": "postgres"
    }
}
```

↓

PostgreSQL利用

---

```json
{
    "database": {
        "type": "sqlserver"
    }
}
```

↓

SQL Server利用

---

```json
{
    "database": {
        "type": "inmemory"
    }
}
```

↓

InMemory利用

### 完了条件

- Config変更のみで切替可能

---

## TASK-010 authentication.type 完全適用

### 実施条件

TASK-003で未完成と判定された場合

### 作業方法

authentication.type に応じて認証方式を切替える。

### 確認方法

```json
{
    "authentication": {
        "type": "jwt"
    }
}
```

↓

JWT認証

---

```json
{
    "authentication": {
        "type": "local"
    }
}
```

↓

Local認証

### 完了条件

- Config変更のみで切替可能

---
