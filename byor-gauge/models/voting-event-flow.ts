import { VotingEventStep } from './voting-event-step';
export interface VotingEventFlow {
  name: string;
  steps: VotingEventStep[];
}
