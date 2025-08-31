import type { SidebarConfig } from '@vuepress/theme-default';


/**
 * Sidebar links.
 */
export const sidebar: SidebarConfig = {
    "/tutorial/": [
        "/tutorial/index.md",
        "/tutorial/method.md",
        // {
        //     text: 'Applications',
        //     collapsible: true,
        //     children: [
        //         "/tutorial/application/power-psychological-networks.md",
        //         "/tutorial/application/power-structural-equation-modeling.md",
        //         "/tutorial/application/power-multilevel-models.md",
        //     ]
        // },
        // {
        //     text: 'FAQ',
        //     collapsible: true,
        //     children: [
        //         "/tutorial/faq/choosing-the-initial-range.md",
        //         "/tutorial/faq/validating-the-results.md",
        //         "/tutorial/faq/choosing-the-true-model.md",
        //     ]
        // },
    ],
    "/reference/": [
        {
            text: "Reference",
            link: "/reference/index.md"
        },
        {
            text: 'Functions',
            collapsible: false,
            children: [
                {
                    text: "generate_model",
                    link: "/reference/function/generate-model.md"
                },
                {
                    text: "powerly",
                    link: "/reference/function/powerly.md"
                },
                {
                    text: "validate",
                    link: "/reference/function/validate.md"
                }
            ]
        },
        {
            text: 'Methods',
            collapsible: true,
            children: [
                {
                    text: "plot.Method",
                    link: "/reference/method/plot-method.md"
                },
                {
                    text: "plot.Validation",
                    link: "/reference/method/plot-validation.md"
                },
                {
                    text: "summary",
                    link: "/reference/method/summary.md"
                }
            ]
        }
    ],
    "/publications/": [
        "/publications/index.md",
    ],
    "/developer/": [
        "/developer/index.md",
    ]
}
