import type { NavbarConfig } from '@vuepress/theme-default';


/**
 * Navbar links.
 */
export const navbar: NavbarConfig = [
    {
        text: "Tutorials",
        link: "/tutorial/"
    },
    {
        text: "Reference",
        children: [
            {
                text: "Functions",
                children: [
                    {
                        text: "generate_model",
                        link: "/reference/function/generate-model.md",
                        activeMatch: 'function/generate-model.*$',
                    },
                    {
                        text: "powerly",
                        link: "/reference/function/powerly.md",
                        activeMatch: 'function/powerly.*$',
                    },
                    {
                        text: "validate",
                        link: "/reference/function/validate.md",
                        activeMatch: 'function/validate.*$',
                    }
                ]
            },
        ]
    },
    {
        text: "Publications",
        link: "/publication/"
    },
    {
        text: "Developer",
        link: "/developer/"
    },
    {
        text: "News",
        link: "https://github.com/mihaiconstantin/powerly/blob/main/NEWS.md"
    },
    {
        text: "CRAN",
        link: "https://CRAN.R-project.org/package=powerly"
    }
]
