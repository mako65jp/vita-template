// import { ConfigLoader } from "./ConfigLoader";
// import { PlatformConfigurator } from "./PlatformConfigurator";

// export class Bootstrap {
//     constructor(
//         private readonly configLoader: ConfigLoader,
//         private readonly platformConfigurator: PlatformConfigurator,
//     ) { }
//     start(): void {
//         const config =
//             this.configLoader.load();

//         this.platformConfigurator.configure(
//             config,
//         );
//     }
// }

import type {
    ConfigLoader,
} from './ConfigLoader';

import type {
    PlatformSelection,
} from './PlatformSelection';

export class Bootstrap {

    constructor(
        private readonly configLoader:
            ConfigLoader,
    ) { }

    loadSelection():
        PlatformSelection {

        const config =
            this.configLoader.load();

        return config.platform;
    }
}
