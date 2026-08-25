@IsTest
public class AccountCasesControllerTest {

    @TestSetup
    static void makeData(){
        // Create test Account
        Account testAccount = TestDataFactory.createTestAccount();

        // Create test Cases
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(
            AccountId = testAccount.Id,
            Subject = 'Test Case 1',
            Status = 'New',
            Priority = 'High'
        ));
        testCases.add(new Case(
            AccountId = testAccount.Id,
            Subject = 'Another Test Case',
            Status = 'Closed',
            Priority = 'Low'
        ));
        testCases.add(new Case(
            AccountId = testAccount.Id,
            Subject = 'Sample Issue',
            Status = 'In Progress',
            Priority = 'Medium'
        ));
        insert testCases;
    }

    @IsTest
    static void testFindCasesBySubject_FoundMatches() {
        // Given
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String searchTerm = 'Test';

        // When
        List<Case> result = AccountCasesController.findCasesBySubject(testAccount.Id, searchTerm);

        // Then
        System.assertEquals(2, result.size(), 'Should find 2 cases with "Test" in subject');
        for(Case c : result) {
            System.assert(c.Subject.contains(searchTerm), 'Subject should contain search term');
            System.assertEquals(testAccount.Id, c.AccountId, 'Case should belong to test account');
        }
    }

    @IsTest
    static void testFindCasesBySubject_NoMatches() {
        // Given
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String searchTerm = 'NonExistent';

        // When
        List<Case> result = AccountCasesController.findCasesBySubject(testAccount.Id, searchTerm);

        // Then
        System.assertEquals(0, result.size(), 'Should find no cases with non-existent search term');
    }

    @IsTest
    static void testFindCasesBySubject_EmptySearchTerm() {
        // Given
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String searchTerm = '';

        // When
        List<Case> result = AccountCasesController.findCasesBySubject(testAccount.Id, searchTerm);

        // Then
        System.assertEquals(3, result.size(), 'Should return all cases when search term is empty');
    }

    @IsTest
    static void testFindCasesBySubject_SingleMatch() {
        // Given
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String searchTerm = 'Sample';

        // When
        List<Case> result = AccountCasesController.findCasesBySubject(testAccount.Id, searchTerm);

        // Then
        System.assertEquals(1, result.size(), 'Should find 1 case with "Sample" in subject');
        System.assertEquals('Sample Issue', result[0].Subject, 'Should return the correct case');
    }
}