export interface AdminAuthenticationProvider {
    authenticate(userName: string, password: string): Promise<boolean>;
}
