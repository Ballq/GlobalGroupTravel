// Batch qui met a jour automatiquement le statut des voyages selon la date du jour.
// Statuts : A venir, En cours, Termine.
global class TripStatusBatch implements Database.Batchable<SObject> {

    // METHODE start : choisit les voyages a traiter.
    // On prend tous les voyages qui ont une date de debut et une date de fin.
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

    // METHODE execute : traite un paquet de voyages.
    // Role : calculer le bon statut de chaque voyage en comparant la date du jour a ses dates.
    global void execute(
        Database.BatchableContext bc,
        List<Trip__c> trips
    ) {

        // On recupere la date du jour une seule fois, avant la boucle.
        Date today = Date.today();

        for (Trip__c trip : trips) {

            // Avant la date de debut : le voyage est a venir.
            if (today < trip.Start_Date__c) {

                trip.Status__c = 'A venir';

            // Entre le debut et la fin : le voyage est en cours.
            } else if (today <= trip.End_Date__c) {

                trip.Status__c = 'En cours';

            // Apres la date de fin : le voyage est termine.
            } else {

                trip.Status__c = 'Terminé';
            }
        }

        if (!trips.isEmpty()) {
            // Un seul update pour tout le paquet.
            update trips;
        }
    }

    // METHODE finish : se lance a la fin du batch. Elle est vide car on n a rien a faire apres.
    global void finish(Database.BatchableContext bc) {
    }
}
