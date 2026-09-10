// // apps/platform/AppConfig.ts

// import { PlatformConfig } from "./PlatformConfig";

// export interface AppConfig {
//     platform: PlatformConfig;
// }

import type {
    PlatformSelection,
} from './PlatformSelection';

export interface AppConfig {
    platform: PlatformSelection;
}
