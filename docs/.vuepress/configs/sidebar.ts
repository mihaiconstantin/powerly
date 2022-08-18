import type { SidebarConfig } from '@vuepress/theme-default';


/**
 * Sidebar links.
 */
export const sidebar: SidebarConfig = {
    "/tutorial/": [
        "/tutorial/index.md",
        "/tutorial/method.md",
        {
            text: 'Applications',
            collapsible: true,
            children: [
                "/tutorial/application/power-psychological-networks.md",
                "/tutorial/application/power-structural-equation-modeling.md",
                "/tutorial/application/power-multilevel-models.md",
            ]
        },
        {
            text: 'FAQ',
            collapsible: true,
            children: [
                "/tutorial/faq/choosing-the-initial-range.md",
                "/tutorial/faq/validating-the-results.md",
                "/tutorial/faq/choosing-the-true-model.md",
            ]
        },
    ],
    "/reference/": [
        "/reference/index.md",
    ],
    "/publication/": [
        "/publication/index.md",
    ],
    "/developer/": [
        "/developer/index.md",
    ]
}
