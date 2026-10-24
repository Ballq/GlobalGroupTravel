// Tests du trigger OpportunityTrigger : creation automatique d un voyage quand l opportunite passe a Closed Won.
@IsTest
private class OpportunityTriggerTest {

// TEST : on passe une opportunite a Closed Won.
// On verifie qu un voyage est cree automatiquement avec les memes infos (destination, dates, participants, montant, compte).
@IsTest
static void testTripCreatedWhenOpportunityIsWon() {

    Account account = TestDataFactory.createAccount();
    insert account;

    Opportunity opp = TestDataFactory.createOpportunity(
        account.Id
    );
    insert opp;

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    opp.StageName = 'Closed Won';
    update opp;

    Test.stopTest();

    Trip__c trip = [
        SELECT Id,
               Status__c,
               Destination__c,
               Start_Date__c,
               End_Date__c,
               Number_of_Participants__c,
               Total_Cost__c,
               Account__c,
               Opportunity__c
        FROM Trip__c
        WHERE Opportunity__c = :opp.Id
        LIMIT 1
    ];

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals('A venir', trip.Status__c);
    System.assertEquals('Paris', trip.Destination__c);
    System.assertEquals(Date.today().addDays(10), trip.Start_Date__c);
    System.assertEquals(Date.today().addDays(15), trip.End_Date__c);
    System.assertEquals(20, trip.Number_of_Participants__c);
    System.assertEquals(5000, trip.Total_Cost__c);
    System.assertEquals(account.Id, trip.Account__c);
    System.assertEquals(opp.Id, trip.Opportunity__c);
}

// TEST : l opportunite est deja Closed Won et on modifie seulement son montant.
// On verifie qu aucun nouveau voyage n est cree (pas de doublon).
@IsTest
static void testNoTripCreatedIfAlreadyClosedWon() {

    Account account = TestDataFactory.createAccount(
        'Test Account 2'
    );
    insert account;

    Opportunity opp = TestDataFactory.createOpportunity(
        account.Id,
        'Test Opportunity 2',
        'Closed Won',
        'Lyon',
        20,
        25,
        15,
        3000
    );
    insert opp;

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    opp.Amount = 3500;
    update opp;

    Test.stopTest();

    Integer tripCount = [
        SELECT COUNT()
        FROM Trip__c
        WHERE Opportunity__c = :opp.Id
    ];

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(
        0,
        tripCount,
        'Aucun Trip ne doit être créé si l’Opportunity était déjà Closed Won.'
    );
}

}
