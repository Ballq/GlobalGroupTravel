@IsTest
private class AccountSelectorTest {

    @IsTest
    static void testGetAccountById() {

        // Création d'un compte
        Account account = new Account(
            Name = 'Client Test',
            Customer_Type__c = 'Particulier'
        );

        insert account;

        Test.startTest();

        Account result = AccountSelector.getAccountById(account.Id);

        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(account.Id, result.Id);
        System.assertEquals('Particulier', result.Customer_Type__c);

    }

}