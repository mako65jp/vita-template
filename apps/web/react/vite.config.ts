import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import fs from 'node:fs';
import { defineConfig } from 'vite';

const configuration = JSON.parse(fs.readFileSync('../../../config/development.json', 'utf-8'));

export default defineConfig({
    plugins: [
        react(),
        tailwindcss(),
        {
            name: 'application-configuration',

            transformIndexHtml(html) {
                return html.replace(
                    '__APPLICATION_CONFIGURATION__',
                    JSON.stringify({
                        backend: configuration.backend,
                    }),
                );
            },
        },
    ],
});

// import { defineConfig } from 'vite';
// import react from '@vitejs/plugin-react';

// export default defineConfig({
//     plugins: [react()],

//     server: {
//         proxy: {
//             '/api': {
//                 target: 'http://localhost:3000',
//                 changeOrigin: true,
//             },
//         },
//     },
// });
