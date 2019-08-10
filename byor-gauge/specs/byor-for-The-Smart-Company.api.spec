# The CEO of SmartCompany gets excited with BYOR app and decides to use it at the SmartCompany
This spec describes a way the BYOR can be used in a Company.
This spec aims to specify and test only the APIs provided by the back end.

// https://bugdiver.dev/gauge-ts/#/


One evenening, the CEO of the SmartCompany attended at a presentation of the BYOR application and decided to try
it at SmartCompany itself.

The morning after the CEO called the Rebecca, the chief architect, told her about the BYOR and got her excited.
Rebecca, when back at her room, downloaded immediately the code and installed on a newly created simple environment,
just a couple of servers.

## The Administrators are added
Then, using the default Admin credentials  which come with installation of BYOR, she set herself as administrator of the application,
specifying the userId and the password she is going to use
* Set administrator with userId "rebecca@smart.com" and pwd "rebecca".

Rebecca wants also James and Martina as additional administrators, so she adds them
* Set administrator with userId "james@smart.com" and pwd "james".
* Set administrator with userId "martina@smart.com" and pwd "martina".

## The first initiative is created
In the afternoon Rebecca calls James and Martina for a meeting to present them the BYOR app and discuss
of possible ways to leverage this new tool.
When they meet, that afternoon, the three quickly come to the agreement of creating an Initiative in BYOR
under which they will group all VotingEvents the SmartCompany will run. Consider that the SmartCompany belongs
to a Group and has other syster Companies. If one sister Company decides in future to use the the BYOR app,
she will be able to create a new Initiative using the same BYOR installation created by Rebecca.
So James logs in with his userid
* Login BYOR with user id "james@smart.com" and pwd "james"

Now, being him an Admin of BYOR, he creates the fist initiative.
Well, actually to be sure that nobody did it before him, he starts cancelling the initiative just in case and then creates it
* Cancel the initiative "FirstInitiativeForTheSmartCompany"
* Create the initiative "FirstInitiativeForTheSmartCompany"

and then James adds Rebecca and Martina as administrators of the initiative
* Add administrator "rebecca@smart.com" to initiative "FirstInitiativeForTheSmartCompany"
* Add administrator "martina@smart.com" to initiative "FirstInitiativeForTheSmartCompany"

## The first voting event is created
Two days later Rebecca, James and Martina meet again to decide which objectives they want to achieve with the BYOR  exercize
and how to structure the first voting event accordingly.
The first objective is to gather the most honest opinion from the IT population about the technologies they currently use
as well as the new ones that SmartCompany is considering for the next future.
Once such data is available, they want to open a structured discussion among the senior IT architects based on the exchange of comments
which will be registered in BYOR application.
Eventually, the architects will divide among themeselves the technologies, and for each of them will provide a final recommendation.
Therefore the first voting event will have to be structured in 3 steps:
Step1: an anonymous voting session, where all IT people will be invite to cast a vote along the 4 rings of the radar, for the
technologies subject to the poll - at the end of this step, the first version of the SmartCompany Tech Radar will be produced
Step2: a conversation among the IT architects will start - each architect will be able to log into BYOR, view the votes and the comments
and comments or respond to other comments
Step3: once this step starts, each architect will be able to log into the BYOR, choose the technologies for which it candidates to
provide the final recommendation, confirm or override the ring resulted from the open voting session run in step1 and log
the motivation for such choice.
BYOR allows configuring voting events with different steps, and each step can itself be configured to accommodate different methods
of authentication or other characteristics. The configuration can be defined in a file, with a specific JSON format.
Martina takes in charge to create the configuration file, "firstVotingEvent.smartCompany.json".
She logs in and then creates the voting event.
* Login BYOR with user id "martina@smart.com" and pwd "martina"
* Create "FirstVotingEventForTheSmartCompany" for "FirstInitiativeForTheSmartCompany" with config "firstVotingEvent.smartCompany.json"

Martina then adds Rebecca and James as administrators of the voting event just created
* Add "rebecca@smart.com" for "FirstVotingEventForTheSmartCompany"
* Add "james@smart.com" for "FirstVotingEventForTheSmartCompany"

## Add technologies to the voting event and identify the architects who will take part in the discussion and final recommendation steps
By the end of the week, Martina and James prepare the list of the technologies they want to add to the voting event.
* Set technologies for "FirstVotingEventForTheSmartCompany"

Together with Rebecca they also prepare the list of the architects who will participate to the discussion step.
Some of them, the so called "champions", will also be the ones who will make the final recommendations.
* Load users for "FirstVotingEventForTheSmartCompany"

## Open the voting event
Three weeks later all people from the IT department of SmartCompnay go to an event organized by Rebecca, James and Martina.
Rebecca opens the event explaining the initiative of the BYOR for SmartCompany and describes why all IT people are called to
participate to the voting session and are encouraged to cast their votes according to their experience.
Rebecca then opens the voting event
* Login BYOR with user id "rebecca@smart.com" and pwd "rebecca"
* Open the voting event "FirstVotingEventForTheSmartCompany"

## People vote
The first one to vote is a developer whose nickname is "hare".
* "Hare" in "FirstVotingEventForTheSmartCompany" gives the votes 

   |technology |ring  |comment|tags             |
   |-----------|------|-------|-----------------|
   |Anemic REST|hold  |crap   |Prod Experience  |
   |Data Lake  |assess|sorta  |Personal Project |
   |Prettier   |trial |not bad|Training         |
   |Swagger    |adopt |good   |Blogs-Conferences|

Then votes a voter whose nickname is "Snail".
* "Snail" in "FirstVotingEventForTheSmartCompany" gives the votes 

   |technology |ring  |comment|tags             |
   |-----------|------|-------|-----------------|
   |Anemic REST|adopt |great  |Prod Experience  |
   |Data Lake  |trial |pretty |Personal Project |
   |Prettier   |assess|well...|Training         |
   |Swagger    |hold  |baddd  |Blogs-Conferences|

Then a "Wise Man" votes.
* "Wise Man" in "FirstVotingEventForTheSmartCompany" gives the votes 

   |technology |ring |comment|tags             |
   |-----------|-----|-------|-----------------|
   |Anemic REST|adopt|go4it  |Prod Experience  |
   |Data Lake  |adopt|go4it  |Personal Project |
   |Prettier   |hold |STOPPP |Training         |
   |Swagger    |hold |STOPPP |Blogs-Conferences|

## Some correct their first vote
After having saved its vote, "Snails" decides to add one technology, "GraphQL" which recently it used with success,
remove its vote for "Data Lake" since it does not have any experience and correct the vote on "Swagger" taking it from
"hold" to "assess".
* "Snail" corrects the vote in "FirstVotingEventForTheSmartCompany" 

   |technology |ring  |comment |tags             |
   |-----------|------|--------|-----------------|
   |Anemic REST|adopt |great   |Prod Experience  |
   |Prettier   |assess|well... |Training         |
   |Swagger    |assess|maybe...|Blogs-Conferences|
   |GraphQL    |adopt |SUPER   |Prod Experience  |

## The first voting event is closed
The voting window lasts 30 minutes, after which Rebecca closes the voting event
* Login BYOR with user id "rebecca@smart.com" and pwd "rebecca"
* Close the voting event "FirstVotingEventForTheSmartCompany"

## The results of the first round are shown
Now Rebecca can show the first version of the Radar, the one built from the votes of the IT people.
The Radar is diplayed using the BYOR official TW application invoked with specific parameters, and thereforeù
is out of the scope of this spec which is exclusively focused on the APIs exposed by the back end.
Via API though we can retrieve the votes
* Fetch the votes posted in "FirstVotingEventForTheSmartCompany"
as well as the Blips
* Calculate the blips for "FirstVotingEventForTheSmartCompany"
