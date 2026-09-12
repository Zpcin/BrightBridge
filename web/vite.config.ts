import react from '@vitejs/plugin-react'
import 'dotenv/config'
import { defineConfig, type Connect, type Plugin } from 'vite'
import { apiApp } from './api.ts'

// 开发时把 Express 直接挂进 Vite，一条命令就能同时跑前端和 AI 接口。
function apiPlugin(): Plugin {
  const handler = apiApp as unknown as Connect.NextHandleFunction
  return {
    name: 'smartbridge-api',
    configureServer(server) {
      server.middlewares.use('/api', handler)
    },
    configurePreviewServer(server) {
      server.middlewares.use('/api', handler)
    },
  }
}

export default defineConfig({
  plugins: [react(), apiPlugin()],
  server: { host: true },
})
