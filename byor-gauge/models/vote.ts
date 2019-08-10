import { Technology } from './technology';
import { Comment } from './comment';
import { ObjectId } from 'mongodb';

export interface Vote {
  technology: Technology;
  ring: string;
  comment?: Comment;
  tags?: string[];
}
