# TASK-003 authentication.type 利用状況確認

## 目的

authentication.type がどこで利用されているかを特定し、
認証機能の設定駆動化完成度を評価する。

---

# 調査対象

## Config

- apps/api/src/config/Config.ts

## DI構築

- apps/api/src/app/createContainer.ts

## Authentication

- apps/api/src/features/authentication/AppJwtPayload.ts
- apps/api/src/features/authentication/AppVariables.ts
- apps/api/src/features/authentication/providers/AuthenticationProvider.ts
- apps/api/src/features/authentication/services/AuthenticationService.ts
- apps/api/src/features/authentication/services/JwtService.ts
- apps/api/src/features/authentication/controllers/AuthenticationController.ts
- apps/api/src/features/authentication/middleware/jwtAuthentication.ts
- apps/api/src/features/authentication/middleware/authorize.ts
- apps/api/src/features/authentication/middleware/authorizeSelfOrAdmin.ts

---

# 調査結果

## authentication.type 定義

Config.ts

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

---

## createContainer の確認

前回調査済み。

```ts
const jwtService = new JwtService(config.authentication.secret ?? 'change-this-secret');

const authenticationService = new AuthenticationService(userService, jwtService);
```

認証サービス生成時に参照されている設定は

```ts
authentication.secret;
```

のみである。

---

## authentication.type の利用箇所調査

認証関連コード全体を確認した。

検索対象

```text
AuthenticationService
JwtService
jwtAuthentication
AuthenticationController
AuthenticationProvider
authorize
authorizeSelfOrAdmin
```

結果

```text
authentication.type の利用箇所は存在しない
```

---

# 実際に使用されている認証方式

実装を確認した結果、

現在の認証方式は JWT 固定である。

---

## AuthenticationService

```ts
constructor(
    private readonly users: UserService,
    private readonly jwt: JwtService,
)
```

ログイン成功時

```ts
return {
    accessToken: this.jwt.createAccessToken(user.id, user.email, user.role),
    expiresIn: 3600,
};
```

JWT発行が前提になっている。

---

## JwtService

```ts
export class JwtService
```

生成

```ts
jwt.sign(...)
```

検証

```ts
jwt.verify(...)
```

JWT専用実装になっている。

---

## jwtAuthentication

```ts
jwtService.verify(token);
```

JWT検証前提。

---

## authorize

```ts
const payload = c.get('jwt');
```

JWTペイロード前提。

---

## authorizeSelfOrAdmin

```ts
const jwt = c.get('jwt');
```

JWTペイロード前提。

---

# 認証アーキテクチャ

現状の依存関係

```text
AuthenticationController
        ↓
AuthenticationService
        ↓
UserService
        ↓
UserRepository
```

トークン生成

```text
AuthenticationService
        ↓
JwtService
        ↓
jsonwebtoken
```

認証確認

```text
Request
 ↓
jwtAuthentication
 ↓
JwtService.verify()
 ↓
AppJwtPayload
 ↓
authorize
 ↓
authorizeSelfOrAdmin
```

---

# authentication.type の影響範囲

理論上

```text
none
jwt
oidc
ldap
```

を切り替えるための設定。

しかし実際には

```text
利用箇所なし
```

である。

依存関係図

```text
authentication.type
        ↓
        未使用
```

---

# AuthenticationProvider の確認

存在

```ts
export interface AuthenticationProvider {
    authenticate(request: Request): Promise<AppJwtPayload | null>;
}
```

非常に重要。

---

## 意味

このインターフェースは

```text
JWT
OIDC
LDAP
None
```

を抽象化するためのものと思われる。

しかし現状では

```text
実装クラスなし
利用箇所なし
```

となっている。

---

# 発見事項

## authentication.type は完全未使用

最重要事項。

Configでは

```ts
type:
  | 'none'
  | 'jwt'
  | 'oidc'
  | 'ldap';
```

を定義している。

しかし実コードでは一度も参照されていない。

---

## 認証方式はJWT固定

createContainer

```ts
new JwtService(...)
```

AuthenticationService

```ts
JwtService;
```

jwtAuthentication

```ts
JwtService.verify(...)
```

すべて JWT 固定。

---

## 認証Factoryが存在しない

Database層には

```ts
createDatabase();
```

が存在した。

認証層には

```ts
createAuthentication();
```

のようなFactoryが存在しない。

そのため

```text
設定
↓
認証方式選択
```

が実現できていない。

---

## AuthenticationProvider が未使用

存在

```ts
AuthenticationProvider;
```

利用

```text
なし
```

状態としては

```text
将来設計だけ存在
実装なし
```

である。

---

## OIDC実装なし

確認できた範囲

```text
OIDC Provider
OIDC Service
OIDC Middleware
```

なし。

---

## LDAP実装なし

確認できた範囲

```text
LDAP Provider
LDAP Service
LDAP Middleware
```

なし。

---

## NONE認証実装なし

確認できた範囲

```text
Anonymous Provider
NoAuth Provider
```

なし。

---

# Database層との比較

## database.type

前回調査結果

```text
Config
↓
createDatabase()
↓
Factory
↓
Interface
↓
実装切替
```

成立していた。

---

## authentication.type

今回調査結果

```text
Config
↓
未使用
```

で停止している。

---

# 設定駆動化完成度評価

## 設定定義

評価

```text
100%
```

理由

```text
AuthenticationConfig存在
Union Type定義済み
```

---

## 設定ロード

評価

```text
100%
```

理由

```text
Configへロードされる
```

---

## DI投入

評価

```text
30%
```

理由

```ts
authentication.secret;
```

のみ利用。

```ts
authentication.type;
```

は未利用。

---

## Factory切替

評価

```text
0%
```

理由

```text
Factoryなし
```

---

## Interface化

評価

```text
20%
```

理由

```ts
AuthenticationProvider;
```

は存在。

しかし利用されていない。

---

## 実装完成度

```text
jwt     完成

none    未実装
oidc    未実装
ldap    未実装
```

評価

```text
25%
```

---

# 総合評価

```text
設定定義       100%
設定ロード     100%
DI投入          30%
Factory切替      0%
Interface化      20%
実装完成度      25%

総合            30%
```

---

# 結論

authentication.type の設定駆動化は未完成である。

現在の実装は実質的に

```text
authentication.type = jwt
```

固定となっている。

実際の構造は

```text
Config
↓
authentication.secret
↓
JwtService
↓
AuthenticationService
```

であり、

```text
none
oidc
ldap
```

への切り替え機構は存在しない。

---

# 推奨アーキテクチャ

Database層と同様に

```text
Config
↓
createAuthenticationProvider()
↓
AuthenticationProvider
 ├─ JwtAuthenticationProvider
 ├─ OidcAuthenticationProvider
 ├─ LdapAuthenticationProvider
 └─ NoAuthenticationProvider
```

とすることで、

```ts
authentication.type;
```

による認証方式切替が可能になる。

---

# 次工程

## TASK-004

```text
frontend.type 利用状況確認
```

目的

```text
frontend.type が
実際に利用されているか確認する
```

候補調査対象

```text
apps/web/*
apps/api/src/app/*
apps/api/src/config/*
```
