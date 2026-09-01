trigger TripTrigger on Trip__c (before insert, before update) {

    for (Trip__c trip : Trigger.new) {

        if (trip.Number_of_Participants__c != null &&
            trip.Number_of_Participants__c > 0 &&
            trip.Total_Budget__c != null) {

            Decimal budgetParParticipant =
                trip.Total_Budget__c / trip.Number_of_Participants__c;

            if (budgetParParticipant < 100) {
                trip.addError(
                    'Le budget par participant doit être supérieur ou égal à 100 €.'
                );
            }
        }
    }
}