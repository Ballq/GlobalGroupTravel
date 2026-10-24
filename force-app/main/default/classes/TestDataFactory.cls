// Classe utilitaire pour les tests : elle fabrique des comptes, opportunites et voyages de test.
// Les methodes renvoient des objets en memoire (pas encore enregistres) : le test fait l insert lui-meme.
// @IsTest = cette classe sert seulement aux tests, elle ne compte pas dans la limite de code.
@IsTest
public class TestDataFactory {

// METHODE : Cree un compte de test avec le nom Test Account.
public static Account createAccount() {
    return new Account(
        Name = 'Test Account'
    );
}

// METHODE : Cree un compte de test avec le nom donne en parametre.
public static Account createAccount(String name) {
    return new Account(
        Name = name
    );
}

// METHODE : Cree un compte de test (meme resultat que createAccount, version avec un autre nom).
public static Account createTestAccount() {
    return new Account(
        Name = 'Test Account'
    );
}

// METHODE : Cree une opportunite de test liee au compte donne : destination Paris, 20 participants, montant 5000, etape Prospecting.
public static Opportunity createOpportunity(Id accountId) {
    return new Opportunity(
        Name = 'Test Opportunity',
        AccountId = accountId,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(30),
        Destination__c = 'Paris',
        Start_Date__c = Date.today().addDays(10),
        End_Date__c = Date.today().addDays(15),
        Number_of_Participants__c = 20,
        Amount = 5000
    );
}

// METHODE : Cree une opportunite de test (meme resultat que createOpportunity(Id), autre nom).
public static Opportunity createTestOpportunity(Id accountId) {
    return new Opportunity(
        Name = 'Test Opportunity',
        AccountId = accountId,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(30),
        Destination__c = 'Paris',
        Start_Date__c = Date.today().addDays(10),
        End_Date__c = Date.today().addDays(15),
        Number_of_Participants__c = 20,
        Amount = 5000
    );
}

// METHODE : Cree une opportunite de test avec tous les parametres au choix (nom, etape, destination, jours avant le debut et la fin, participants, montant).
public static Opportunity createOpportunity(
    Id accountId,
    String name,
    String stageName,
    String destination,
    Integer startDaysFromToday,
    Integer endDaysFromToday,
    Integer participants,
    Decimal amount
) {
    return new Opportunity(
        Name = name,
        AccountId = accountId,
        StageName = stageName,
        CloseDate = Date.today().addDays(30),
        Destination__c = destination,
        Start_Date__c = Date.today().addDays(startDaysFromToday),
        End_Date__c = Date.today().addDays(endDaysFromToday),
        Number_of_Participants__c = participants,
        Amount = amount
    );
}

// METHODE : Cree un voyage de test avec la destination, le nombre de participants et les jours de debut et de fin donnes.
public static Trip__c createTrip(
    String destination,
    Integer participants,
    Integer startDaysFromToday,
    Integer endDaysFromToday
) {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = destination,
        Start_Date__c = Date.today().addDays(startDaysFromToday),
        End_Date__c = Date.today().addDays(endDaysFromToday),
        Number_of_Participants__c = participants,
        Total_Budget__c = 5000,
        Total_Cost__c = 4000
    );
}

// METHODE : Cree un voyage avec des dates correctes (debut dans 10 jours, fin dans 15 jours).
public static Trip__c createValidDateTrip() {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = 'Lyon',
        Start_Date__c = Date.today().addDays(10),
        End_Date__c = Date.today().addDays(15),
        Number_of_Participants__c = 20,
        Total_Budget__c = 10000,
        Total_Cost__c = 8000
    );
}

// METHODE : Cree un voyage avec des dates incorrecte (la date de fin est AVANT la date de debut).
public static Trip__c createInvalidDateTrip() {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = 'Marseille',
        Start_Date__c = Date.today().addDays(15),
        End_Date__c = Date.today().addDays(10),
        Number_of_Participants__c = 20,
        Total_Budget__c = 10000,
        Total_Cost__c = 8000
    );
}

// METHODE : Cree un voyage qui part dans 7 jours avec 5 participant (il doit etre annule par le batch).
public static Trip__c createTripWithLessThan10Participants() {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = 'Paris',
        Start_Date__c = Date.today().addDays(7),
        End_Date__c = Date.today().addDays(10),
        Number_of_Participants__c = 5,
        Total_Budget__c = 5000,
        Total_Cost__c = 4000
    );
}

// METHODE : Cree un voyage qui part dans 7 jours avec 10 participant (il ne doit pas etre annule).
public static Trip__c createTripWith10Participants() {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = 'Lyon',
        Start_Date__c = Date.today().addDays(7),
        End_Date__c = Date.today().addDays(10),
        Number_of_Participants__c = 10,
        Total_Budget__c = 5000,
        Total_Cost__c = 4000
    );
}

// METHODE : Cree un voyage qui commence dans 5 jours (statut attendu : A venir).
public static Trip__c createUpcomingTrip() {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = 'Paris',
        Start_Date__c = Date.today().addDays(5),
        End_Date__c = Date.today().addDays(10),
        Number_of_Participants__c = 20,
        Total_Budget__c = 5000,
        Total_Cost__c = 4000
    );
}

// METHODE : Cree un voyage qui commence aujourd hui et finit dans 5 jours (statut attendu : En cours).
public static Trip__c createCurrentTrip() {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = 'Lyon',
        Start_Date__c = Date.today(),
        End_Date__c = Date.today().addDays(5),
        Number_of_Participants__c = 15,
        Total_Budget__c = 5000,
        Total_Cost__c = 4000
    );
}

// METHODE : Cree un voyage deja fini (il y a 10 a 5 jours) (statut attendu : Termine).
public static Trip__c createFinishedTrip() {
    return new Trip__c(
        Status__c = 'En cours',
        Destination__c = 'Marseille',
        Start_Date__c = Date.today().addDays(-10),
        End_Date__c = Date.today().addDays(-5),
        Number_of_Participants__c = 12,
        Total_Budget__c = 5000,
        Total_Cost__c = 4000
    );
}

// METHODE : Cree un voyage standard pour les tests CRUD, avec la destination donne.
public static Trip__c createCrudTrip(String destination) {
    return new Trip__c(
        Status__c = 'A venir',
        Destination__c = destination,
        Start_Date__c = Date.today().addDays(5),
        End_Date__c = Date.today().addDays(10),
        Number_of_Participants__c = 15,
        Total_Budget__c = 5000,
        Total_Cost__c = 4000
    );
}

}
