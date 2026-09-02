@IsTest
private class TripControllerTest {

    @IsTest
    static void testGetTrips() {

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Paris',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 30,
            Total_Budget__c = 15000,
            Total_Cost__c = 12000
        );

        insert trip;

        Test.startTest();
        List<Trip__c> trips = TripController.getTrips();
        Test.stopTest();

        System.assertEquals(1, trips.size());
        System.assertEquals('Paris', trips[0].Destination__c);
        System.assertEquals(30, trips[0].Number_of_Participants__c);
    }

    @IsTest
    static void testValidDates() {

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Lyon',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 20,
            Total_Budget__c = 10000,
            Total_Cost__c = 8000
        );

        Test.startTest();
        insert trip;
        Test.stopTest();

        System.assertNotEquals(null, trip.Id);
    }

    @IsTest
    static void testInvalidDates() {

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Marseille',
            Start_Date__c = Date.today().addDays(15),
            End_Date__c = Date.today().addDays(10),
            Number_of_Participants__c = 20,
            Total_Budget__c = 10000,
            Total_Cost__c = 8000
        );

        Test.startTest();

        try {
            insert trip;
            System.assert(false, 'Le trigger aurait dû bloquer le Trip.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains(
                    'La date de fin doit être postérieure ou égale à la date de début.'
                )
            );
        }

        Test.stopTest();
    }
}

