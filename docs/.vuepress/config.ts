import { defineUserConfig } from "vuepress";
import { defaultTheme } from "vuepress";
import { sidebar, navbar, head } from "./configs";
import { shikiPlugin } from "@vuepress/plugin-shiki";
import { katexPlugin } from "@renovamen/vuepress-plugin-katex";
import { getDirname, path } from "@vuepress/utils";
import { registerComponentsPlugin } from "@vuepress/plugin-register-components";

// Get directory name.
const __dirname = getDirname(import.meta.url);

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
        // Syntax highlighting plugin.
        shikiPlugin({
            theme: "dark-plus"
        }),

        // LaTeX plugin.
        // @ts-ignore
        katexPlugin(),

        // Register components automatically.
        // @ts-ignore
        registerComponentsPlugin({
            componentsDir: path.resolve(__dirname, './components')
        })
    ]
})
