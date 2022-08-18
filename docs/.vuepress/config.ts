import { defineUserConfig } from "vuepress"
import { defaultTheme } from "vuepress";
import { sidebar, navbar, head } from "./configs";
import { katexPlugin } from "@renovamen/vuepress-plugin-katex";
import { shikiPlugin } from '@vuepress/plugin-shiki';

/**
 * VuePress config.
 */
export default defineUserConfig({
    base: "/",
    lang: "en-US",
    title: "powerly",
    description: "Sample Size Analysis for Psychological Networks and more...",
    head: head,
    theme: defaultTheme({
        docsDir: "docs",
        docsBranch: "main",
        repoLabel: "GitHub",
        lastUpdated: true,
        contributors: true,
        navbar: navbar,
        sidebar: sidebar,
        sidebarDepth: 2,
        logo: "/images/logos/powerly-logo.png",
        repo: "https://github.com/mihaiconstantin/powerly",
        editLinkText: "Edit this page on GitHub"
    }),
    plugins: [
        // LaTeX plugin.
        katexPlugin(),

        // Syntax highlighting plugin.
        shikiPlugin({
            theme: "dark-plus"
        })
    ]
})
