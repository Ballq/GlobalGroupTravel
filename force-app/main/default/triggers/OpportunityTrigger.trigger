// Trigger sur Opportunity : il se lance APRES la modification d une opportunite.
// Role : quand une opportunite passe a Closed Won (gagnee), on cree automatiquement un voyage (Trip__c).
trigger OpportunityTrigger on Opportunity (after update) {

    // Liste des voyages a creer. On les stocke ici pour les enregistrer tous en une seule fois a la fin.
    List<Trip__c> tripsToCreate = new List<Trip__c>();

    // Set = liste sans doublons. Ici on garde les Id des opportunites qui viennent de passer a Closed Won.
    Set<Id> opportunityIds = new Set<Id>();

    // Premiere boucle : on parcourt les opportunites modifiees pour trouver celles qui viennent d etre gagnees.
    for (Opportunity opp : Trigger.new) {

        // oldMap = les anciennes valeurs. On s en sert pour savoir si l etape a vraiment change.
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        // On garde seulement les opportunites qui sont maintenant Closed Won alors qu avant elles ne l etaient pas.
        if (opp.StageName == 'Closed Won' &&
            oldOpp.StageName != 'Closed Won') {

            opportunityIds.add(opp.Id);
        }
    }

    // Si aucune opportunite n est concernee, on arrete le trigger tout de suite (pas besoin de faire de requete).
    if (opportunityIds.isEmpty()) {
        return;
    }

    // Ici on garde les opportunites qui ont deja un voyage, pour ne pas creer de doublon.
    Set<Id> opportunitiesWithTrip = new Set<Id>();

    // Une seule requete SOQL pour toutes les opportunites (jamais de requete dans une boucle, a cause des limites Salesforce).
    for (Trip__c trip : [
        SELECT Opportunity__c
        FROM Trip__c
        WHERE Opportunity__c IN :opportunityIds
    ]) {
        opportunitiesWithTrip.add(trip.Opportunity__c);
    }

    // Deuxieme boucle : on cree un voyage pour chaque opportunite gagnee qui n en a pas encore.
    for (Opportunity opp : Trigger.new) {

        if (opportunityIds.contains(opp.Id) &&
            !opportunitiesWithTrip.contains(opp.Id)) {

            // On recopie les infos de l opportunite dans le voyage (destination, dates, participants, montant, compte).
            Trip__c trip = new Trip__c(
                Status__c = 'A venir',
                Destination__c = opp.Destination__c,
                Start_Date__c = opp.Start_Date__c,
                End_Date__c = opp.End_Date__c,
                Number_of_Participants__c = opp.Number_of_Participants__c,
                Total_Cost__c = opp.Amount,
                Account__c = opp.AccountId,
                Opportunity__c = opp.Id
            );

            tripsToCreate.add(trip);
        }
    }

    if (!tripsToCreate.isEmpty()) {
        // Un seul insert pour tous les voyages (meilleure performance que un insert par voyage).
        insert tripsToCreate;
    }
}
