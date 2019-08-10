export const APPLICATION_ADMIN = 'admin';

export interface User {
    user: string;
    pwd?: string;
    groups?: string[];
    roles?: string[];
}