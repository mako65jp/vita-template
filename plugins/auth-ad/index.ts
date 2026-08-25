import { Client } from 'ldapts';
import { AuthPlugin, AuthUser, env } from '@shared/functions';

export class ActiveDirectoryAuthPlugin implements AuthPlugin {
    name = 'ad';

    async authenticate(credentials: Record<string, any>): Promise<AuthUser> {
        const { username, password, email } = credentials;
        const loginId = username || email;

        if (!loginId || !password) {
            throw new Error('ユーザー名（またはメールアドレス）とパスワードを入力してください。');
        }

        const ldapUrl = env.LDAP_URL;
        const ldapDomain = env.LDAP_DOMAIN;

        if (!ldapUrl || !ldapDomain) {
            throw new Error('LDAP_URL または LDAP_DOMAIN が設定されていません。');
        }

        const client = new Client({ url: ldapUrl });

        try {
            const accountName = loginId.split('@')[0];
            const userPrincipalName = `${accountName}@${ldapDomain}`;

            await client.bind(userPrincipalName, password);

            return {
                id: accountName,
                email: loginId.includes('@') ? loginId : `${accountName}@${ldapDomain}`,
                name: accountName,
                role: 'user',
            };
        } catch (error) {
            throw new Error('Active Directory authentication failed');
        } finally {
            await client.unbind().catch(() => { });
        }
    }
}
