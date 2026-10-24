// Classe de service : elle contient les regles metier sur les voyages (dates et nombre de participants).
// Elle est appelee par le trigger TripTrigger.
public with sharing class TripService {

// METHODE validateDates : verifie les dates de chaque voyage.
// Role : si la date de debut est apres la date de fin, on bloque l enregistrement avec un message.
// On recoit une liste (List) car un trigger peut traiter plusieurs voyages en meme temps.
public static void validateDates(List<Trip__c> trips) {

    // On regarde les voyages un par un.
    for (Trip__c trip : trips) {

        if (trip.Start_Date__c != null &&
            trip.End_Date__c != null &&
            trip.Start_Date__c > trip.End_Date__c) {

            // addError = empeche l enregistrement de ce voyage et affiche le message a l utilisateur.
            trip.addError(
                'La date de fin doit être postérieure ou égale à la date de début.'
            );
        }
    }
}

// METHODE validateMinimumParticipants : verifie le nombre de participants quand on cree un voyage.
// Role : refuser un voyage qui commence dans moins de 7 jours avec moins de 10 participants,
// car le batch TripCancellationBatch l annulerait tout de suite.
public static void validateMinimumParticipants(List<Trip__c> trips) {

    // Date limite = aujourd hui + 7 jours.
    Date limitDate = Date.today().addDays(7);

    // On regarde les voyages un par un.
    for (Trip__c trip : trips) {

        // On controle seulement si le nombre de participants et la date de debut sont remplis,
        // et on ignore les voyages deja annules.
        if (trip.Number_of_Participants__c != null &&
            trip.Start_Date__c != null &&
            trip.Status__c != 'Annulé' &&
            trip.Number_of_Participants__c < 10 &&
            trip.Start_Date__c < limitDate) {

            // addError = empeche l enregistrement de ce voyage et affiche le message a l utilisateur.
            trip.addError(
                'Un voyage qui commence dans moins de 7 jours doit avoir au moins 10 participants.'
            );
        }
    }
}

}