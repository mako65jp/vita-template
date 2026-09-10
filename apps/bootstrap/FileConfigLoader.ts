// import { AppConfig } from "./AppConfig";
// import * as fs from 'fs';
// import { resolveFromProjectRoot } from "@shared/server-utils";
// import YAML from 'yaml';
// import { ConfigLoader } from "./ConfigLoader";

// export class FileConfigLoader
//     implements ConfigLoader {

//     private filePath: string;
//     constructor(fileName: string) {
//         this.filePath = resolveFromProjectRoot('apps', 'config', fileName);
//     }

//     load(): AppConfig {
//         const content = fs.readFileSync(this.filePath, 'utf8');
//         return YAML.parse(content) as AppConfig;
//     }
// }

import fs from 'node:fs';

import YAML from 'yaml';

import type {
    AppConfig,
} from './AppConfig';

import type {
    ConfigLoader,
} from './ConfigLoader';

export class FileConfigLoader
    implements ConfigLoader {

    constructor(
        private readonly filePath: string,
    ) { }

    load(): AppConfig {

        const content =
            fs.readFileSync(
                this.filePath,
                'utf-8',
            );

        return YAML.parse(
            content,
        ) as AppConfig;
    }
}
