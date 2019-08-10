// https://bugdiver.dev/gauge-ts/#/

import {expect} from 'chai';

import { Step } from "gauge-ts";
import {connectObs, findObs} from 'observable-mongo';
import {tap, delay, toArray,} from 'rxjs/operators'
import { MongoClient } from 'mongodb';

export default class MongoSteps {

    private mongoClient: MongoClient;

    @Step("Connect with URI <uri>")
    public async connectWithURI(uri: string) {
        await this._connect(uri);
        // connectObs(uri).pipe(
        //     tap(client => this.mongoClient = client),
        //     // tap(client => expect(client).to.be.undefined),
        //     tap(client => console.log(client)),
        // ).subscribe();
    }

    @Step("Read the users")
    public async readUsers() {
        await this._readUsers();
    }

    @Step("Close the connection")
    public async closeDb() {
        await this._closeConnection();
    }

    @Step("Print on console <something>")
    public async printOnConsole(something) {
        await this.printSmt(something);
    }

    private _connect(uri: string) {
        return connectObs(uri).pipe(
            tap(client => this.mongoClient = client),
            delay(10000),
            // tap(client => expect(client).to.be.undefined),
            // tap(client => console.log(client)),
        ).toPromise();
    }
    private _readUsers() {
        const usersColl = this.mongoClient.db('byorDev1').collection('users');
        return findObs(usersColl).pipe(
            toArray(),
            tap(users => console.log('Number of users:', users.length)),
        ).toPromise();
    }
    private _closeConnection() {
        return this.mongoClient.close();    
    }

    private async printSmt(something) {
        console.log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', something);
    }

}

