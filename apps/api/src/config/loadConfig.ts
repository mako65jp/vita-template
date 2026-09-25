import { readFile } from 'node:fs/promises';

import { Config } from './Config';

export async function loadConfig(): Promise<Config> {
    const json = await readFile('./config/development.json', 'utf8');
    const config = JSON.parse(json) as Config;

    if (config.backend.applicationRoot == undefined) {
        config.backend.applicationRoot = '/api';
    }
    if (config.backend.host == undefined) {
        config.backend.host = 'localhost';
    }
    if (config.backend.port == undefined) {
        config.backend.port = '3000';
    }
    if (config.backend.protocol == undefined) {
        config.backend.protocol = 'http';
    }

    if (config.authentication.secret == undefined) {
        config.authentication.secret = 'change-this-secret';
    }

    if (config.frontend.host == undefined) {
        config.frontend.host = 'localhost';
    }

    return config;
}
