import { Technology } from './technology';
import { VotingEventFlow } from './voting-event-flow';
import { User } from './user';
import { Roles } from './roles';

export type VotingEventStatus = 'open' | 'closed';

export interface VotingEvent {
  _id?: any;
  name: string;
  status?: VotingEventStatus;
  creationTS?: string;
  lastOpenedTS?: string;
  lastClosedTS?: string;
  technologies?: Technology[];
  round?: number;
  openForRevote?: boolean;
  hasTechnologiesForRevote?: boolean;
  url?: string;
  flow?: VotingEventFlow;
  owner: User;
  roles?: Roles;
  initiativeName?: string;
  initiativeId?: string;
}
