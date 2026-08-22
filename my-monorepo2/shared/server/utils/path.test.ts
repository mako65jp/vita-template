import { describe, it, expect } from 'vitest';
import path from 'node:path';
import fs from 'node:fs';
import { getProjectRootDir, resolveFromProjectRoot } from './path';

describe('path utils', () => {
    it('getProjectRootDir がプロジェクトのルートディレクトリ（package.json が存在する場所）を返すこと', () => {
        const rootDir = getProjectRootDir();

        // ルートディレクトリとして正しく判定されているか（ルートの package.json の存在確認）
        const rootPackageJsonPath = path.join(rootDir, 'package.json');
        expect(fs.existsSync(rootPackageJsonPath)).toBe(true);
    });

    it('resolveFromProjectRoot がルートからの相対パスを正しい絶対パスに変換すること', () => {
        const resolvedPath = resolveFromProjectRoot('shared', 'core');
        const expectedPath = path.resolve(getProjectRootDir(), 'shared/core');

        expect(resolvedPath).toBe(expectedPath);
    });
});
