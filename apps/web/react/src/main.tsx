import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { App } from './app/App'
import { AuthProvider } from './app/providers/AuthProvider'
// アプリ全体のスタイル（CSS）をインポートしている場合はここに記述します
import './index.css'

createRoot(document.getElementById('root')!).render(
    <StrictMode>
        <AuthProvider>
            <App />
        </AuthProvider>
    </StrictMode>,
)
