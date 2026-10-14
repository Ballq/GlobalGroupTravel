
@IsTest
private class OpportunityCrudControllerTest {

    // ============================================================
    // HELPERS : données de test
    // ============================================================

    private static Account insertTestAccount() {
        Account account = TestDataFactory.createTestAccount();
        insert account;
        return account;
    }

    private static Opportunity insertTestOpportunity(Id accountId) {
        Opportunity opportunity =
            TestDataFactory.createTestOpportunity(accountId);
        insert opportunity;
        return opportunity;
    }

    // ============================================================
    // CREATE
    // ============================================================

    @IsTest
    static void testCreateOpportunity() {
        Account account = insertTestAccount();

        Test.startTest();

        Opportunity opportunity =
            OpportunityCrudController.createOpportunity(
                'Test Opportunity CRUD',
                account.Id,
                'Prospecting',
                Date.today().addDays(30),
                5000,
                'Paris',
                Date.today().addDays(10),
                Date.today().addDays(15),
                20
            );

        Test.stopTest();

        System.assertNotEquals(null, opportunity.Id);
        System.assertEquals('Test Opportunity CRUD', opportunity.Name);
        System.assertEquals(account.Id, opportunity.AccountId);
        System.assertEquals('Prospecting', opportunity.StageName);
        System.assertEquals(5000, opportunity.Amount);
        System.assertEquals('Paris', opportunity.Destination__c);
        System.assertEquals(20, opportunity.Number_of_Participants__c);
    }

    @IsTest
    static void testCreateOpportunityWithEmptyName() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.createOpportunity(
                '',
                account.Id,
                'Prospecting',
                Date.today().addDays(30),
                5000,
                'Paris',
                Date.today().addDays(10),
                Date.today().addDays(15),
                20
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testCreateOpportunityWithNullAccount() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.createOpportunity(
                'Test Opportunity',
                null,
                'Prospecting',
                Date.today().addDays(30),
                5000,
                'Paris',
                Date.today().addDays(10),
                Date.today().addDays(15),
                20
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testCreateOpportunityWithEmptyStage() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.createOpportunity(
                'Test Opportunity',
                account.Id,
                '',
                Date.today().addDays(30),
                5000,
                'Paris',
                Date.today().addDays(10),
                Date.today().addDays(15),
                20
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testCreateOpportunityWithNullCloseDate() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.createOpportunity(
                'Test Opportunity',
                account.Id,
                'Prospecting',
                null,
                5000,
                'Paris',
                Date.today().addDays(10),
                Date.today().addDays(15),
                20
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testCreateOpportunityWithInvalidDates() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.createOpportunity(
                'Test Opportunity',
                account.Id,
                'Prospecting',
                Date.today().addDays(30),
                5000,
                'Paris',
                Date.today().addDays(20),
                Date.today().addDays(10),
                20
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    // ============================================================
    // READ
    // ============================================================

    @IsTest
    static void testGetOpportunities() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        Test.startTest();
        List<Opportunity> opportunities =
            OpportunityCrudController.getOpportunities();
        Test.stopTest();

        System.assert(
            opportunities.size() >= 1,
            'La liste des opportunités ne doit pas être vide.'
        );

        Boolean found = false;
        for (Opportunity currentOpportunity : opportunities) {
            if (currentOpportunity.Id == opportunity.Id) {
                found = true;
                break;
            }
        }

        System.assertEquals(
            true,
            found,
            'L’opportunité créée doit être présente dans le résultat.'
        );
    }

    // ============================================================
    // UPDATE
    // ============================================================

    @IsTest
    static void testUpdateOpportunity() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        opportunity.Name = 'Opportunity Updated';
        opportunity.Amount = 7500;

        Test.startTest();
        OpportunityCrudController.updateOpportunity(opportunity);
        Test.stopTest();

        Opportunity updatedOpportunity = [
            SELECT Id, Name, Amount
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];

        System.assertEquals(
            'Opportunity Updated',
            updatedOpportunity.Name
        );
        System.assertEquals(7500, updatedOpportunity.Amount);
    }

    @IsTest
    static void testUpdateOpportunityWithNullOpportunity() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.updateOpportunity(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testUpdateOpportunityWithEmptyName() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);
        opportunity.Name = '';

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testUpdateOpportunityWithNullAccount() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);
        opportunity.AccountId = null;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testUpdateOpportunityWithNullCloseDate() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);
        opportunity.CloseDate = null;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testUpdateOpportunityWithInvalidDates() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        opportunity.Start_Date__c = Date.today().addDays(20);
        opportunity.End_Date__c = Date.today().addDays(10);

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    // ============================================================
    // DELETE
    // ============================================================

    @IsTest
    static void testDeleteOpportunity() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        Test.startTest();
        OpportunityCrudController.deleteOpportunity(opportunity.Id);
        Test.stopTest();

        Integer opportunityCount = [
            SELECT COUNT()
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];

        System.assertEquals(0, opportunityCount);
    }

    @IsTest
    static void testDeleteOpportunityWithNullId() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.deleteOpportunity(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testDeleteOpportunityWithUnknownId() {
        Id fakeOpportunityId = '006000000000000AAA';
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OpportunityCrudController.deleteOpportunity(
                fakeOpportunityId
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }
}