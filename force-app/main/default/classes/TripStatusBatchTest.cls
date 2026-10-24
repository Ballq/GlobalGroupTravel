// Test du batch TripStatusBatch : mise a jour du statut selon les dates.
@IsTest
private class TripStatusBatchTest {

// TEST : trois voyages (a venir, en cours, termine).
// Apres le batch, chaque voyage doit avoir le bon statut : A venir, En cours, Termine.
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

    // startTest : ici commence la partie du test qui execute le code a tester.
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

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
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
