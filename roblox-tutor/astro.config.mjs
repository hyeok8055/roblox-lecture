// @ts-check
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
    integrations: [tailwind()],
    // Lit 컴포넌트를 클라이언트에서 hydrate
    vite: {
        optimizeDeps: {
            include: ['lit', 'wasmoon']
        },
        ssr: {
            noExternal: ['lit']
        }
    }
});
