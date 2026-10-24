
// Tests du controleur OpportunityCrudController : creer, lire, modifier, supprimer une opportunite, cas normaux et cas d erreur.
@IsTest
private class OpportunityCrudControllerTest {

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

    // TEST : creation d un opportunite valide.
    // On verifie qu il est bien enregistre avec les bonnes valeurs.
    @IsTest
    static void testCreateOpportunity() {
        Account account = insertTestAccount();

        // startTest : ici commence la partie du test qui execute le code a tester.
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

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(null, opportunity.Id);
        System.assertEquals('Test Opportunity CRUD', opportunity.Name);
        System.assertEquals(account.Id, opportunity.AccountId);
        System.assertEquals('Prospecting', opportunity.StageName);
        System.assertEquals(5000, opportunity.Amount);
        System.assertEquals('Paris', opportunity.Destination__c);
        System.assertEquals(20, opportunity.Number_of_Participants__c);
    }

    // TEST : creation sans nom (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateOpportunityWithEmptyName() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
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

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : creation sans compte (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateOpportunityWithNullAccount() {
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
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

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : creation sans etape (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateOpportunityWithEmptyStage() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
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

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : creation sans date de cloture (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateOpportunityWithNullCloseDate() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
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

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : creation avec des dates incoherentes (la fin n est pas apres le debut).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateOpportunityWithInvalidDates() {
        Account account = insertTestAccount();
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
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

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : lecture de la liste des opportunites.
    // On cree des donnees puis on verifie le contenu de la liste renvoyee.
    @IsTest
    static void testGetOpportunities() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        List<Opportunity> opportunities =
            OpportunityCrudController.getOpportunities();
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
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

    // TEST : modification d un opportunite existant.
    // On verifie que les nouvelles valeurs sont bien enregistrees.
    @IsTest
    static void testUpdateOpportunity() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        opportunity.Name = 'Opportunity Updated';
        opportunity.Amount = 7500;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        OpportunityCrudController.updateOpportunity(opportunity);
        Test.stopTest();

        Opportunity updatedOpportunity = [
            SELECT Id, Name, Amount
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            'Opportunity Updated',
            updatedOpportunity.Name
        );
        System.assertEquals(7500, updatedOpportunity.Amount);
    }

    // TEST : modification avec un opportunite null (objet vide).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateOpportunityWithNullOpportunity() {
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            OpportunityCrudController.updateOpportunity(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : modification sans nom (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateOpportunityWithEmptyName() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);
        opportunity.Name = '';

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : modification sans compte (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateOpportunityWithNullAccount() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);
        opportunity.AccountId = null;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : modification sans date de cloture (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateOpportunityWithNullCloseDate() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);
        opportunity.CloseDate = null;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : modification avec des dates incoherentes (la fin n est pas apres le debut).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateOpportunityWithInvalidDates() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        opportunity.Start_Date__c = Date.today().addDays(20);
        opportunity.End_Date__c = Date.today().addDays(10);

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            OpportunityCrudController.updateOpportunity(opportunity);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : suppression d un opportunite existant.
    // On verifie qu il n existe plus apres.
    @IsTest
    static void testDeleteOpportunity() {
        Account account = insertTestAccount();
        Opportunity opportunity = insertTestOpportunity(account.Id);

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        OpportunityCrudController.deleteOpportunity(opportunity.Id);
        Test.stopTest();

        Integer opportunityCount = [
            SELECT COUNT()
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(0, opportunityCount);
    }

    // TEST : suppression sans identifiant (null).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testDeleteOpportunityWithNullId() {
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            OpportunityCrudController.deleteOpportunity(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : suppression avec un identifiant qui n existe pas.
    // On s attend a une erreur claire (AuraHandledException).
    @IsTest
    static void testDeleteOpportunityWithUnknownId() {
        Id fakeOpportunityId = '006000000000000AAA';
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            OpportunityCrudController.deleteOpportunity(
                fakeOpportunityId
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }
}