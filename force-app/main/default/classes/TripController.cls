public with sharing class TripController {

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
}