export interface Comment {
  text: string;
  id?: string;
  author?: string;
  replies?: Comment[];
}
