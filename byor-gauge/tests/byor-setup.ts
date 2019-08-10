// https://bugdiver.dev/gauge-ts/#/

import { expect } from 'chai';

import { Step } from 'gauge-ts';
import { connectObs, updateOneObs } from 'observable-mongo';
import { concatMap, tap } from 'rxjs/operators';
import { httpPostRequestObs } from 'observable-http-request';

export default class BYOR_Setup {
  private executionContext: {
    authorizationHeaders: {
      authorization: string;
    };
  } = { authorizationHeaders: null };

  @Step(
    'Set administrator with userId <userId> and pwd <pwd>. The default admin credentials after installation are: id <defaultAdminID> and pwd <defaultAdminPwd>'
  )
  public async setAdministrator(userId: string, pwd: string, defaultAdminID: string, defaultAdminPwd: string) {
    this._setAdministrator(userId, pwd, defaultAdminID, defaultAdminPwd)
      .pipe(
        tap((resp) => {
          expect(resp.statusCode).equal(200);
        })
      )
      .toPromise();
  }

  private _setAdministrator(userId: string, pwd: string, defaultAdminID: string, defaultAdminPwd: string) {
    console.log('here');
    const body = {
      service: 'setAdminUserAndPwd',
      adminUserName: defaultAdminID,
      adminPwd: defaultAdminPwd,
      newAdminUsername: userId,
      newAdminPassword: pwd
    };
    return httpPostRequestObs('http://localhost:3000/', body);
  }

  private async printSmt(something) {
    console.log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', something);
  }
}
