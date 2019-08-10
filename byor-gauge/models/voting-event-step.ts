export type IdentificationTypeNames = 'nickname' | 'login' | 'anonymous';
export type ActionNames = 'vote' | 'conversation' | 'recommendation';
export type TechSelectLogic = 'TechWithComments' | 'TechUncertain';

export interface VotingEventStep {
    name: string;
    description?: string;
    identification: { name: IdentificationTypeNames; groups?: string[] };
    action: {
        name: ActionNames;
        parameters?: {
            commentOnVoteBlocked?: boolean;
            techSelectLogic?: TechSelectLogic;
            displayVotesAndCommentNumbers?: boolean;
            tags?: string[];
            allowTagsOnVote?: boolean;
        };
    };
}
