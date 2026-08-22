import { describe, it, expect, vi, beforeEach } from 'vitest';
import { toast, showErrorToast } from './toaster';

// sonner の toast 関数をモック化
vi.mock('sonner', async () => {
  const actual = await vi.importActual('sonner');
  return {
    ...actual,
    toast: {
      error: vi.fn(),
      success: vi.fn(),
    },
  };
});

describe('showErrorToast Utility', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('RFC 9457 形式 (ProblemDetails) のエラーオブジェクトを受け取った場合、title と detail を表示すること', () => {
    const problemDetails = {
      type: 'https://example.com/errors/invalid',
      title: 'バリデーションエラー',
      status: 400,
      detail: '入力値が不適切です。',
    };

    showErrorToast(problemDetails);

    expect(toast.error).toHaveBeenCalledWith('バリデーションエラー', {
      description: '入力値が不適切です。',
    });
  });

  it('Standard Error オブジェクトを受け取った場合、message を表示すること', () => {
    const error = new Error('ネットワーク接続に失敗しました');

    showErrorToast(error);

    expect(toast.error).toHaveBeenCalledWith('エラーが発生しました', {
      description: 'ネットワーク接続に失敗しました',
    });
  });

  it('不明なエラータイプ（文字列や null 等）を受け取った場合、デフォルトのエラーメッセージを表示すること', () => {
    showErrorToast('Unknown Error String');

    expect(toast.error).toHaveBeenCalledWith('エラーが発生しました', {
      description: '通信エラーまたは予期せぬエラーです。',
    });
  });
});
