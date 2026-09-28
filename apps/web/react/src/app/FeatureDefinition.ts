// src/app/FeatureDefinition.ts

import { RouteObject } from 'react-router-dom';

export interface FeatureDefinition {
    readonly id: string;

    readonly menu?: {
        readonly title: string;
        readonly path: string;
        readonly order?: number;
    };

    readonly routes?: RouteObject[];
}
