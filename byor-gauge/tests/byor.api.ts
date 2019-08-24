// https://bugdiver.dev/gauge-ts/#/

import { expect } from 'chai';

import { Step } from 'gauge-ts';
import { tap, map, concatMap } from 'rxjs/operators';

import { ProtoTable } from './proto-table.types';

import {
  setAdministrator,
  login,
  cancelInitiative,
  createInitiative,
  createVotingEvent,
  addAdministratorToVotingEvent,
  addAdministratorToInitiative,
  setTechnologiesForVotingEvent,
  loadUsersForVotingEvent,
  openVotingEvent,
  getVotingEvent,
  saveVotes,
  getVotes,
  closeVotingEvent,
  calculateBlips,
  moveToNexFlowStep,
  getVotesWithCommentsForTechAndEvent,
  addReplyToVoteComment
} from './byor.api.functions';
import { VoteCredentialized } from '../models/vote-credentialized';
import { VoteCredentials } from '../models/vote-credentials';
import { Vote } from '../models/vote';
import { VotingEvent } from '../models/voting-event';
import { Comment } from '../models/comment';

export default class BYOR_APIs {
  private executionContext: {
    token: string;
    initiativeNameIdMap: { [name: string]: string };
    votingEventNameIdMap: { [name: string]: string };
    selectedVotingEvent: VotingEvent;
    votesOnSelectedTechnology: Vote[];
  } = { token: null, initiativeNameIdMap: {}, votingEventNameIdMap: {}, selectedVotingEvent: null, votesOnSelectedTechnology: null };

  @Step('Set administrator with userId <userId> and pwd <pwd>.')
  public setAdministrator(userId: string, pwd: string) {
    const defaultAdminID = 'abc';
    const defaultAdminPwd = '123';
    return setAdministrator(userId, pwd, defaultAdminID, defaultAdminPwd).toPromise();
  }

  @Step('Login BYOR with user id <userId> and pwd <pwd>')
  public login(userId: string, pwd: string) {
    return login(userId, pwd)
      .pipe(
        tap(({ token, pwdInserted }: { token: string; pwdInserted: boolean }) => {
          expect(token).to.be.not.undefined;
          expect(pwdInserted).to.be.not.undefined;
          this.executionContext.token = token;
        })
      )
      .toPromise();
  }

  @Step('Cancel the initiative <initiativeName>')
  public cancelInitiative(initiativeName: string) {
    return cancelInitiative(initiativeName, this.executionContext.token, true).toPromise();
  }

  @Step('Create the initiative <initiativeName>')
  public createInitiative(initiativeName: string) {
    return createInitiative(initiativeName, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data).to.be.not.undefined; // contains the initiative id
          expect(data.error).to.be.undefined;
        }),
        tap((data) => {
          this.executionContext.initiativeNameIdMap[initiativeName] = data;
        })
      )
      .toPromise();
  }

  @Step('Add administrator <administratorId> to initiative <initiativeName>')
  public addAdministratorToInitiative(administrator: string, initiativeName: string) {
    const initiativeId = this.executionContext.initiativeNameIdMap[initiativeName];
    return addAdministratorToInitiative(initiativeId, administrator, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('Create <votingEventName> for <initiativeName> with config <configFileName>')
  public createVotingEvent(votingEventName: string, initiativeName: string, configFileName: string) {
    return createVotingEvent(votingEventName, initiativeName, configFileName, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data).to.be.not.undefined; // contains the votingEvent id
          expect(data.error).to.be.undefined;
        }),
        tap((data) => {
          this.executionContext.votingEventNameIdMap[votingEventName] = data;
        })
      )
      .toPromise();
  }

  @Step('Add <administrator> for <votingEventName>')
  public addAdministratorToVotingEvent(administrator: string, votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return addAdministratorToVotingEvent(votingEventId, administrator, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('Set technologies for <votingEventName>')
  public setTechnologiesForVotingEvent(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return setTechnologiesForVotingEvent(votingEventId, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('Load users for <votingEventName>')
  public loadUsersForVotingEvent(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return loadUsersForVotingEvent(votingEventId, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('Open the voting event <votingEventName>')
  public openVotingEvent(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return openVotingEvent(votingEventId, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('<voterNickname> in <votingEventName> gives the votes <votesTable>')
  public saveVotes(voterNickname: string, votingEventName: string, votesTable: ProtoTable<string>) {
    return this._saveVotes(voterNickname, votingEventName, votesTable)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('<voterNickname> corrects the vote in <votingEventName> <votesTable>')
  public updateVote(voterNickname: string, votingEventName: string, votesTable: ProtoTable<string>) {
    return this._saveVotes(voterNickname, votingEventName, votesTable, true)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  private _saveVotes(voterNickname: string, votingEventName: string, votesTable: ProtoTable<string>, override = false) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return getVotingEvent(votingEventId).pipe(
      map((data) => data.technologies),
      map((technologies) => {
        const voteCredentials: VoteCredentials = {
          voterId: { nickname: voterNickname },
          votingEvent: { _id: votingEventId }
        };
        const votes: Vote[] = votesTable.rows.map((r) => {
          const technology = technologies.find((t) => t.name === r.cells[0]);
          if (!technology) {
            throw `Technology ${r.cells[0]} not found among the technologies of voting event ${votingEventName}`;
          }
          const vote: Vote = {
            technology,
            ring: r.cells[1]
          };
          if (r.cells[2].trim().length > 0) {
            vote.comment = { text: r.cells[2] };
          }
          if (r.cells[3].trim().length > 0) {
            vote.tags = [r.cells[3]];
          }
          return vote;
        });
        let voteCredentialized: VoteCredentialized = {
          credentials: voteCredentials,
          votes,
          override
        };
        return voteCredentialized;
      }),
      concatMap((voteCredentialized) => {
        return saveVotes(voteCredentialized);
      })
    );
  }

  @Step('Close the voting event <votingEventName>')
  public closeVotingEvent(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return closeVotingEvent(votingEventId, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('Fetch the votes posted in <votingEventName>')
  public getVotes(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return getVotes(votingEventId)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        }),
        tap((votes) => {
          expect(votes.length).equal(12); // 12 are the votes posted in the voting session
        })
      )
      .toPromise();
  }

  @Step('Calculate the blips for <votingEventName>')
  public calculateBlips(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return calculateBlips(votingEventId, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        }),
        tap((blips) => {
          expect(blips.length).equal(5); // The votes posted are for 5 different technologies and therefore generate 5 blips
        })
      )
      .toPromise();
  }

  @Step('Move <votingEventName> to the next step in the flow')
  public moveToNexFlowStep(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return moveToNexFlowStep(votingEventId, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('Fetch voting event <votingEventName> to see all votes and comments')
  public getVotingEvent(votingEventName: string) {
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return getVotingEvent(votingEventId)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        }),
        tap((votingEvent) => {
          const totalNumberOfVotes = votingEvent.technologies.reduce((acc, tech) => {
            acc = tech.numberOfVotes ? acc + tech.numberOfVotes : acc;
            return acc;
          }, 0);
          expect(totalNumberOfVotes).equal(12); // in total Hare, Snail and Wise Man have posted 12 votes
          const totalNumberOfComments = votingEvent.technologies.reduce((acc, tech) => {
            acc = tech.numberOfComments ? acc + tech.numberOfComments : acc;
            return acc;
          }, 0);
          expect(totalNumberOfComments).equal(9); // in total Hare, Snail and Wise Man have posted 9 comments
        }),
        tap((votingEvent) => (this.executionContext.selectedVotingEvent = votingEvent))
      )
      .toPromise();
  }

  @Step('Look at the details of the votes for <technologyName> in event <votingEventName>')
  public getVotesWithCommentsForTechAndEvent(technologyName: string, votingEventName: string) {
    return this._getVotesWithCommentsForTechAndEvent(technologyName, votingEventName)
      .pipe(
        tap((votes: Vote[]) => {
          expect(votes.length).equal(2); // 2 votes have been posted on Data Lake
          votes.forEach((v) => expect(v.comment).to.be.not.undefined);
        }),
        tap((votes: Vote[]) => {
          this.executionContext.votesOnSelectedTechnology = votes;
        })
      )
      .toPromise();
  }

  private _getVotesWithCommentsForTechAndEvent(technologyName: string, votingEventName: string) {
    const technologyId = this.executionContext.selectedVotingEvent.technologies.find((tech) => tech.name === technologyName)._id;
    const votingEventId = this.executionContext.votingEventNameIdMap[votingEventName];
    return getVotesWithCommentsForTechAndEvent(technologyId, votingEventId, this.executionContext.token).pipe(
      tap((data) => {
        expect(data.error).to.be.undefined;
      })
    );
  }

  @Step('Respond <commentText> to the first comment of <voterNickname>')
  public addReplyToVoteComment(commentText: string, voterNickname: string) {
    const selectedVote = this.executionContext.votesOnSelectedTechnology.find(
      (vote) => vote.voterId.nickname === voterNickname.toUpperCase()
    );
    const voteId = selectedVote._id;
    const replay: Comment = { text: commentText };
    const commentReceivingReplyId = selectedVote.comment.id;
    return addReplyToVoteComment(voteId, replay, commentReceivingReplyId, this.executionContext.token)
      .pipe(
        tap((data) => {
          expect(data.error).to.be.undefined;
        })
      )
      .toPromise();
  }

  @Step('Look at details of <technologyName> in event <votingEventName> after <userId> added a replay to a comment of <voterNickname>')
  public getVotesWithCommentsForTechAndEventAfterOneReplayAdded(
    technologyName: string,
    votingEventName: string,
    userId: string,
    voterNickname: string
  ) {
    return this._getVotesWithCommentsForTechAndEvent(technologyName, votingEventName)
      .pipe(
        tap((votes: Vote[]) => {
          const selectedVote = votes.find((vote) => vote.voterId.nickname === voterNickname.toUpperCase());
          expect(selectedVote.comment.replies).to.be.not.undefined;
          expect(selectedVote.comment.replies.length).equal(1);
          expect(selectedVote.comment.replies[0].author).equal(userId);
        }),
        tap((votes: Vote[]) => {
          this.executionContext.votesOnSelectedTechnology = votes;
        })
      )
      .toPromise();
  }
}
