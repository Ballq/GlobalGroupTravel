@IsTest
private class TripCancellationBatchTest {

    @IsTest
    static void testTripIsCancelledWhenLessThan10Participants() {

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Paris',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(10),
            Number_of_Participants__c = 5,
            Total_Budget__c = 5000,
            Total_Cost__c = 4000
        );

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

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Lyon',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(10),
            Number_of_Participants__c = 10,
            Total_Budget__c = 5000,
            Total_Cost__c = 4000
        );

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
