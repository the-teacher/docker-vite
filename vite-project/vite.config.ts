import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// console.log("VITE CONFIG")

const viteConfig = defineConfig({
  build: {
    manifest: true
  },
  plugins: [vue()],
})

// it helps to debug `viteConfig`
// console.log(viteConfig)

// https://vitejs.dev/config/
export default viteConfig
