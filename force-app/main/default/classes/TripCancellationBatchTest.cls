// Tests du batch TripCancellationBatch : annulation des voyages de moins de 10 participants.
@IsTest
private class TripCancellationBatchTest {

// TEST : voyage qui part dans 7 jours avec 5 participants.
// Apres le batch, on verifie que son statut est Annule.
@IsTest
static void testTripIsCancelledWhenLessThan10Participants() {

    Trip__c trip = TestDataFactory.createTripWithLessThan10Participants();

    insert trip;

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    Database.executeBatch(new TripCancellationBatch());

    Test.stopTest();

    Trip__c updatedTrip = [
        SELECT Id, Status__c
        FROM Trip__c
        WHERE Id = :trip.Id
    ];

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(
        'Annulé',
        updatedTrip.Status__c,
        'Le Trip doit être annulé avec moins de 10 participants.'
    );
}

// TEST : voyage qui part dans 7 jours avec 10 participants.
// Apres le batch, on verifie que son statut reste A venir.
@IsTest
static void testTripIsNotCancelledWith10OrMoreParticipants() {

    Trip__c trip = TestDataFactory.createTripWith10Participants();

    insert trip;

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    Database.executeBatch(new TripCancellationBatch());

    Test.stopTest();

    Trip__c updatedTrip = [
        SELECT Id, Status__c
        FROM Trip__c
        WHERE Id = :trip.Id
    ];

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(
        'A venir',
        updatedTrip.Status__c,
        'Le Trip ne doit pas être annulé avec 10 participants ou plus.'
    );
}

}
