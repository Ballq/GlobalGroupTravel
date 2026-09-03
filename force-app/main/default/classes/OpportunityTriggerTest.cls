@IsTest
private class OpportunityTriggerTest {

    @IsTest
    static void testTripCreatedWhenOpportunityIsWon() {

        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Destination__c = 'Paris',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 20,
            Amount = 5000
        );
        insert opp;

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

        System.assertEquals('A venir', trip.Status__c);
        System.assertEquals('Paris', trip.Destination__c);
        System.assertEquals(Date.today().addDays(10), trip.Start_Date__c);
        System.assertEquals(Date.today().addDays(15), trip.End_Date__c);
        System.assertEquals(20, trip.Number_of_Participants__c);
        System.assertEquals(5000, trip.Total_Cost__c);
        System.assertEquals(account.Id, trip.Account__c);
        System.assertEquals(opp.Id, trip.Opportunity__c);
    }

    @IsTest
    static void testNoTripCreatedIfAlreadyClosedWon() {

        Account account = new Account(
            Name = 'Test Account 2'
        );
        insert account;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 2',
            AccountId = account.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(30),
            Destination__c = 'Lyon',
            Start_Date__c = Date.today().addDays(20),
            End_Date__c = Date.today().addDays(25),
            Number_of_Participants__c = 15,
            Amount = 3000
        );
        insert opp;

        Test.startTest();

        opp.Amount = 3500;
        update opp;

        Test.stopTest();

        Integer tripCount = [
            SELECT COUNT()
            FROM Trip__c
            WHERE Opportunity__c = :opp.Id
        ];

        System.assertEquals(
            0,
            tripCount,
            'Aucun Trip ne doit être créé si l’Opportunity était déjà Closed Won.'
        );
    }
}
