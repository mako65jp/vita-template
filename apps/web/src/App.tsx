import { AppLayout, HeaderContent, SidebarNav, Button } from '@app/ui';

export function App() {
  const navItems = [
    { label: 'ダッシュボード', href: '#', active: true },
    { label: 'プロジェクト一覧', href: '#' },
    { label: '設定', href: '#' },
  ];

  return (
    <AppLayout
      header={<HeaderContent title="管理システム" />}
      sidebar={<SidebarNav items={navItems} />}
    >
      <div className="flex flex-col gap-6">
        <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900 mb-2">メインコンテンツエリア</h2>
          <p className="text-sm text-gray-600 mb-4">
            共通 Layout コンポーネント（AppLayout / HeaderContent / SidebarNav）が正常に機能しています。
          </p>
          <div className="flex gap-2">
            <Button variant="default">アクション 1</Button>
            <Button variant="outline">アクション 2</Button>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}

export default App;
