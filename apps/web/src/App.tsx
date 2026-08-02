import React from 'react';
import { env } from './env';
import { LoginForm } from './components/LoginForm.tsx';

export default function App() {
  return (
    <div>
      <h1>DevContainer + Docker Compose {env.VITE_APP_TITLE}</h1>
      <LoginForm />
    </div>
  );
}
