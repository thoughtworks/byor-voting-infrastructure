import { httpPostRequestObs } from 'observable-http-request';
import { tap, map } from 'rxjs/operators';

const byorServerUrl = 'http://localhost:3000/';

export function createPostRequestObs(body: any, authToken?: any) {
  return httpPostRequestObs(byorServerUrl, body, authToken).pipe(
    tap((resp) => {
      if (resp.statusCode !== 200) {
        throw `The http post request for service "${body.service}" returned statusCode equal to ${resp.statusCode}`;
      }
    }),
    map((resp) => resp.body.data)
  );
}
