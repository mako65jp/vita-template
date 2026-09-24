export interface AdminAuthenticationProvider {
    authenticate(email: string, password: string): Promise<boolean>;
}
