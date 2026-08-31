import fs from 'node:fs';
import path from 'node:path';
import { resolveFromProjectRoot } from '@shared/server-utils';

// 💡 プロジェクトルートを環境に依存せず確実に取得

// 1. schemaディレクトリ内のファイルを自動で全取得
const schemaDir = resolveFromProjectRoot('shared', 'db', 'src', 'schema');

// .tsファイルのみを対象とし、インデックスファイル等は除外
const files = fs.readdirSync(schemaDir).filter(file => file.endsWith('.ts') && file !== 'index.ts');

console.log(`[Codegen] 检测到スキーマファイル変更:`, files);

// 2. 取得したファイル名からテーブル名（キャメルケース）を動的に抽出
const tables = files.map(file => {
  const baseName = path.basename(file, '.ts'); // 例: 'users', 'posts'

  // 関数名や型名に使うためのパスカルケース（大文字始まり）
  const pascalName = baseName.charAt(0).toUpperCase() + baseName.slice(1); // 例: 'Users', 'Posts'

  // 複数形の「s」を除去して単数形にする（リポジトリ名用、例: users -> User）
  // 💡 簡易的な除去です。必要に応じて 'replies' -> 'reply' などの変換ルールを追加してください
  const singularName = pascalName.endsWith('s') ? pascalName.slice(0, -1) : pascalName;

  return {
    origin: pascalName,     // 
    raw: baseName,          // schema.users の部分に使用
    singular: singularName  // createUserRepository の部分に使用
  };
});

// 3. 各テーブルのリポジトリ関数を動的に生成
const repositoryFunctions = tables.map(table => `
// ${table.origin} リポジトリ
export function create${table.singular}Repository(db: Database) {
  return {
    async findById(id: typeof schema.${table.raw}.$inferSelect.id) {
      return await db.query.${table.raw}.findFirst({ where: eq(schema.${table.raw}.id, id) });
    }
  };
}`).join('\n');

// 4. 全体のテンプレートを組み立て
const template = `// 
// このファイルは codegen.ts で、自動生成されました
// 
import { Database } from '../database';
import * as schema from '../schema';
import { eq } from 'drizzle-orm';
${repositoryFunctions}
`;

// 5. generated/repositories.ts に書き出す
const generatedDir = resolveFromProjectRoot('shared', 'db', 'src', 'generated');

// ディレクトリが存在しない場合の考慮
if (!fs.existsSync(generatedDir)) {
  fs.mkdirSync(generatedDir, { recursive: true });
}

fs.writeFileSync(path.resolve(generatedDir, 'repositories.ts'), template.trim() + '\n');
console.log(`[Codegen] repositories.ts を正常に生成しました。`);
