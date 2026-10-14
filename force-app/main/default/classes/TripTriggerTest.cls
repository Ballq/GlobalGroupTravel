@IsTest
private class TripTriggerTest {

    @IsTest
    static void testInsertTripWithInvalidDates() {
        Trip__c trip = new Trip__c(
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(5),
            Status__c = 'A venir'
        );

        Test.startTest();

        Boolean errorCaught = false;

        try {
            insert trip;
        } catch (DmlException e) {
            errorCaught = true;
        }

        Test.stopTest();

        System.assert(
            errorCaught,
            'Le trigger doit empêcher la création d’un voyage dont la date de fin précède la date de début.'
        );
    }

    @IsTest
    static void testUpdateTripWithInvalidDates() {
        Trip__c trip = new Trip__c(
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10),
            Status__c = 'A venir'
        );
        insert trip;

        trip.End_Date__c = Date.today().addDays(3);

        Test.startTest();

        Boolean errorCaught = false;

        try {
            update trip;
        } catch (DmlException e) {
            errorCaught = true;
        }

        Test.stopTest();

        System.assert(
            errorCaught,
            'Le trigger doit empêcher la mise à jour si la date de fin précède la date de début.'
        );
    }

    @IsTest
    static void testInsertTripWithValidDates() {
        Trip__c trip = new Trip__c(
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10),
            Status__c = 'A venir'
        );

        Test.startTest();
        insert trip;
        Test.stopTest();

        System.assertNotEquals(
            null,
            trip.Id,
            'Un voyage avec des dates valides doit être créé.'
        );
    }
}