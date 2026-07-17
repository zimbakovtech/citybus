import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// Served from the root of the custom domain (citybus.zimbakov.dev),
// so the default base of '/' is correct.
export default defineConfig({
  plugins: [react(), tailwindcss()],
})
