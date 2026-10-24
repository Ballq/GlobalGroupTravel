// Test de la classe TripController (lecture des voyages).
@IsTest
private class TripControllerTest {

// TEST : on cree un voyage puis on appelle getTrips.
// On verifie qu on recupere bien 1 voyage avec la bonne destination et le bon nombre de participants.
@IsTest
static void testGetTrips() {

    Trip__c trip = TestDataFactory.createTrip(
        'Paris',
        30,
        10,
        15
    );

    insert trip;

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    List<Trip__c> trips = TripController.getTrips();

    Test.stopTest();

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(1, trips.size());
    System.assertEquals('Paris', trips[0].Destination__c);
    System.assertEquals(30, trips[0].Number_of_Participants__c);
}

}
