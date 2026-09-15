public with sharing class TripService {

public static void validateDates(List<Trip__c> trips) {

    for (Trip__c trip : trips) {

        if (trip.Start_Date__c != null &&
            trip.End_Date__c != null &&
            trip.Start_Date__c > trip.End_Date__c) {

            trip.addError(
                'La date de fin doit être postérieure ou égale à la date de début.'
            );
        }
    }
}

}
