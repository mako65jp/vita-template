import { readFile } from 'node:fs/promises';

import { Config } from './Config';

export async function loadConfig(): Promise<Config> {
    const json = await readFile('./config/development.json', 'utf8');

    return JSON.parse(json) as Config;
}
