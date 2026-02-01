/** @type {import('tailwindcss').Config} */
export default {
    content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
    theme: {
        extend: {
            colors: {
                'ink-deep': '#1a1625',
                'ink-medium': '#2d2640',
                'ink-light': '#3d3654',
                'ink-pale': '#f8f6f4',
                'ink-cream': '#fdfcfb',
                'neon-mint': '#3DFFA2',
                'neon-coral': '#FF6B6B',
                'neon-gold': '#FFD93D',
                'neon-sky': '#6BCFFF',
                'roblox-red': '#E2231A',
            },
            fontFamily: {
                display: ['Space Grotesk', 'sans-serif'],
                body: ['Pretendard', 'sans-serif'],
                code: ['JetBrains Mono', 'monospace'],
            },
        },
    },
    plugins: [],
};
