import { Credentials } from './credentials';

export interface VoteCredentials {
  voterId: Credentials;
  votingEvent: { _id: any };
}
