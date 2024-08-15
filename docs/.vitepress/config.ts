import { defineConfig } from 'vitepress'

function sidebar() {
  return [
    { text: 'State', link: '/State' },
    { text: 'Grid', link: '/Grid' },
    { text: 'Quest', link: '/Quest' },
    { text: 'Test', link: '/Test' },
    { text: 'Tween', link: '/Tween' },
  ]
}

export default defineConfig({
  base: '/RobloxLibs/',
  title: 'RobloxLibs',
  description: 'A collection of libraries to speed up roblox development.',
  lang: 'en-US',
  head: [
    // ['link', { rel: 'icon', href: '/favicon.png' }],
  ],
  themeConfig: {
    logo: '/logo.png',
    // siteTitle: false,
    outline: 'deep',
    socialLinks: [
      { icon: 'github', link: 'https://github.com/Parihsz/RobloxLibs' },
    ],
    nav: [
      { text: 'Installing', link: '/installing' },
    ],
    sidebar: sidebar(),
  }
})
