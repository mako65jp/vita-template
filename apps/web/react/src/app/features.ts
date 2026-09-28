// src/app/features.ts

import { FeatureDefinition } from './FeatureDefinition';

const modules = import.meta.glob('../features/**/Feature.tsx', {
    eager: true,
});

console.log(`自動認識機能：${Object.keys(modules)}`);

export const features = Object.values(modules).map(
    (x) => (x as { default: FeatureDefinition }).default,
);

export const menus = features
    .filter((feature) => feature.menu)
    .sort((a, b) => (a.menu?.order ?? 9999) - (b.menu?.order ?? 9999));

export const defaultPath = menus[0]?.menu?.path ?? '/';
