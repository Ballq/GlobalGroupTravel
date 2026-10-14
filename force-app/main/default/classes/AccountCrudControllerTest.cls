@IsTest
private class AccountCrudControllerTest {

    @IsTest
    static void testCreateAccount() {
        Test.startTest();
        Account result = AccountCrudController.createAccount(
            'Compte Test',
            '0102030405',
            'https://example.com',
            'Technology'
        );
        Test.stopTest();

        System.assertNotEquals(null, result.Id);
        System.assertEquals('Compte Test', result.Name);
        System.assertEquals('0102030405', result.Phone);
        System.assertEquals('https://example.com', result.Website);
        System.assertEquals('Technology', result.Industry);
    }

    @IsTest
    static void testCreateAccountWithEmptyName() {
        Boolean exceptionThrown = false;

        Test.startTest();
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

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testCreateAccountWithOptionalFieldsNull() {
        Test.startTest();
        Account result = AccountCrudController.createAccount(
            'Compte Sans Champs Optionnels',
            null,
            null,
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, result.Id);
        System.assertEquals(null, result.Phone);
        System.assertEquals(null, result.Website);
        System.assertEquals(null, result.Industry);
    }

    @IsTest
    static void testDeleteAccount() {
        Account account = new Account(Name = 'Compte à supprimer');
        insert account;

        Test.startTest();
        AccountCrudController.deleteAccount(account.Id);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Account WHERE Id = :account.Id]
        );
    }

    @IsTest
    static void testDeleteAccountWithNullId() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AccountCrudController.deleteAccount(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testDeleteAccountWithUnknownId() {
        Boolean exceptionThrown = false;
        Id unknownAccountId = '001000000000001';

        Test.startTest();
        try {
            AccountCrudController.deleteAccount(unknownAccountId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testGetAccounts() {
        insert new List<Account>{
            new Account(Name = 'Compte B'),
            new Account(Name = 'Compte A')
        };

        Test.startTest();
        List<Account> results = AccountCrudController.getAccounts();
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assertEquals('Compte A', results[0].Name);
        System.assertEquals('Compte B', results[1].Name);
    }

    @IsTest
    static void testUpdateAccount() {
        Account account = new Account(Name = 'Ancien Nom');
        insert account;

        account.Name = 'Nouveau Nom';
        account.Phone = '0612345678';

        Test.startTest();
        AccountCrudController.updateAccount(account);
        Test.stopTest();

        Account updated = [
            SELECT Name, Phone
            FROM Account
            WHERE Id = :account.Id
        ];

        System.assertEquals('Nouveau Nom', updated.Name);
        System.assertEquals('0612345678', updated.Phone);
    }

    @IsTest
    static void testUpdateAccountWithEmptyName() {
        Account account = new Account(Name = 'Compte à modifier');
        insert account;
        account.Name = '';

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AccountCrudController.updateAccount(account);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testUpdateAccountWithNullAccount() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AccountCrudController.updateAccount(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testUpdateAccountWithMissingId() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AccountCrudController.updateAccount(
                new Account(Name = 'Compte sans identifiant')
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void testCreateAccountHandlesDmlException() {
        Test.startTest();
        try {
            AccountCrudController.createAccount(
                null,
                '0123456789',
                'https://example.com',
                null
            );
            System.assert(false, 'Une exception devait être déclenchée.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateAccountHandlesNullAccount() {
        Test.startTest();
        try {
            AccountCrudController.updateAccount(null);
            System.assert(false, 'Une exception devait être déclenchée.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }

    @IsTest
    static void testDeleteAccountHandlesNullId() {
        Test.startTest();
        try {
            AccountCrudController.deleteAccount(null);
            System.assert(false, 'Une exception devait être déclenchée.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }

    
@IsTest
static void testCreateAccountWithNameTooLongThrowsHandledException() {
    String longName = '';
    for (Integer i = 0; i < 300; i++) {
        longName += 'A';
    }

    Test.startTest();

    Boolean exceptionCaught = false;

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

    System.assert(
        exceptionCaught,
        'Une exception gérée doit être levée si le nom dépasse la longueur autorisée.'
    );
}

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

    Test.startTest();

    Boolean exceptionCaught = false;

    try {
        AccountCrudController.updateAccount(account);
    } catch (AuraHandledException e) {
        exceptionCaught = true;
    }

    Test.stopTest();

    System.assert(
        exceptionCaught,
        'Une exception gérée doit être levée si la mise à jour échoue.'
    );
}


}