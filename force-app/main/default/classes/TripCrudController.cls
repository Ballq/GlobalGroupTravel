public with sharing class TripCrudController {

    @AuraEnabled
    public static Trip__c createTrip(
        String destination,
        Date startDate,
        Date endDate,
        Decimal numberOfParticipants,
        Decimal totalBudget,
        Decimal totalCost
    ) {

        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = destination,
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Number_of_Participants__c = numberOfParticipants,
            Total_Budget__c = totalBudget,
            Total_Cost__c = totalCost
        );

        insert trip;

        return trip;
    }


    @AuraEnabled(cacheable=true)
    public static List<Trip__c> getTrips() {

        return [
            SELECT Id,
                   Name,
                   Account__c,
                   Destination__c,
                   Start_Date__c,
                   End_Date__c,
                   Status__c,
                   Number_of_Participants__c,
                   Total_Budget__c,
                   Total_Cost__c,
                   Opportunity__c
            FROM Trip__c
            ORDER BY Start_Date__c ASC
        ];
    }


    @AuraEnabled
    public static void updateTrip(Trip__c trip) {

        update trip;
    }


    @AuraEnabled
    public static void deleteTrip(Id tripId) {

        Trip__c trip = [
            SELECT Id
            FROM Trip__c
            WHERE Id = :tripId
            LIMIT 1
        ];

        delete trip;
    }
}