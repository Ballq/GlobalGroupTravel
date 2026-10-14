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
        if (String.isBlank(destination)) {
            throw new AuraHandledException(
                'La destination est obligatoire.'
            );
        }

        if (startDate == null) {
            throw new AuraHandledException(
                'La date de début est obligatoire.'
            );
        }

        if (endDate == null) {
            throw new AuraHandledException(
                'La date de fin est obligatoire.'
            );
        }

        if (startDate > endDate) {
            throw new AuraHandledException(
                'La date de fin doit être postérieure ou égale à la date de début.'
            );
        }

        if (numberOfParticipants == null) {
            throw new AuraHandledException(
                'Le nombre de participants est obligatoire.'
            );
        }

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

        if (trip == null || trip.Id == null) {
            throw new AuraHandledException(
                'Le voyage à modifier est invalide.'
            );
        }

        if (String.isBlank(trip.Destination__c)) {
            throw new AuraHandledException(
                'La destination est obligatoire.'
            );
        }

        if (trip.Start_Date__c == null) {
            throw new AuraHandledException(
                'La date de début est obligatoire.'
            );
        }

        if (trip.End_Date__c == null) {
            throw new AuraHandledException(
                'La date de fin est obligatoire.'
            );
        }

        if (trip.Start_Date__c > trip.End_Date__c) {
            throw new AuraHandledException(
                'La date de fin doit être postérieure ou égale à la date de début.'
            );
        }

        if (trip.Number_of_Participants__c == null) {
            throw new AuraHandledException(
                'Le nombre de participants est obligatoire.'
            );
        }

        update trip;
    }


    @AuraEnabled
    public static void deleteTrip(Id tripId) {

        if (tripId == null) {
            throw new AuraHandledException(
                'L’identifiant du voyage est obligatoire.'
            );
        }

        Trip__c trip = [
            SELECT Id
            FROM Trip__c
            WHERE Id = :tripId
            LIMIT 1
        ];

        delete trip;
    }
}