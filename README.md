# Webアプリケーション基盤 今後の開発計画

## 1. 現状整理

現在、本プロジェクトは TypeScript をベースとしたモノレポ構成の Web アプリケーション基盤として、以下を目標としている。

### アーキテクチャ方針

- 標準機能と共通ロジックを提供するアプリケーション基盤を提供する
- 拡張機能は独立したモジュールとして分離する
- DI（Dependency Injection）による疎結合な構成を採用する
- 設定値による機能選択を可能にする
- 認証方式・DB・フロントエンド技術を差し替え可能とする
- 保守性・拡張性の高いコンポーザブルアーキテクチャを実現する
- テスタブルな構造とする

### 標準構成

#### 認証

- JWT（標準）

#### データベース

- PostgreSQL（標準）

#### フロントエンド

- React（標準）

### 現在確認済み事項

- Reactアプリケーション起動
- フロントエンドとバックエンドの通信
- 型安全なAPIクライアント
- Contextによる認証状態管理
- DI基盤
- 機能拡張の基本構造
- 選択可能なデータベース

React依存の抽象化については将来的な課題とし、現時点では後回しとする。

---

# 2. 現在の懸念事項

開発過程において試行錯誤を重ねた結果、以下の確認が必要となっている。

## 設定管理

- 設定項目の増加に追従できているか
- 設定値に応じた動作切替が実装されているか
- ハードコーディングが残存していないか

## DI適用状況

- DIコンテナを経由しないインスタンス生成が残っていないか
- 抽象化されたサービス利用になっているか

## モジュール構成

- 拡張機能の独立性が維持されているか
- 不適切な依存関係が存在しないか

## 技術的負債

- 不要ファイル
- 不要フォルダ
- 不要型定義
- 不要メソッド
- 不要ライブラリ

などが残存している可能性がある。

---

# 3. 開発方針

当面は新規機能の追加を優先せず、アーキテクチャの健全化を優先する。

### 目的

1. 設定駆動アーキテクチャの完成
2. プラグインアーキテクチャの完成
3. 技術的負債の解消
4. 将来のフロントエンド切替への備え

---

# 4. フェーズ1 アーキテクチャ監査

最優先。

新規機能開発より先に実施する。

## 4.1 設定値監査

### 目的

設定による切替が可能な状態を保証する。

### 確認内容

以下のようなハードコーディングの洗い出し。

```ts
const apiUrl = 'http://localhost:3000';
const provider = 'jwt';
const database = 'postgres';
```

### 対応方針

すべて設定オブジェクト経由へ統一する。

```ts
configuration.api.baseUrl;

configuration.authentication.provider;

configuration.database.provider;
```

### 成果物

- Hard Coding Report

---

## 4.2 DI監査

### 目的

依存性の生成をDIへ統一する。

### 確認内容

以下のようなコードの調査。

```ts
new UserService();
new JwtAuthenticationService();
```

### 目標

```ts
container.resolve(UserService);
```

または

```ts
@Inject(UserService)
```

へ統一する。

### 成果物

- Dependency Report

---

## 4.3 モジュール依存監査

### 目的

依存方向を固定する。

### 想定レイヤー

```text
core
authentication
database
extensions
api
web
```

### 依存ルール例

許可：

```text
web → api
api → core
authentication → core
database → core
extension → core
```

禁止：

```text
core → extension
core → web
extension → web
database → web
```

### 成果物

- Architecture Dependency Diagram
- Dependency Rules

---

# 5. フェーズ2 技術的負債の解消

監査結果に基づき不要資産を削除する。

## 対象

### 未使用コード

- class
- interface
- type
- enum
- utility

### 未使用ファイル

```text
*.ts
*.tsx
```

### 未使用フォルダ

`*`text
legacy
sample
temp*backup
old

````

*## 未使用ライブラリ

```json
dependencies
*evDependencies
````

の整理。

*## 成果物

- Cleanup Report

---

-   6. フェーズ3 設定システム完成

本*ロ*ェクトの最重要フェーズ。

## 目的

すべ**主要機能を設定で切り替えられるよう*する。

### 設定モデル

```json
{
  "*uthentication": {
    "provider": *jwt"
  },
  "*atabase": {
    "provider": "postg*es"
  },
  "frontend": {
    "fram*work": "react"
  }
}
```

*--

## 機能選択方式

### 認*

```json
{
 *"authentication": {
    "*rovider": "jwt"
  }
}
```

↓

```t*
JwtAuthenticationModule
```

をロード*

---

### データベース

```*son
{
  "database": {
    "*rovider": "postgres"
* }
}
```

↓

```ts*PostgreSqlDatabaseModule

```

をロード*

---

### フロントエンド

```json*{
  "frontend": {
    "framework":*"react"
  }
}
```

↓

`ts*ReactFrontendModule*`

をロード。

### 成果物

-*Configuration Specification

- Conf*guration Loader
- Module Resolver
  *---

# 7. フェーズ4 プラグイン機構完成

## *的

機能*加時に既存コード修正を最小*する。

### 目標構成

```text*packages/extensions

├─ auth-jwt
├* auth-oidc
├* auth-saml
├─ db-postgres
├─*db-mysql
├─ db-sqlserver
├─ fronte*d-react
├* frontend-vue
└─ frontend-svelte
`*`

---

## 実現したい機能

### 発*

*``text
自動検出
```

*## 登録

```text
自動登録
```

*## 有効化

*``json
{
"authentication": {
*"provider": "oidc"
}
}

````

### *効化

```json
{
  "authentication": *
    "provider": null
  }
}
*``

### 成果物

- Plugin Contract
- P*ugin*Registry
- Plugin Loader

---

# 8* フェーズ5 標準実装整理

まずは*用済みの標*実装を完成させる。

## 認証

-*JWT

## データベース

- PostgreSQL

## フ**トエンド

- React

### 実施内容

- DI*用
- 設定適用
- プ*グイン化
* テスト整備

### 成果物

-*JWT Module
- PostgreSQL Module
- R*act Module

---

* 9. フェーズ6 複数実装対応

標**装完成後に実施する。

## 認*

候補：

- OIDC
-*Azure AD / Entra ID
- SAML

##*デ*タベース

候補：

- MySQL
- SQL*Server
- SQLite

## フロントエンド

候補：

**Vue
- Svelte

重要なの*機*ではなく、

**設定*****替えられること**

である。

---

# 10. フェ*ズ* 品質基盤整備

## 単*テスト

対象：

```text
core
configurati*n
*uthentication
database
````

### 目標*

- 主要*メインロジックのテスト*羅
- 継*的リファクタリング可能な状態

---

*# 統合*スト

対象：

```text
ログイン
ユーザー*得
認証更新
DB接続
設定反映
```

*--

*# E2Eテスト

対象：

```text*ログイン
ログアウト
ユーザー管理
```

*--

# 11* フェーズ8 フロントエンド抽象化

最後*実施する。

## 現在

```text**eact
↓
Application
```

## 目標

```*ext
React Adapter
Vue Adapter
Svel*e*Adapter
↓
Frontend Framework Abstr*ction
↓
Application
```

## 目的

- *eact依存の排除
- UI*レームワーク選択可能化
- コ**ジックの再利用

---

-   12. 推奨*ィレクトリ構成*到達目*）

```text
packages

├─ core
├* configuration
├─*di

*─ authentication
│ *├─ contracts
│  └─ runtime

├─*database
*  ├─ contracts
│  └─ runtime

├* frontend
│  ├─ contracts
│ *└─*runtime

└─ extensions
  *├─ auth-jwt
   ├* auth-oidc*   ├─ db-postgres
  *├─ db-mysql
   ├─ frontend-react
 **├─ frontend-vue
   └─ frontend-sve*te
```

---

# 13. 優先順位

最終*な*施順序は以下とする。

```text*1. アーキテクチャ監査
2.*技術的負*の解消
3.*設定システム完成
4. プラグイン機構完成
5.*JWT/Postgre*QL/React実装整理
6.*追加認証方式対応
7. 追加データベース対応
8**テスト基盤整備
9.*React依存除去
10. Vue/Svelte対応
```

*--

#*14. 完了*件

*下の*態を達成した時点で、本基盤のアーキテクチャ上の第一段階完了とする。
*- 設定値が全レイヤーで利用される

- ハ*ドコーディング*排除されている
- DI*外でサービス生成を行わない
  -*認**式を設定のみで切り替えられる
- デ*タベースを設定のみで切り替えられる*- フ*ントエンド実装を設定のみで切り替えられる
- プ*グイン追加時に*存コード修正を不要とする
  \-*標準*装（JWT／PostgreSQL／*eact）がプラグインとして動*する

この状態*なって初めて、

**「選択*能で*張可能な TypeScript モノレポ型*Webアプリケーション基盤」**

としての*礎が完成したと判断する。

```*

```
