import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

console.log('%c智触心桥 SmartBridge%c\n方括号千抹两份米饭队 制作', 'font-size:20px;font-weight:900;color:#0e7c86;', 'font-size:13px;color:#5f7482;')

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
