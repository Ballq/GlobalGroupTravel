// Classe qui gere les voyages (Trip__c) : creer, lire, modifier, supprimer (CRUD).
// "with sharing" veut dire qu on respecte les droits de l utilisateur connecte.
// Le composant LWC tripManager appelle ces methodes.
public with sharing class TripCrudController {

    // METHODE createTrip : cree un nouveau voyage.
    // Role : verifier les donnees recues, puis enregistrer le voyage dans Salesforce.
    // @AuraEnabled permet au composant LWC d appeler cette methode.
    @AuraEnabled
    public static Trip__c createTrip(
        String destination,
        Date startDate,
        Date endDate,
        Decimal numberOfParticipants,
        Decimal totalBudget,
        Decimal totalCost
    ) {
        // On verifie que la destination n est pas vide, sinon on renvoie une erreur lisible.
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

        // La date de debut ne doit pas etre apres la date de fin.
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

        // On prepare le voyage en memoire (il n est pas encore enregistre). Le statut de depart est A venir.
        Trip__c trip = new Trip__c(
            Status__c = 'A venir',
            Destination__c = destination,
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Number_of_Participants__c = numberOfParticipants,
            Total_Budget__c = totalBudget,
            Total_Cost__c = totalCost
        );

        try {
            // insert = on enregistre le voyage dans la base. Si une regle de validation refuse, on passe dans le catch.
            insert trip;
        // Si l enregistrement echoue, on renvoie le premier message d erreur a l ecran.
        } catch (DmlException e) {
            throw new AuraHandledException(
                e.getDmlMessage(0)
            );
        }

        return trip;
    }

    // METHODE getTrips : lit tous les voyages.
    // Role : renvoyer la liste des voyages, tries par date de debut (du plus proche au plus lointain).
    // Pas de cacheable=true ici : sinon Salesforce renvoie d anciennes donnees gardees en cache et le bouton Actualiser ne marche pas.
    @AuraEnabled
    public static List<Trip__c> getTrips() {
        // Requete SOQL : on choisit les champs dont l ecran a besoin dans la table Trip__c.
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

    // METHODE updateTrip : modifie un voyage qui existe deja.
    // Role : verifier que le voyage et ses champs obligatoires sont valides, puis mettre a jour.
    @AuraEnabled
    public static void updateTrip(Trip__c trip) {

        // Sans Id on ne sait pas quel voyage modifier, donc on refuse.
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

        try {
            // update = on enregistre les modifications dans la base.
            update trip;
        } catch (DmlException e) {
            throw new AuraHandledException(
                e.getDmlMessage(0)
            );
        }
    }

    // METHODE deleteTrip : supprime un voyage grace a son Id.
    // Role : retrouver le voyage puis le supprimer de la base.
    @AuraEnabled
    public static void deleteTrip(Id tripId) {

        if (tripId == null) {
            throw new AuraHandledException(
                'L’identifiant du voyage est obligatoire.'
            );
        }

        // On cherche le voyage avec son Id (LIMIT 1 = un seul resultat).
        Trip__c trip = [
            SELECT Id
            FROM Trip__c
            WHERE Id = :tripId
            LIMIT 1
        ];

        // delete = on supprime le voyage de la base.
        delete trip;
    }
}
