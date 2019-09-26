import { Comment } from './comment';

export interface Technology {
  _id?: string;
  name: string;
  quadrant: string;
  is_new: boolean;
  numberOfVotes?: number;
  numberOfComments?: number;
  comments?: Comment[];
  recommendation?: Recommendation;
}

export interface Recommendation {
  author?: string;
  ring?: string;
  text?: string;
  timestamp?: string;
}
