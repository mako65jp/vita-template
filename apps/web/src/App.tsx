// apps/web/src/App.tsx
import { Button } from '@app/ui';

export function App() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 bg-gray-50 p-4">
      <h1 className="text-2xl font-bold text-gray-800">Step 6: UI Component Test</h1>
      <div className="flex gap-2">
        <Button variant="default" onClick={() => alert('Default Clicked')}>
          Default Button
        </Button>
        <Button variant="outline" onClick={() => alert('Outline Clicked')}>
          Outline Button
        </Button>
        <Button variant="destructive" onClick={() => alert('Destructive Clicked')}>
          Destructive Button
        </Button>
      </div>
    </div>
  );
}

export default App;

// import React from 'react';
// import { AuthProvider, useAuth } from './context/AuthContext';
// import { LoginForm } from './components/LoginForm';

// const MainContent: React.FC = () => {
//   const { user, logout, isAuthenticated, isLoading } = useAuth();

//   if (isLoading) {
//     return <div>読み込み中...</div>;
//   }

//   return (
//     <main style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
//       <h1>DevContainer + Docker Compose マイアプリケーション</h1>

//       {isAuthenticated && user ? (
//         <div style={{ marginTop: '1rem', padding: '1rem', border: '1px solid #ccc', borderRadius: '4px' }}>
//           <h2>ようこそ、{user.name || user.email} さん！</h2>
//           <p><strong>Email:</strong> {user.email}</p>
//           <p><strong>ID:</strong> {user.id}</p>
//           <button
//             onClick={logout}
//             style={{ padding: '0.5rem 1rem', marginTop: '1rem', cursor: 'pointer' }}
//           >
//             ログアウト
//           </button>
//         </div>
//       ) : (
//         <div style={{ marginTop: '1rem' }}>
//           <LoginForm />
//         </div>
//       )}
//     </main>
//   );
// };

// export function App() {
//   return (
//     <AuthProvider>
//       <MainContent />
//     </AuthProvider>
//   );
// }

// export default App;
