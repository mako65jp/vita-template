# TASK-005 設定駆動化ギャップ分析

## 目的

以下の設定が、

```text
Config
 ↓
Factory
 ↓
Interface
 ↓
Implementation
```

という設定駆動アーキテクチャとして成立しているかを評価し、
不足部分を明確化する。

対象

```text
database.type
authentication.type
frontend.type
```

---

# 調査結果サマリー

| 設定                | 完成度 | 状態     |
| ------------------- | -----: | -------- |
| database.type       |    95% | ほぼ完成 |
| authentication.type |    30% | 未完成   |
| frontend.type       |    25% | 未完成   |
| Config Validation   |     0% | 未実装   |
| Config Save         |     0% | 未実装   |

---

# 理想アーキテクチャ

本プロジェクトの方向性から考えると、
最終的には以下の構造を目指している。

```text
Config

├─ database.type
├─ authentication.type
└─ frontend.type

        ↓

Factory

├─ createDatabase()
├─ createAuthenticationProvider()
└─ createFrontend()

        ↓

Interface

├─ Database
├─ AuthenticationProvider
└─ FrontendProvider

        ↓

Implementation

Database
├─ Memory
├─ PostgreSQL
└─ SqlServer

Authentication
├─ None
├─ JWT
├─ OIDC
└─ LDAP

Frontend
├─ React
└─ Vue
```

---

# database.type

## 現状

```text
Config
 ↓
createDatabase()
 ↓
Database
 ↓
実装切替
```

成立している。

---

## 実装済み

```text
memory
postgres
```

---

## 未実装

```text
sqlserver
```

---

## 良い点

Factoryあり。

```ts
createDatabase();
```

Interfaceあり。

```ts
Database;
```

DI組み込み済み。

```ts
createContainer();
```

---

## ギャップ

### sqlserver未実装

Config

```ts
'memory';
'postgres';
'sqlserver';
```

Factory

```ts
sqlserver
 ↓
Error
```

---

### Dead Code

存在

```text
PostgreSqlDatabase.ts
SqlServerDatabase.ts
```

利用なし。

---

## 評価

```text
95%
```

---

# authentication.type

## 現状

Config

```ts
type:
  | 'none'
  | 'jwt'
  | 'oidc'
  | 'ldap';
```

存在。

---

しかし利用箇所は存在しない。

---

## 実際の構造

```text
Config
 ↓
authentication.secret
 ↓
JwtService
 ↓
AuthenticationService
```

---

## 実装済み

```text
jwt
```

---

## 未実装

```text
none
oidc
ldap
```

---

## 発見事項

AuthenticationProvider 存在。

```ts
export interface AuthenticationProvider
```

しかし利用されていない。

---

## ギャップ

### Factoryなし

存在しない。

理想

```ts
createAuthenticationProvider();
```

---

### Provider実装なし

必要

```text
JwtAuthenticationProvider
NoAuthenticationProvider
OidcAuthenticationProvider
LdapAuthenticationProvider
```

---

### MiddlewareがJWT固定

現在

```ts
jwtAuthentication(...)
```

固定。

---

### createContainerがJWT固定

現在

```ts
new JwtService(...)
```

固定。

---

## 評価

```text
30%
```

---

# frontend.type

## 現状

Config

```ts
type:
  | 'react'
  | 'vue';
```

存在。

---

利用箇所なし。

---

## 実際の構造

```text
React
 ↓
直接起動
```

---

## React

存在

```text
apps/web/react
```

利用中。

---

## Vue

存在

```text
apps/web/vue
```

雛形のみ。

---

## ギャップ

### Factoryなし

理想

```ts
createFrontend();
```

---

### frontend.type未使用

利用箇所なし。

---

### React固定

実質

```text
frontend.type = react
```

状態。

---

## 評価

```text
25%
```

---

# Config Validation

## 現状

```ts
JSON.parse(json) as Config;
```

のみ。

---

## 問題

以下でも起動可能。

```json
{
    "authentication": {
        "type": "aaaa"
    }
}
```

---

## 理想

```text
JSON
 ↓
Schema Validation
 ↓
Config
```

---

## 候補

```text
zod
ajv
valibot
```

---

## 評価

```text
0%
```

---

# Config Save

## 現状

```ts
saveConfig();
```

未実装。

---

## 評価

```text
0%
```

---

# ギャップ優先順位

## Priority 1

authentication.type

理由

```text
Interface存在
Factoryなし
```

であり、

最も少ない変更で
設定駆動化できる。

---

## Priority 2

Config Validation

理由

設定ミスを防ぐため。

---

## Priority 3

frontend.type

理由

Vue実装不足のため、
Factoryだけ作っても意味がない。

---

## Priority 4

saveConfig

---

## Priority 5

sqlserver

---

# 次工程

## TASK-006

Authentication Factory化

対象

```text
apps/api/src/features/authentication/providers/*
apps/api/src/features/authentication/createAuthenticationProvider.ts
apps/api/src/features/authentication/middleware/*
apps/api/src/app/createContainer.ts
apps/api/src/app/createApp.ts
apps/api/src/app/DependencyContainer.ts
```

成果物

```text
authentication.type

  none
  jwt
  oidc
  ldap

      ↓

Factory

      ↓

AuthenticationProvider

      ↓

各実装
```

---

# 結論

設定駆動アーキテクチャの完成という観点では、

最大のボトルネックは

```text
authentication.type
```

である。

理由は、

```text
AuthenticationProvider
```

という抽象化が既に存在しているにも関わらず、

```text
Factory
実装切替
DI統合
```

が未実装だからである。

したがって次に実施すべき作業は

```text
TASK-006 Authentication Factory化
```

である。
