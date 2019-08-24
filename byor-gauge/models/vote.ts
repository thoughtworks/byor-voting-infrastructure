import { Technology } from './technology';
import { Comment } from './comment';
import { ObjectId } from 'mongodb';

export interface Vote {
  _id?: string;
  technology: Technology;
  ring: string;
  voterId?: { nickname?: string; userId?: string };
  comment?: Comment;
  tags?: string[];
}
