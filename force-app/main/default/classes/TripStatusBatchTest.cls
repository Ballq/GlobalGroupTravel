@IsTest
private class TripStatusBatchTest {

    @IsTest
    static void testTripStatusBatch() {

        Date today = Date.today();

        Trip__c upcomingTrip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Paris',
            Start_Date__c = today.addDays(5),
            End_Date__c = today.addDays(10),
            Number_of_Participants__c = 20,
            Total_Budget__c = 5000,
            Total_Cost__c = 4000
        );

        Trip__c currentTrip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Lyon',
            Start_Date__c = today,
            End_Date__c = today.addDays(5),
            Number_of_Participants__c = 15,
            Total_Budget__c = 5000,
            Total_Cost__c = 4000
        );

        Trip__c finishedTrip = new Trip__c(
            Status__c = 'En cours',
            Destination__c = 'Marseille',
            Start_Date__c = today.addDays(-10),
            End_Date__c = today.addDays(-5),
            Number_of_Participants__c = 12,
            Total_Budget__c = 5000,
            Total_Cost__c = 4000
        );

        insert new List<Trip__c>{
            upcomingTrip,
            currentTrip,
            finishedTrip
        };

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
