import { httpPostRequestObs } from 'observable-http-request';
import { tap, map, catchError } from 'rxjs/operators';
import { throwError, of } from 'rxjs';

const byorServerUrl = 'http://localhost:3000/';

export function createPostRequestObs(body: any, authToken?: any) {
  return httpPostRequestObs(byorServerUrl, body, authToken).pipe(
    tap((resp) => {
      if (resp.statusCode !== 200) {
        const errMsg = `The http post request for service "${body.service}" returned statusCode equal to ${resp.statusCode}
        Resp body is ${JSON.stringify(resp.body, null, 2)}`;
        throw new Error(errMsg);
      }
    }),
    map((resp) => resp.body.data)
  );
}
