global class TripStatusBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id,
                   Start_Date__c,
                   End_Date__c,
                   Status__c
            FROM Trip__c
            WHERE Start_Date__c != null
              AND End_Date__c != null
        ]);
    }

    global void execute(
        Database.BatchableContext bc,
        List<Trip__c> trips
    ) {

        Date today = Date.today();

        for (Trip__c trip : trips) {

            if (today < trip.Start_Date__c) {

                trip.Status__c = 'A venir';

            } else if (today <= trip.End_Date__c) {

                trip.Status__c = 'En cours';

            } else {

                trip.Status__c = 'Terminé';
            }
        }

        if (!trips.isEmpty()) {
            update trips;
        }
    }

    global void finish(Database.BatchableContext bc) {
    }
}
