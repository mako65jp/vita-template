// import { describe, expect, it } from 'vitest';
// import { FileConfigLoader } from './FileConfigLoader';

// import fs from 'node:fs';
// import os from 'node:os';
// import path from 'node:path';

// describe('FileConfigLoader', () => {
//     it('loads platform configuration', () => {
//         const tmpFile = path.join(
//             os.tmpdir(),
//             'app-config.yaml',
//         );

//         fs.writeFileSync(
//             tmpFile,
//             `
// platform:
//   database: postgres
//   auth: local
//   authorization: local
//   frontend: react
// `,
//         );

//         const loader =
//             new FileConfigLoader(tmpFile);

//         const config = loader.load();

//         expect(config).toEqual({
//             platform: {
//                 database: 'postgres',
//                 auth: 'local',
//                 authorization: 'local',
//                 frontend: 'react',
//             },
//         });
//     });
// });


import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

import {
    describe,
    expect,
    it,
} from 'vitest';

import {
    FileConfigLoader,
} from './FileConfigLoader';

describe(
    'FileConfigLoader',
    () => {

        it(
            'loads platform configuration',
            () => {

                const file =
                    path.join(
                        os.tmpdir(),
                        'config.yaml',
                    );

                fs.writeFileSync(
                    file,
                    `
platform:
  database: postgres
  auth: local
  authorization: local
  frontend: react
`,
                );

                const loader =
                    new FileConfigLoader(
                        file,
                    );

                expect(
                    loader.load(),
                ).toEqual({
                    platform: {
                        database:
                            'postgres',
                        auth:
                            'local',
                        authorization:
                            'local',
                        frontend:
                            'react',
                    },
                });
            },
        );
    },
);
