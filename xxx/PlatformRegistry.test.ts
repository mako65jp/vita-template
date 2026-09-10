import { it, vi, expect } from "vitest";
import { PlatformRegistry } from "./PlatformRegistry";

const config = {
    platform: {
        database: 'postgres',
        auth: 'local',
        authorization: 'local',
        frontend: 'react',
    }
}

function createRegistry(): PlatformRegistry {
    const registry = new PlatformRegistry();

    registry.addDatabaseProvider('postgres', { connect: vi.fn() });
    registry.addAuthProvider('local', vi.fn());
    registry.addAuthorizationProvider('local', vi.fn());
    registry.addFrontendProvider('react', vi.fn());

    return registry;
}

it('throws for unknown database provider', () => {
    const registry = new PlatformRegistry();

    expect(() =>
        registry.configure({
            platform: {
                database: 'unknown',
                auth: 'local',
                authorization: 'local',
                frontend: 'react',
            },
        }),
    ).toThrow(
        'Unknown database provider: unknown',
    );
});

it('throws for unknown auth provider', () => {
    const registry = createRegistry();

    expect(() =>
        registry.configure({
            platform: {
                database: 'postgres',
                auth: 'unknown',
                authorization: 'local',
                frontend: 'react',
            },
        }),
    ).toThrow(
        'Unknown auth provider: unknown',
    );
});

it('throws for unknown authorization provider', () => {
    const registry = createRegistry();

    expect(() =>
        registry.configure({
            platform: {
                database: 'postgres',
                auth: 'local',
                authorization: 'unknown',
                frontend: 'react',
            },
        }),
    ).toThrow(
        'Unknown authorization provider: unknown',
    );
});

it('throws for unknown frontend provider', () => {
    const registry = createRegistry();

    expect(() =>
        registry.configure({
            platform: {
                database: 'postgres',
                auth: 'local',
                authorization: 'local',
                frontend: 'unknown',
            },
        }),
    ).toThrow(
        'Unknown frontend provider: unknown',
    );
});

it('configures all selected providers', () => {
    const postgresProvider = { connect: vi.fn() };
    const authProvide = vi.fn();
    const authorizationProvider = vi.fn();
    const frontendProvider = vi.fn();

    const registry = new PlatformRegistry();

    registry.addDatabaseProvider('postgres', postgresProvider);
    registry.addAuthProvider('local', authProvide);
    registry.addAuthorizationProvider('local', authorizationProvider);
    registry.addFrontendProvider('react', frontendProvider);

    registry.configure(config);

    expect(postgresProvider).toHaveBeenCalledOnce();
    expect(authProvide).toHaveBeenCalledOnce();
    expect(authorizationProvider).toHaveBeenCalledOnce();
    expect(frontendProvider).toHaveBeenCalledOnce();
});

it('calls provider only once', () => {
    const dbProvider = {
        connect: vi.fn(),
    };

    const registry = createRegistry();

    registry.addDatabaseProvider('postgres', dbProvider);

    registry.configure(config);

    expect(dbProvider).toHaveBeenCalledTimes(1);
});

it('connects selected database provider', () => {
    const dbProvider = { connect: vi.fn() };

    const registry = new PlatformRegistry();

    registry.addDatabaseProvider('postgres', dbProvider);

    registry.configure(config);

    expect(dbProvider.connect).toHaveBeenCalledOnce();
});


// import { describe, expect, it, vi } from 'vitest';
// import { PlatformRegistry } from './PlatformRegistry';

// describe('PlatformRegistry', () => {
//     it('calls selected database provider', () => {
//         const postgresProvider = vi.fn();

//         const registry = new PlatformRegistry();

//         registry.addDatabaseProvider('postgres', postgresProvider);

//         registry.configure({
//             platform: {
//                 database: 'postgres',
//                 auth: 'local',
//                 authorization: 'local',
//                 frontend: 'react',
//             },
//         });

//         expect(postgresProvider)
//             .toHaveBeenCalledOnce();
//     });

//     it('throws for unknown database provider', () => {
//         const registry = new PlatformRegistry();

//         expect(() =>
//             registry.configure({
//                 platform: {
//                     database: 'unknown',
//                     auth: 'local',
//                     authorization: 'local',
//                     frontend: 'react',
//                 },
//             }),
//         ).toThrow(
//             'Unknown database provider: unknown',
//         );
//     });
// });

// it('calls selected auth provider', () => {
//     const authProvider = vi.fn();

//     const registry = new PlatformRegistry();

//     registry.addAuthProvider('local', authProvider);

//     registry.configure({
//         platform: {
//             database: 'postgres',
//             auth: 'local',
//             authorization: 'local',
//             frontend: 'react',
//         },
//     });

//     expect(authProvider)
//         .toHaveBeenCalledOnce();
// });

// it('calls selected authorization provider', () => {
//     const provider = vi.fn();

//     const registry = new PlatformRegistry();

//     registry.addAuthorizationProvider('local', provider);

//     registry.configure({
//         platform: {
//             database: 'postgres',
//             auth: 'local',
//             authorization: 'local',
//             frontend: 'react',
//         },
//     });

//     expect(provider)
//         .toHaveBeenCalledOnce();
// });

// it('calls selected authorization provider', () => {
//     const provider = vi.fn();

//     const registry = new PlatformRegistry();

//     registry.addAuthorizationProvider('local', provider);

//     registry.configure({
//         platform: {
//             database: 'postgres',
//             auth: 'local',
//             authorization: 'local',
//             frontend: 'react',
//         },
//     });

//     expect(provider)
//         .toHaveBeenCalledOnce();
// });

// it('calls selected frontend provider', () => {
//     const provider = vi.fn();

//     const registry = new PlatformRegistry();

//     registry.addFrontendProvider('react', provider);

//     registry.configure({
//         platform: {
//             database: 'postgres',
//             auth: 'local',
//             authorization: 'local',
//             frontend: 'react',
//         },
//     });

//     expect(provider)
//         .toHaveBeenCalledOnce();
// });
