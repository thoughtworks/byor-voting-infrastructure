import { httpPostRequestObs } from 'observable-http-request';
import { tap, map, } from 'rxjs/operators';
import { loggedUserId } from './loggedUserId';

const byorServerUrl = process.env['BYOR_SERVER_URL'] || 'http://localhost:3000/';

export function createPostRequestObs(body: any, authToken?: any) {
  // to be removed once aws lambda implementation is able to receive authentication header
  console.log('loggedUserId', loggedUserId.loggedUserId);
  body['userId'] = loggedUserId.loggedUserId;

  return httpPostRequestObs(byorServerUrl, body, authToken).pipe(
    tap((resp) => {
      if (resp.statusCode !== 200) {
        const errMsg = `The http post request for service "${body.service}" returned statusCode equal to ${resp.statusCode}
        Resp body is ${JSON.stringify(resp.body, null, 2)}`;
        throw new Error(errMsg);
      }
    }),
    map((resp) => resp.body)
  );
}
