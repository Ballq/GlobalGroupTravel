@IsTest
private class ContractCrudControllerTest {

    // ============================================================
    // CREATE
    // ============================================================

    @IsTest
    static void testCreateContract() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

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


    @IsTest
    static void testCreateContractWithNullAccount() {

        Boolean exceptionThrown = false;

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le compte est null.'
        );
    }


    @IsTest
    static void testCreateContractWithNullStartDate() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la date de début est null.'
        );
    }


    @IsTest
    static void testCreateContractWithInvalidContractTerm() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est inférieure ou égale à 0.'
        );
    }


    @IsTest
    static void testCreateContractWithNullContractTerm() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est null.'
        );
    }


    @IsTest
    static void testCreateContractWithEmptyStatus() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le statut est vide.'
        );
    }


    // ============================================================
    // READ
    // ============================================================

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

        System.assertEquals(
            true,
            found,
            'Le contrat créé doit être présent dans le résultat.'
        );
    }


    // ============================================================
    // UPDATE
    // ============================================================

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


    @IsTest
    static void testUpdateContractWithNullId() {

        Account account = TestDataFactory.createTestAccount();
        insert account;

        Boolean exceptionThrown = false;

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si l’identifiant est null.'
        );
    }


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

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le compte est null.'
        );
    }


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

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la date de début est null.'
        );
    }


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

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est inférieure ou égale à 0.'
        );
    }


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

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si la durée est null.'
        );
    }


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

        Test.startTest();

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

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si le statut est vide.'
        );
    }


    // ============================================================
    // DELETE
    // ============================================================

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

        System.assertEquals(
            0,
            contractCount,
            'Le contrat doit être supprimé.'
        );
    }


    @IsTest
    static void testDeleteContractWithNullId() {

        Boolean exceptionThrown = false;

        Test.startTest();

        try {
            ContractCrudController.deleteContract(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        System.assertEquals(
            true,
            exceptionThrown,
            'Une erreur doit être levée si l’identifiant est null.'
        );
    }
}