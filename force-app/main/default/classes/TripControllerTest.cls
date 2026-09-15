@IsTest
private class TripControllerTest {

@IsTest
static void testGetTrips() {

    Trip__c trip = TestDataFactory.createTrip(
        'Paris',
        30,
        10,
        15
    );

    insert trip;

    Test.startTest();

    List<Trip__c> trips = TripController.getTrips();

    Test.stopTest();

    System.assertEquals(1, trips.size());
    System.assertEquals('Paris', trips[0].Destination__c);
    System.assertEquals(30, trips[0].Number_of_Participants__c);
}

}
