@IsTest
private class TripCrudControllerTest {

@IsTest
static void testCreateTrip() {

    Test.startTest();

    Trip__c trip = TripCrudController.createTrip(
        'Paris',
        Date.today().addDays(10),
        Date.today().addDays(15),
        20,
        5000,
        4000
    );

    Test.stopTest();

    System.assertNotEquals(null, trip.Id);
    System.assertEquals('Paris', trip.Destination__c);
    System.assertEquals('A venir', trip.Status__c);
    System.assertEquals(20, trip.Number_of_Participants__c);
    System.assertEquals(5000, trip.Total_Budget__c);
    System.assertEquals(4000, trip.Total_Cost__c);
}

@IsTest
static void testGetTrips() {

    Trip__c trip = TestDataFactory.createCrudTrip('Lyon');

    insert trip;

    Test.startTest();

    List<Trip__c> trips = TripCrudController.getTrips();

    Test.stopTest();

    System.assertEquals(1, trips.size());
    System.assertEquals('Lyon', trips[0].Destination__c);
}

@IsTest
static void testUpdateTrip() {

    Trip__c trip = TestDataFactory.createCrudTrip('Marseille');

    insert trip;

    trip.Destination__c = 'Nice';

    Test.startTest();

    TripCrudController.updateTrip(trip);

    Test.stopTest();

    Trip__c updatedTrip = [
        SELECT Id, Destination__c
        FROM Trip__c
        WHERE Id = :trip.Id
    ];

    System.assertEquals('Nice', updatedTrip.Destination__c);
}

@IsTest
static void testDeleteTrip() {

    Trip__c trip = TestDataFactory.createCrudTrip('Bordeaux');

    insert trip;

    Test.startTest();

    TripCrudController.deleteTrip(trip.Id);

    Test.stopTest();

    Integer tripCount = [
        SELECT COUNT()
        FROM Trip__c
        WHERE Id = :trip.Id
    ];

    System.assertEquals(0, tripCount);
}

}
