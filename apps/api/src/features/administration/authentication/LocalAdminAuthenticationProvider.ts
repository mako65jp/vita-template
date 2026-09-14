import { AdminAuthenticationProvider } from './AdminAuthenticationProvider';

export class LocalAdminAuthenticationProvider implements AdminAuthenticationProvider {
    async authenticate() {
        return true;
    }
}
