@IsTest
private class TripServiceTest {

@IsTest
static void testValidDates() {

    Trip__c trip = TestDataFactory.createValidDateTrip();

    Test.startTest();

    TripService.validateDates(new List<Trip__c>{ trip });

    Test.stopTest();

    System.assertEquals(
        Date.today().addDays(10),
        trip.Start_Date__c
    );

    System.assertEquals(
        Date.today().addDays(15),
        trip.End_Date__c
    );
}

@IsTest
static void testInvalidDates() {

    Trip__c trip = TestDataFactory.createInvalidDateTrip();

    Test.startTest();

    TripService.validateDates(new List<Trip__c>{ trip });

    Test.stopTest();

    System.assertEquals(
        Date.today().addDays(15),
        trip.Start_Date__c
    );

    System.assertEquals(
        Date.today().addDays(10),
        trip.End_Date__c
    );
}

}
