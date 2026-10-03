#!/bin/bash

echo "プロジェクトの復元を開始します..."

# バイナリ復元用の base64 デコードコマンド判定
if command -v base64 >/dev/null 2>&1; then
    if base64 --version 2>&1 | grep -q "GNU"; then
        B64_DECODE="base64 -d"
    else
        B64_DECODE="base64 -D"
    fi
fi

echo "作成: package.json"
cat << 'EOF_1791008797_25283' > "package.json"
{
    "name": "generated-project",
    "private": true,
    "type": "module",
    "workspaces": [
        "apps/api",
        "apps/web/core",
        "apps/web/react",
        "packages/*"
    ],
    "scripts": {
        "build": "npm run build:api && npm run build:web",
        "build:api": "npm run build -w @apps/api",
        "build:web": "npm run build -w @apps/web-react",
        "check": "tsc --noEmit",
        "db:generate": "drizzle-kit generate",
        "db:migrate": "drizzle-kit migrate",
        "db:push": "drizzle-kit push",
        "dev": "npm run dev -w @apps/api",
        "dev:api": "npm run dev -w @apps/api",
        "dev:web": "cd apps/web/react && vite --host 0.0.0.0",
        "format": "prettier --write .",
        "test": "npm run test --workspaces --if-present"
    },
    "dependencies": {
        "zod": "^4.6.5"
    },
    "devDependencies": {
        "drizzle-kit": "^0.31.10",
        "eslint": "^10.11.0",
        "eslint-config-prettier": "^10.1.8",
        "prettier": "^3.9.9",
        "tsx": "^4.20.5",
        "typescript": "^5.9.3",
        "vitest": "^4.1.11"
    }
}
EOF_1791008797_25283

echo "作成: cat.sh"
cat << 'EOF_1791008797_25523' > "cat.sh"
#!/bin/bash

RECURSIVE=false
SHOW_PATH_ONLY=false
EXCLUDE_PATTERN=""

# オプション解析
while getopts "rRlL-e:" opt; do
    case "$opt" in
        r|R) RECURSIVE=true ;;
        l|L) SHOW_PATH_ONLY=true ;;
        e)   EXCLUDE_PATTERN="$OPTARG" ;;
        *)   echo "使用方法: $0 [-r] [-l] [-e 除外パターン] <ファイル|フォルダ|ワイルドカード...>" ; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    echo "使用方法: $0 [-r] [-l] [-e 除外パターン] <ファイル|フォルダ|ワイルドカード...>"
    exit 1
fi

print_file() {
    local file="$1"
    if [ "$SHOW_PATH_ONLY" = true ]; then
        echo "$file"
    else
        echo "$file :"
        cat "$file"
        echo ""
    fi
}

# 除外判定関数
is_excluded() {
    local path="$1"
    local filename
    filename=$(basename "$path")

    # 常時除外したいフォルダ名のリスト
    local exclude_dirs=("node_modules" ".git" "dist" "build" "coverage" ".vscode")

    # リスト内のフォルダがパスに含まれているかチェック
    for dir in "${exclude_dirs[@]}"; do
        if [[ "$path" == */"$dir"/* ]] || [[ "$filename" == "$dir" ]]; then
            return 0 # 除外対象
        fi
    done
    
    # ユーザー指定の除外パターン（-e オプション）のチェック
    if [ -n "$EXCLUDE_PATTERN" ]; then
        if [[ "$filename" == $EXCLUDE_PATTERN ]] || [[ "$path" == *$EXCLUDE_PATTERN* ]]; then
            return 0 # 除外対象
        fi
    fi
    return 1 # 除外対象外
}

for target in "$@"; do
    if [ "$RECURSIVE" = true ]; then
        # ==========================================
        # -r 指定時：カレントフォルダ(.)を含め再帰検索
        # ==========================================
        if [ -d "$target" ]; then
            search_dir="$target"
            pattern=""
        else
            search_dir="."
            pattern=$(basename "$target")
        fi

        if [ -n "$pattern" ]; then
            find_cmd=(find "$search_dir" -type f -name "$pattern")
        else
            find_cmd=(find "$search_dir" -type f)
        fi

        found_any=false      # find でファイルが見つかったか
        printed_any=false    # 除外を抜けて実際に出力されたか

        while read -r file; do
            [ -z "$file" ] && continue
            found_any=true
            if ! is_excluded "$file"; then
                print_file "$file"
                printed_any=true
            fi
        done < <("${find_cmd[@]}" 2>/dev/null)

        # そもそもファイルが存在しない場合のみ警告を表示
        if [ "$found_any" = false ]; then
            echo "警告: '$target' に一致するファイルが見つかりません。" >&2
        fi

    else
        # ==========================================
        # -r なし：指定されたパスのみを直接処理
        # ==========================================
        if [ -f "$target" ]; then
            if ! is_excluded "$target"; then
                print_file "$target"
            fi
        elif [ -d "$target" ]; then
            found_any=false
            while read -r file; do
                [ -z "$file" ] && continue
                found_any=true
                if ! is_excluded "$file"; then
                    print_file "$file"
                fi
            done < <(find "$target" -type f 2>/dev/null)

            if [ "$found_any" = false ]; then
                echo "警告: フォルダ '$target' 内にファイルが見つかりません。" >&2
            fi
        else
            echo "警告: '$target' に一致するファイルやフォルダが見つかりません。" >&2
        fi
    fi
done
EOF_1791008797_25523

echo "作成: .gitignore"
cat << 'EOF_1791008797_16026' > ".gitignore"
### Node
# Dependencies
node_modules/

# Logs
*.log

# Runtime data
*.pid
*.pid.lock

# Coverage
coverage/
*.lcov
.nyc_output

# Build output
dist/
build/Release

# TypeScript cache
*.tsbuildinfo

# Framework build output and caches
.cache
.parcel-cache
.next
out/
.nuxt

# dotenv environment variable files
.env
.env.local
.env.*.local

# npm cache directory
.npm
*.tgz

# yarn v2
.yarn/cache
.yarn/unplugged
.yarn/install-state.gz
.pnp.*

### macOS
# Finder metadata
.DS_Store

# Thumbnails
._*

# Custom folder icons
Icon

# Volume root files
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

### Windows
# Windows thumbnail cache files
Thumbs.db

# Folder config file
[Dd]esktop.ini

# Recycle Bin used on file shares
$RECYCLE.BIN/

# Windows shortcuts
*.lnk

### Linux
# Backup files
*~

# Temporary files from deleted open files
.fuse_hidden*

# KDE directory preferences
.directory

# Linux trash folder
.Trash-*

# NFS temporary files
.nfs*

### VS Code
# VSCode settings (keep shared configuration)
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Local History for Visual Studio Code
.history/

# Built Visual Studio Code Extensions
*.vsix
EOF_1791008797_16026

echo "作成: WBS_1-設定駆動アーキテクチャの完成.md"
cat << 'EOF_1791008797_6390' > "WBS_1-設定駆動アーキテクチャの完成.md"
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
EOF_1791008797_6390

echo "作成: phase-9.http"
cat << 'EOF_1791008797_7864' > "phase-9.http"

@host = http://localhost:3000

### 管理者ログイン
# @name loginRequestAdmin
POST {{host}}/api/auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "new-password"
}

### 管理者トークンを変数に代入
@authTokenAdmin = {{loginRequestAdmin.response.body.accessToken}}

### 管理者の情報取得
# @name infoAdmin
GET {{host}}/users/me
Authorization: Bearer {{authTokenAdmin}}

@itAdmin = {{infoAdmin.response.body.id}}

### 自分自身を無効化："message": "Cannot disable yourself"
PUT {{host}}/users/{{itAdmin}}/active
Authorization: Bearer {{authTokenAdmin}}
Content-Type: application/json

{
  "isActive": false
}

### 自分自身を user に変更："message": "Cannot change your own role"
PUT {{host}}/users/{{itAdmin}}/role
Authorization: Bearer {{authTokenAdmin}}
Content-Type: application/json

{
  "role": "user"
}









### 一般利用者ログイン
# @name loginRequestUser
POST {{host}}/auth/login
Content-Type: application/json

{
  "email": "user1@example.com",
  "password": "new-password"
}

### 一般利用者トークンを変数に代入
@authTokenUser = {{loginRequestUser.response.body.accessToken}}

### 自分の情報取得
# @name infoUser
GET {{host}}/users/me
Authorization: Bearer {{authTokenUser}}

@itUser = {{infoUser.response.body.id}}


### 自分の情報更新
PUT {{host}}/users/me
Authorization: Bearer {{authTokenUser}}
Content-Type: application/json

{
  "name": "テストユーザー",
  "email": "user1@example.com"
}

### 自分自身を admin に変更："message": "Forbidden"
PUT {{host}}/users/me/role
Authorization: Bearer {{authTokenUser}}
Content-Type: application/json

{
  "role": "admin"
}

### 自分自身を無効化："message": "Forbidden"
PUT {{host}}/users/me/active
Authorization: Bearer {{authTokenUser}}
Content-Type: application/json

{
  "isActive": false
}


### 自分のパスワード変更
PUT {{host}}/users/me/password
Authorization: Bearer {{authTokenUser}}
Content-Type: application/json

{
  "password": "new-password-2"
}

### 自分のパスワード戻す
PUT {{host}}/users/me/password
Authorization: Bearer {{authTokenUser}}
Content-Type: application/json

{
  "password": "new-password"
}



EOF_1791008797_7864

echo "作成: TASK-001.md"
cat << 'EOF_1791008797_29989' > "TASK-001.md"
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
EOF_1791008797_29989

mkdir -p "config"
echo "作成: config/production.json"
cat << 'EOF_1791008797_17533' > "config/production.json"
{}
EOF_1791008797_17533

mkdir -p "config"
echo "作成: config/development.json"
cat << 'EOF_1791008797_18638' > "config/development.json"
{
    "backend": {
        "protocol": "http",
        "host": "localhost",
        "port": 3000,
        "applicationRoot": "/api"
    },
    "database": {
        "type": "postgres",
        "connectionString": "postgresql://postgres:postgres@db:5432/app_db"
    },
    "authentication": {
        "type": "local",
        "secret": "change-this-secret"
    },
    "administration": {
        "enabled": true,
        "authentication": {
            "type": "local"
        }
    },
    "features": {
        "user": true
    },
    "frontend": {
        "type": "react"
    }
}
EOF_1791008797_18638

mkdir -p "config"
echo "作成: config/staging.json"
cat << 'EOF_1791008797_15679' > "config/staging.json"
{}
EOF_1791008797_15679

echo "作成: TASK-005.md"
cat << 'EOF_1791008797_4331' > "TASK-005.md"
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
EOF_1791008797_4331

mkdir -p ".devcontainer/scripts"
echo "作成: .devcontainer/scripts/init-test-db.sh"
cat << 'EOF_1791008797_12274' > ".devcontainer/scripts/init-test-db.sh"
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB_TEST;
EOSQL
EOF_1791008797_12274

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1791008797_843' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone
EOF_1791008797_843

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1791008797_17008' > ".devcontainer/devcontainer.json"
{
    "name": "Monorepo DevContainer with DB",
    "dockerComposeFile": "docker-compose.yml",
    "service": "app",
    "workspaceFolder": "/workspace",
    "customizations": {
        "vscode": {
            // 1. コンテナ内に自動でインストールする拡張機能
            "extensions": [
                "dbaeumer.vscode-eslint",
                "esbenp.prettier-vscode",
                "vitest.explorer",
                "humao.rest-client"
            ],
            // 2. コンテナ内だけで有効にしたいVSCodeの設定（settings.jsonの内容）
            "settings": {
                "js/ts.tsdk.path": "node_modules/typescript/lib",
                // デフォルトのフォーマッターを Prettier に指定
                "editor.defaultFormatter": "esbenp.prettier-vscode",
                // ファイル保存時に自動でフォーマットを実行
                "editor.formatOnSave": true,
                // [オプション] 保存時にインポート文の整理や未使用コードの削除も同時に行う場合
                "editor.codeActionsOnSave": {
                    "source.organizeImports": "explicit"
                },
                "editor.tabSize": 4,
                "eslint.workingDirectories": [
                    {
                        "mode": "auto"
                    }
                ],
                "vitest.enable": true,
                // コンテナ内のファイル監視負荷を下げ、スリープ復帰時のクラッシュを防ぐ
                "files.watcherExclude": {
                    "**/node_modules/**": true,
                    "**/dist/**": true,
                    "**/.git/objects/**": true,
                    "**/.git/subtree-cache/**": true
                },
                "[typescript]": {
                    "editor.defaultFormatter": "esbenp.prettier-vscode"
                },
                "[typescriptreact]": {
                    "editor.defaultFormatter": "esbenp.prettier-vscode"
                }
            }
        }
    },
    "forwardPorts": [3000, 3001, 5432],
    "updateContentCommand": "sudo chown -R node:node /workspace && npm install"
}
EOF_1791008797_17008

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1791008797_14697' > ".devcontainer/docker-compose.yml"
services:
    app:
        build:
            context: .
            dockerfile: Dockerfile
        volumes:
            - ..:/workspace:cached
            - /workspace/node_modules
        command: /bin/sh -c "while sleep 1000; do :; done"
        ports:
            - '${VITE_PORT:-3000}:3000'
            - '${PORT:-3001}:3001'
        depends_on:
            - db

    db:
        image: postgres:16-alpine
        restart: always
        environment:
            POSTGRES_USER: postgres
            POSTGRES_PASSWORD: postgres
            POSTGRES_DB: app_db
            # POSTGRES_DB_TEST: app_db_test
        ports:
            - '5432:5432'
        volumes:
            - postgres-data:/var/lib/postgresql/data
            # - ./scripts/init-test-db.sh:/docker-entrypoint-initdb.d/init-multiple-databases.sh
            # 起動時に app_db_test も自動作成するスクリプトをマウント

volumes:
    postgres-data:
EOF_1791008797_14697

echo "作成: .prettierrc.json"
cat << 'EOF_1791008797_18489' > ".prettierrc.json"
{
    "printWidth": 100,
    "tabWidth": 4,
    "semi": true,
    "singleQuote": true,
    "trailingComma": "all"
}
EOF_1791008797_18489

echo "作成: memo.txt"
cat << 'EOF_1791008797_27955' > "memo.txt"
./cat.sh package.json \
tsconfig.json \
tsconfig.base.json \
apps/api/package.json \
apps/web/package.json \
apps/web/tsconfig.json \
apps/web/vitest.config.ts \
apps/web/react/package.json \
apps/web/react/tsconfig.json \
apps/web/react/vite.config.ts \
apps/web/react/vitest.config.ts \
apps/api/src/main.ts \
apps/api/src/app/createApp.ts \
apps/api/src/app/createContainer.ts \
apps/web/Application.ts \
apps/web/ApplicationConfiguration.ts \
apps/web/FrontendConfigurationService.ts \
apps/web/RuntimeConfigurationProvider.ts \
packages/types/package.json \
.gitignore 


tree -I 'node_modules|dist|build' > tree2.txt

./cat.sh \
apps/web/react/src/app/features.ts \
apps/web/react/src/app/router.tsx \
packages/features/authentication/Feature.tsx \
packages/features/authentication/routes.tsx \
apps/web/react/src/app/FeatureDefinition.ts \
apps/web/react/src/components/Layout.tsx


いまの段階で、優先順位順に確認すべきファイルはこれです。

./cat.sh \
apps/web/react/src/app/router.tsx \
apps/web/react/src/app/providers/AuthProvider.tsx \
apps/web/react/src/app/App.tsx \
apps/web/react/src/main.tsx \
packages/features/authentication/hooks/useLogin.ts \
packages/features/authentication/api/login.ts \
packages/features/authentication/api/login.ts \
apps/web/react/src/app/router.tsx \
apps/web/react/src/app/providers/AuthProvider.tsx \
packages/features/authentication/hooks/useLogin.ts \
packages/features/authentication/api/login.ts \
packages/features/authentication/api/login.ts


./cat.sh \
apps/web/react/src/app/features.ts \
packages/features/authentication/Feature.tsx \
packages/features/settings/Feature.tsx


./cat.sh \
packages/features/settings/pages/SettingsPage.tsx \
apps/api/src/features/administration/domain/SystemConfiguration.ts \
apps/api/src/features/administration/controllers/ConfigurationController.ts \
packages/api-client/administration/ConfigurationApi.ts

./cat.sh \
packages/features/authentication/providers/createAuthenticationProvider.ts \
packages/features/user/repositories/UserRepositoryImpl.ts
EOF_1791008797_27955

echo "作成: tsconfig.json"
cat << 'EOF_1791008797_20087' > "tsconfig.json"
{
    "extends": "./tsconfig.base.json",
    "include": ["apps/**/*", "config/**/*", "packages/**/*"],
    "exclude": ["node_modules", "dist", "build"]
}
EOF_1791008797_20087

echo "作成: TASK-004.md"
cat << 'EOF_1791008797_21240' > "TASK-004.md"
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
EOF_1791008797_21240

echo "作成: tree2.txt"
cat << 'EOF_1791008797_12549' > "tree2.txt"
.
├── apps
│   ├── api
│   │   └── src
│   │       ├── app
│   │       ├── common
│   │       │   ├── middleware
│   │       │   └── repositories
│   │       ├── database
│   │       ├── features
│   │       │   ├── administration
│   │       │   │   ├── authentication
│   │       │   │   ├── controllers
│   │       │   │   ├── domain
│   │       │   │   ├── mappers
│   │       │   │   ├── repositories
│   │       │   │   └── services
│   │       │   ├── authentication
│   │       │       ├── controllers
│   │       │       ├── domain
│   │       │       ├── middleware
│   │       │       ├── providers
│   │       │       └── services
│   │       └── systemConfig
│   └── web
│       ├── core
│       │   └── src
│       │       └── api-client
│       │           ├── administration
│       │           ├── authentication
│       │           ├── http
│       │           └── user
│       └── react
│           └── src
│               ├── app
│               │   └── providers
│               ├── components
│               ├── config
│               └── features
│                   ├── authentication
│                   │   ├── api
│                   │   ├── components
│                   │   ├── hooks
│                   │   └── pages
│                   ├── dashboard
│                   │   └── pages
│                   └── settings
│                       └── pages
├── config
└── packages
    ├── constants
    ├── types
        ├── administration
        ├── authentication
        ├── authorization
        ├── common
        └── user
EOF_1791008797_12549

echo "作成: tsconfig.base.json"
cat << 'EOF_1791008797_29092' > "tsconfig.base.json"
{
    "compilerOptions": {
        "target": "ES2022", //"NodeNext",
        "module": "ESNext", //"NodeNext",
        "moduleResolution": "bundler", //"NodeNext","bundler",
        "strict": true,
        "skipLibCheck": true,
        "esModuleInterop": true,
        "forceConsistentCasingInFileNames": true,
        // "useDefineForClassFields": true,
        "lib": ["DOM", "DOM.Iterable", "ESNext"],
        "allowJs": false,
        // "allowSyntheticDefaultImports": true,
        // "resolveJsonModule": true,
        // "isolatedModules": true,
        // "sourceMap": true,
        // "noEmit": true,
        "jsx": "react-jsx",
        "outDir": "dist",
        "baseUrl": ".",
        "paths": {
            "@/*": ["*"],
            "@apps/api/*": ["apps/api/src/*"],
            "@apps/web-core/*": ["apps/web/core/src/*"],
            "@apps/web-react/*": ["apps/web/react/src/*"],
            "@packages/schemas/*": ["packages/schemas/*"],
            "@packages/types/*": ["packages/types/*"]
        }
    },
    "exclude": ["node_modules", "dist", "build"]
}
EOF_1791008797_29092

mkdir -p "packages/schemas"
echo "作成: packages/schemas/package.json"
cat << 'EOF_1791008797_13181' > "packages/schemas/package.json"
{
    "name": "@packages/schemas",
    "private": true,
    "type": "module",
    "exports": {
        ".": "./src/index.ts"
    }
}
EOF_1791008797_13181

mkdir -p "packages/schemas/src"
echo "作成: packages/schemas/src/index.ts"
cat << 'EOF_1791008797_20048' > "packages/schemas/src/index.ts"
export * from './user/create-user';
export * from './user/user';
export * from './user/user-detail';
EOF_1791008797_20048

mkdir -p "packages/schemas/src/user"
echo "作成: packages/schemas/src/user/create-user.ts"
cat << 'EOF_1791008797_23861' > "packages/schemas/src/user/create-user.ts"
import { z } from 'zod';

export const CreateUserSchema = z.object({
    name: z.string().nonempty(),
    email: z.email(),
    password: z.string().nonempty(),
});

export type CreateUser = z.infer<typeof CreateUserSchema>;
EOF_1791008797_23861

mkdir -p "packages/schemas/src/user"
echo "作成: packages/schemas/src/user/user-detail.ts"
cat << 'EOF_1791008797_3101' > "packages/schemas/src/user/user-detail.ts"
import { z } from 'zod';

export const UserDetailSchema = z.object({
    id: z.number(),
    name: z.string(),
    email: z.string(),
    role: z.string(),
    isActive: z.boolean(),
    createdAt: z.date(),
});

export type UserDetail = z.infer<typeof UserDetailSchema>;
EOF_1791008797_3101

mkdir -p "packages/schemas/src/user"
echo "作成: packages/schemas/src/user/user.ts"
cat << 'EOF_1791008797_11273' > "packages/schemas/src/user/user.ts"
export interface User {
    id: number;
    name: string;
    email: string;
    passwordHash: string;
    role: string;
    isActive: boolean;
    createdAt: Date;
}
EOF_1791008797_11273

mkdir -p "packages/types"
echo "作成: packages/types/package.json"
cat << 'EOF_1791008797_9094' > "packages/types/package.json"
{
    "name": "@packages/types",
    "private": true,
    "type": "module"
}
EOF_1791008797_9094

mkdir -p "packages/types/user"
echo "作成: packages/types/user/UpdateUserRequest.ts"
cat << 'EOF_1791008797_11968' > "packages/types/user/UpdateUserRequest.ts"
export interface UpdateUserRequest {
    name: string;
    email: string;
    role: string;
    isActive: boolean;
}
EOF_1791008797_11968

mkdir -p "packages/types/user"
echo "作成: packages/types/user/UserDto.ts"
cat << 'EOF_1791008797_2006' > "packages/types/user/UserDto.ts"
export interface UserDto {
    id: number;
    name: string;
    email: string;
    role: string;
    isActive: boolean;
    createdAt: string;
}
EOF_1791008797_2006

mkdir -p "packages/types/user"
echo "作成: packages/types/user/CreateUserRequest.ts"
cat << 'EOF_1791008797_29620' > "packages/types/user/CreateUserRequest.ts"
export interface CreateUserRequest {
    name: string;
    email: string;
    passwordHash: string;
    role?: string;
}
EOF_1791008797_29620

mkdir -p "packages/types/administration"
echo "作成: packages/types/administration/AuthenticationPolicy.ts"
cat << 'EOF_1791008797_7457' > "packages/types/administration/AuthenticationPolicy.ts"
export interface AuthenticationPolicy {
    session: {
        reloadBehavior: 'keep-session' | 'logout';
        idleTimeoutMinutes: number;
        absoluteTimeoutMinutes: number;
    };

    token: {
        accessTokenLifetimeMinutes: number;
        autoRefreshEnabled: boolean;
        refreshThresholdMinutes: number;
    };

    deepLink: {
        enabled: boolean;
        afterLogin: 'restore' | 'home';
    };

    reAuthentication: {
        enabled: boolean;
        validMinutes: number;
        requireForSystemSettings: boolean;
        requireForUserDelete: boolean;
        requireForRoleChange: boolean;
    };

    navigation: {
        loginPageWhileAuthenticated: 'back' | 'home';
        forbiddenPage: 'back' | 'home' | '403';
        notFoundPage: 'back' | 'home' | '404';
    };

    expiredToken: {
        behavior: 'login' | 're-authenticate' | 'refresh';
        afterRecovery: 'restore' | 'home';
    };
}
EOF_1791008797_7457

mkdir -p "packages/types/administration"
echo "作成: packages/types/administration/FeatureFlagDto.ts"
cat << 'EOF_1791008797_13802' > "packages/types/administration/FeatureFlagDto.ts"
export interface FeatureFlagDto {
    name: string;

    enabled: boolean;
}
EOF_1791008797_13802

mkdir -p "packages/types/administration"
echo "作成: packages/types/administration/ConfigurationDto.ts"
cat << 'EOF_1791008797_5881' > "packages/types/administration/ConfigurationDto.ts"
import { AuthenticationPolicy } from './AuthenticationPolicy';

export interface ConfigurationDto {
    authenticationPolicy: AuthenticationPolicy;
}
EOF_1791008797_5881

mkdir -p "packages/types/administration"
echo "作成: packages/types/administration/defaultAuthenticationPolicy.ts"
cat << 'EOF_1791008797_27788' > "packages/types/administration/defaultAuthenticationPolicy.ts"
import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';

export const defaultAuthenticationPolicy: AuthenticationPolicy = {
    session: {
        reloadBehavior: 'keep-session',
        idleTimeoutMinutes: 30,
        absoluteTimeoutMinutes: 480,
    },

    token: {
        accessTokenLifetimeMinutes: 60,
        autoRefreshEnabled: true,
        refreshThresholdMinutes: 5,
    },

    deepLink: {
        enabled: true,
        afterLogin: 'restore',
    },

    reAuthentication: {
        enabled: true,
        validMinutes: 15,
        requireForSystemSettings: true,
        requireForUserDelete: true,
        requireForRoleChange: true,
    },

    navigation: {
        loginPageWhileAuthenticated: 'back',
        forbiddenPage: 'back',
        notFoundPage: '404',
    },

    expiredToken: {
        behavior: 're-authenticate',
        afterRecovery: 'restore',
    },
};
EOF_1791008797_27788

mkdir -p "packages/types"
echo "作成: packages/types/Config.ts"
cat << 'EOF_1791008797_796' > "packages/types/Config.ts"
export interface SystemConfig {}
EOF_1791008797_796

mkdir -p "packages/types/authorization"
echo "作成: packages/types/authorization/PermissionDto.ts"
cat << 'EOF_1791008797_10991' > "packages/types/authorization/PermissionDto.ts"
export interface PermissionDto {
    name: string;
}
EOF_1791008797_10991

mkdir -p "packages/types/authorization"
echo "作成: packages/types/authorization/RoleDto.ts"
cat << 'EOF_1791008797_3838' > "packages/types/authorization/RoleDto.ts"
export interface RoleDto {
    name: string;
}
EOF_1791008797_3838

mkdir -p "packages/types/authentication"
echo "作成: packages/types/authentication/LoginResponse.ts"
cat << 'EOF_1791008797_20358' > "packages/types/authentication/LoginResponse.ts"
export interface LoginResponse {
    accessToken: string;
}
EOF_1791008797_20358

mkdir -p "packages/types/authentication"
echo "作成: packages/types/authentication/LoginRequest.ts"
cat << 'EOF_1791008797_25557' > "packages/types/authentication/LoginRequest.ts"
export interface LoginRequest {
    email: string;
    password: string;
}
EOF_1791008797_25557

mkdir -p "packages/validation/user"
echo "作成: packages/validation/user/CreateUserSchema.ts"
cat << 'EOF_1791008797_11132' > "packages/validation/user/CreateUserSchema.ts"
export const CreateUserSchema = {};
EOF_1791008797_11132

mkdir -p "packages/validation/user"
echo "作成: packages/validation/user/UpdateUserSchema.ts"
cat << 'EOF_1791008797_4155' > "packages/validation/user/UpdateUserSchema.ts"
export const UpdateUserSchema = {};
EOF_1791008797_4155

mkdir -p "packages/validation/authentication"
echo "作成: packages/validation/authentication/LoginSchema.ts"
cat << 'EOF_1791008797_31569' > "packages/validation/authentication/LoginSchema.ts"
export const LoginSchema = {};
EOF_1791008797_31569

echo "作成: TASK-002.md"
cat << 'EOF_1791008797_9184' > "TASK-002.md"
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
EOF_1791008797_9184

echo "作成: スキーマ、レイヤ.txt"
cat << 'EOF_1791008797_18185' > "スキーマ、レイヤ.txt"
                    ┌─────────────┐
                    │  Frontend   │
                    └──────┬──────┘
                           │
                           │ RequestSchema
                           │ (Zod 必須)
                           ▼
                    ┌─────────────┐
                    │ Controller  │
                    └──────┬──────┘
                           │
                           │ EntityRequestSchema
                           ▼
                    ┌─────────────┐
                    │  Service    │
                    └──────┬──────┘
                           │
                           │ RepositoryRequestSchema
                           ▼
                    ┌─────────────┐
                    │ Repository  │
                    └──────┬──────┘
                           │
                           │ DBRequestSchema
                           ▼

                ┌─────────────────────┐
                │     DbProvider      │
                │                     │
                │ postgres            │
                │ sqlserver           │
                │ memory              │
                └─────────┬───────────┘
                          │
          ┌───────────────┼────────────────┐
          ▼               ▼                ▼

     PostgreSQL      SQL Server       InMemory

          ▲               ▲                ▲
          │               │                │
          │ DBSchema      │ DBSchema       │ DBSchema
          │               │                │

          └───────────────┼────────────────┘
                          │
                          ▼

                    ┌─────────────┐
                    │ Repository  │
                    └──────┬──────┘
                           │
                           │ RepositorySchema
                           ▼
                    ┌─────────────┐
                    │  Service    │
                    └──────┬──────┘
                           │
                           │ EntitySchema
                           ▼
                    ┌─────────────┐
                    │ Controller  │
                    └──────┬──────┘
                           │
                           │ ResponseSchema
                           │ (Zod 必須)
                           ▼
                    ┌─────────────┐
                    │  Frontend   │
                    └─────────────┘
`
EOF_1791008797_18185

echo "作成: tree.txt"
cat << 'EOF_1791008797_5411' > "tree.txt"
.
├── apps
│   ├── api
│   │   ├── package.json
│   │   ├── src
│   │   │   ├── app
│   │   │   │   ├── AppContext.ts
│   │   │   │   ├── createApp.ts
│   │   │   │   ├── createContainer.ts
│   │   │   │   └── DependencyContainer.ts
│   │   │   ├── common
│   │   │   │   ├── cors.ts
│   │   │   │   ├── csrf.ts
│   │   │   │   ├── errors
│   │   │   │   ├── error.ts
│   │   │   │   ├── logger.ts
│   │   │   │   ├── middleware
│   │   │   │   │   ├── authentication.ts
│   │   │   │   │   ├── authorization.ts
│   │   │   │   │   ├── errorHandler.ts
│   │   │   │   │   └── featureGuard.ts
│   │   │   │   └── repositories
│   │   │   │       ├── BaseRepository.ts
│   │   │   │       └── Repository.ts
│   │   │   ├── config
│   │   │   │   ├── Config.ts
│   │   │   │   ├── loadConfig.ts
│   │   │   │   └── saveConfig.ts
│   │   │   ├── database
│   │   │   │   ├── createDatabase.ts
│   │   │   │   ├── Database.ts
│   │   │   │   ├── DrizzleDatabase.ts
│   │   │   │   ├── InMemoryDatabase.ts
│   │   │   │   ├── PostgreSqlDatabase.ts
│   │   │   │   └── SqlServerDatabase.ts
│   │   │   ├── drizzle
│   │   │   │   ├── db.ts
│   │   │   │   ├── index.ts
│   │   │   │   └── schema.ts
│   │   │   ├── features
│   │   │   │   ├── administration
│   │   │   │   │   ├── authentication
│   │   │   │   │   │   ├── AdminAuthenticationProvider.ts
│   │   │   │   │   │   └── LocalAdminAuthenticationProvider.ts
│   │   │   │   │   ├── controllers
│   │   │   │   │   │   ├── AdminUserController.ts
│   │   │   │   │   │   ├── ConfigurationController.ts
│   │   │   │   │   │   ├── FeatureFlagController.ts
│   │   │   │   │   │   └── SystemStatusController.ts
│   │   │   │   │   ├── domain
│   │   │   │   │   │   ├── AdminUser.ts
│   │   │   │   │   │   ├── FeatureFlag.ts
│   │   │   │   │   │   ├── SystemConfiguration.ts
│   │   │   │   │   │   └── SystemStatus.ts
│   │   │   │   │   ├── repositories
│   │   │   │   │   │   ├── AdminUserRepository.ts
│   │   │   │   │   │   ├── ConfigurationRepository.ts
│   │   │   │   │   │   └── FeatureFlagRepository.ts
│   │   │   │   │   ├── routes.ts
│   │   │   │   │   └── services
│   │   │   │   │       ├── AdminUserService.ts
│   │   │   │   │       ├── ConfigurationService.ts
│   │   │   │   │       ├── FeatureFlagService.ts
│   │   │   │   │       └── SystemStatusService.ts
│   │   │   │   ├── authentication
│   │   │   │   │   ├── AppJwtPayload.ts
│   │   │   │   │   ├── AppVariables.ts
│   │   │   │   │   ├── AuthenticationCredential.ts
│   │   │   │   │   ├── controllers
│   │   │   │   │   │   └── AuthenticationController.ts
│   │   │   │   │   ├── domain
│   │   │   │   │   │   └── UserPrincipal.ts
│   │   │   │   │   ├── middleware
│   │   │   │   │   │   ├── authorizeSelfOrAdmin.ts
│   │   │   │   │   │   ├── authorize.ts
│   │   │   │   │   │   └── jwtAuthentication.ts
│   │   │   │   │   ├── providers
│   │   │   │   │   │   ├── AuthenticationProvider.ts
│   │   │   │   │   │   ├── createAuthenticationProvider.ts
│   │   │   │   │   │   ├── LdapAuthenticationProvider.ts
│   │   │   │   │   │   ├── LocalAuthenticationProvider.ts
│   │   │   │   │   │   ├── NoAuthenticationProvider.ts
│   │   │   │   │   │   └── OidcAuthenticationProvider.ts
│   │   │   │   │   ├── routes.ts
│   │   │   │   │   └── services
│   │   │   │   │       ├── AuthenticationService.ts
│   │   │   │   │       └── JwtService.ts
│   │   │   │   ├── authorization
│   │   │   │   │   ├── controllers
│   │   │   │   │   │   └── AuthorizationController.ts
│   │   │   │   │   ├── domain
│   │   │   │   │   │   ├── Permission.ts
│   │   │   │   │   │   └── Role.ts
│   │   │   │   │   ├── repositories
│   │   │   │   │   │   └── RoleRepository.ts
│   │   │   │   │   ├── routes.ts
│   │   │   │   │   └── services
│   │   │   │   │       └── AuthorizationService.ts
│   │   │   │   └── user
│   │   │   │       ├── controllers
│   │   │   │       │   └── UserController.ts
│   │   │   │       ├── domain
│   │   │   │       │   └── User.ts
│   │   │   │       ├── mappers
│   │   │   │       │   └── UserMapper.ts
│   │   │   │       ├── repositories
│   │   │   │       │   ├── UserRepositoryImpl.ts
│   │   │   │       │   └── UserRepository.ts
│   │   │   │       ├── routes.ts
│   │   │   │       └── services
│   │   │   │           └── UserService.ts
│   │   │   └── main.ts
│   │   ├── tsconfig.json
│   │   └── vitest.config.ts
│   └── web
│       ├── ApplicationConfiguration.ts
│       ├── Application.ts
│       ├── FrontendConfigurationService.ts
│       ├── package.json
│       ├── package-lock.json
│       ├── react
│       │   ├── index.html
│       │   ├── package.json
│       │   ├── src
│       │   │   ├── app
│       │   │   │   ├── App.tsx
│       │   │   │   ├── FeatureDefinition.ts
│       │   │   │   ├── features.ts
│       │   │   │   ├── providers
│       │   │   │   │   ├── AuthProvider.tsx
│       │   │   │   │   ├── ConfigurationProvider.tsx
│       │   │   │   │   └── ReactQueryProvider.tsx
│       │   │   │   └── router.tsx
│       │   │   ├── components
│       │   │   │   └── Layout.tsx
│       │   │   ├── config
│       │   │   ├── features
│       │   │   │   └── dashboard
│       │   │   │       └── pages
│       │   │   │           └── DashboardPage.tsx
│       │   │   ├── index.css
│       │   │   └── main.tsx
│       │   ├── tsconfig.json
│       │   ├── vite.config.ts
│       │   └── vitest.config.ts
│       ├── RuntimeConfigurationProvider.ts
│       ├── tsconfig.json
│       ├── vitest.config.ts
│       └── vue
├── config
│   ├── development.json
│   ├── production.json
│   └── staging.json
├── package.json
├── package-lock.json
├── packages
│   ├── api-client
│   │   ├── administration
│   │   │   └── ConfigurationApi.ts
│   │   ├── authentication
│   │   │   └── AuthenticationApi.ts
│   │   ├── http
│   │   │   ├── FetchHttpClient.ts
│   │   │   └── HttpClient.ts
│   │   └── user
│   │       └── UserApi.ts
│   ├── features
│   │   ├── authentication
│   │   │   ├── api
│   │   │   │   └── login.ts
│   │   │   ├── components
│   │   │   │   └── LoginForm.tsx
│   │   │   ├── Feature.tsx
│   │   │   ├── hooks
│   │   │   │   └── useLogin.ts
│   │   │   ├── pages
│   │   │   │   └── LoginPage.tsx
│   │   │   └── routes.tsx
│   │   ├── package.json
│   │   ├── settings
│   │   │   ├── Feature.tsx
│   │   │   └── pages
│   │   │       └── SettingsPage.tsx
│   │   ├── tsconfig.json
│   │   └── vitest.config.ts
│   ├── shared
│   │   ├── collections
│   │   ├── constants
│   │   ├── errors
│   │   └── utilities
│   ├── types
│   │   ├── administration
│   │   │   ├── ConfigurationDto.ts
│   │   │   └── FeatureFlagDto.ts
│   │   ├── authentication
│   │   │   ├── LoginRequest.ts
│   │   │   └── LoginResponse.ts
│   │   ├── authorization
│   │   │   ├── PermissionDto.ts
│   │   │   └── RoleDto.ts
│   │   ├── common
│   │   ├── Config.ts
│   │   ├── package.json
│   │   └── user
│   │       ├── CreateUserRequest.ts
│   │       ├── UpdateUserRequest.ts
│   │       └── UserDto.ts
│   └── validation
│       ├── administration
│       ├── authentication
│       │   └── LoginSchema.ts
│       ├── common
│       └── user
│           ├── CreateUserSchema.ts
│           └── UpdateUserSchema.ts
├── tsconfig.base.json
└── tsconfig.json
EOF_1791008797_5411

echo "作成: TASK-003.md"
cat << 'EOF_1791008797_25782' > "TASK-003.md"
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
EOF_1791008797_25782

echo "作成: drizzle.config.ts"
cat << 'EOF_1791008797_31850' > "drizzle.config.ts"
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
    schema: './packages/schema/src/database/*',
    out: './apps/api/drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: process.env.DATABASE_URL!,
    },
});
EOF_1791008797_31850

mkdir -p "apps/web/react"
echo "作成: apps/web/react/package.json"
cat << 'EOF_1791008797_30768' > "apps/web/react/package.json"
{
    "name": "@apps/web-react",
    "private": true,
    "type": "module",
    "scripts": {
        "dev": "vite",
        "build": "vite build",
        "preview": "vite preview",
        "test": "vitest"
    },
    "dependencies": {
        "react": "^19.3.0",
        "react-dom": "^19.3.0",
        "react-router-dom": "^7.18.3"
    },
    "devDependencies": {
        "@tailwindcss/vite": "^4.3.3",
        "@types/react": "^19.3.0",
        "@types/react-dom": "^19.3.0",
        "@vitejs/plugin-react": "^6.1.1",
        "tailwindcss": "^4.3.3",
        "vite": "^8.3.0"
    }
}
EOF_1791008797_30768

mkdir -p "apps/web/react"
echo "作成: apps/web/react/index.html"
cat << 'EOF_1791008797_9224' > "apps/web/react/index.html"
<!doctype html>
<html lang="ja">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        <title>User Management</title>

        <script id="application-configuration" type="application/json">
            __APPLICATION_CONFIGURATION__
        </script>
    </head>

    <body>
        <div id="root"></div>

        <script type="module" src="/src/main.tsx"></script>
    </body>
</html>
EOF_1791008797_9224

mkdir -p "apps/web/react"
echo "作成: apps/web/react/tsconfig.json"
cat << 'EOF_1791008797_17603' > "apps/web/react/tsconfig.json"
{
    "extends": "../../../tsconfig.base.json",
    "include": ["**/*.ts"],
    "compilerOptions": {
        "types": ["vite/client"]
    }
}
EOF_1791008797_17603

mkdir -p "apps/web/react"
echo "作成: apps/web/react/vitest.config.ts"
cat << 'EOF_1791008797_21222' > "apps/web/react/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'jsdom',
        include: ['**/*.test.ts'],
    },
});
EOF_1791008797_21222

mkdir -p "apps/web/react/src/app"
echo "作成: apps/web/react/src/app/router.tsx"
cat << 'EOF_1791008797_3601' > "apps/web/react/src/app/router.tsx"
import { Navigate, createBrowserRouter } from 'react-router-dom';

import { Layout } from '../components/Layout';
import { defaultPath, features } from './features';
import { useAuth } from './providers/AuthProvider';

import { LoginPage } from '../features/authentication/pages/LoginPage';

function LoginRoute() {
    const auth = useAuth();

    if (auth.isAuthenticated) {
        return <Navigate to={defaultPath} replace />;
    }

    return <LoginPage />;
}

function ProtectedLayout() {
    const auth = useAuth();

    if (!auth.isAuthenticated) {
        return <Navigate to="/login" replace />;
    }

    return <Layout />;
}

function RootRoute() {
    const auth = useAuth();

    return <Navigate to={auth.isAuthenticated ? defaultPath : '/login'} replace />;
}

function NotFoundRoute() {
    const auth = useAuth();

    return <Navigate to={auth.isAuthenticated ? defaultPath : '/login'} replace />;
}

const featureRoutes = features
    .flatMap((feature) => feature.routes ?? [])
    .filter((route) => route.path !== '/login')
    .map((route) => ({
        ...route,
        path: route.path?.replace(/^\//, ''),
    }));

export const router = createBrowserRouter([
    {
        path: '/login',
        element: <LoginRoute />,
    },
    {
        path: '/',
        element: <ProtectedLayout />,
        children: [
            {
                index: true,
                element: <Navigate to={defaultPath} replace />,
            },
            ...featureRoutes,
        ],
    },
    {
        path: '*',
        element: <NotFoundRoute />,
    },
]);
EOF_1791008797_3601

mkdir -p "apps/web/react/src/app"
echo "作成: apps/web/react/src/app/FeatureDefinition.ts"
cat << 'EOF_1791008797_14607' > "apps/web/react/src/app/FeatureDefinition.ts"
// src/app/FeatureDefinition.ts

import { RouteObject } from 'react-router-dom';

export interface FeatureDefinition {
    readonly id: string;

    readonly menu?: {
        readonly title: string;
        readonly path: string;
        readonly order?: number;
    };

    readonly routes?: RouteObject[];
}
EOF_1791008797_14607

mkdir -p "apps/web/react/src/app"
echo "作成: apps/web/react/src/app/App.tsx"
cat << 'EOF_1791008797_16098' > "apps/web/react/src/app/App.tsx"
import { RouterProvider } from 'react-router-dom';
import { router } from './router';

export function App() {
    return <RouterProvider router={router} />;
}
EOF_1791008797_16098

mkdir -p "apps/web/react/src/app"
echo "作成: apps/web/react/src/app/features.ts"
cat << 'EOF_1791008797_19147' > "apps/web/react/src/app/features.ts"
// src/app/features.ts

import { FeatureDefinition } from './FeatureDefinition';

const modules = import.meta.glob('../features/**/Feature.tsx', {
    eager: true,
});

console.log(`自動認識機能：${Object.keys(modules)}`);

export const features = Object.values(modules).map(
    (x) => (x as { default: FeatureDefinition }).default,
);

export const menus = features
    .filter((feature) => feature.menu)
    .sort((a, b) => (a.menu?.order ?? 9999) - (b.menu?.order ?? 9999));

export const defaultPath = menus[0]?.menu?.path ?? '/';
EOF_1791008797_19147

mkdir -p "apps/web/react/src/app/providers"
echo "作成: apps/web/react/src/app/providers/ReactQueryProvider.tsx"
cat << 'EOF_1791008797_5639' > "apps/web/react/src/app/providers/ReactQueryProvider.tsx"
export function ReactQueryProvider(props: any) {
    return props.children;
}
EOF_1791008797_5639

mkdir -p "apps/web/react/src/app/providers"
echo "作成: apps/web/react/src/app/providers/AuthProvider.tsx"
cat << 'EOF_1791008797_15091' > "apps/web/react/src/app/providers/AuthProvider.tsx"
import { createContext, useContext, useEffect, useMemo, useState } from 'react';

interface AuthContextValue {
    readonly accessToken: string | null;
    readonly isAuthenticated: boolean;

    signIn(accessToken: string): void;
    signOut(): void;
}

const AuthContext = createContext<AuthContextValue>(null as never);

function getTokenExpiration(token: string): number | null {
    try {
        const [, payloadBase64] = token.split('.');

        const payload = JSON.parse(atob(payloadBase64));

        if (typeof payload.exp !== 'number') {
            return null;
        }

        return payload.exp * 1000;
    } catch {
        return null;
    }
}

function isTokenExpired(token: string): boolean {
    const expiresAt = getTokenExpiration(token);

    if (expiresAt === null) {
        return true;
    }

    return expiresAt <= Date.now();
}

export function AuthProvider(props: any) {
    const [accessToken, setAccessToken] = useState<string | null>(null);

    useEffect(() => {
        if (!accessToken) {
            return;
        }

        const expiresAt = getTokenExpiration(accessToken);
        if (expiresAt === null) {
            setAccessToken(null);
            return;
        }

        const timeout = expiresAt - Date.now();
        if (timeout <= 0) {
            setAccessToken(null);
            return;
        }

        const timer = window.setTimeout(() => setAccessToken(null), timeout);

        return () => window.clearTimeout(timer);
    }, [accessToken]);

    const isAuthenticated = accessToken !== null && !isTokenExpired(accessToken);

    const value = useMemo(
        () => ({
            accessToken,
            isAuthenticated,
            signIn(token: string) {
                setAccessToken(token);
            },
            signOut() {
                setAccessToken(null);
            },
        }),
        [accessToken, isAuthenticated],
    );

    return <AuthContext.Provider value={value}>{props.children}</AuthContext.Provider>;
}

export function useAuth() {
    return useContext(AuthContext);
}
EOF_1791008797_15091

mkdir -p "apps/web/react/src/app/providers"
echo "作成: apps/web/react/src/app/providers/ConfigurationProvider.tsx"
cat << 'EOF_1791008798_907' > "apps/web/react/src/app/providers/ConfigurationProvider.tsx"
export function ConfigurationProvider(props: any) {
    return props.children;
}
EOF_1791008798_907

mkdir -p "apps/web/react/src"
echo "作成: apps/web/react/src/index.css"
cat << 'EOF_1791008798_6559' > "apps/web/react/src/index.css"
@import 'tailwindcss';
EOF_1791008798_6559

mkdir -p "apps/web/react/src/features/settings"
echo "作成: apps/web/react/src/features/settings/Feature.tsx"
cat << 'EOF_1791008798_17665' > "apps/web/react/src/features/settings/Feature.tsx"
import { SettingsPage } from './pages/SettingsPage';

export default {
    id: 'settings',

    menu: {
        title: '設定',
        path: '/settings',
        order: 100,
    },

    routes: [
        {
            path: '/settings',
            element: <SettingsPage />,
        },
    ],
};
EOF_1791008798_17665

mkdir -p "apps/web/react/src/features/settings/pages"
echo "作成: apps/web/react/src/features/settings/pages/SettingsPage.tsx"
cat << 'EOF_1791008798_9492' > "apps/web/react/src/features/settings/pages/SettingsPage.tsx"
import { ConfigurationApi } from '@apps/web-core/api-client/administration/ConfigurationApi';
import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';
import { defaultAuthenticationPolicy } from '@packages/types/administration/defaultAuthenticationPolicy';
import { useState } from 'react';

export function SettingsPage() {
    const [policy, setPolicy] = useState<AuthenticationPolicy>(defaultAuthenticationPolicy);
    const [isSaving, setIsSaving] = useState(false); // 保存中のローディング状態
    const configurationApi = new ConfigurationApi();

    async function handleSave() {
        if (isSaving) return; // 二重クリック防止

        setIsSaving(true);
        try {
            await configurationApi.saveConfiguration({
                authenticationPolicy: policy,
            });

            alert('保存しました');
        } catch {
            alert('保存に失敗しました');
        } finally {
            setIsSaving(false); // 成功・失敗に関わらずローディングを解除
        }
    }

    return (
        <div className="max-w-5xl mx-auto flex flex-col gap-8">
            <div>
                <h1 className="text-3xl font-bold">認証・セキュリティ設定</h1>

                <p className="text-gray-500 mt-2">
                    ユーザー認証、セッション管理、およびアクセス制御を構成します。
                </p>
            </div>

            <section className="bg-white border rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-6">セッション管理</h2>

                <div className="grid gap-6">
                    <div>
                        <label className="block font-medium mb-2">ブラウザ再読込時</label>

                        <select
                            value={policy.session.reloadBehavior}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    session: {
                                        ...policy.session,
                                        reloadBehavior: e.target.value as 'keep-session' | 'logout',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="keep-session">ログイン状態を維持する</option>

                            <option value="logout">ログアウトする</option>
                        </select>
                    </div>

                    <div>
                        <label className="block font-medium mb-2">アイドルタイムアウト（分）</label>

                        <input
                            type="number"
                            value={policy.session.idleTimeoutMinutes}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    session: {
                                        ...policy.session,
                                        idleTimeoutMinutes: Number(e.target.value),
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-40"
                        />
                    </div>

                    <div>
                        <label className="block font-medium mb-2">
                            絶対セッションタイムアウト（分）
                        </label>

                        <input
                            type="number"
                            value={policy.session.absoluteTimeoutMinutes}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    session: {
                                        ...policy.session,
                                        absoluteTimeoutMinutes: Number(e.target.value),
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-40"
                        />
                    </div>
                </div>
            </section>

            <section className="bg-white border rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-6">Deep Link</h2>

                <div className="grid gap-6">
                    <label className="flex items-center gap-3">
                        <input
                            type="checkbox"
                            checked={policy.deepLink.enabled}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    deepLink: {
                                        ...policy.deepLink,
                                        enabled: e.target.checked,
                                    },
                                })
                            }
                        />
                        ログイン前URLを保持する
                    </label>

                    <div>
                        <label className="block font-medium mb-2">ログイン成功後</label>

                        <select
                            value={policy.deepLink.afterLogin}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    deepLink: {
                                        ...policy.deepLink,
                                        afterLogin: e.target.value as 'restore' | 'home',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="restore">元URLへ戻る</option>

                            <option value="home">ホームへ戻る</option>
                        </select>
                    </div>
                </div>
            </section>

            <section className="bg-white border rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-6">アクセス制御</h2>

                <div className="grid gap-6">
                    <div>
                        <label className="block font-medium mb-2">
                            認証済みで /login にアクセス
                        </label>

                        <select
                            value={policy.navigation.loginPageWhileAuthenticated}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    navigation: {
                                        ...policy.navigation,
                                        loginPageWhileAuthenticated: e.target.value as
                                            'back' | 'home',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="back">元画面へ戻る</option>

                            <option value="home">ホームへ戻る</option>
                        </select>
                    </div>

                    <div>
                        <label className="block font-medium mb-2">権限なしURLアクセス時</label>

                        <select
                            value={policy.navigation.forbiddenPage}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    navigation: {
                                        ...policy.navigation,
                                        forbiddenPage: e.target.value as 'back' | 'home' | '403',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="back">元画面へ戻る</option>

                            <option value="home">ホームへ戻る</option>

                            <option value="403">403画面を表示</option>
                        </select>
                    </div>
                </div>
            </section>

            <div className="flex justify-end">
                <button
                    onClick={handleSave}
                    disabled={isSaving}
                    className={`px-8 py-3 rounded-xl text-white transition-colors ${
                        isSaving
                            ? 'bg-blue-400 cursor-not-allowed'
                            : 'bg-blue-600 hover:bg-blue-700'
                    }`}
                >
                    {isSaving ? '保存中...' : '保存'}
                </button>
            </div>
        </div>
    );
}
EOF_1791008798_9492

mkdir -p "apps/web/react/src/features/dashboard"
echo "作成: apps/web/react/src/features/dashboard/Feature.tsx"
cat << 'EOF_1791008798_920' > "apps/web/react/src/features/dashboard/Feature.tsx"
import { DashboardPage } from './pages/DashboardPage';

export default {
    id: 'dashboard',

    menu: {
        title: 'ダッシュボード',
        path: '/dashboard',
        order: 10,
    },

    routes: [
        {
            path: '/dashboard',
            element: <DashboardPage />,
        },
    ],
};
EOF_1791008798_920

mkdir -p "apps/web/react/src/features/dashboard/pages"
echo "作成: apps/web/react/src/features/dashboard/pages/DashboardPage.tsx"
cat << 'EOF_1791008798_15140' > "apps/web/react/src/features/dashboard/pages/DashboardPage.tsx"
import { useAuth } from '@apps/web-react/src/app/providers/AuthProvider';

export function DashboardPage() {
    const auth = useAuth();

    // 簡易的なデータ定義
    const stats = [
        { label: '総ユーザー数', value: '1,280 人', change: '+4.75%', isPositive: true },
        { label: '本日の売上', value: '¥48,500', change: '+10.2%', isPositive: true },
        { label: 'システム稼働率', value: '99.98%', change: '-0.02%', isPositive: false },
    ];

    return (
        <div className="flex flex-col gap-8">
            {/* 上部ヘッダー */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900 tracking-tight">ダッシュボード</h1>
                <p className="text-sm text-gray-500 mt-1">
                    システムの状況と主要なインサイトを一覧で確認できます。
                </p>
            </div>

            {/* 統計カードエリア */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {stats.map((stat, index) => (
                    <div
                        key={index}
                        className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm flex flex-col gap-2"
                    >
                        <span className="text-sm font-semibold text-gray-500">{stat.label}</span>
                        <div className="flex items-baseline justify-between">
                            <span className="text-2xl font-bold text-gray-900">{stat.value}</span>
                            <span
                                className={`text-xs font-bold px-2 py-1 rounded-sm ${
                                    stat.isPositive
                                        ? 'bg-green-50 text-green-700'
                                        : 'bg-red-50 text-red-700'
                                }`}
                            >
                                {stat.change}
                            </span>
                        </div>
                    </div>
                ))}
            </div>

            {/* メインコンテンツエリア */}
            <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                <h3 className="text-base font-bold text-gray-900 mb-4">最近のアクティビティ</h3>
                <div className="border-t border-gray-100 divide-y divide-gray-100">
                    <div className="py-3.5 flex justify-between text-sm">
                        <span className="text-gray-700">システム設定が更新されました</span>
                        <span className="text-gray-400">10分前</span>
                    </div>
                    <div className="py-3.5 flex justify-between text-sm">
                        <span className="text-gray-700">新規ユーザーが登録されました</span>
                        <span className="text-gray-400">1時間前</span>
                    </div>
                </div>
            </div>
        </div>
    );
}
EOF_1791008798_15140

mkdir -p "apps/web/react/src/features/authentication"
echo "作成: apps/web/react/src/features/authentication/routes.tsx"
cat << 'EOF_1791008798_12737' > "apps/web/react/src/features/authentication/routes.tsx"
import { Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';

export const routes = [
    {
        path: '/',
        element: <Navigate to="/login" replace />,
    },
    {
        path: '/login',
        element: <LoginPage />,
    },
];
EOF_1791008798_12737

mkdir -p "apps/web/react/src/features/authentication"
echo "作成: apps/web/react/src/features/authentication/Feature.tsx"
cat << 'EOF_1791008798_3094' > "apps/web/react/src/features/authentication/Feature.tsx"
import { LoginPage } from './pages/LoginPage';

export default {
    id: 'auth',

    // menu: {
    //     title: 'ログイン',
    //     path: '/login',
    //     order: 10,
    // },

    routes: [
        {
            path: '/login',
            element: <LoginPage />,
        },
    ],
};
EOF_1791008798_3094

mkdir -p "apps/web/react/src/features/authentication/api"
echo "作成: apps/web/react/src/features/authentication/api/login.ts"
cat << 'EOF_1791008798_16152' > "apps/web/react/src/features/authentication/api/login.ts"
import { Application } from '@apps/web-core/Application';
import { LoginRequest } from '@packages/types/authentication/LoginRequest';
import { LoginResponse } from '@packages/types/authentication/LoginResponse';

const application = new Application();

export async function login(request: LoginRequest): Promise<LoginResponse> {
    console.log('login request', JSON.stringify(request));

    const response = await application.fetch(`/auth/login`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(request),
    });
    if (!response.ok) {
        throw new Error(`Login failed: ${response.status}`);
    }

    return await response.json();
}
EOF_1791008798_16152

mkdir -p "apps/web/react/src/features/authentication/pages"
echo "作成: apps/web/react/src/features/authentication/pages/LoginPage.tsx"
cat << 'EOF_1791008798_28403' > "apps/web/react/src/features/authentication/pages/LoginPage.tsx"
import { LoginForm } from '../components/LoginForm';

export function LoginPage() {
    return (
        <main className="min-h-screen w-screen flex items-center justify-center bg-gray-50 p-6">
            <LoginForm />
        </main>
    );
}
EOF_1791008798_28403

mkdir -p "apps/web/react/src/features/authentication/hooks"
echo "作成: apps/web/react/src/features/authentication/hooks/useLogin.ts"
cat << 'EOF_1791008798_30878' > "apps/web/react/src/features/authentication/hooks/useLogin.ts"
import { defaultPath } from '@apps/web-react/src/app/features';
import { useAuth } from '@apps/web-react/src/app/providers/AuthProvider';
import { useNavigate } from 'react-router-dom';
import { login } from '../api/login';

export function useLogin() {
    const auth = useAuth();
    const navigate = useNavigate();

    return async (email: string, password: string) => {
        const result = await login({
            email: email,
            password,
        });

        auth.signIn(result.accessToken);

        navigate(defaultPath, {
            replace: true,
        });
    };
}
EOF_1791008798_30878

mkdir -p "apps/web/react/src/features/authentication/components"
echo "作成: apps/web/react/src/features/authentication/components/LoginForm.tsx"
cat << 'EOF_1791008798_31299' > "apps/web/react/src/features/authentication/components/LoginForm.tsx"
import { useState, type SubmitEvent } from 'react';
import { useLogin } from '../hooks/useLogin';

export function LoginForm() {
    const login = useLogin();

    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    async function submit(event: SubmitEvent<HTMLFormElement>) {
        event.preventDefault();

        try {
            setLoading(true);
            setError('');
            await login(email, password);
        } catch {
            setError('Login failed');
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="w-full max-w-md bg-white rounded-2xl border border-gray-200 p-8 shadow-sm">
            <div className="flex flex-col items-center mb-8">
                <div className="w-12 h-12 bg-blue-600 rounded-xl flex items-center justify-center text-white font-bold text-2xl mb-4">
                    M
                </div>
                <h1 className="text-2xl font-bold text-gray-900 tracking-tight">
                    アカウントにログイン
                </h1>
                <p className="text-sm text-gray-500 mt-1">
                    画面にアクセスするための資格情報を入力してください
                </p>
            </div>
            {error && (
                <div className="mb-6 p-4 bg-red-50 border border-red-100 rounded-xl text-sm text-red-600 font-medium解">
                    {error}
                </div>
            )}
            <form onSubmit={submit} className="flex flex-col gap-5">
                <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Email</label>
                    <input
                        value={email}
                        onChange={(event) => setEmail(event.target.value)}
                        required
                        className="w-full px-4 py-3 bg-white border border-gray-300 rounded-xl text-gray-900 text-sm focus:outline-hidden focus:border-blue-600 focus:ring-1 focus:ring-blue-600 transition-colors"
                        placeholder="name@example.com"
                    />
                </div>
                <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Password
                    </label>
                    <input
                        type="password"
                        value={password}
                        onChange={(event) => setPassword(event.target.value)}
                        required
                        className="w-full px-4 py-3 bg-white border border-gray-300 rounded-xl text-gray-900 text-sm focus:outline-hidden focus:border-blue-600 focus:ring-1 focus:ring-blue-600 transition-colors"
                        placeholder="••••••••"
                    />
                </div>
                <button
                    type="submit"
                    disabled={loading}
                    className="w-full mt-2 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-semibold py-3 px-4 rounded-xl transition-colors text-center text-sm shadow-xs cursor-pointer flex justify-center items-center"
                >
                    {loading ? 'Loading...' : 'Login'}
                </button>
            </form>
        </div>
    );
}
EOF_1791008798_31299

mkdir -p "apps/web/react/src"
echo "作成: apps/web/react/src/main.tsx"
cat << 'EOF_1791008798_6914' > "apps/web/react/src/main.tsx"
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './app/App';
import { AuthProvider } from './app/providers/AuthProvider';
// アプリ全体のスタイル（CSS）をインポートしている場合はここに記述します
import './index.css';

createRoot(document.getElementById('root')!).render(
    <StrictMode>
        <AuthProvider>
            <App />
        </AuthProvider>
    </StrictMode>,
);
EOF_1791008798_6914

mkdir -p "apps/web/react/src/components"
echo "作成: apps/web/react/src/components/Layout.tsx"
cat << 'EOF_1791008798_32565' > "apps/web/react/src/components/Layout.tsx"
import { Link, Outlet, useNavigate } from 'react-router-dom';
import { menus } from '../app/features';
import { useAuth } from '../app/providers/AuthProvider';

export function Layout() {
    const navigate = useNavigate();
    const auth = useAuth();

    const handleLogout = () => {
        auth.signOut();
        navigate('/login', {
            replace: true,
        });
    };

    return (
        <div className="flex h-screen w-screen overflow-hidden bg-gray-50">
            {/* 左側：サイドバーメニュー */}
            <aside className="w-64 bg-white border-r border-gray-200 flex flex-col justify-between">
                {/* 上部メニューエリア */}
                <div className="p-6">
                    <div className="flex items-center gap-2 mb-8">
                        <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center text-white font-bold text-lg">
                            M
                        </div>
                        <h2 className="text-xl font-bold text-gray-800 tracking-tight">
                            マイアプリ
                        </h2>
                    </div>

                    <nav className="flex flex-col gap-1">
                        {menus.map((menu) => (
                            <Link
                                key={menu.id}
                                to={menu.menu!.path}
                                className="flex items-center gap-3 px-4 py-3 text-gray-700 hover:bg-gray-100 rounded-xl transition-colors font-medium"
                            >
                                {menu.menu!.title}
                            </Link>
                        ))}
                    </nav>
                </div>

                {/* 下部ユーザー・アクションエリア */}
                <div className="p-6 border-t border-gray-100">
                    <button
                        onClick={handleLogout}
                        className="w-full bg-red-50 hover:bg-red-100 text-red-600 font-semibold py-3 px-4 rounded-xl transition-colors text-center text-sm"
                    >
                        ログアウト
                    </button>
                </div>
            </aside>

            {/* 右側：メインコンテンツ表示エリア */}
            <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
                {/* 必要に応じてここに共通ヘッダー（パンくずリストなど）を配置可能 */}

                {/* 下位ルート（ホームや設定画面）の中身がここに動的にはめ込まれます */}
                <div className="flex-1 p-8 overflow-y-auto">
                    <Outlet />
                </div>
            </main>
        </div>
    );
}
EOF_1791008798_32565

mkdir -p "apps/web/react"
echo "作成: apps/web/react/vite.config.ts"
cat << 'EOF_1791008798_27344' > "apps/web/react/vite.config.ts"
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import fs from 'node:fs';
import { defineConfig } from 'vite';

const configuration = JSON.parse(fs.readFileSync('../../../config/development.json', 'utf-8'));

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    plugins: [
        react(),
        tailwindcss(),
        {
            name: 'application-configuration',

            transformIndexHtml(html) {
                return html.replace(
                    '__APPLICATION_CONFIGURATION__',
                    JSON.stringify({
                        backend: configuration.backend,
                    }),
                );
            },
        },
    ],
});

// import { defineConfig } from 'vite';
// import react from '@vitejs/plugin-react';

// export default defineConfig({
//     plugins: [react()],

//     server: {
//         proxy: {
//             '/api': {
//                 target: 'http://localhost:3000',
//                 changeOrigin: true,
//             },
//         },
//     },
// });
EOF_1791008798_27344

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1791008798_18161' > "apps/web/package.json"
{
    "name": "@apps/web",
    "private": true,
    "type": "module",
    "dependencies": {
        "@packages/schemas": "*"
    }
}
EOF_1791008798_18161

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1791008798_28287' > "apps/web/tsconfig.json"
{
    "extends": "../../tsconfig.base.json",
    "include": ["./*.ts"]
}
EOF_1791008798_28287

mkdir -p "apps/web"
echo "作成: apps/web/vitest.config.ts"
cat << 'EOF_1791008798_15420' > "apps/web/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        include: ['**/*.test.ts'],
    },
});
EOF_1791008798_15420

mkdir -p "apps/web/core"
echo "作成: apps/web/core/package.json"
cat << 'EOF_1791008798_30991' > "apps/web/core/package.json"
{
    "name": "@apps/web-core",
    "private": true,
    "type": "module",
    "scripts": {
        "dev": "vite",
        "build": "vite build",
        "preview": "vite preview",
        "test": "vitest"
    }
}
EOF_1791008798_30991

mkdir -p "apps/web/core"
echo "作成: apps/web/core/tsconfig.json"
cat << 'EOF_1791008798_1756' > "apps/web/core/tsconfig.json"
{
    "extends": "../../../tsconfig.base.json",
    "include": ["**/*.ts"]
}
EOF_1791008798_1756

mkdir -p "apps/web/core"
echo "作成: apps/web/core/vitest.config.ts"
cat << 'EOF_1791008798_7132' > "apps/web/core/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        include: ['**/*.test.ts'],
    },
});
EOF_1791008798_7132

mkdir -p "apps/web/core/src"
echo "作成: apps/web/core/src/ApplicationConfiguration.ts"
cat << 'EOF_1791008798_22265' > "apps/web/core/src/ApplicationConfiguration.ts"
export interface ApplicationConfiguration {
    readonly backend: {
        readonly protocol: string;
        readonly host: string;
        readonly port: number;
        readonly applicationRoot: string;
    };
}
EOF_1791008798_22265

mkdir -p "apps/web/core/src/api-client/user"
echo "作成: apps/web/core/src/api-client/user/UserApi.ts"
cat << 'EOF_1791008798_245' > "apps/web/core/src/api-client/user/UserApi.ts"
export class UserApi {}
EOF_1791008798_245

mkdir -p "apps/web/core/src/api-client/administration"
echo "作成: apps/web/core/src/api-client/administration/ConfigurationApi.ts"
cat << 'EOF_1791008798_18364' > "apps/web/core/src/api-client/administration/ConfigurationApi.ts"
import { ConfigurationDto } from '@packages/types/administration/ConfigurationDto';
import { Application } from '../../Application';

const application = new Application();

export class ConfigurationApi {
    async getConfiguration(): Promise<ConfigurationDto> {
        const response = await application.fetch(`/configuration`);

        if (!response.ok) {
            throw new Error(`Get configuration failed: ${response.status}`);
        }

        return await response.json();
    }

    async saveConfiguration(configuration: ConfigurationDto): Promise<void> {
        const response = await application.fetch(`/configuration`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(configuration),
        });

        if (!response.ok) {
            throw new Error(`Save configuration failed: ${response.status}`);
        }
    }
}
EOF_1791008798_18364

mkdir -p "apps/web/core/src/api-client/http"
echo "作成: apps/web/core/src/api-client/http/FetchHttpClient.ts"
cat << 'EOF_1791008798_23249' > "apps/web/core/src/api-client/http/FetchHttpClient.ts"
import { Application } from '../../Application';
import { HttpClient } from './HttpClient';

const application = new Application();

export class FetchHttpClient implements HttpClient {
    async get<T>(url: string): Promise<T> {
        const response = await application.fetch(url);

        return response.json();
    }

    async post<T>(url: string, body: unknown): Promise<T> {
        const response = await application.fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
        });

        return response.json();
    }
}
EOF_1791008798_23249

mkdir -p "apps/web/core/src/api-client/http"
echo "作成: apps/web/core/src/api-client/http/HttpClient.ts"
cat << 'EOF_1791008798_5469' > "apps/web/core/src/api-client/http/HttpClient.ts"
export interface HttpClient {
    get<T>(url: string): Promise<T>;
    post<T>(url: string, body: unknown): Promise<T>;
}
EOF_1791008798_5469

mkdir -p "apps/web/core/src/api-client/authentication"
echo "作成: apps/web/core/src/api-client/authentication/AuthenticationApi.ts"
cat << 'EOF_1791008798_3396' > "apps/web/core/src/api-client/authentication/AuthenticationApi.ts"
export class AuthenticationApi {}
EOF_1791008798_3396

mkdir -p "apps/web/core/src"
echo "作成: apps/web/core/src/Application.ts"
cat << 'EOF_1791008798_12077' > "apps/web/core/src/Application.ts"
import { FrontendConfigurationService } from './FrontendConfigurationService';
import { RuntimeConfigurationProvider } from './RuntimeConfigurationProvider';

export class Application {
    private configurationService: FrontendConfigurationService;

    public constructor() {
        const configurationProvider = new RuntimeConfigurationProvider();

        this.configurationService = new FrontendConfigurationService(
            configurationProvider.getConfiguration(),
        );
    }

    public async fetch(input: string, init?: RequestInit): Promise<Response> {
        console.log('Application.fetch:');
        console.log('  input:', input);
        console.log('  method', init?.method);
        console.log('  body', init?.body);

        const url = this.configurationService.getApiBaseUrl() + input;
        console.log('  url:', url);

        return await fetch(url, init);
    }
}
EOF_1791008798_12077

mkdir -p "apps/web/core/src"
echo "作成: apps/web/core/src/FrontendConfigurationService.ts"
cat << 'EOF_1791008798_28877' > "apps/web/core/src/FrontendConfigurationService.ts"
import { ApplicationConfiguration } from './ApplicationConfiguration';

export class FrontendConfigurationService {
    constructor(private readonly configuration: ApplicationConfiguration) {}

    public getApiBaseUrl(): string {
        const backend = this.configuration.backend;

        console.log('  getApiBaseUrl()', backend);

        return (
            `${backend.protocol}://` +
            `${backend.host}:` +
            `${backend.port}` +
            `${backend.applicationRoot}`
        );
    }
}
EOF_1791008798_28877

mkdir -p "apps/web/core/src"
echo "作成: apps/web/core/src/RuntimeConfigurationProvider.ts"
cat << 'EOF_1791008798_11743' > "apps/web/core/src/RuntimeConfigurationProvider.ts"
import { ApplicationConfiguration } from './ApplicationConfiguration';

export class RuntimeConfigurationProvider {
    public getConfiguration(): ApplicationConfiguration {
        const element = document.getElementById('application-configuration');

        if (element === null) {
            throw new Error('application-configuration element not found.');
        }

        const json = element.textContent;

        if (json === null) {
            throw new Error('application configuration not found.');
        }

        return JSON.parse(json) as ApplicationConfiguration;
    }
}
EOF_1791008798_11743

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1791008798_30253' > "apps/api/package.json"
{
    "name": "@apps/api",
    "private": true,
    "type": "module",
    "scripts": {
        "dev": "tsx src/main.ts",
        "build": "tsc -p tsconfig.json",
        "test": "vitest"
    },
    "dependencies": {
        "@hono/node-server": "^1.19.0",
        "@packages/schemas": "*",
        "bcrypt": "^6.0.0",
        "drizzle-orm": "^0.45.3",
        "drizzle-zod": "^0.8.3",
        "hono": "^4.9.6",
        "jsonwebtoken": "^9.0.3",
        "mssql": "^12.7.2",
        "pg": "^8.23.0"
    },
    "devDependencies": {
        "@types/bcrypt": "^6.0.0",
        "@types/jsonwebtoken": "^9.0.10",
        "@types/mssql": "^12.3.0",
        "@types/node": "^24.4.0",
        "@types/pg": "^8.23.1"
    }
}
EOF_1791008798_30253

mkdir -p "apps/api"
echo "作成: apps/api/tsconfig.json"
cat << 'EOF_1791008798_9584' > "apps/api/tsconfig.json"
{
    "extends": "../../tsconfig.base.json",
    "compilerOptions": {
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "types": ["node"]
    }
}
EOF_1791008798_9584

mkdir -p "apps/api"
echo "作成: apps/api/vitest.config.ts"
cat << 'EOF_1791008798_13227' > "apps/api/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        include: ['**/*.test.ts'],
    },
});
EOF_1791008798_13227

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/Repositories.ts"
cat << 'EOF_1791008798_28826' > "apps/api/src/app/Repositories.ts"
import type { UserRepository } from '../repositories/user-repository';

export interface Repositories {
    userRepository: UserRepository;
}
EOF_1791008798_28826

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/Services.ts"
cat << 'EOF_1791008798_25369' > "apps/api/src/app/Services.ts"
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserService } from '../features/user/service';

export interface Services {
    userService: UserService;
    jwtService: JwtService;
    authenticationService: AuthenticationService;
}
EOF_1791008798_25369

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/createRepositories.ts"
cat << 'EOF_1791008798_27983' > "apps/api/src/app/createRepositories.ts"
import { MemoryUserRepository } from '../infrastructure/memory/user-repository';
import { createPostgresDb } from '../infrastructure/postgres/db';
import { PostgresUserRepository } from '../infrastructure/postgres/user-repository';
import { createSqlServerDb } from '../infrastructure/sqlserver/db';
import { SqlServerUserRepository } from '../infrastructure/sqlserver/user-repository';
import type { DatabaseConfig } from '../systemConfig/SystemConfig';
import type { Repositories } from './Repositories';

export async function createRepositories(config: DatabaseConfig): Promise<Repositories> {
    switch (config.type) {
        case 'memory': {
            return {
                userRepository: new MemoryUserRepository(),
            };
        }

        case 'postgres': {
            const db = createPostgresDb(config.connectionString!);

            return {
                userRepository: new PostgresUserRepository(db),
            };
        }

        case 'sqlserver': {
            const db = await createSqlServerDb(config.connectionString!);

            return {
                userRepository: new SqlServerUserRepository(db),
            };
        }

        default: {
            throw new Error(`Unsupported database type: ${config.type}`);
        }
    }
}
EOF_1791008798_27983

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/createServices.ts"
cat << 'EOF_1791008798_31465' > "apps/api/src/app/createServices.ts"
import { createAuthenticationProvider } from '../features/authentication/providers/createAuthenticationProvider';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserService } from '../features/user/service';
import { SystemConfig } from '../systemConfig/SystemConfig';
import { Repositories } from './Repositories';
import { Services } from './Services';

export function createServices(dependencies: {
    repositories: Repositories;
    systemConfig: SystemConfig;
}): Services {
    const userService = new UserService(dependencies.repositories.userRepository);

    const jwtService = new JwtService(dependencies.systemConfig.authentication.secret!);

    const authenticationProvider = createAuthenticationProvider(
        dependencies.systemConfig.authentication,
        { userService },
    );

    const authenticationService = new AuthenticationService(authenticationProvider, jwtService);

    return {
        userService,
        jwtService,
        authenticationService,
    };
}
EOF_1791008798_31465

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/AppContext.ts"
cat << 'EOF_1791008798_6717' > "apps/api/src/app/AppContext.ts"
export interface AppContext {}
EOF_1791008798_6717

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/createDependencyContainer.ts"
cat << 'EOF_1791008798_6208' > "apps/api/src/app/createDependencyContainer.ts"
import { SystemConfig } from '../systemConfig/SystemConfig';
import { createRepositories } from './createRepositories';
import { createServices } from './createServices';
import { DependencyContainer } from './DependencyContainer';

export async function createDependencyContainer(
    systemConfig: SystemConfig,
): Promise<DependencyContainer> {
    const repositories = await createRepositories(systemConfig.database);

    const services = createServices({
        repositories,
        systemConfig,
    });

    return new DependencyContainer(systemConfig, repositories, services);
}
EOF_1791008798_6208

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/DependencyContainer.ts"
cat << 'EOF_1791008798_8121' > "apps/api/src/app/DependencyContainer.ts"
import type { SystemConfig } from '../systemConfig/SystemConfig';
import type { Repositories } from './Repositories';
import { Services } from './Services';

export class DependencyContainer {
    constructor(
        public readonly systemConfig: SystemConfig,
        public readonly repositories: Repositories,
        public readonly services: Services,
    ) {}
}
EOF_1791008798_8121

mkdir -p "apps/api/src/app"
echo "作成: apps/api/src/app/createApp.ts"
cat << 'EOF_1791008798_605' > "apps/api/src/app/createApp.ts"
import { Hono } from 'hono';

import { createAuthenticationController } from '../features/authentication/routes';
import { createUserController } from '../features/user/controller';
import { DependencyContainer } from './DependencyContainer';

import cors from '../common/cors.js';
import csrf from '../common/csrf.js';
import error from '../common/error.js';
import logger from '../common/logger.js';
import { jwtAuthentication } from '../features/authentication/middleware/jwtAuthentication';
// import notFound from "./handlers/not-found.js";

export function createApp(container: DependencyContainer) {
    const apiRoot = container.systemConfig.backend.applicationRoot;

    const app = new Hono()
        //
        // Route registration policy
        //
        // Hono は Middleware を登録順に適用する。
        //
        // このセクションはアプリケーション全体の
        // 認証境界および Route 構成を定義する。

        //
        // Global middleware
        //
        // 必ず実行する Middleware（システム共通処理）
        //
        .onError(error)
        // .notFound(notFound)
        .use(logger)
        .use('*', cors(container.systemConfig))
        .use('*', csrf(container.systemConfig))

        //
        // Health check
        //
        .get('/', (c) => c.text('Backend running.'))

        //
        // Routes Not Requiring Authentication
        //
        // 認証不要な Route を登録する
        //

        .route(
            `${apiRoot}`,
            createAuthenticationController(container.services.authenticationService),
        )

        //
        // Authentication boundary
        //
        // この Middleware が
        // 認証不要な Route
        // と
        // 認証が必要な Route
        // の境界となる。
        //
        .use(`${apiRoot}/*`, jwtAuthentication(container.services.jwtService))

        //
        // Routes Requiring Authentication
        //
        // 認証が必要な Route を登録する
        //
        .route(`${apiRoot}/users/*`, createUserController(container.services.userService));
    return app;
}
EOF_1791008798_605

mkdir -p "apps/api/src/infrastructure/memory"
echo "作成: apps/api/src/infrastructure/memory/user-repository.ts"
cat << 'EOF_1791008798_23917' > "apps/api/src/infrastructure/memory/user-repository.ts"
import type { CreateUser, User } from '@packages/schemas';
import { hashPassword } from '../../features/user/auth-utils';
import type { UserRepository } from '../../repositories/user-repository';

export class MemoryUserRepository implements UserRepository {
    private sequence = 1;

    private readonly users = new Map<number, User>();

    async findById(id: number): Promise<User | null> {
        return this.users.get(id) ?? null;
    }

    async findByEmail(email: string): Promise<User | null> {
        let result = null;
        for (const user of this.users.values()) {
            if (user.email === email) {
                result = user;
                break;
            }
        }
        return result;
    }

    async findAll(): Promise<User[]> {
        throw new Error('not implemented');
    }
    async countAdmins(): Promise<number> {
        throw new Error('not implemented');
    }

    async create(request: CreateUser): Promise<User> {
        const passwordHash = await hashPassword(request.password);
        const user: User = {
            id: this.sequence++,
            name: request.name,
            email: request.email,
            passwordHash: passwordHash,
            role: 'user',
            isActive: true,
            createdAt: new Date(),
        };
        this.users.set(user.id, user);
        return user;
    }

    async save(user: User): Promise<User> {
        throw new Error('not implemented');
    }
    async updatePassword(id: number, passwordHash: string): Promise<User> {
        throw new Error('not implemented');
    }
    async updateRole(id: number, role: string): Promise<User> {
        throw new Error('not implemented');
    }
    async updateActive(id: number, isActive: boolean): Promise<User> {
        throw new Error('not implemented');
    }
    async remove(id: number): Promise<void> {
        throw new Error('not implemented');
    }
}
EOF_1791008798_23917

mkdir -p "apps/api/src/infrastructure/memory"
echo "作成: apps/api/src/infrastructure/memory/README.md"
cat << 'EOF_1791008798_31' > "apps/api/src/infrastructure/memory/README.md"
Memory Provider

This provider stores data in memory using a Map.

It is intended for:

- local development
- unit testing
- integration testing

Data is lost when the process exits.
EOF_1791008798_31

mkdir -p "apps/api/src/infrastructure/sqlserver"
echo "作成: apps/api/src/infrastructure/sqlserver/user-repository.ts"
cat << 'EOF_1791008798_8298' > "apps/api/src/infrastructure/sqlserver/user-repository.ts"
import sql from 'mssql';

import type { CreateUser, User } from '@packages/schemas';
import { hashPassword } from '../../features/user/auth-utils';
import type { UserRepository } from '../../repositories/user-repository';
import { users } from './schema';

export class SqlServerUserRepository implements UserRepository {
    constructor(private readonly db: sql.ConnectionPool) {}

    async findById(id: number): Promise<User | null> {
        const result = await this.db.request().input('id', sql.UniqueIdentifier, id).query(`
                SELECT
                    ${users.id.select},
                    ${users.name.select},
                    ${users.email.select},
                    $(users.passwordHash.select),
                    ${users.role.select},
                    ${users.isActive.select},
                    $(users.createdAt.select())
                FROM ${users.tableName}
                WHERE ${users.id} = @id
            `);

        if (result.recordset.length === 0) {
            return null;
        }

        const row = result.recordset[0];

        return {
            id: row.id,
            name: row.name,
            email: row.email,
            passwordHash: row.passwordHash,
            role: row.role,
            isActive: row.isActive,
            createdAt: row.createdAt,
        };
    }

    async findByEmail(email: string): Promise<User | null> {
        const result = await this.db.request().input('email', sql.NVarChar(255), email).query(`
                SELECT
                    ${users.id.select},
                    ${users.name.select},
                    ${users.email.select},
                    $(users.passwordHash.select),
                    ${users.role.select},
                    ${users.isActive.select},
                    $(users.createdAt.select)
                FROM ${users.tableName}
                WHERE ${users.email} = @email
            `);

        if (result.recordset.length === 0) {
            return null;
        }

        const row = result.recordset[0];

        return {
            id: row.id,
            name: row.name,
            email: row.email,
            passwordHash: row.password_hash,
            role: row.role,
            isActive: row.isActive,
            createdAt: row.createdAt,
        };
    }

    findAll(): Promise<User[]> {
        throw new Error('Method not implemented.');
    }
    countAdmins(): Promise<number> {
        throw new Error('Method not implemented.');
    }

    async create(request: CreateUser): Promise<User> {
        const passwordHash = await hashPassword(request.password);
        const result = await this.db
            .request()
            .input('name', sql.NVarChar(255), request.name)
            .input('email', sql.NVarChar(255), request.email)
            .input('passwordHash', sql.NVarChar(255), passwordHash).query(`
                INSERT INTO ${users.tableName} (
                    ${users.name},
                    ${users.email},
                    ${users.passwordHash}
                )
                OUTPUT
                    ${users.id.inserted},
                    ${users.name.inserted},
                    ${users.email.inserted},
                    ${users.passwordHash.inserted}
                    ${users.role.inserted},
                    ${users.isActive.inserted},
                    ${users.createdAt.inserted}
                VALUES (
                    @name,
                    @email,
                    @passwordHash
                )
            `);

        const row = result.recordset[0];

        return {
            id: row.id,
            name: row.name,
            email: row.email,
            passwordHash: row.passwordHash,
            role: row.role,
            isActive: row.isActive,
            createdAt: row.createdAt,
        };
    }

    save(user: User): Promise<User> {
        throw new Error('Method not implemented.');
    }
    updatePassword(id: number, passwordHash: string): Promise<User> {
        throw new Error('Method not implemented.');
    }
    updateRole(id: number, role: string): Promise<User> {
        throw new Error('Method not implemented.');
    }
    updateActive(id: number, isActive: boolean): Promise<User> {
        throw new Error('Method not implemented.');
    }
    remove(id: number): Promise<void> {
        throw new Error('Method not implemented.');
    }
}

// import { eq } from 'drizzle-orm';

// import { type CreateUser, type User } from '@packages/schemas';
// import { hashPassword } from '../../features/user/auth-utils';
// import type { UserRepository } from '../../repositories/user-repository';
// import { createSqlServerDb } from './db';
// import { users } from './schema';

// export class SqlServerUserRepository implements UserRepository {
//     constructor(private readonly db: ReturnType<typeof createSqlServerDb>) {}

//     async findById(id: number): Promise<User | null> {
//         const result = await this.db.select().from(users).where(eq(users.id, id)).limit(1);

//         if (result.length === 0) {
//             return null;
//         }

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async findByEmail(email: string): Promise<User | null> {
//         const result = await this.db.select().from(users).where(eq(users.email, email)).limit(1);

//         if (result.length === 0) {
//             return null;
//         }

//         return result[0];
//     }

//     async findAll(): Promise<User[]> {
//         const result = await this.db.select().from(users);
//         return result;
//     }

//     async countAdmins(): Promise<number> {
//         const result = await this.db.select().from(users);
//         return result.length;
//     }

//     async create(request: CreateUser): Promise<User> {
//         const passwordHash = await hashPassword(request.password);
//         const result = await this.db
//             .insert(users)
//             .values({
//                 name: request.name,
//                 email: request.email,
//                 passwordHash: passwordHash,
//                 role: 'user',
//             })
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async save(user: User): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 name: user.name,
//                 email: user.email,
//                 role: user.role,
//                 isActive: user.isActive,
//             })
//             .where(eq(users.id, user.id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async updatePassword(id: number, passwordHash: string): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 passwordHash: passwordHash,
//             })
//             .where(eq(users.id, id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async updateRole(id: number, role: string): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 role: role,
//             })
//             .where(eq(users.id, id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async updateActive(id: number, isActive: boolean): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 isActive: isActive,
//             })
//             .where(eq(users.id, id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async remove(id: number): Promise<void> {
//         const result = await this.db.delete(users).where(eq(users.id, id)).returning();
//     }
// }
EOF_1791008798_8298

mkdir -p "apps/api/src/infrastructure/sqlserver"
echo "作成: apps/api/src/infrastructure/sqlserver/schema.ts"
cat << 'EOF_1791008798_29726' > "apps/api/src/infrastructure/sqlserver/schema.ts"
import { Column } from './db';

export const users = {
    tableName: 'users',

    id: new Column('id', 'id'),
    name: new Column('name', 'name'),
    email: new Column('email', 'email'),
    passwordHash: new Column('passwordHash', 'password_hash'),
    role: new Column('role', 'emroleail'),
    isActive: new Column('isActive', 'isActive'),
    createdAt: new Column('createdAt', 'created_at'),
} as const;
EOF_1791008798_29726

mkdir -p "apps/api/src/infrastructure/sqlserver"
echo "作成: apps/api/src/infrastructure/sqlserver/db.ts"
cat << 'EOF_1791008798_20668' > "apps/api/src/infrastructure/sqlserver/db.ts"
import sql from 'mssql';

export type SqlServerDb = sql.ConnectionPool;

export async function createSqlServerDb(connectionString: string): Promise<SqlServerDb> {
    const pool = new sql.ConnectionPool(connectionString);

    await pool.connect();

    return pool;
}

export class Column {
    constructor(
        public readonly property: string,
        public readonly columnName: string,
    ) {}

    get column(): string {
        return this.columnName;
    }

    get select(): string {
        return `${this.columnName} AS ${this.property}`;
    }
    get inserted(): string {
        return `inserted.${this.select}`;
    }
    get deleted(): string {
        return `deleted.${this.select}`;
    }

    toString(): string {
        return this.columnName;
    }
}
EOF_1791008798_20668

mkdir -p "apps/api/src/infrastructure/postgres"
echo "作成: apps/api/src/infrastructure/postgres/user-repository.ts"
cat << 'EOF_1791008798_25811' > "apps/api/src/infrastructure/postgres/user-repository.ts"
import { eq } from 'drizzle-orm';

import { type CreateUser, type User } from '@packages/schemas';
import { hashPassword } from '../../features/user/auth-utils';
import type { UserRepository } from '../../repositories/user-repository';
import { createPostgresDb } from './db';
import { users } from './schema';

export class PostgresUserRepository implements UserRepository {
    constructor(private readonly db: ReturnType<typeof createPostgresDb>) {}

    async findById(id: number): Promise<User | null> {
        const result = await this.db.select().from(users).where(eq(users.id, id)).limit(1);

        if (result.length === 0) {
            return null;
        }

        return {
            id: result[0].id,
            name: result[0].name,
            email: result[0].email,
            passwordHash: result[0].passwordHash,
            role: result[0].role,
            isActive: result[0].isActive,
            createdAt: result[0].createdAt,
        };
    }

    async findByEmail(email: string): Promise<User | null> {
        const result = await this.db.select().from(users).where(eq(users.email, email)).limit(1);

        if (result.length === 0) {
            return null;
        }

        return result[0];
    }

    async findAll(): Promise<User[]> {
        const result = await this.db.select().from(users);
        return result;
    }

    async countAdmins(): Promise<number> {
        const result = await this.db.select().from(users);
        return result.length;
    }

    async create(request: CreateUser): Promise<User> {
        const passwordHash = await hashPassword(request.password);
        const result = await this.db
            .insert(users)
            .values({
                name: request.name,
                email: request.email,
                passwordHash: passwordHash,
                role: 'user',
            })
            .returning();

        return {
            id: result[0].id,
            name: result[0].name,
            email: result[0].email,
            passwordHash: result[0].passwordHash,
            role: result[0].role,
            isActive: result[0].isActive,
            createdAt: result[0].createdAt,
        };
    }

    async save(user: User): Promise<User> {
        const result = await this.db
            .update(users)
            .set({
                name: user.name,
                email: user.email,
                role: user.role,
                isActive: user.isActive,
            })
            .where(eq(users.id, user.id))
            .returning();

        return {
            id: result[0].id,
            name: result[0].name,
            email: result[0].email,
            passwordHash: result[0].passwordHash,
            role: result[0].role,
            isActive: result[0].isActive,
            createdAt: result[0].createdAt,
        };
    }

    async updatePassword(id: number, passwordHash: string): Promise<User> {
        const result = await this.db
            .update(users)
            .set({
                passwordHash: passwordHash,
            })
            .where(eq(users.id, id))
            .returning();

        return {
            id: result[0].id,
            name: result[0].name,
            email: result[0].email,
            passwordHash: result[0].passwordHash,
            role: result[0].role,
            isActive: result[0].isActive,
            createdAt: result[0].createdAt,
        };
    }

    async updateRole(id: number, role: string): Promise<User> {
        const result = await this.db
            .update(users)
            .set({
                role: role,
            })
            .where(eq(users.id, id))
            .returning();

        return {
            id: result[0].id,
            name: result[0].name,
            email: result[0].email,
            passwordHash: result[0].passwordHash,
            role: result[0].role,
            isActive: result[0].isActive,
            createdAt: result[0].createdAt,
        };
    }

    async updateActive(id: number, isActive: boolean): Promise<User> {
        const result = await this.db
            .update(users)
            .set({
                isActive: isActive,
            })
            .where(eq(users.id, id))
            .returning();

        return {
            id: result[0].id,
            name: result[0].name,
            email: result[0].email,
            passwordHash: result[0].passwordHash,
            role: result[0].role,
            isActive: result[0].isActive,
            createdAt: result[0].createdAt,
        };
    }

    async remove(id: number): Promise<void> {
        const result = await this.db.delete(users).where(eq(users.id, id)).returning();
    }
}
EOF_1791008798_25811

mkdir -p "apps/api/src/infrastructure/postgres"
echo "作成: apps/api/src/infrastructure/postgres/schema.ts"
cat << 'EOF_1791008798_10594' > "apps/api/src/infrastructure/postgres/schema.ts"
import { boolean, pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';

export const users = pgTable('users', {
    id: serial('id').primaryKey(),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    passwordHash: text('password_hash').notNull(),
    role: text('role').notNull().default('user'),
    isActive: boolean('is_active').notNull().default(true),
    createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const UserSelectSchema = createSelectSchema(users);
export const UserInsertSchema = createInsertSchema(users);
EOF_1791008798_10594

mkdir -p "apps/api/src/infrastructure/postgres"
echo "作成: apps/api/src/infrastructure/postgres/db.ts"
cat << 'EOF_1791008798_11912' > "apps/api/src/infrastructure/postgres/db.ts"
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';

export function createPostgresDb(connectionString: string) {
    const pool = new Pool({
        connectionString,
    });

    return drizzle(pool);
}
EOF_1791008798_11912

mkdir -p "apps/api/src/features/user"
echo "作成: apps/api/src/features/user/auth-utils.ts"
cat << 'EOF_1791008798_262' > "apps/api/src/features/user/auth-utils.ts"
import bcrypt from 'bcrypt';

// ----------------------------------------------------
// 1. パスワードハッシュ化 & 照合処理
// ----------------------------------------------------

/**
 * 平文パスワードをハッシュ化します
 */
export async function hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
}

/**
 * 平文パスワードとハッシュ値を照合します
 */
export async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
}

// // ----------------------------------------------------
// // 2. JWT 発行 & 検証処理
// // ----------------------------------------------------

// import { SignJWT, jwtVerify } from 'jose';

// /**
//  * Payload を受け取り、署名済み JWT を生成します
//  */
// export async function signJwt(
//     payload: Record<string, unknown>,
//     secret: string,
//     expiresIn: string = '2h',
// ): Promise<string> {
//     const secretKey = new TextEncoder().encode(secret);

//     return await new SignJWT(payload)
//         .setProtectedHeader({ alg: 'HS256' })
//         .setIssuedAt()
//         .setExpirationTime(expiresIn)
//         .sign(secretKey);
// }

// /**
//  * JWT を検証し、デコードされた Payload を返します。
//  * 不正または改ざんされたトークンの場合は null を返します。
//  */
// export async function verifyJwt<T = Record<string, unknown>>(
//     token: string,
//     secret: string,
// ): Promise<T | null> {
//     try {
//         const secretKey = new TextEncoder().encode(secret);
//         const { payload } = await jwtVerify(token, secretKey);
//         return payload as T;
//     } catch {
//         // トークンが不正、改ざんされている、または有効期限切れの場合
//         return null;
//     }
// }
EOF_1791008798_262

mkdir -p "apps/api/src/features/user"
echo "作成: apps/api/src/features/user/service.ts"
cat << 'EOF_1791008798_17985' > "apps/api/src/features/user/service.ts"
import type { CreateUser, User } from '@packages/schemas';
import type { UserRepository } from '../../repositories/user-repository';

export class UserService {
    constructor(private readonly repository: UserRepository) {}

    async findById(id: number) {
        return this.repository.findById(id);
    }

    async findByEmail(email: string) {
        return this.repository.findByEmail(email);
    }

    async findAll() {
        return this.repository.findAll();
    }

    async create(user: CreateUser) {
        await this.repository.create(user);
    }

    async update(user: User) {
        await this.repository.save(user);
    }

    async changePassword(id: number, passwordHash: string) {
        await this.repository.updatePassword(id, passwordHash);
    }

    async changeRole(currentUserId: number, targetUserId: number, role: string) {
        if (currentUserId === targetUserId) {
            throw new Error('Cannot change your own role');
        }

        const target = await this.repository.findById(targetUserId);

        if (target?.role === 'admin' && role !== 'admin') {
            const adminCount = await this.repository.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot demote last admin');
            }
        }

        await this.repository.updateRole(targetUserId, role);
    }

    async changeActive(currentUserId: number, targetUserId: number, isActive: boolean) {
        if (currentUserId === targetUserId) {
            throw new Error('Cannot disable yourself');
        }

        const target = await this.repository.findById(targetUserId);

        if (target?.role === 'admin' && !isActive) {
            const adminCount = await this.repository.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot disable last admin');
            }
        }

        await this.repository.updateActive(targetUserId, isActive);
    }

    async delete(currentUserId: number, targetUserId?: number) {
        const id = targetUserId ?? currentUserId;

        if (currentUserId === id) {
            throw new Error('Cannot delete yourself');
        }

        const target = await this.repository.findById(id);

        if (target?.role === 'admin') {
            const adminCount = await this.repository.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot delete last admin');
            }
        }

        await this.repository.remove(id);
    }
}
EOF_1791008798_17985

mkdir -p "apps/api/src/features/user"
echo "作成: apps/api/src/features/user/controller.ts"
cat << 'EOF_1791008798_2108' > "apps/api/src/features/user/controller.ts"
import { CreateUserSchema, UserDetailSchema } from '@packages/schemas';
import { Hono } from 'hono';
import { AppVariables } from '../authentication/AppVariables';
import { authorize } from '../authentication/middleware/authorize';
import { hashPassword } from './auth-utils';
import type { UserService } from './service';

export function createUserController(userService: UserService) {
    const router = new Hono<{
        Variables: AppVariables;
    }>();

    router.get('/me', authorize('admin', 'user'), async (c) => {
        const principal = c.get('principal');

        const user = await userService.findById(Number(principal.userId));
        if (!user) {
            return c.notFound();
        }

        return c.json(UserDetailSchema.parse(user));
    });

    router.put('/me', authorize('admin', 'user'), async (c) => {
        const principal = c.get('principal');

        const current = await userService.findById(Number(principal.userId));
        if (!current) {
            return c.notFound();
        }

        const body = await c.req.json();

        const user = {
            id: current.id,
            name: body.name,
            email: body.email,
            passwordHash: current.passwordHash,
            role: current.role,
            isActive: current.isActive,
            createdAt: current.createdAt,
        };

        await userService.update(user);

        return c.json({
            message: 'updated',
        });
    });

    router.put('/me/password', authorize('admin', 'user'), async (c) => {
        const principal = c.get('principal');
        const body = await c.req.json();

        const passwordHash = await hashPassword(body.password);

        await userService.changePassword(Number(principal.userId), passwordHash);

        return c.json({
            message: 'password updated',
        });
    });

    router.get('/:id', async (c) => {
        const id = Number(c.req.param('id'));
        if (Number.isNaN(id)) {
            return c.json(
                {
                    message: 'invalid id',
                },
                400,
            );
        }
        const user = await userService.findById(id);
        if (!user) {
            return c.json({ message: 'user not found' }, 404);
        }

        return c.json(UserDetailSchema.parse(user));
    });

    router.post('/', async (c) => {
        const body = await c.req.json();
        const request = CreateUserSchema.parse(body);

        const user = await userService.create(request);

        return c.json(UserDetailSchema.parse(user), 201);
    });

    return router;
}
EOF_1791008798_2108

mkdir -p "apps/api/src/features/administration/mappers"
echo "作成: apps/api/src/features/administration/mappers/ConfigurationMapper.ts"
cat << 'EOF_1791008798_29263' > "apps/api/src/features/administration/mappers/ConfigurationMapper.ts"
import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';
import { ConfigurationDto } from '@packages/types/administration/ConfigurationDto';
import { Configuration } from '../domain/Configuration';

export class ConfigurationMapper {
    static toDto(configuration: Configuration): ConfigurationDto {
        const authenticationPolicy: AuthenticationPolicy = {
            session: {
                reloadBehavior: 'keep-session',
                idleTimeoutMinutes: 30,
                absoluteTimeoutMinutes: 480,
            },

            token: {
                accessTokenLifetimeMinutes: 60,
                autoRefreshEnabled: true,
                refreshThresholdMinutes: 5,
            },

            deepLink: {
                enabled: true,
                afterLogin: 'restore',
            },

            reAuthentication: {
                enabled: true,
                validMinutes: 15,
                requireForSystemSettings: true,
                requireForUserDelete: true,
                requireForRoleChange: true,
            },

            navigation: {
                loginPageWhileAuthenticated: 'back',
                forbiddenPage: 'back',
                notFoundPage: '404',
            },

            expiredToken: {
                behavior: 're-authenticate',
                afterRecovery: 'restore',
            },
        };

        return {
            authenticationPolicy: authenticationPolicy,
        };
    }
}
EOF_1791008798_29263

mkdir -p "apps/api/src/features/administration"
echo "作成: apps/api/src/features/administration/routes.ts"
cat << 'EOF_1791008798_3909' > "apps/api/src/features/administration/routes.ts"
export { createConfigurationController } from './controllers/ConfigurationController';
EOF_1791008798_3909

mkdir -p "apps/api/src/features/administration/controllers"
echo "作成: apps/api/src/features/administration/controllers/AdminUserController.ts"
cat << 'EOF_1791008798_10313' > "apps/api/src/features/administration/controllers/AdminUserController.ts"
import { Hono } from 'hono';

export const adminUserRouter = new Hono();
EOF_1791008798_10313

mkdir -p "apps/api/src/features/administration/controllers"
echo "作成: apps/api/src/features/administration/controllers/SystemStatusController.ts"
cat << 'EOF_1791008798_24155' > "apps/api/src/features/administration/controllers/SystemStatusController.ts"
import { Hono } from 'hono';

export const systemStatusRouter = new Hono();
EOF_1791008798_24155

mkdir -p "apps/api/src/features/administration/controllers"
echo "作成: apps/api/src/features/administration/controllers/ConfigurationController.ts"
cat << 'EOF_1791008798_22197' > "apps/api/src/features/administration/controllers/ConfigurationController.ts"
import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';
import { defaultAuthenticationPolicy } from '@packages/types/administration/defaultAuthenticationPolicy';
import { Hono } from 'hono';
import { ConfigurationService } from '../services/ConfigurationService';

const configuration = {
    authenticationPolicy: defaultAuthenticationPolicy,
};

export function createConfigurationController(service: ConfigurationService) {
    const router = new Hono();

    router.get('/configuration', (c) => {
        return c.json(configuration);
    });

    router.put('/configuration', async (c) => {
        const body = await c.req.json();

        configuration.authenticationPolicy = body.authenticationPolicy as AuthenticationPolicy;

        return c.json(configuration);
    });

    return router;
}
EOF_1791008798_22197

mkdir -p "apps/api/src/features/administration/controllers"
echo "作成: apps/api/src/features/administration/controllers/FeatureFlagController.ts"
cat << 'EOF_1791008798_22612' > "apps/api/src/features/administration/controllers/FeatureFlagController.ts"
import { Hono } from 'hono';

export const featureFlagRouter = new Hono();
EOF_1791008798_22612

mkdir -p "apps/api/src/features/administration/services"
echo "作成: apps/api/src/features/administration/services/ConfigurationService.ts"
cat << 'EOF_1791008798_17310' > "apps/api/src/features/administration/services/ConfigurationService.ts"
import { ConfigurationRepository } from '../repositories/ConfigurationRepository';

export class ConfigurationService {
    constructor(private readonly repository: ConfigurationRepository) {}
}
EOF_1791008798_17310

mkdir -p "apps/api/src/features/administration/services"
echo "作成: apps/api/src/features/administration/services/AdminUserService.ts"
cat << 'EOF_1791008798_10373' > "apps/api/src/features/administration/services/AdminUserService.ts"
import { AdminUserRepository } from '../repositories/AdminUserRepository';

export class AdminUserService {
    constructor(private readonly repository: AdminUserRepository) {}
}
EOF_1791008798_10373

mkdir -p "apps/api/src/features/administration/services"
echo "作成: apps/api/src/features/administration/services/SystemStatusService.ts"
cat << 'EOF_1791008798_22466' > "apps/api/src/features/administration/services/SystemStatusService.ts"
export class SystemStatusService {}
EOF_1791008798_22466

mkdir -p "apps/api/src/features/administration/services"
echo "作成: apps/api/src/features/administration/services/FeatureFlagService.ts"
cat << 'EOF_1791008798_17693' > "apps/api/src/features/administration/services/FeatureFlagService.ts"
import { FeatureFlagRepository } from '../repositories/FeatureFlagRepository';

export class FeatureFlagService {
    constructor(private readonly repository: FeatureFlagRepository) {}
}
EOF_1791008798_17693

mkdir -p "apps/api/src/features/administration/domain"
echo "作成: apps/api/src/features/administration/domain/SystemStatus.ts"
cat << 'EOF_1791008798_29159' > "apps/api/src/features/administration/domain/SystemStatus.ts"
export interface SystemStatus {
    version: string;

    uptime: number;
}
EOF_1791008798_29159

mkdir -p "apps/api/src/features/administration/domain"
echo "作成: apps/api/src/features/administration/domain/SystemConfiguration.ts"
cat << 'EOF_1791008798_3246' > "apps/api/src/features/administration/domain/SystemConfiguration.ts"
export interface SystemConfiguration {
    databaseType: 'memory' | 'postgres' | 'sqlserver';
    authenticationType: 'none' | 'local' | 'oidc' | 'ldap';
    frontendType: 'react' | 'vue';
}
EOF_1791008798_3246

mkdir -p "apps/api/src/features/administration/domain"
echo "作成: apps/api/src/features/administration/domain/AdminUser.ts"
cat << 'EOF_1791008798_1512' > "apps/api/src/features/administration/domain/AdminUser.ts"
export interface AdminUser {
    userName: string;
}
EOF_1791008798_1512

mkdir -p "apps/api/src/features/administration/domain"
echo "作成: apps/api/src/features/administration/domain/FeatureFlag.ts"
cat << 'EOF_1791008798_3843' > "apps/api/src/features/administration/domain/FeatureFlag.ts"
export interface FeatureFlag {
    name: string;

    enabled: boolean;
}
EOF_1791008798_3843

mkdir -p "apps/api/src/features/administration/domain"
echo "作成: apps/api/src/features/administration/domain/Configuration.ts"
cat << 'EOF_1791008798_16279' > "apps/api/src/features/administration/domain/Configuration.ts"
export interface Configuration {
    databaseType: 'memory' | 'postgres' | 'sqlserver';
    authenticationType: 'none' | 'local' | 'oidc' | 'ldap';
    frontendType: 'react' | 'vue';
}
EOF_1791008798_16279

mkdir -p "apps/api/src/features/administration/authentication"
echo "作成: apps/api/src/features/administration/authentication/LocalAdminAuthenticationProvider.ts"
cat << 'EOF_1791008798_20537' > "apps/api/src/features/administration/authentication/LocalAdminAuthenticationProvider.ts"
import { AdminAuthenticationProvider } from './AdminAuthenticationProvider';

export class LocalAdminAuthenticationProvider implements AdminAuthenticationProvider {
    async authenticate() {
        return true;
    }
}
EOF_1791008798_20537

mkdir -p "apps/api/src/features/administration/authentication"
echo "作成: apps/api/src/features/administration/authentication/AdminAuthenticationProvider.ts"
cat << 'EOF_1791008798_6117' > "apps/api/src/features/administration/authentication/AdminAuthenticationProvider.ts"
export interface AdminAuthenticationProvider {
    authenticate(email: string, password: string): Promise<boolean>;
}
EOF_1791008798_6117

mkdir -p "apps/api/src/features/administration/repositories"
echo "作成: apps/api/src/features/administration/repositories/AdminUserRepository.ts"
cat << 'EOF_1791008798_17207' > "apps/api/src/features/administration/repositories/AdminUserRepository.ts"
import { AdminUser } from '../domain/AdminUser';

export interface AdminUserRepository {
    findAll(): Promise<AdminUser[]>;
}
EOF_1791008798_17207

mkdir -p "apps/api/src/features/administration/repositories"
echo "作成: apps/api/src/features/administration/repositories/FeatureFlagRepository.ts"
cat << 'EOF_1791008798_19762' > "apps/api/src/features/administration/repositories/FeatureFlagRepository.ts"
import { FeatureFlag } from '../domain/FeatureFlag';

export interface FeatureFlagRepository {
    findAll(): Promise<FeatureFlag[]>;

    save(feature: FeatureFlag): Promise<void>;
}
EOF_1791008798_19762

mkdir -p "apps/api/src/features/administration/repositories"
echo "作成: apps/api/src/features/administration/repositories/ConfigurationRepository.ts"
cat << 'EOF_1791008798_20808' > "apps/api/src/features/administration/repositories/ConfigurationRepository.ts"
import { Configuration } from '../domain/Configuration';

export interface ConfigurationRepository {
    load(): Promise<Configuration>;

    save(configuration: Configuration): Promise<void>;
}
EOF_1791008798_20808

mkdir -p "apps/api/src/features/authentication/middleware"
echo "作成: apps/api/src/features/authentication/middleware/authorizeSelfOrAdmin.ts"
cat << 'EOF_1791008798_12137' > "apps/api/src/features/authentication/middleware/authorizeSelfOrAdmin.ts"
import { Context, Next } from 'hono';

export function authorizeSelfOrAdmin() {
    return async (c: Context, next: Next) => {
        const principal = c.get('principal');

        if (!principal) {
            return c.json({ message: 'Unauthorized' }, 401);
        }

        if (principal.role === 'admin') {
            await next();
            return;
        }

        const id = c.req.param('id');
        if (principal.userId !== id) {
            return c.json({ message: 'Forbidden' }, 403);
        }

        await next();
    };
}
EOF_1791008798_12137

mkdir -p "apps/api/src/features/authentication/middleware"
echo "作成: apps/api/src/features/authentication/middleware/jwtAuthentication.ts"
cat << 'EOF_1791008798_9669' > "apps/api/src/features/authentication/middleware/jwtAuthentication.ts"
import { Context, Next } from 'hono';
import { JwtService } from '../services/JwtService';

export function jwtAuthentication(jwtService: JwtService) {
    return async (c: Context, next: Next) => {
        const authorization = c.req.header('Authorization');

        if (!authorization || !authorization.startsWith('Bearer ')) {
            return c.json({ message: 'Unauthorized' }, 401);
        }

        try {
            const token = authorization.substring(7);
            const principal = jwtService.verify(token);

            c.set('principal', principal);

            await next();
        } catch {
            return c.json({ message: 'Unauthorized' }, 401);
        }
    };
}
EOF_1791008798_9669

mkdir -p "apps/api/src/features/authentication/middleware"
echo "作成: apps/api/src/features/authentication/middleware/authorize.ts"
cat << 'EOF_1791008798_24739' > "apps/api/src/features/authentication/middleware/authorize.ts"
import { Context, Next } from 'hono';

export function authorize(...roles: string[]) {
    return async (c: Context, next: Next) => {
        const principal = c.get('principal');

        if (!principal) {
            return c.json({ message: 'Unauthorized' }, 401);
        }

        if (!roles.includes(principal.role)) {
            return c.json({ message: 'Forbidden' }, 403);
        }

        await next();
    };
}
EOF_1791008798_24739

mkdir -p "apps/api/src/features/authentication"
echo "作成: apps/api/src/features/authentication/routes.ts"
cat << 'EOF_1791008798_16975' > "apps/api/src/features/authentication/routes.ts"
export { createAuthenticationController } from './controllers/AuthenticationController';
EOF_1791008798_16975

mkdir -p "apps/api/src/features/authentication"
echo "作成: apps/api/src/features/authentication/AuthenticationCredential.ts"
cat << 'EOF_1791008798_1280' > "apps/api/src/features/authentication/AuthenticationCredential.ts"
export interface AuthenticationCredential {
    username: string;
    password: string;
}
EOF_1791008798_1280

mkdir -p "apps/api/src/features/authentication/controllers"
echo "作成: apps/api/src/features/authentication/controllers/AuthenticationController.ts"
cat << 'EOF_1791008798_17624' > "apps/api/src/features/authentication/controllers/AuthenticationController.ts"
import { LoginRequest } from '@packages/types/authentication/LoginRequest';
import { Hono } from 'hono';
import { AuthenticationService } from '../services/AuthenticationService';

export function createAuthenticationController(service: AuthenticationService) {
    const router = new Hono();

    router.post('/auth/login', async (c) => {
        const body = await c.req.json<LoginRequest>();

        const result = await service.login(body.email, body.password);

        if (!result) {
            return c.json({ message: 'Invalid credentials' }, 401);
        }

        return c.json(result);
    });

    return router;
}
EOF_1791008798_17624

mkdir -p "apps/api/src/features/authentication/services"
echo "作成: apps/api/src/features/authentication/services/JwtService.ts"
cat << 'EOF_1791008798_24153' > "apps/api/src/features/authentication/services/JwtService.ts"
import jwt from 'jsonwebtoken';
import { AppJwtPayload } from '../AppJwtPayload';
import { UserPrincipal } from '../domain/UserPrincipal';

function isAppJwtPayload(value: unknown): value is AppJwtPayload {
    if (typeof value !== 'object' || value === null) {
        return false;
    }

    const payload = value as Record<string, unknown>;

    return (
        typeof payload.sub === 'string' &&
        typeof payload.email === 'string' &&
        typeof payload.role === 'string'
    );
}

export class JwtService {
    expiresInSeconds = 3600;

    constructor(private readonly secret: string) {}

    createAccessToken(principal: UserPrincipal): string {
        return jwt.sign(
            {
                sub: principal.userId,
                email: principal.email,
                role: principal.role,
            },
            this.secret,
            {
                expiresIn: `${this.expiresInSeconds}SECONDS`,
            },
        );
    }

    verify(token: string): UserPrincipal {
        const payload = jwt.verify(token, this.secret);

        if (!isAppJwtPayload(payload)) {
            throw new Error('Invalid JWT payload.');
        }

        return {
            userId: payload.sub,
            email: payload.email,
            role: payload.role,
        };
    }
}
EOF_1791008798_24153

mkdir -p "apps/api/src/features/authentication/services"
echo "作成: apps/api/src/features/authentication/services/AuthenticationService.ts"
cat << 'EOF_1791008798_11479' > "apps/api/src/features/authentication/services/AuthenticationService.ts"
import { AuthenticationProvider } from '../providers/AuthenticationProvider';
import { JwtService } from './JwtService';

export class AuthenticationService {
    constructor(
        private readonly provider: AuthenticationProvider,
        private readonly jwtService: JwtService,
    ) {}

    async login(username: string, password: string) {
        const principal = await this.provider.authenticate(username, password);

        if (!principal) {
            console.log(`AuthenticationService:`);
            console.log(`  username:${username}`);
            console.log(`  password:${password}`);
            console.log(`  provider:${this.provider !== null}`);
            return undefined;
        }

        const accessToken = this.jwtService.createAccessToken(principal);
        const expiresIn = this.jwtService.expiresInSeconds;
        return {
            accessToken: accessToken,
            expiresIn: expiresIn,
        };
    }
}
EOF_1791008798_11479

mkdir -p "apps/api/src/features/authentication/domain"
echo "作成: apps/api/src/features/authentication/domain/SystemConfiguration.ts"
cat << 'EOF_1791008798_31344' > "apps/api/src/features/authentication/domain/SystemConfiguration.ts"
import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';

export interface SystemConfiguration {
    databaseType: 'memory' | 'postgres' | 'sqlserver';
    authenticationType: 'none' | 'local' | 'oidc' | 'ldap';
    frontendType: 'react' | 'vue';
    authenticationPolicy: AuthenticationPolicy;
}
EOF_1791008798_31344

mkdir -p "apps/api/src/features/authentication/domain"
echo "作成: apps/api/src/features/authentication/domain/UserPrincipal.ts"
cat << 'EOF_1791008798_20354' > "apps/api/src/features/authentication/domain/UserPrincipal.ts"
export interface UserPrincipal {
    userId: string;
    email: string;
    role: string;
}
EOF_1791008798_20354

mkdir -p "apps/api/src/features/authentication"
echo "作成: apps/api/src/features/authentication/AppVariables.ts"
cat << 'EOF_1791008798_18348' > "apps/api/src/features/authentication/AppVariables.ts"
import { UserPrincipal } from './domain/UserPrincipal';

export interface AppVariables {
    principal: UserPrincipal;
}
EOF_1791008798_18348

mkdir -p "apps/api/src/features/authentication"
echo "作成: apps/api/src/features/authentication/AppJwtPayload.ts"
cat << 'EOF_1791008798_2360' > "apps/api/src/features/authentication/AppJwtPayload.ts"
export interface AppJwtPayload {
    /**
     * UserPrincipal.userId
     */
    sub: string;

    /**
     * UserPrincipal.email
     */
    email: string;

    /**
     * UserPrincipal.role
     */
    role: string;

    /**
     * issued at
     */
    iat?: number;

    /**
     * expiration time
     */
    exp?: number;
}

// export interface AppJwtPayload {
//     sub: number;
//     email: string;
//     role: string;
//     iat?: number;
//     exp?: number;
// }
EOF_1791008798_2360

mkdir -p "apps/api/src/features/authentication/providers"
echo "作成: apps/api/src/features/authentication/providers/createAuthenticationProvider.ts"
cat << 'EOF_1791008798_29466' > "apps/api/src/features/authentication/providers/createAuthenticationProvider.ts"
import { AuthenticationConfig } from '@apps/api/systemConfig/SystemConfig';
import { UserService } from '../../user/service';
import { AuthenticationProvider } from './AuthenticationProvider';
import { LdapAuthenticationProvider } from './LdapAuthenticationProvider';
import { LocalAuthenticationProvider } from './LocalAuthenticationProvider';
import { NoAuthenticationProvider } from './NoAuthenticationProvider';
import { OidcAuthenticationProvider } from './OidcAuthenticationProvider';

export function createAuthenticationProvider(
    config: AuthenticationConfig,
    services: {
        userService: UserService;
    },
): AuthenticationProvider {
    switch (config.type) {
        case 'local':
            return new LocalAuthenticationProvider(services.userService);

        case 'ldap':
            return new LdapAuthenticationProvider();

        case 'oidc':
            return new OidcAuthenticationProvider();

        case 'none':
            return new NoAuthenticationProvider();

        default:
            throw new Error(`Unsupported authentication type: ${config.type}`);
    }
}
EOF_1791008798_29466

mkdir -p "apps/api/src/features/authentication/providers"
echo "作成: apps/api/src/features/authentication/providers/LdapAuthenticationProvider.ts"
cat << 'EOF_1791008798_6662' > "apps/api/src/features/authentication/providers/LdapAuthenticationProvider.ts"
import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class LdapAuthenticationProvider implements AuthenticationProvider {
    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        throw new Error('LDAP authentication not implemented.');
    }
}
EOF_1791008798_6662

mkdir -p "apps/api/src/features/authentication/providers"
echo "作成: apps/api/src/features/authentication/providers/LocalAuthenticationProvider.ts"
cat << 'EOF_1791008798_28891' > "apps/api/src/features/authentication/providers/LocalAuthenticationProvider.ts"
import bcrypt from 'bcrypt';

import { UserService } from '../../user/service';
import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class LocalAuthenticationProvider implements AuthenticationProvider {
    constructor(private readonly userService: UserService) {}

    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        const user = await this.userService.findByEmail(username);

        if (!user) {
            console.log(`LocalAuthenticationProvider.authenticate:`);
            console.log(`  userService:${this.userService.findByEmail !== null}`);
            console.log(`  username:${username}`);
            console.log(`  password:${password}`);
            return null;
        }

        if (!user.isActive) {
            return null;
        }

        const matched = await bcrypt.compare(password, user.passwordHash);

        if (!matched) {
            return null;
        }

        return {
            userId: String(user.id),
            email: user.email,
            role: user.role,
        };
    }
}
EOF_1791008798_28891

mkdir -p "apps/api/src/features/authentication/providers"
echo "作成: apps/api/src/features/authentication/providers/OidcAuthenticationProvider.ts"
cat << 'EOF_1791008798_3602' > "apps/api/src/features/authentication/providers/OidcAuthenticationProvider.ts"
import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class OidcAuthenticationProvider implements AuthenticationProvider {
    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        throw new Error('OIDC authentication not implemented.');
    }
}
EOF_1791008798_3602

mkdir -p "apps/api/src/features/authentication/providers"
echo "作成: apps/api/src/features/authentication/providers/AuthenticationProvider.ts"
cat << 'EOF_1791008798_21224' > "apps/api/src/features/authentication/providers/AuthenticationProvider.ts"
import { UserPrincipal } from '../domain/UserPrincipal';

export interface AuthenticationProvider {
    authenticate(username: string, password: string): Promise<UserPrincipal | null>;
}
EOF_1791008798_21224

mkdir -p "apps/api/src/features/authentication/providers"
echo "作成: apps/api/src/features/authentication/providers/NoAuthenticationProvider.ts"
cat << 'EOF_1791008798_24731' > "apps/api/src/features/authentication/providers/NoAuthenticationProvider.ts"
import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class NoAuthenticationProvider implements AuthenticationProvider {
    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        return {
            userId: 'system',
            email: 'system@localhost',
            role: 'admin',
        };
    }
}
EOF_1791008798_24731

mkdir -p "apps/api/src"
echo "作成: apps/api/src/main.ts"
cat << 'EOF_1791008798_28997' > "apps/api/src/main.ts"
import { serve } from '@hono/node-server';
import { createApp } from './app/createApp';
import { createDependencyContainer } from './app/createDependencyContainer';
import { loadSystemConfig } from './systemConfig/loadSystemConfig';

import path, { dirname, join } from 'path';
import { fileURLToPath } from 'url';

// 現在のファイルのパスを取得
const __filename: string = fileURLToPath(import.meta.url);
// 現在のファイルが存在するディレクトリのパスを取得
const __dirname: string = dirname(__filename);
// このアプリケーションのRoot
const __root: string = path.resolve(__dirname, '../../../');

// ディレクトリ内にある設定ファイルを読み込む例
const configPath: string = join(__root, 'config/development.json');

const config = await loadSystemConfig(configPath);

const dependencyContainer = await createDependencyContainer(config);
const app = createApp(dependencyContainer);
const port = Number(config.backend.port);

serve({
    fetch: app.fetch,
    port: port,
});

console.log(`Listening on :${port}`);
EOF_1791008798_28997

mkdir -p "apps/api/src/common"
echo "作成: apps/api/src/common/cors.ts"
cat << 'EOF_1791008798_3275' > "apps/api/src/common/cors.ts"
import { cors as honoCors } from 'hono/cors';
import { SystemConfig } from '../systemConfig/SystemConfig';

function cors(systemConfig: SystemConfig) {
    /*
     * CORS ミドルウェア・ハンドラー
     *
     * これも Hono にビルトインされているものを使う
     */
    return honoCors({
        origin: (origin) => {
            try {
                const url = new URL(origin);
                // ホスト名（ポート番号を除いた部分）が一致しているかチェック
                if (url.hostname === systemConfig.frontend.host) {
                    return origin; // マッチしたらリクエストのoriginをそのまま返して許可
                }
            } catch (e) {
                // origin が無効なURL、または存在しない場合は許可しない
            }
            // マッチしない場合は、デフォルトのオリジンを返すか、許可しない
            return 'http://' + 'localhost';
        },

        allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
        allowHeaders: ['Accept', 'Content-Type', 'Authorization'],
        exposeHeaders: [],
        credentials: false,
        maxAge: 0,
    });
}

export default cors;
EOF_1791008798_3275

mkdir -p "apps/api/src/common/middleware"
echo "作成: apps/api/src/common/middleware/authorization.ts"
cat << 'EOF_1791008798_6147' > "apps/api/src/common/middleware/authorization.ts"
export function authorization() {}
EOF_1791008798_6147

mkdir -p "apps/api/src/common/middleware"
echo "作成: apps/api/src/common/middleware/featureGuard.ts"
cat << 'EOF_1791008798_15999' > "apps/api/src/common/middleware/featureGuard.ts"
export function featureGuard() {}
EOF_1791008798_15999

mkdir -p "apps/api/src/common/middleware"
echo "作成: apps/api/src/common/middleware/authentication.ts"
cat << 'EOF_1791008798_13957' > "apps/api/src/common/middleware/authentication.ts"
export function authentication() {}
EOF_1791008798_13957

mkdir -p "apps/api/src/common/middleware"
echo "作成: apps/api/src/common/middleware/errorHandler.ts"
cat << 'EOF_1791008798_10883' > "apps/api/src/common/middleware/errorHandler.ts"
export function errorHandler() {}
EOF_1791008798_10883

mkdir -p "apps/api/src/common"
echo "作成: apps/api/src/common/csrf.ts"
cat << 'EOF_1791008798_8528' > "apps/api/src/common/csrf.ts"
import { csrf as honoCsrf } from 'hono/csrf';
import { SystemConfig } from '../systemConfig/SystemConfig';

function csrf(systemConfig: SystemConfig) {
    /*
     * csrf ミドルウェア・ハンドラー
     *
     * これも Hono にビルトインされているものを使う
     */
    return honoCsrf({
        origin: (origin, c) => {
            try {
                const url = new URL(origin);
                // CORSのときと同様に、ホスト名が一致していればCSRF的にも安全とみなして許可する
                return url.hostname === systemConfig.frontend.host;
            } catch {
                return false;
            }
        },
    });
}

export default csrf;
EOF_1791008798_8528

mkdir -p "apps/api/src/common"
echo "作成: apps/api/src/common/error.ts"
cat << 'EOF_1791008798_32545' > "apps/api/src/common/error.ts"
import type { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { JwtTokenInvalid } from 'hono/utils/jwt/types';
import { customLogger } from './logger.js';

const error = (e: Error, c: Context) => {
    if (e instanceof HTTPException) {
        if (e.status === 400) {
            return c.json({ message: e.message }, e.status);
        }
        if (e.status === 401) {
            //   if (e.cause) customLogger(`${e.cause}`);
            if (e.cause) console.log(`${e.cause}`);
            return c.json({ message: 'unauthorized' }, e.status);
        }
        if (e.status === 403) {
            return c.json({ message: 'forbidden' }, e.status);
        }
        if (e.status === 404) {
            return c.json({ message: 'not found' }, e.status);
        }
        if (e.status === 422) {
            return c.json({ message: e.cause }, e.status);
        }
    }

    if (e instanceof JwtTokenInvalid) {
        customLogger(e.message);
        return c.json({ message: 'invalid token' }, 400);
    }

    return c.json({ message: e.message }, 500);
};

export default error;
EOF_1791008798_32545

mkdir -p "apps/api/src/common"
echo "作成: apps/api/src/common/logger.ts"
cat << 'EOF_1791008798_30702' > "apps/api/src/common/logger.ts"
import { logger as honoLogger } from 'hono/logger';

/*
 * 簡易的なロガー
 *
 * HTTP のステータスコードや
 * エラーログなどが追いやすくなるのであると助かる
 */
export const customLogger = (message: string, ...rest: Array<string>) => {
    console.log(message, ...rest);
    //  if (env.LOG_LEVEL === "debug") {
    //     console.log(message, ...rest);
    //   }
};

const logger = honoLogger(customLogger);

export default logger;
EOF_1791008798_30702

mkdir -p "apps/api/src/common/repositories"
echo "作成: apps/api/src/common/repositories/BaseRepository.ts"
cat << 'EOF_1791008798_23294' > "apps/api/src/common/repositories/BaseRepository.ts"
export abstract class BaseRepository<TEntity> {}
EOF_1791008798_23294

mkdir -p "apps/api/src/common/repositories"
echo "作成: apps/api/src/common/repositories/Repository.ts"
cat << 'EOF_1791008798_28437' > "apps/api/src/common/repositories/Repository.ts"
export interface Repository<TEntity> {}
EOF_1791008798_28437

mkdir -p "apps/api/src/drizzle"
echo "作成: apps/api/src/drizzle/index.ts"
cat << 'EOF_1791008798_15546' > "apps/api/src/drizzle/index.ts"
export * from './db';
export * from './schema';
EOF_1791008798_15546

mkdir -p "apps/api/src/drizzle"
echo "作成: apps/api/src/drizzle/schema.ts"
cat << 'EOF_1791008798_1645' > "apps/api/src/drizzle/schema.ts"
export const tables = {
    users: 'users',
};
EOF_1791008798_1645

mkdir -p "apps/api/src/drizzle"
echo "作成: apps/api/src/drizzle/db.ts"
cat << 'EOF_1791008798_24005' > "apps/api/src/drizzle/db.ts"
export interface DrizzleConnection {}
EOF_1791008798_24005

mkdir -p "apps/api/src/systemConfig"
echo "作成: apps/api/src/systemConfig/saveSystemConfig.ts"
cat << 'EOF_1791008798_27738' > "apps/api/src/systemConfig/saveSystemConfig.ts"
export async function saveSystemConfig() {
    throw new Error('Not implemented.');
}
EOF_1791008798_27738

mkdir -p "apps/api/src/systemConfig"
echo "作成: apps/api/src/systemConfig/loadSystemConfig.ts"
cat << 'EOF_1791008798_6604' > "apps/api/src/systemConfig/loadSystemConfig.ts"
import { readFile } from 'node:fs/promises';
import { SystemConfig } from './SystemConfig';

export async function loadSystemConfig(path: string): Promise<SystemConfig> {
    const json = await readFile(path, 'utf8');
    const systemConfig = JSON.parse(json) as SystemConfig;

    if (systemConfig.backend.applicationRoot == undefined) {
        systemConfig.backend.applicationRoot = '/api';
    }
    if (systemConfig.backend.host == undefined) {
        systemConfig.backend.host = 'localhost';
    }
    if (systemConfig.backend.port == undefined) {
        systemConfig.backend.port = '3000';
    }
    if (systemConfig.backend.protocol == undefined) {
        systemConfig.backend.protocol = 'http';
    }

    if (systemConfig.authentication.secret == undefined) {
        systemConfig.authentication.secret = 'change-this-secret';
    }

    if (systemConfig.frontend.host == undefined) {
        systemConfig.frontend.host = 'localhost';
    }

    return systemConfig;
}
EOF_1791008798_6604

mkdir -p "apps/api/src/systemConfig"
echo "作成: apps/api/src/systemConfig/SystemConfig.ts"
cat << 'EOF_1791008798_12898' > "apps/api/src/systemConfig/SystemConfig.ts"
export interface BackendConfig {
    protocol?: string; //"http";
    host?: string; //"localhost";
    port?: string; //3000;
    applicationRoot?: string; //"/api";
}

export interface DatabaseConfig {
    type: 'memory' | 'postgres' | 'sqlserver';
    connectionString?: string;
}

export interface AuthenticationConfig {
    type: 'none' | 'local' | 'oidc' | 'ldap';
    secret?: string;
}

export interface FrontendConfig {
    type: 'react' | 'vue';
    host?: string; //"localhost";
}

export interface SystemConfig {
    backend: BackendConfig;
    database: DatabaseConfig;
    authentication: AuthenticationConfig;
    frontend: FrontendConfig;
}
EOF_1791008798_12898

mkdir -p "apps/api/src/repositories"
echo "作成: apps/api/src/repositories/user-repository.ts"
cat << 'EOF_1791008798_23340' > "apps/api/src/repositories/user-repository.ts"
import type { CreateUser, User } from '@packages/schemas';

export interface UserRepository {
    findById(id: number): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    findAll(): Promise<User[]>;
    countAdmins(): Promise<number>;

    create(user: CreateUser): Promise<User>;
    save(user: User): Promise<User>;

    updatePassword(id: number, passwordHash: string): Promise<User>;
    updateRole(id: number, role: string): Promise<User>;
    updateActive(id: number, isActive: boolean): Promise<User>;
    remove(id: number): Promise<void>;
}
EOF_1791008798_23340

echo "作成: チャット1.txt"
cat << 'EOF_1791008798_526' > "チャット1.txt"
Phase 1 現状把握

TASK-001 設定一覧作成
TASK-002 database.type 利用状況確認
TASK-003 authentication.type 利用状況確認
TASK-004 frontend.type 利用状況確認
TASK-005 administration.enabled 利用状況確認
TASK-006 features.user 利用状況確認




TypeScriptモノレポのWebアプリケーション基盤です。
設定駆動アーキテクチャ完成のための作業を進めます。
以下のWBSに従って進めてください。
まずは Phase 1 の TASK-002 database.type 利用状況確認から始めます。
対象:
apps/api/src/database/createDatabase.ts
apps/api/src/database/*
コードを提示するので、
・何をしているか
・database.type がどこで使われているか
・設定駆動化の完成度
・次に確認すべき箇所
を整理してください。



EOF_1791008798_526

echo "作成: README.md"
cat << 'EOF_1791008798_4476' > "README.md"
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
EOF_1791008798_4476

mkdir -p "temp"
echo "作成: temp/package.json"
cat << 'EOF_1791008798_2605' > "temp/package.json"
{
    "name": "workspace",
    "private": true,
    "workspaces": [
        "apps/*",
        "packages/*"
    ],
    "scripts": {
        "dev": "npm run dev -w apps/api",
        "db:generate": "drizzle-kit generate",
        "db:migrate": "drizzle-kit migrate",
        "db:push": "drizzle-kit push"
    },
    "devDependencies": {
        "drizzle-kit": "^0.31.4",
        "typescript": "^5.9.2"
    }
}
EOF_1791008798_2605

mkdir -p "temp/packages/schemas"
echo "作成: temp/packages/schemas/package.json"
cat << 'EOF_1791008798_9898' > "temp/packages/schemas/package.json"
{
    "name": "@packages/schemas",
    "version": "1.0.0",
    "type": "module",
    "exports": {
        ".": "./src/index.ts"
    },
    "dependencies": {
        "zod": "^4.1.11"
    }
}
EOF_1791008798_9898

mkdir -p "temp/packages/schemas/src"
echo "作成: temp/packages/schemas/src/index.ts"
cat << 'EOF_1791008798_2069' > "temp/packages/schemas/src/index.ts"
export * from './user/create-user';
export * from './user/user';
export * from './user/user-detail';
EOF_1791008798_2069

mkdir -p "temp/packages/schemas/src/user"
echo "作成: temp/packages/schemas/src/user/create-user.ts"
cat << 'EOF_1791008798_29203' > "temp/packages/schemas/src/user/create-user.ts"
import { z } from 'zod';

export const CreateUserSchema = z.object({
    name: z.string().min(1).max(100),

    email: z.email(),
});

export type CreateUser = z.infer<typeof CreateUserSchema>;
EOF_1791008798_29203

mkdir -p "temp/packages/schemas/src/user"
echo "作成: temp/packages/schemas/src/user/user-detail.ts"
cat << 'EOF_1791008798_10758' > "temp/packages/schemas/src/user/user-detail.ts"
import { z } from 'zod';

export const UserDetailSchema = z.object({
    id: z.number(),

    name: z.string(),

    email: z.string(),
});

export type UserDetail = z.infer<typeof UserDetailSchema>;
EOF_1791008798_10758

mkdir -p "temp/packages/schemas/src/user"
echo "作成: temp/packages/schemas/src/user/user.ts"
cat << 'EOF_1791008798_771' > "temp/packages/schemas/src/user/user.ts"
export interface User {
    id: number;
    name: string;
    email: string;
}
EOF_1791008798_771

mkdir -p "temp"
echo "作成: temp/drizzle.config.ts"
cat << 'EOF_1791008798_10901' > "temp/drizzle.config.ts"
import type { Config } from 'drizzle-kit';

export default {
    schema: './apps/api/src/infrastructure/postgres/schema.ts',

    out: './migrations',

    dialect: 'postgresql',

    dbCredentials: {
        url: process.env.DATABASE_URL!,
    },
} satisfies Config;
EOF_1791008798_10901

mkdir -p "temp/apps/api"
echo "作成: temp/apps/api/package.json"
cat << 'EOF_1791008798_27312' > "temp/apps/api/package.json"
{
    "name": "api",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "scripts": {
        "dev": "tsx watch src/main.ts"
    },
    "dependencies": {
        "@packages/schemas": "*",
        "drizzle-orm": "^0.44.5",
        "drizzle-zod": "^0.8.3",
        "hono": "^4.9.9",
        "pg": "^8.16.3",
        "zod": "^4.1.11"
    },
    "devDependencies": {
        "@types/node": "^24.5.2",
        "tsx": "^4.20.5",
        "typescript": "^5.9.2"
    }
}
EOF_1791008798_27312

mkdir -p "temp/apps/api"
echo "作成: temp/apps/api/tsconfig.json"
cat << 'EOF_1791008798_27943' > "temp/apps/api/tsconfig.json"
{
    "compilerOptions": {
        "target": "ES2022",

        "module": "ESNext",

        "moduleResolution": "Bundler",

        "strict": true,

        "skipLibCheck": true,

        "esModuleInterop": true,

        "allowSyntheticDefaultImports": true,

        "baseUrl": "./src",

        "paths": {
            "@/*": ["*"]
        }
    },

    "include": ["src"]
}
EOF_1791008798_27943

mkdir -p "temp/apps/api/src/infrastructure/memory"
echo "作成: temp/apps/api/src/infrastructure/memory/user-repository.ts"
cat << 'EOF_1791008798_25621' > "temp/apps/api/src/infrastructure/memory/user-repository.ts"
import type { UserRepository } from '@/repositories/user-repository';

import type { CreateUser, User } from '@packages/schemas';

export class MemoryUserRepository implements UserRepository {
    private sequence = 1;

    private readonly users = new Map<number, User>();

    async findById(id: number): Promise<User | null> {
        return this.users.get(id) ?? null;
    }

    async create(request: CreateUser): Promise<User> {
        const user: User = {
            id: this.sequence++,

            name: request.name,

            email: request.email,
        };

        this.users.set(user.id, user);

        return user;
    }
}
EOF_1791008798_25621

mkdir -p "temp/apps/api/src/infrastructure/memory"
echo "作成: temp/apps/api/src/infrastructure/memory/README.md"
cat << 'EOF_1791008798_7796' > "temp/apps/api/src/infrastructure/memory/README.md"
Memory Provider

This provider stores data in memory using a Map.

It is intended for:

- local development
- unit testing
- integration testing

Data is lost when the process exits.
EOF_1791008798_7796

mkdir -p "temp/apps/api/src/infrastructure/postgres"
echo "作成: temp/apps/api/src/infrastructure/postgres/user-repository.ts"
cat << 'EOF_1791008798_3662' > "temp/apps/api/src/infrastructure/postgres/user-repository.ts"
import { eq } from 'drizzle-orm';

import type { CreateUser, User } from '@packages/schemas';

import type { UserRepository } from '@/repositories/user-repository';

import { db } from './db';

import { users } from './schema';

export class PostgresUserRepository implements UserRepository {
    async findById(id: number): Promise<User | null> {
        const result = await db.select().from(users).where(eq(users.id, id)).limit(1);

        if (result.length === 0) {
            return null;
        }

        return {
            id: result[0].id,

            name: result[0].name,

            email: result[0].email,
        };
    }

    async create(request: CreateUser): Promise<User> {
        const result = await db
            .insert(users)
            .values({
                name: request.name,

                email: request.email,
            })
            .returning();

        return {
            id: result[0].id,

            name: result[0].name,

            email: result[0].email,
        };
    }
}
EOF_1791008798_3662

mkdir -p "temp/apps/api/src/infrastructure/postgres"
echo "作成: temp/apps/api/src/infrastructure/postgres/schema.ts"
cat << 'EOF_1791008798_19719' > "temp/apps/api/src/infrastructure/postgres/schema.ts"
import { pgTable, serial, varchar } from 'drizzle-orm/pg-core';

import { createInsertSchema, createSelectSchema } from 'drizzle-zod';

export const users = pgTable('users', {
    id: serial('id').primaryKey(),

    name: varchar('name', {
        length: 100,
    }).notNull(),

    email: varchar('email', {
        length: 255,
    }).notNull(),
});

export const UserSelectSchema = createSelectSchema(users);

export const UserInsertSchema = createInsertSchema(users);
EOF_1791008798_19719

mkdir -p "temp/apps/api/src/infrastructure/postgres"
echo "作成: temp/apps/api/src/infrastructure/postgres/db.ts"
cat << 'EOF_1791008798_29758' > "temp/apps/api/src/infrastructure/postgres/db.ts"
import { Pool } from 'pg';

import { drizzle } from 'drizzle-orm/node-postgres';

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

export const db = drizzle(pool);
EOF_1791008798_29758

mkdir -p "temp/apps/api/src/provider"
echo "作成: temp/apps/api/src/provider/db-provider.ts"
cat << 'EOF_1791008798_20147' > "temp/apps/api/src/provider/db-provider.ts"
import type { UserRepository } from '@/repositories/user-repository';

import { UserService } from '@/features/user/service';

import { PostgresUserRepository } from '@/infrastructure/postgres/user-repository';

import { MemoryUserRepository } from '@/infrastructure/memory/user-repository';

export type DbProvider = 'postgres' | 'memory';

function createUserRepository(): UserRepository {
    const provider = (process.env.DB_PROVIDER ?? 'memory') as DbProvider;

    switch (provider) {
        case 'postgres':
            return new PostgresUserRepository();

        case 'memory':
            return new MemoryUserRepository();

        default:
            throw new Error(`Unsupported provider: ${provider}`);
    }
}

export const userRepository = createUserRepository();

export const userService = new UserService(userRepository);
EOF_1791008798_20147

mkdir -p "temp/apps/api/src/features/user"
echo "作成: temp/apps/api/src/features/user/service.ts"
cat << 'EOF_1791008798_26847' > "temp/apps/api/src/features/user/service.ts"
import type { UserRepository } from '@/repositories/user-repository';

import type { CreateUser } from '@packages/schemas';

export class UserService {
    constructor(private readonly repository: UserRepository) {}

    async getUser(id: number) {
        return await this.repository.findById(id);
    }

    async createUser(request: CreateUser) {
        return await this.repository.create(request);
    }
}
EOF_1791008798_26847

mkdir -p "temp/apps/api/src/features/user"
echo "作成: temp/apps/api/src/features/user/controller.ts"
cat << 'EOF_1791008798_222' > "temp/apps/api/src/features/user/controller.ts"
import { Hono } from 'hono';

import { CreateUserSchema, UserDetailSchema } from '@packages/schemas';

import { userService } from '@/provider/db-provider';

export const userController = new Hono();

userController.get('/:id', async (c) => {
    const id = Number(c.req.param('id'));

    if (Number.isNaN(id)) {
        return c.json(
            {
                message: 'invalid id',
            },
            400,
        );
    }

    const user = await userService.getUser(id);

    if (!user) {
        return c.json(
            {
                message: 'user not found',
            },
            404,
        );
    }

    return c.json(UserDetailSchema.parse(user));
});

userController.post('/', async (c) => {
    const body = await c.req.json();

    const request = CreateUserSchema.parse(body);

    const user = await userService.createUser(request);

    return c.json(UserDetailSchema.parse(user), 201);
});
EOF_1791008798_222

mkdir -p "temp/apps/api/src"
echo "作成: temp/apps/api/src/main.ts"
cat << 'EOF_1791008798_29527' > "temp/apps/api/src/main.ts"
import { serve } from '@hono/node-server';

import { Hono } from 'hono';

import { userController } from './features/user/controller';

const app = new Hono();

app.get('/health', (c) =>
    c.json({
        status: 'ok',
    }),
);

app.route('/users', userController);

const port = Number(process.env.PORT ?? 3000);

serve(
    {
        fetch: app.fetch,
        port,
    },
    (info) => {
        console.log(`server started : ${info.port}`);
    },
);
EOF_1791008798_29527

mkdir -p "temp/apps/api/src/repositories"
echo "作成: temp/apps/api/src/repositories/user-repository.ts"
cat << 'EOF_1791008798_365' > "temp/apps/api/src/repositories/user-repository.ts"
import type { CreateUser, User } from '@packages/schemas';

export interface UserRepository {
    findById(id: number): Promise<User | null>;

    create(request: CreateUser): Promise<User>;
}
EOF_1791008798_365

mkdir -p "temp/apps/api"
echo "作成: temp/apps/api/.env.example"
cat << 'EOF_1791008798_15275' > "temp/apps/api/.env.example"
#
# memory
#
DB_PROVIDER=memory

#
# postgres
#
# DB_PROVIDER=postgres
# DATABASE_URL=postgres://postgres:postgres@localhost:5432/app

PORT=3000
EOF_1791008798_15275

mkdir -p "temp/apps/api"
echo "作成: temp/apps/api/.env"
cat << 'EOF_1791008798_3586' > "temp/apps/api/.env"
DB_PROVIDER=memory

PORT=3000
EOF_1791008798_3586

mkdir -p "temp"
echo "作成: temp/generate.sh"
cat << 'EOF_1791008798_25058' > "temp/generate.sh"
#!/usr/bin/env bash

set -eu

###############################################################################
# directories
###############################################################################

mkdir -p apps/api/src/features/user
mkdir -p apps/api/src/repositories
mkdir -p apps/api/src/provider

mkdir -p apps/api/src/infrastructure/postgres/schema
mkdir -p apps/api/src/infrastructure/postgres

mkdir -p apps/api/src/infrastructure/memory

mkdir -p packages/schemas/src/user

mkdir -p migrations

###############################################################################
# root package.json
###############################################################################

cat > package.json <<'EOF'
{
  "name": "workspace",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "dev": "npm run dev -w apps/api",
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:push": "drizzle-kit push"
  },
  "devDependencies": {
    "drizzle-kit": "^0.31.4",
    "typescript": "^5.9.2"
  }
}
EOF

###############################################################################
# drizzle.config.ts
###############################################################################

cat > drizzle.config.ts <<'EOF'
import type { Config }
from "drizzle-kit";

export default {
  schema:
    "./apps/api/src/infrastructure/postgres/schema.ts",

  out:
    "./migrations",

  dialect:
    "postgresql",

  dbCredentials: {
    url:
      process.env.DATABASE_URL!,
  },
} satisfies Config;
EOF

###############################################################################
# packages/schemas/package.json
###############################################################################

cat > packages/schemas/package.json <<'EOF'
{
  "name": "@packages/schemas",
  "version": "1.0.0",
  "type": "module",
  "exports": {
    ".": "./src/index.ts"
  },
  "dependencies": {
    "zod": "^4.1.11"
  }
}
EOF

###############################################################################
# packages/schemas/src/index.ts
###############################################################################

cat > packages/schemas/src/index.ts <<'EOF'
export * from "./user/create-user";
export * from "./user/user";
export * from "./user/user-detail";
EOF

###############################################################################
# packages/schemas/src/user/create-user.ts
###############################################################################

cat > packages/schemas/src/user/create-user.ts <<'EOF'
import { z } from "zod";

export const CreateUserSchema =
  z.object({
    name:
      z.string()
        .min(1)
        .max(100),

    email:
      z.email(),
  });

export type CreateUser =
  z.infer<
    typeof CreateUserSchema
  >;
EOF

###############################################################################
# packages/schemas/src/user/user.ts
###############################################################################

cat > packages/schemas/src/user/user.ts <<'EOF'
export interface User {
  id: number;
  name: string;
  email: string;
}
EOF

###############################################################################
# packages/schemas/src/user/user-detail.ts
###############################################################################

cat > packages/schemas/src/user/user-detail.ts <<'EOF'
import { z } from "zod";

export const UserDetailSchema =
  z.object({
    id:
      z.number(),

    name:
      z.string(),

    email:
      z.string(),
  });

export type UserDetail =
  z.infer<
    typeof UserDetailSchema
  >;
EOF

###############################################################################
# apps/api/package.json
###############################################################################

cat > apps/api/package.json <<'EOF'
{
  "name": "api",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/main.ts"
  },
  "dependencies": {
    "@packages/schemas": "*",
    "drizzle-orm": "^0.44.5",
    "drizzle-zod": "^0.8.3",
    "hono": "^4.9.9",
    "pg": "^8.16.3",
    "zod": "^4.1.11"
  },
  "devDependencies": {
    "@types/node": "^24.5.2",
    "tsx": "^4.20.5",
    "typescript": "^5.9.2"
  }
}
EOF

###############################################################################
# apps/api/tsconfig.json
###############################################################################

cat > apps/api/tsconfig.json <<'EOF'
{
  "compilerOptions": {

    "target": "ES2022",

    "module": "ESNext",

    "moduleResolution": "Bundler",

    "strict": true,

    "skipLibCheck": true,

    "esModuleInterop": true,

    "allowSyntheticDefaultImports": true,

    "baseUrl": "./src",

    "paths": {
      "@/*": [
        "*"
      ]
    }
  },

  "include": [
    "src"
  ]
}
EOF

###############################################################################
# Repository Interface
###############################################################################

cat > apps/api/src/repositories/user-repository.ts <<'EOF'
import type {
  User,
  CreateUser,
} from "@packages/schemas";

export interface UserRepository {

  findById(
    id: number,
  ): Promise<User | null>;

  create(
    request: CreateUser,
  ): Promise<User>;
}
EOF

###############################################################################
# User Service
###############################################################################

cat > apps/api/src/features/user/service.ts <<'EOF'
import type {
  UserRepository,
} from "@/repositories/user-repository";

import type {
  CreateUser,
} from "@packages/schemas";

export class UserService {

  constructor(
    private readonly repository:
      UserRepository,
  ) {}

  async getUser(
    id: number,
  ) {

    return await this.repository
      .findById(id);
  }

  async createUser(
    request: CreateUser,
  ) {

    return await this.repository
      .create(request);
  }
}
EOF

###############################################################################
# DbProvider
###############################################################################

cat > apps/api/src/provider/db-provider.ts <<'EOF'
import type {
  UserRepository,
} from "@/repositories/user-repository";

import {
  UserService,
} from "@/features/user/service";

import {
  PostgresUserRepository,
} from "@/infrastructure/postgres/user-repository";

import {
  MemoryUserRepository,
} from "@/infrastructure/memory/user-repository";

export type DbProvider =
  | "postgres"
  | "memory";

function createUserRepository():
  UserRepository {

  const provider =
    (
      process.env.DB_PROVIDER
      ?? "memory"
    ) as DbProvider;

  switch (provider) {

    case "postgres":
      return new PostgresUserRepository();

    case "memory":
      return new MemoryUserRepository();

    default:
      throw new Error(
        `Unsupported provider: ${provider}`,
      );
  }
}

export const userRepository =
  createUserRepository();

export const userService =
  new UserService(
    userRepository,
  );
EOF

###############################################################################
# PostgreSQL db.ts
###############################################################################

cat > apps/api/src/infrastructure/postgres/db.ts <<'EOF'
import { Pool } from "pg";

import { drizzle }
  from "drizzle-orm/node-postgres";

const pool =
  new Pool({
    connectionString:
      process.env.DATABASE_URL,
  });

export const db =
  drizzle(pool);
EOF

###############################################################################
# PostgreSQL schema.ts
###############################################################################

cat > apps/api/src/infrastructure/postgres/schema.ts <<'EOF'
import {
  pgTable,
  serial,
  varchar,
} from "drizzle-orm/pg-core";

import {
  createInsertSchema,
  createSelectSchema,
} from "drizzle-zod";

export const users =
  pgTable(
    "users",
    {
      id:
        serial("id")
          .primaryKey(),

      name:
        varchar(
          "name",
          {
            length: 100,
          },
        ).notNull(),

      email:
        varchar(
          "email",
          {
            length: 255,
          },
        ).notNull(),
    },
  );

export const UserSelectSchema =
  createSelectSchema(users);

export const UserInsertSchema =
  createInsertSchema(users);
EOF

###############################################################################
# PostgreSQL user-repository.ts
###############################################################################

cat > apps/api/src/infrastructure/postgres/user-repository.ts <<'EOF'
import { eq }
  from "drizzle-orm";

import type {
  User,
  CreateUser,
} from "@packages/schemas";

import type {
  UserRepository,
} from "@/repositories/user-repository";

import {
  db,
} from "./db";

import {
  users,
} from "./schema";

export class PostgresUserRepository
  implements UserRepository {

  async findById(
    id: number,
  ): Promise<User | null> {

    const result =
      await db
        .select()
        .from(users)
        .where(
          eq(
            users.id,
            id,
          ),
        )
        .limit(1);

    if (
      result.length === 0
    ) {
      return null;
    }

    return {
      id:
        result[0].id,

      name:
        result[0].name,

      email:
        result[0].email,
    };
  }

  async create(
    request: CreateUser,
  ): Promise<User> {

    const result =
      await db
        .insert(users)
        .values({
          name:
            request.name,

          email:
            request.email,
        })
        .returning();

    return {
      id:
        result[0].id,

      name:
        result[0].name,

      email:
        result[0].email,
    };
  }
}
EOF


###############################################################################
# Memory user-repository.ts
###############################################################################

cat > apps/api/src/infrastructure/memory/user-repository.ts <<'EOF'
import type {
  UserRepository,
} from "@/repositories/user-repository";

import type {
  User,
  CreateUser,
} from "@packages/schemas";

export class MemoryUserRepository
  implements UserRepository {

  private sequence = 1;

  private readonly users =
    new Map<
      number,
      User
    >();

  async findById(
    id: number,
  ): Promise<User | null> {

    return (
      this.users.get(id)
      ?? null
    );
  }

  async create(
    request: CreateUser,
  ): Promise<User> {

    const user: User = {
      id:
        this.sequence++,

      name:
        request.name,

      email:
        request.email,
    };

    this.users.set(
      user.id,
      user,
    );

    return user;
  }
}
EOF

###############################################################################
# Memory README (optional)
###############################################################################

cat > apps/api/src/infrastructure/memory/README.md <<'EOF'
Memory Provider

This provider stores data in memory using a Map.

It is intended for:
- local development
- unit testing
- integration testing

Data is lost when the process exits.
EOF


###############################################################################
# User Controller
###############################################################################

cat > apps/api/src/features/user/controller.ts <<'EOF'
import { Hono }
  from "hono";

import {
  CreateUserSchema,
  UserDetailSchema,
} from "@packages/schemas";

import {
  userService,
} from "@/provider/db-provider";

export const userController =
  new Hono();

userController.get(
  "/:id",
  async (c) => {

    const id =
      Number(
        c.req.param("id"),
      );

    if (
      Number.isNaN(id)
    ) {

      return c.json(
        {
          message:
            "invalid id",
        },
        400,
      );
    }

    const user =
      await userService
        .getUser(id);

    if (!user) {

      return c.json(
        {
          message:
            "user not found",
        },
        404,
      );
    }

    return c.json(
      UserDetailSchema.parse(
        user,
      ),
    );
  },
);

userController.post(
  "/",
  async (c) => {

    const body =
      await c.req.json();

    const request =
      CreateUserSchema.parse(
        body,
      );

    const user =
      await userService
        .createUser(
          request,
        );

    return c.json(
      UserDetailSchema.parse(
        user,
      ),
      201,
    );
  },
);
EOF

###############################################################################
# Main
###############################################################################

cat > apps/api/src/main.ts <<'EOF'
import { serve }
  from "@hono/node-server";

import { Hono }
  from "hono";

import {
  userController,
} from "./features/user/controller";

const app =
  new Hono();

app.get(
  "/health",
  (c) =>
    c.json({
      status: "ok",
    }),
);

app.route(
  "/users",
  userController,
);

const port =
  Number(
    process.env.PORT
    ?? 3000,
  );

serve(
  {
    fetch: app.fetch,
    port,
  },
  (info) => {

    console.log(
      `server started : ${info.port}`,
    );
  },
);
EOF

###############################################################################
# .env.example
###############################################################################

cat > apps/api/.env.example <<'EOF'
#
# memory
#
DB_PROVIDER=memory

#
# postgres
#
# DB_PROVIDER=postgres
# DATABASE_URL=postgres://postgres:postgres@localhost:5432/app

PORT=3000
EOF

###############################################################################
# .env
###############################################################################

cat > apps/api/.env <<'EOF'
DB_PROVIDER=memory

PORT=3000
EOF

###############################################################################
# done
###############################################################################

echo ""
echo "========================================"
echo "Project generated."
echo "========================================"
echo ""
echo "Install:"
echo "npm install"
echo ""
echo "Run:"
echo "npm run dev -w apps/api"
echo ""
EOF_1791008798_25058

echo "作成: TASK-001_004-設定駆動化ギャップ分析.md"
cat << 'EOF_1791008798_22336' > "TASK-001_004-設定駆動化ギャップ分析.md"
# TASK-005 設定駆動化ギャップ分析

## 目的

Phase1調査結果を基に、

```text
Config
↓
設定値
↓
Factory
↓
Interface
↓
実装
```

という理想状態とのギャップを分析し、
今後の実装優先順位を決定する。

---

# 調査対象

## TASK-001

設定構造調査

---

## TASK-002

database.type 利用状況確認

---

## TASK-003

authentication.type 利用状況確認

---

## TASK-004

frontend.type 利用状況確認

---

# 理想アーキテクチャ

このプロジェクトが目指している構造は以下と考えられる。

```text
Config
 ├─ database.type
 ├─ authentication.type
 └─ frontend.type

        ↓

Factory

 ├─ createDatabase()
 ├─ createAuthentication()
 └─ createFrontend()

        ↓

Interface

 ├─ Database
 ├─ AuthenticationProvider
 └─ FrontendProvider

        ↓

Implementation

 ├─ Postgres
 ├─ SqlServer
 ├─ JWT
 ├─ OIDC
 ├─ LDAP
 ├─ React
 └─ Vue
```

---

# 現在の完成度

## database.type

状態

```text
完成
```

実態

```text
Config
↓
createDatabase()
↓
Database
↓
実装切替
```

確認済み実装

```text
memory
postgres
```

未実装

```text
sqlserver
```

完成度

```text
95%
```

---

## authentication.type

状態

```text
未完成
```

実態

```text
Config
↓
未使用
↓
JwtService固定
```

確認結果

```text
none 未実装
jwt 完成
oidc 未実装
ldap 未実装
```

完成度

```text
30%
```

---

## frontend.type

状態

```text
未完成
```

実態

```text
Config
↓
未使用
↓
React固定
```

確認結果

```text
react 利用中
vue 雛形のみ
```

完成度

```text
25%
```

---

# ギャップ分析

## ギャップ①

Configに存在する設定値と
実際の実装が一致していない

---

### Database

Config

```ts
type:
  | 'memory'
  | 'postgres'
  | 'sqlserver'
```

実装

```text
memory
postgres
```

のみ。

---

### Authentication

Config

```ts
type:
  | 'none'
  | 'jwt'
  | 'oidc'
  | 'ldap'
```

実装

```text
jwt
```

のみ。

---

### Frontend

Config

```ts
type:
  | 'react'
  | 'vue'
```

実装

```text
react
```

のみ。

---

## 評価

現在のConfigは

```text
実装済み機能一覧
```

ではなく

```text
将来構想
```

になっている。

---

# ギャップ②

認証Factoryが存在しない

---

## Database

存在

```ts
createDatabase();
```

---

## Authentication

存在しない

理想

```ts
createAuthenticationProvider();
```

---

## 現状

```ts
new JwtService(...)
```

固定。

---

## 結果

authentication.type を変更しても
動作は変わらない。

---

# ギャップ③

FrontendFactoryが存在しない

---

理想

```ts
createFrontend();
```

または

```ts
createFrontendApplication();
```

---

現状

```text
React直接起動
```

---

結果

frontend.type を変更しても
動作は変わらない。

---

# ギャップ④

Interfaceが存在するのに利用されていない

---

## AuthenticationProvider

存在

```ts
interface AuthenticationProvider
```

---

利用

```text
なし
```

---

評価

これは非常に重要。

設計意図としては

```text
JWT
OIDC
LDAP
```

切替を考慮している。

しかしFactory接続が未実装。

---

# ギャップ⑤

Config検証が存在しない

---

現在

```ts
JSON.parse();
```

のみ。

---

問題例

```json
{
    "authentication": {
        "type": "aaaa"
    }
}
```

でもロード可能。

---

理想

```text
JSON
↓
Schema Validation
↓
Config
```

---

# ギャップ⑥

保存機能が存在しない

---

現状

```ts
saveConfig();
```

未実装。

---

結果

```text
設定変更
↓
保存
```

の仕組みが存在しない。

---

# ギャップ⑦

設定と実装の同期ルールが存在しない

---

現状

設定定義

```ts
type:
 | jwt
 | oidc
 | ldap
```

を追加できる。

---

しかし

```text
Factory実装
Provider実装
Middleware実装
```

が存在する保証が無い。

---

推奨

```text
Configに追加
↓
Factory追加
↓
Interface実装追加
↓
テスト追加
```

をルール化する。

---

# 技術的負債一覧

## High

### authentication.type未実装

影響

```text
認証切替不可
```

優先度

```text
最高
```

---

### frontend.type未実装

影響

```text
フロント切替不可
```

優先度

```text
高
```

---

### Config Validation未実装

影響

```text
誤設定検知不可
```

優先度

```text
高
```

---

## Medium

### sqlserver未実装

影響

```text
Configとの不整合
```

優先度

```text
中
```

---

### saveConfig未実装

影響

```text
運用性不足
```

優先度

```text
中
```

---

## Low

### Dead Code

対象

```text
PostgreSqlDatabase.ts
SqlServerDatabase.ts
```

優先度

```text
低
```

---

# 推奨実装順序

## Phase2-1

authentication.type完成

実装

```text
AuthenticationProvider

JwtAuthenticationProvider
OidcAuthenticationProvider
LdapAuthenticationProvider
NoAuthenticationProvider

createAuthenticationProvider()
```

---

## Phase2-2

frontend.type完成

実装

```text
FrontendFactory

ReactFrontend
VueFrontend
```

---

## Phase2-3

Config Validation

候補

```text
zod
ajv
valibot
```

---

## Phase2-4

saveConfig実装

---

## Phase2-5

sqlserver実装

---

# 最終評価

| 項目                | 完成度 |
| ------------------- | -----: |
| database.type       |    95% |
| authentication.type |    30% |
| frontend.type       |    25% |
| Config Validation   |     0% |
| Config Save         |     0% |

---

# 結論

現在のアーキテクチャは

```text
Database
```

のみ設定駆動化がほぼ完成している。

一方で

```text
Authentication
Frontend
```

は

```text
Config定義のみ存在
↓
実装切替なし
```

という状態である。

設定駆動アーキテクチャ完成のための最優先課題は

```text
authentication.type
```

のFactory化である。

理由は、

```text
AuthenticationProvider
```

という抽象化が既に存在しており、
実装コストに対する効果が最も高いためである。
EOF_1791008798_22336

echo -e "\n復元が完了しました！"
