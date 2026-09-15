@IsTest
private class TripStatusBatchTest {

@IsTest
static void testTripStatusBatch() {

    Trip__c upcomingTrip = TestDataFactory.createUpcomingTrip();
    Trip__c currentTrip = TestDataFactory.createCurrentTrip();
    Trip__c finishedTrip = TestDataFactory.createFinishedTrip();

    insert new List<Trip__c>{
        upcomingTrip,
        currentTrip,
        finishedTrip
    };

    Test.startTest();

    Database.executeBatch(new TripStatusBatch());

    Test.stopTest();

    Map<Id, Trip__c> trips = new Map<Id, Trip__c>([
        SELECT Id, Status__c
        FROM Trip__c
        WHERE Id IN :new Set<Id>{
            upcomingTrip.Id,
            currentTrip.Id,
            finishedTrip.Id
        }
    ]);

    System.assertEquals(
        'A venir',
        trips.get(upcomingTrip.Id).Status__c
    );

    System.assertEquals(
        'En cours',
        trips.get(currentTrip.Id).Status__c
    );

    System.assertEquals(
        'Terminé',
        trips.get(finishedTrip.Id).Status__c
    );
}

}
