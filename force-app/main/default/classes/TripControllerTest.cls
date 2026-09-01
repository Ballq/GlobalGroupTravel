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
    static void testBudgetPerParticipantValid() {

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Lyon',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 10,
            Total_Budget__c = 1000,
            Total_Cost__c = 800
        );

        Test.startTest();
        insert trip;
        Test.stopTest();

        System.assertNotEquals(null, trip.Id);
    }

    @IsTest
    static void testBudgetPerParticipantInvalid() {

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Marseille',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 10,
            Total_Budget__c = 500,
            Total_Cost__c = 400
        );

        Test.startTest();

        try {
            insert trip;
            System.assert(false, 'Le trigger aurait dû bloquer le Trip.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains(
                    'Le budget par participant doit être supérieur ou égal à 100 €.'
                )
            );
        }

        Test.stopTest();
    }
}