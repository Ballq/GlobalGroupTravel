// Tests du controleur AccountCrudController : creer, lire, modifier, supprimer un compte, cas normaux et cas d erreur.
@IsTest
private class AccountCrudControllerTest {

    // TEST : creation d un compte valide.
    // On verifie qu il est bien enregistre avec les bonnes valeurs.
    @IsTest
    static void testCreateAccount() {
        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        Account result = AccountCrudController.createAccount(
            'Compte Test',
            '0102030405',
            'https://example.com',
            'Technology'
        );
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(null, result.Id);
        System.assertEquals('Compte Test', result.Name);
        System.assertEquals('0102030405', result.Phone);
        System.assertEquals('https://example.com', result.Website);
        System.assertEquals('Technology', result.Industry);
    }

    // TEST : creation sans nom (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateAccountWithEmptyName() {
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.createAccount(
                ' ',
                null,
                null,
                null
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : creation d un compte avec telephone, site web et secteur vides.
    // Ces champs sont facultatifs : le compte doit etre cree sans erreur.
    @IsTest
    static void testCreateAccountWithOptionalFieldsNull() {
        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        Account result = AccountCrudController.createAccount(
            'Compte Sans Champs Optionnels',
            null,
            null,
            null
        );
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(null, result.Id);
        System.assertEquals(null, result.Phone);
        System.assertEquals(null, result.Website);
        System.assertEquals(null, result.Industry);
    }

    // TEST : suppression d un compte existant.
    // On verifie qu il n existe plus apres.
    @IsTest
    static void testDeleteAccount() {
        Account account = new Account(Name = 'Compte à supprimer');
        insert account;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        AccountCrudController.deleteAccount(account.Id);
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Account WHERE Id = :account.Id]
        );
    }

    // TEST : suppression sans identifiant (null).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testDeleteAccountWithNullId() {
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.deleteAccount(null);
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
    static void testDeleteAccountWithUnknownId() {
        Boolean exceptionThrown = false;
        Id unknownAccountId = '001000000000001';

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.deleteAccount(unknownAccountId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : lecture de la liste des comptes.
    // On cree des donnees puis on verifie le contenu de la liste renvoyee.
    @IsTest
    static void testGetAccounts() {
        insert new List<Account>{
            new Account(Name = 'Compte B'),
            new Account(Name = 'Compte A')
        };

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        List<Account> results = AccountCrudController.getAccounts();
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(2, results.size());
        System.assertEquals('Compte A', results[0].Name);
        System.assertEquals('Compte B', results[1].Name);
    }

    // TEST : modification d un compte existant.
    // On verifie que les nouvelles valeurs sont bien enregistrees.
    @IsTest
    static void testUpdateAccount() {
        Account account = new Account(Name = 'Ancien Nom');
        insert account;

        account.Name = 'Nouveau Nom';
        account.Phone = '0612345678';

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        AccountCrudController.updateAccount(account);
        Test.stopTest();

        Account updated = [
            SELECT Name, Phone
            FROM Account
            WHERE Id = :account.Id
        ];

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals('Nouveau Nom', updated.Name);
        System.assertEquals('0612345678', updated.Phone);
    }

    // TEST : modification sans nom (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateAccountWithEmptyName() {
        Account account = new Account(Name = 'Compte à modifier');
        insert account;
        account.Name = '';

        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.updateAccount(account);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : modification avec un compte null (objet vide).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateAccountWithNullAccount() {
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.updateAccount(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : modification sans identifiant (null).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateAccountWithMissingId() {
        Boolean exceptionThrown = false;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.updateAccount(
                new Account(Name = 'Compte sans identifiant')
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(true, exceptionThrown);
    }

    // TEST : creation d un compte avec un nom vide.
    // On verifie que l erreur est renvoyee sous forme d AuraHandledException (message lisible pour l ecran).
    @IsTest
    static void testCreateAccountHandlesDmlException() {
        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.createAccount(
                null,
                '0123456789',
                'https://example.com',
                null
            );
            // assert : le test echoue si le resultat obtenu n est pas celui attendu.
            System.assert(false, 'Une exception devait être déclenchée.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }

    // TEST : modification avec un compte null.
    // On verifie qu une AuraHandledException est levee.
    @IsTest
    static void testUpdateAccountHandlesNullAccount() {
        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.updateAccount(null);
            // assert : le test echoue si le resultat obtenu n est pas celui attendu.
            System.assert(false, 'Une exception devait être déclenchée.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }

    // TEST : suppression avec un identifiant null.
    // On verifie qu une AuraHandledException est levee.
    @IsTest
    static void testDeleteAccountHandlesNullId() {
        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            AccountCrudController.deleteAccount(null);
            // assert : le test echoue si le resultat obtenu n est pas celui attendu.
            System.assert(false, 'Une exception devait être déclenchée.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }

// TEST : creation avec un nom de 300 caracteres (trop long).
// On verifie que l erreur de la base est renvoyee sous forme d AuraHandledException.
@IsTest
static void testCreateAccountWithNameTooLongThrowsHandledException() {
    String longName = '';
    for (Integer i = 0; i < 300; i++) {
        longName += 'A';
    }

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    Boolean exceptionCaught = false;

    // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
    try {
        AccountCrudController.createAccount(
            longName,
            null,
            null,
            null
        );
    } catch (AuraHandledException e) {
        exceptionCaught = true;
    }

    Test.stopTest();

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assert(
        exceptionCaught,
        'Une exception gérée doit être levée si le nom dépasse la longueur autorisée.'
    );
}

// TEST : modification avec un nom de 300 caracteres (trop long).
// On verifie que l erreur de la base est renvoyee sous forme d AuraHandledException.
@IsTest
static void testUpdateAccountWithNameTooLongThrowsHandledException() {
    Account account = new Account(
        Name = 'Compte Test Longueur'
    );
    insert account;

    String longName = '';
    for (Integer i = 0; i < 300; i++) {
        longName += 'A';
    }

    account.Name = longName;

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    Boolean exceptionCaught = false;

    // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
    try {
        AccountCrudController.updateAccount(account);
    } catch (AuraHandledException e) {
        exceptionCaught = true;
    }

    Test.stopTest();

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assert(
        exceptionCaught,
        'Une exception gérée doit être levée si la mise à jour échoue.'
    );
}

}