export type SiteConfig = typeof siteConfig

export const siteConfig = {
  name: "Expensy",
  description:
    "Lightweight Expense tracker app built with NextJs",
  mainNav: [
    {
      title: "Home",
      href: "/",
    },
  ],
  links: {
    home: "/home",
  },
}

// comment just to trigger the CI/CD pipeline