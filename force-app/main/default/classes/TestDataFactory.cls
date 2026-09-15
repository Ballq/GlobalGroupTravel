@IsTest
public class TestDataFactory {

/*
 * =========================
 * ACCOUNT
 * =========================
 */

public static Account createAccount() {

    return new Account(
        Name = 'Test Account'
    );
}

public static Account createAccount(String name) {

    return new Account(
        Name = name
    );
}
 
/*
 * =========================
 * OPPORTUNITY
 * =========================
 */
 
public static Opportunity createOpportunity(
    Id accountId
) {

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

/*
 * =========================
 * TRIP PARAMETRE
 * =========================
 */

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


/*
 * =========================
 * TRIP - VALID DATES
 * =========================
 */

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


/*
 * =========================
 * TRIP - INVALID DATES
 * =========================
 */

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


/*
 * =========================
 * TRIP - CANCELLATION
 * =========================
 */

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


/*
 * =========================
 * TRIP - STATUS BATCH
 * =========================
 */

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


/*
 * =========================
 * TRIP - CRUD TEST
 * =========================
 */

public static Trip__c createCrudTrip(
    String destination
) {

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
