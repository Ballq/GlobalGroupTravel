global class TripCancellationBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        Date targetDate = Date.today().addDays(7);

        return Database.getQueryLocator([
            SELECT Id,
                   Status__c,
                   Start_Date__c,
                   Number_of_Participants__c
            FROM Trip__c
            WHERE Start_Date__c = :targetDate
              AND Status__c != 'Annulé'
        ]);
    }

    global void execute(
        Database.BatchableContext bc,
        List<Trip__c> trips
    ) {

        for (Trip__c trip : trips) {

            if (trip.Number_of_Participants__c != null &&
                trip.Number_of_Participants__c < 10) {

                trip.Status__c = 'Annulé';
            }
        }

        if (!trips.isEmpty()) {
            update trips;
        }
    }

    global void finish(Database.BatchableContext bc) {
    }
}
