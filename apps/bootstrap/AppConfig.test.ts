// import { describe, it, expect } from "vitest";
// import { AppConfig } from "./AppConfig";

// describe("AppConfig", () => {
//     it("has platform selection", () => {
//         const config: AppConfig = {
//             platform: {
//                 database: "postgres",
//                 auth: "local",
//                 authorization: "local",
//                 frontend: "react",
//             },
//         };

//         expect(config.platform.database)
//             .toBe("postgres");
//     });
// });


import {
    describe,
    expect,
    it,
} from 'vitest';

import type {
    AppConfig,
} from './AppConfig';

describe(
    'AppConfig',
    () => {

        it(
            'contains platform selection',
            () => {

                const config:
                    AppConfig = {
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
                };

                expect(
                    config.platform.database,
                ).toBe(
                    'postgres',
                );
            },
        );
    },
);
