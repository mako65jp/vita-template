// import { describe, it, vi, expect } from "vitest";
// import { Bootstrap } from "./Bootstrap";

// describe('Bootstrap', () => {
//     it('loads config and configures platform', () => {
//         const config = {
//             platform: {
//                 database: 'postgres',
//                 auth: 'local',
//                 authorization: 'local',
//                 frontend: 'react',
//             },
//         };

//         const configLoader = {
//             load: vi.fn(() => config),
//         };

//         const platformRegistry = {
//             configure: vi.fn(),
//         };

//         const bootstrap = new Bootstrap(
//             configLoader,
//             platformRegistry,
//         );

//         bootstrap.start();

//         expect(configLoader.load)
//             .toHaveBeenCalledOnce();

//         expect(platformRegistry.configure)
//             .toHaveBeenCalledWith(config);
//     });
// });


import {
    describe,
    expect,
    it,
    vi,
} from 'vitest';

import {
    Bootstrap,
} from './Bootstrap';

describe(
    'Bootstrap',
    () => {

        it(
            'loads platform selection',
            () => {

                const loader = {
                    load:
                        vi.fn(
                            () => ({
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
                            }),
                        ),
                };

                const bootstrap =
                    new Bootstrap(
                        loader,
                    );

                expect(
                    bootstrap.loadSelection(),
                ).toEqual({
                    database:
                        'postgres',
                    auth:
                        'local',
                    authorization:
                        'local',
                    frontend:
                        'react',
                });
            },
        );
    },
);
