// 例: apps/web/src/components/Header.tsx
import { clientEnv } from '@app/core';

export const Header = () => {
  return (
    <header>
      <h1>{clientEnv.VITE_APP_TITLE}</h1>
    </header>
  );
};
