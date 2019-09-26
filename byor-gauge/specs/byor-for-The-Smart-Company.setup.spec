# Setup of the first Voting Event
This spec can be used to setup a demo environment.
It uses guage with Typescript with the support of the following package
https://bugdiver.dev/gauge-ts/#/

## The Administrators are added
* Set administrator with userId "james@smart.com" and pwd "james".
* Set administrator with userId "martina@smart.com" and pwd "martina".

## The first initiative is created
* Login BYOR with user id "james@smart.com" and pwd "james"
* Cancel the initiative "FirstInitiativeForTheSmartCompany"
* Create the initiative "FirstInitiativeForTheSmartCompany"

* Add administrator "rebecca@smart.com" to initiative "FirstInitiativeForTheSmartCompany"
* Add administrator "martina@smart.com" to initiative "FirstInitiativeForTheSmartCompany"

## The first voting event is created
* Login BYOR with user id "martina@smart.com" and pwd "martina"
* Create "FirstVotingEventForTheSmartCompany" for "FirstInitiativeForTheSmartCompany" with config "firstVotingEvent.smartCompany.json"

* Add "rebecca@smart.com" for "FirstVotingEventForTheSmartCompany"
* Add "james@smart.com" for "FirstVotingEventForTheSmartCompany"

## Add technologies to the voting event and identify the architects who will take part in the discussion and final recommendation steps
* Set technologies for "FirstVotingEventForTheSmartCompany"

* Load users for "FirstVotingEventForTheSmartCompany"

## Open the voting event
* Login BYOR with user id "rebecca@smart.com" and pwd "rebecca"
* Open the voting event "FirstVotingEventForTheSmartCompany"

## People vote
* "Hare" in "FirstVotingEventForTheSmartCompany" gives the votes 

   |technology |ring  |comment|tags             |
   |-----------|------|-------|-----------------|
   |Anemic REST|hold  |crap   |Prod Experience  |
   |Data Lake  |assess|sorta  |Personal Project |
   |Prettier   |trial |not bad|Training         |
   |Swagger    |adopt |good   |Blogs-Conferences|

* "Snail" in "FirstVotingEventForTheSmartCompany" gives the votes 

   |technology |ring  |comment|tags             |
   |-----------|------|-------|-----------------|
   |Anemic REST|adopt |great  |Prod Experience  |
   |Data Lake  |trial |pretty |Personal Project |
   |Prettier   |assess|well...|Training         |
   |Swagger    |hold  |baddd  |Blogs-Conferences|
   
* "Wise Man" in "FirstVotingEventForTheSmartCompany" gives the votes 

   |technology |ring |comment|tags            |
   |-----------|-----|-------|----------------|
   |Anemic REST|adopt|go4it  |Prod Experience |
   |Data Lake  |adopt|go4it  |Personal Project|
   |Prettier   |hold |STOPPP |Training        |
   |TypeScript |adopt|great  |Prod Experience |

