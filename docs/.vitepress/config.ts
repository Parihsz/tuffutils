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
  base: '/Schlop/',
  title: 'Schlop',
  description: 'Schlop',
  lang: 'en-US',
  head: [
    // ['link', { rel: 'icon', href: '/favicon.png' }],
  ],
  themeConfig: {
    logo: '/logo.png',
    // siteTitle: false,
    outline: 'deep',
    socialLinks: [
      { icon: 'github', link: 'https://github.com/Parihsz/Schlop' },
    ],
    nav: [
      { text: 'Installing', link: '/installing' },
    ],
    sidebar: sidebar(),
  }
})
