import fs from 'node:fs'
import path from 'node:path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const certDir = path.resolve(__dirname, '../certs')

export default defineConfig({
  plugins: [react()],
  server: {
    https: {
      key: fs.readFileSync(path.join(certDir, 'server.key')),
      cert: fs.readFileSync(path.join(certDir, 'server.crt')),
    },
    port: 5173,
    proxy: {
      '/api': {
        target: 'https://localhost:8443',
        secure: false,
      },
    },
  },
})
