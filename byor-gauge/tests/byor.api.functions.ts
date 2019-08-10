import { normalize } from 'path';

import { map, concatMap, toArray, skip } from 'rxjs/operators';

import { createPostRequestObs } from './byor.api.functions.utils';
import { readLinesObs, readLineObs } from 'observable-fs';

import { Technology } from '../models/technology';
import { VoteCredentialized } from '../models/vote-credentialized';
import { Observable } from 'rxjs';
import { Vote } from '../models/vote';

export function setAdministrator(userId: string, pwd: string, defaultAdminID: string, defaultAdminPwd: string) {
  const body = {
    service: 'setAdminUserAndPwd',
    adminUserName: defaultAdminID,
    adminPwd: defaultAdminPwd,
    newAdminUsername: userId,
    newAdminPassword: pwd
  };
  return createPostRequestObs(body);
}

export function login(user: string, pwd: string) {
  const body = {
    service: 'authenticateOrSetPwdIfFirstTime',
    user,
    pwd
  };
  return createPostRequestObs(body).pipe(
    map((data) => {
      const token = data.token;
      const pwdInserted = data.pwdInserted;
      return { token, pwdInserted };
    })
  );
}

export function cancelInitiative(initiativeName: string, headers: any, removeFromDb?: boolean) {
  let body = { service: 'cancelInitiative', name: initiativeName };
  const options = removeFromDb ? { hard: removeFromDb } : null;
  if (options) {
    body = { ...body, ...options };
  }
  return createPostRequestObs(body, headers);
}

export function createInitiative(initiativeName: string, headers: any) {
  const body = { service: 'createInitiative', name: initiativeName };
  return createPostRequestObs(body, headers);
}

export function addAdministratorToInitiative(initiativeId: string, administrator: string, headers: any) {
  const body = {
    service: 'loadAdministratorsForInitiative',
    _id: initiativeId,
    administrators: [administrator]
  };
  return createPostRequestObs(body, headers);
}

export function createVotingEvent(votingEventName: string, initiativeName: string, configFileName: string, headers: any) {
  const configFilePath = normalize(`${__dirname}/configurations/firstVotingEvent.smartCompany.json`);
  return readLinesObs(configFilePath).pipe(
    map((lines) => {
      const content = lines.join('');
      return JSON.parse(content);
    }),
    concatMap((flow) => {
      const body = {
        service: 'createVotingEvent',
        name: votingEventName,
        initiativeName,
        flow
      };
      return createPostRequestObs(body, headers);
    })
  );
}

export function addAdministratorToVotingEvent(votingEventId: string, administrator: string, headers: any) {
  const body = {
    service: 'loadAdministratorsForVotingEvent',
    votingEventId,
    administrators: [administrator]
  };
  return createPostRequestObs(body, headers);
}

export function setTechnologiesForVotingEvent(votingEventId: string, headers: any) {
  const configFilePath = normalize(`${__dirname}/configurations/technologies.csv`);
  return readLineObs(configFilePath).pipe(
    skip(1),
    map((line) => {
      const content = line.split(',');
      const is_new = content[2] === 'TRUE';
      const tech: Technology = { name: content[0], quadrant: content[1], is_new };
      return tech;
    }),
    toArray(),
    concatMap((technologies) => {
      const body = {
        service: 'setTechologiesForEvent',
        _id: votingEventId,
        technologies
      };
      return createPostRequestObs(body, headers);
    })
  );
}

export function loadUsersForVotingEvent(votingEventId: string, headers: any) {
  const configFilePath = normalize(`${__dirname}/configurations/users.csv`);
  return readLineObs(configFilePath).pipe(
    skip(1),
    map((line) => {
      const content = line.split(',');
      const usersRow = { user: content[0], group: content[1] };
      return usersRow;
    }),
    toArray(),
    concatMap((userRows) => {
      const body = {
        service: 'loadUsersForVotingEvent',
        votingEventId,
        users: userRows
      };
      return createPostRequestObs(body, headers);
    })
  );
}

export function openVotingEvent(votingEventId: string, headers: any) {
  let body = { service: 'openVotingEvent', _id: votingEventId };
  return createPostRequestObs(body, headers);
}

export function getVotingEvent(votingEventId: string) {
  let body = { service: 'getVotingEvent', _id: votingEventId };
  return createPostRequestObs(body);
}

export function saveVotes(voteCredentialized: VoteCredentialized) {
  const body = voteCredentialized;
  body['service'] = 'saveVotes';
  return createPostRequestObs(body);
}

export function getVotes(eventId: any, voterId?: { nickname?: string; userId?: string }): Observable<Vote[] & { error: any }> {
  let body = { service: 'getVotes', eventId, voterId };
  return createPostRequestObs(body);
}

export function closeVotingEvent(votingEventId: string, headers: any) {
  let body = { service: 'closeVotingEvent', _id: votingEventId };
  return createPostRequestObs(body, headers);
}

export function calculateBlips(votingEventId: string, headers: any) {
  let body = { service: 'calculateBlips', votingEvent: { _id: votingEventId } };
  return createPostRequestObs(body, headers);
}
