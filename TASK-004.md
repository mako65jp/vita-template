# TASK-004 frontend.type 利用状況確認

## 目的

frontend.type がどこで利用されているかを特定し、
フロントエンド切替の設定駆動化完成度を評価する。

---

# 調査対象

## Config

- apps/api/src/config/Config.ts
- apps/api/src/config/loadConfig.ts

## API

- apps/api/src/app/createApp.ts
- apps/api/src/app/createContainer.ts

## Web共通

- apps/web/Application.ts
- apps/web/ApplicationConfiguration.ts
- apps/web/FrontendConfigurationService.ts
- apps/web/RuntimeConfigurationProvider.ts

## React

- apps/web/react/*
- apps/web/react/src/**/*

## Vue

- apps/web/vue/*
- apps/web/vue/src/*

---

# 調査結果

## frontend.type 定義

Config.ts

```ts
export interface FrontendConfig {
    type: 'react' | 'vue';
}
```

利用可能値

```text
react
vue
```

---

# frontend.type 利用箇所調査

調査対象全体を確認した。

検索観点

```text
config.frontend
frontend.type
react
vue
createFrontend
FrontendFactory
```

結果

```text
frontend.type の利用箇所は存在しない
```

---

# 現在の実際のFrontend

## Reactは存在

存在する。

```text
apps/web/react
```

内容

```text
React
React Router
Vite
```

で構成されている。

---

## Vueは存在

存在する。

```text
apps/web/vue
```

内容

```text
App.vue
router.ts
main.ts
```

のみ。

ほぼ空実装。

---

# 実際に起動されるFrontend

確認できたコード。

```text
apps/web/react/package.json
```

```json
{
    "name": "web-react"
}
```

Vite設定

```text
apps/web/react/vite.config.ts
```

存在。

Reactアプリとして動作している。

---

Vue側

```text
apps/web/vue/src/main.ts
```

内容

```ts
export {};
```

のみ。

---

結論

現在動作しているFrontendは

```text
React固定
```

である。

---

# frontend.type の影響範囲

理論上は

```text
frontend.type
 ├─ react
 └─ vue
```

を切り替えるための設定。

しかし実際には

```text
利用箇所なし
```

である。

---

# React起動経路

## index.html

```html
<script id="application-configuration" type="application/json">
    __APPLICATION_CONFIGURATION__
</script>
```

構成情報埋込ポイント。

---

## vite.config.ts

```ts
transformIndexHtml(html) {
    return html.replace(
        '__APPLICATION_CONFIGURATION__',
        JSON.stringify({
            backend:
                configuration.backend,
        }),
    );
}
```

Vite起動時に設定を埋め込んでいる。

---

## RuntimeConfigurationProvider

```ts
document.getElementById('application-configuration');
```

埋め込まれた設定を取得。

---

## Application

```ts
const configurationProvider = new RuntimeConfigurationProvider();
```

設定構築。

---

## FrontendConfigurationService

```ts
getApiBaseUrl();
```

API接続先生成。

---

## login.ts

```ts
const application = new Application();
```

```ts
application.configurationService.getApiBaseUrl();
```

でAPIへ接続している。

---

# 発見事項

## frontend.type は完全未使用

最重要事項。

Config定義

```ts
frontend.type;
```

存在。

利用箇所

```text
なし
```

---

## React固定

現在の構造

```text
Config
↓
frontend.type
↓
未使用

React
↓
直接起動
```

となっている。

---

## FrontendFactoryが存在しない

Database層

```ts
createDatabase();
```

あり。

Authentication層

Factoryなし。

Frontend層も

```ts
createFrontend();
```

が存在しない。

---

## React/Vue切替機能なし

存在するのは

```text
React実装
Vue雛形
```

のみ。

切替ロジックなし。

---

## Vue実装未完成

Vue側確認結果。

```text
App.vue
router.ts
main.ts
```

存在。

しかし

```text
画面
認証
API接続
ルーティング
```

は未実装。

---

## Vite設定はReact専用

```ts
import react from '@vitejs/plugin-react';
```

のみ。

---

## frontend.type がViteに伝播していない

現在

```text
development.json
↓
vite.config.ts
```

で参照しているのは

```text
backend
```

のみ。

---

# Configとの整合性

Config

```ts
frontend: {
    type: 'react' | 'vue';
}
```

実態

```text
Reactのみ利用可能
```

状態になっている。

---

# Databaseとの比較

Database

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

完成。

---

Authentication

```text
Config
↓
未使用
```

未完成。

---

Frontend

```text
Config
↓
未使用
```

未完成。

---

# 設定駆動化完成度評価

## 設定定義

評価

```text
100%
```

理由

```text
FrontendConfig存在
Union Typeあり
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
0%
```

理由

```text
frontend.type利用なし
```

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

## 実装完成度

```text
React 完成

Vue 雛形のみ
```

評価

```text
40%
```

---

# 総合評価

```text
設定定義       100%
設定ロード     100%
DI投入           0%
Factory切替       0%
実装完成度       40%

総合            25%
```

---

# 結論

frontend.type の設定駆動化は未実装である。

現在の実態は

```text
frontend.type = react
```

固定であり、

設定変更による切替機能は存在しない。

---

# 推奨アーキテクチャ

理想形

```text
Config
↓
createFrontend()
↓
frontend.type
 ├─ react
 └─ vue
```

または

```text
Config
↓
FrontendFactory
 ├─ ReactFrontend
 └─ VueFrontend
```

---

# Phase1時点まとめ

## database.type

```text
完成度 95%
```

状態

```text
設定駆動化ほぼ完成
```

---

## authentication.type

```text
完成度 30%
```

状態

```text
JWT固定
```

---

## frontend.type

```text
完成度 25%
```

状態

```text
React固定
```

---

# 次工程候補

優先順位1

```text
TASK-005
frontend.type を利用する設計への変更
```

または

優先順位1

```text
設定駆動化ギャップ分析
(database/authentication/frontend)
```

現在の調査結果から見ると、

最大の未完成領域は

```text
authentication.type
frontend.type
```

である。
