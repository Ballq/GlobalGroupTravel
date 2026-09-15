@IsTest
private class TripCancellationBatchTest {

@IsTest
static void testTripIsCancelledWhenLessThan10Participants() {

    Trip__c trip = TestDataFactory.createTripWithLessThan10Participants();

    insert trip;

    Test.startTest();

    Database.executeBatch(new TripCancellationBatch());

    Test.stopTest();

    Trip__c updatedTrip = [
        SELECT Id, Status__c
        FROM Trip__c
        WHERE Id = :trip.Id
    ];

    System.assertEquals(
        'Annulé',
        updatedTrip.Status__c,
        'Le Trip doit être annulé avec moins de 10 participants.'
    );
}

@IsTest
static void testTripIsNotCancelledWith10OrMoreParticipants() {

    Trip__c trip = TestDataFactory.createTripWith10Participants();

    insert trip;

    Test.startTest();

    Database.executeBatch(new TripCancellationBatch());

    Test.stopTest();

    Trip__c updatedTrip = [
        SELECT Id, Status__c
        FROM Trip__c
        WHERE Id = :trip.Id
    ];

    System.assertEquals(
        'A venir',
        updatedTrip.Status__c,
        'Le Trip ne doit pas être annulé avec 10 participants ou plus.'
    );
}

}
