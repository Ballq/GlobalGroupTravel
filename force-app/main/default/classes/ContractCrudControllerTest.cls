// Tests du controleur ContractCrudController : creer, lire, modifier, supprimer un contrat, cas normaux et cas d erreur.
@IsTest
private class ContractCrudControllerTest {

    // TEST : creation d un contrat valide.
    // On verifie qu il est bien enregistre avec les bonnes valeurs.
    @IsTest
    static void testCreateContract() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(
            null,
            contractRecord.Id,
            'Le contrat doit être créé.'
        );

        System.assertEquals(
            account.Id,
            contractRecord.AccountId
        );

        System.assertEquals(
            Date.today(),
            contractRecord.StartDate
        );

        System.assertEquals(
            12,
            contractRecord.ContractTerm
        );

        System.assertEquals(
            'Draft',
            contractRecord.Status
        );

        System.assertEquals(
            'Test contract',
            contractRecord.Description
        );
    }

    // TEST : creation sans compte (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateContractWithNullAccount() {

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.createContract(
                null,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le compte est null.'
        );
    }

    // TEST : creation sans date de debut (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateContractWithNullStartDate() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.createContract(
                account.Id,
                null,
                12,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la date de début est null.'
        );
    }

    // TEST : creation avec duree du contrat invalide(s).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateContractWithInvalidContractTerm() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                0,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est inférieure ou égale à 0.'
        );
    }

    // TEST : creation sans duree du contrat (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateContractWithNullContractTerm() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                null,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est null.'
        );
    }

    // TEST : creation sans statut (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateContractWithEmptyStatus() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                '',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le statut est vide.'
        );
    }

    // TEST : lecture de la liste des contrats.
    // On cree des donnees puis on verifie le contenu de la liste renvoyee.
    @IsTest
    static void testGetContracts() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        List<Contract> contracts =
            ContractCrudController.getContracts();

        Test.stopTest();

        Boolean found = false;

        for (Contract currentContract : contracts) {

            if (currentContract.Id == contractRecord.Id) {
                found = true;
                break;
            }
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            found,
            'Le contrat créé doit être présent dans le résultat.'
        );
    }

    // TEST : modification d un contrat existant.
    // On verifie que les nouvelles valeurs sont bien enregistrees.
    @IsTest
    static void testUpdateContract() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Initial description'
            );

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        ContractCrudController.updateContract(
            contractRecord.Id,
            account.Id,
            Date.today().addDays(1),
            24,
            'Activated',
            'Updated description'
        );

        Test.stopTest();

        Contract updatedContract = [
            SELECT Id,
                   AccountId,
                   StartDate,
                   ContractTerm,
                   Status,
                   Description
            FROM Contract
            WHERE Id = :contractRecord.Id
        ];

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            account.Id,
            updatedContract.AccountId
        );

        System.assertEquals(
            Date.today().addDays(1),
            updatedContract.StartDate
        );

        System.assertEquals(
            24,
            updatedContract.ContractTerm
        );

        System.assertEquals(
            'Activated',
            updatedContract.Status
        );

        System.assertEquals(
            'Updated description',
            updatedContract.Description
        );
    }

    // TEST : modification sans identifiant (null).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateContractWithNullId() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.updateContract(
                null,
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si l’identifiant est null.'
        );
    }

    // TEST : modification sans compte (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateContractWithNullAccount() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.updateContract(
                contractRecord.Id,
                null,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le compte est null.'
        );
    }

    // TEST : modification sans date de debut (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateContractWithNullStartDate() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.updateContract(
                contractRecord.Id,
                account.Id,
                null,
                12,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la date de début est null.'
        );
    }

    // TEST : modification avec duree du contrat invalide(s).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateContractWithInvalidContractTerm() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.updateContract(
                contractRecord.Id,
                account.Id,
                Date.today(),
                0,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est inférieure ou égale à 0.'
        );
    }

    // TEST : modification sans duree du contrat (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateContractWithNullContractTerm() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.updateContract(
                contractRecord.Id,
                account.Id,
                Date.today(),
                null,
                'Draft',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est null.'
        );
    }

    // TEST : modification sans statut (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateContractWithEmptyStatus() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.updateContract(
                contractRecord.Id,
                account.Id,
                Date.today(),
                12,
                '',
                'Test contract'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le statut est vide.'
        );
    }

    // TEST : suppression d un contrat existant.
    // On verifie qu il n existe plus apres.
    @IsTest
    static void testDeleteContract() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        ContractCrudController.deleteContract(
            contractRecord.Id
        );

        Test.stopTest();

        Integer contractCount = [
            SELECT COUNT()
            FROM Contract
            WHERE Id = :contractRecord.Id
        ];

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            0,
            contractCount,
            'Le contrat doit être supprimé.'
        );
    }

    // TEST : suppression sans identifiant (null).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testDeleteContractWithNullId() {

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.deleteContract(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si l’identifiant est null.'
        );
    }
        // TEST : suppression d un contrat qui n existe plus (identifiant deja supprime).
    // On s attend a une erreur claire (AuraHandledException).
    @IsTest
    static void testDeleteContractWithUnknownId() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        // On supprime le contrat pour que son Id n existe plus.
        delete contractRecord;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.deleteContract(contractRecord.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit etre levee si le contrat n existe pas.'
        );
    }

    // TEST : modification d un contrat qui a ete supprime.
    // Salesforce refuse l update : on verifie que l erreur est renvoyee sous forme d AuraHandledException.
    @IsTest
    static void testUpdateDeletedContractThrowsHandledException() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Contract contractRecord =
            ContractCrudController.createContract(
                account.Id,
                Date.today(),
                12,
                'Draft',
                'Test contract'
            );

        // On supprime le contrat pour que la modification echoue.
        delete contractRecord;

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            ContractCrudController.updateContract(
                contractRecord.Id,
                account.Id,
                Date.today(),
                6,
                'Draft',
                'Modification'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur lisible doit etre renvoyee.'
        );
    }
}