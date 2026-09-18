import { cp, mkdir, rename, writeFile } from 'node:fs/promises';

async function exists(path) {
    try {
        await cp(path, path, {
            recursive: true,
            force: false,
            errorOnExist: true,
        });

        return true;
    } catch {
        return false;
    }
}

await mkdir('apps/web', {
    recursive: true,
});

//
// apps/web-react
// ↓
// apps/web/react
//

try {
    await mkdir('apps/web', {
        recursive: true,
    });

    await rename('apps/web-react', 'apps/web/react');

    console.log('moved: apps/web-react -> apps/web/react');
} catch (error) {
    console.log('move skipped:', error.message);
}

//
// FrontendConfig.ts
//

await writeFile(
    'apps/web/FrontendConfig.ts',
    `
export interface BackendConfig {
    protocol: string;
    host: string;
    port: number;
    applicationRoot: string;
}

export interface FrontendConfig {
    backend: BackendConfig;
}
`.trimStart(),
);

//
// FrontendConfigurationService.ts
//

await writeFile(
    'apps/web/FrontendConfigurationService.ts',
    `
import {
    FrontendConfig,
} from './FrontendConfig';

export class FrontendConfigurationService {
    private config:
        FrontendConfig
        | undefined;

    async load()
    : Promise<void> {
        const response =
            await fetch(
                '/config',
            );

        this.config =
            await response.json();
    }

    getConfig()
    : FrontendConfig {
        if (
            !this.config
        ) {
            throw new Error(
                'Configuration is not loaded.',
            );
        }

        return this.config;
    }
}
`.trimStart(),
);

//
// root package.json
//

await writeFile(
    'update-dev-web-script.txt',
    `
package.json の

"dev:web": "cd apps/web-react && vite --host 0.0.0.0"

を

"dev:web": "cd apps/web/react && vite --host 0.0.0.0"

へ変更する。
`.trimStart(),
);

console.log('web structure created');
