// Classe simple qui permet seulement de LIRE les voyages (pas de creation ni de suppression).
public with sharing class TripController {

    // METHODE getTrips : renvoie la liste des voyages tries par date de debut.
    // cacheable=true : le resultat peut etre garde en cache car on ne modifie rien.
    @AuraEnabled(cacheable=true)
    public static List<Trip__c> getTrips() {
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
}