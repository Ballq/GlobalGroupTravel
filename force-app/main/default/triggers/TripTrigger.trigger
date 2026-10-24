// Trigger sur Trip__c : il se lance AVANT la creation (insert) et AVANT la modification (update) d un voyage.
// Il ne contient pas de logique : il appelle TripService pour que le code reste propre.
// Regles : dates coherentes (insert et update) et minimum de participants (insert seulement).
trigger TripTrigger on Trip__c (before insert, before update) {

// Trigger.new = la liste des voyages qu on est en train d enregistrer.
TripService.validateDates(Trigger.new);

    // A la creation seulement (insert) : on verifie aussi le minimum de participants.
    // On ne le fait pas a la modification, sinon les batchs ne pourraient plus changer le statut des voyages.
    if (Trigger.isInsert) {
        TripService.validateMinimumParticipants(Trigger.new);
    }

}
