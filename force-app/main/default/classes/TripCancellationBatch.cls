// Batch = traitement automatique qui travaille sur beaucoup d enregistrements par petits paquets.
// Role : annuler les voyages qui partent dans 7 jours et qui ont moins de 10 participants.
global class TripCancellationBatch implements Database.Batchable<SObject> {

    // METHODE start : choisit les voyages a traiter.
    // Elle se lance en premier et renvoie la requete qui donne les voyages.
    global Database.QueryLocator start(Database.BatchableContext bc) {

        // Date cible = aujourd hui + 7 jours.
        Date targetDate = Date.today().addDays(7);

        // On prend les voyages qui commencent a la date cible et qui ne sont pas deja annules.
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

    // METHODE execute : traite un paquet de voyages renvoyes par start.
    // Role : mettre le statut Annule si le voyage a moins de 10 participants.
    global void execute(
        Database.BatchableContext bc,
        List<Trip__c> trips
    ) {

        // On regarde chaque voyage du paquet.
        for (Trip__c trip : trips) {

            // Regle metier : moins de 10 participants = voyage annule.
            if (trip.Number_of_Participants__c != null &&
                trip.Number_of_Participants__c < 10) {

                trip.Status__c = 'Annulé';
            }
        }

        if (!trips.isEmpty()) {
            // Un seul update pour tout le paquet (bonne pratique pour respecter les limites Salesforce).
            update trips;
        }
    }

    // METHODE finish : se lance a la fin du batch.
    // Elle est vide ici car on n a rien a faire apres (par exemple envoyer un mail).
    global void finish(Database.BatchableContext bc) {
    }
}
