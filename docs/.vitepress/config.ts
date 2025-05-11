import { defineConfig } from 'vitepress'

function sidebar() {
  return [
    { text: 'State', link: '/State' },
    { text: 'Grid', link: '/Grid' },
    { text: 'Quest', link: '/Quest' },
    { text: 'Snapshots', link: '/Snapshots' },
    { text: 'Test', link: '/Test' },
  ]
}

export default defineConfig({
  base: '/tuffutils/',
  title: 'tuffutils',
  description: 'tuffutils',
  lang: 'en-US',
  head: [
    // ['link', { rel: 'icon', href: '/favicon.png' }],
  ],
  themeConfig: {
    logo: '/logo.png',
    // siteTitle: false,
    outline: 'deep',
    socialLinks: [
      { icon: 'github', link: 'https://github.com/Parihsz/tuffutils' },
    ],
    nav: [
      { text: 'Installing', link: '/installing' },
    ],
    sidebar: sidebar(),
  }
})
