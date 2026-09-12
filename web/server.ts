import 'dotenv/config'
import express from 'express'
import { apiApp } from './api.ts'

const app = express()
app.use('/api', apiApp)
const port = Number(process.env.PORT || 3001)
app.listen(port, () => console.log(`SmartBridge API 已启动： http://localhost:${port}/api/health`))
