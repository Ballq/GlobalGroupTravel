trigger TripTrigger on Trip__c (before insert, before update) {

    for (Trip__c trip : Trigger.new) {

        if (trip.Start_Date__c != null &&
            trip.End_Date__c != null &&
            trip.End_Date__c < trip.Start_Date__c) {

            trip.addError(
                'La date de fin doit être postérieure ou égale à la date de début.'
            );
        }
    }
}