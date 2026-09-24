export interface ApplicationConfiguration {
    readonly backend: {
        readonly protocol: string;
        readonly host: string;
        readonly port: number;
        readonly applicationRoot: string;
    };
}

// export interface ApplicationConfiguration {
//     readonly apiBaseUrl: string;
// }
