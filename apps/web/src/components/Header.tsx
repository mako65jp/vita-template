import { clientEnv } from '@shared/client';

export const Header = () => {
  return (
    <header>
      <h1>{clientEnv.VITE_APP_TITLE}</h1>
    </header>
  );
};
