// import { AppConfig } from "./AppConfig";

// export interface ConfigLoader {
//     load(): AppConfig;
// }

import type {
    AppConfig,
} from './AppConfig';

export interface ConfigLoader {
    load(): AppConfig;
}
