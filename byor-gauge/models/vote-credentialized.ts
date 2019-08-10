import { Vote } from './vote';
import { VoteCredentials } from './vote-credentials';

export interface VoteCredentialized {
    credentials: VoteCredentials;
    votes: Vote[];
    override?: boolean;
}
