public with sharing class AccountCasesController {

    @AuraEnabled(cacheable=true)
    public static List<Case> findCasesBySubject(Id accountId, String subjectSearchTerm){

        return [
            SELECT Id,
                   Subject,
                   Status,
                   Priority,
                   AccountId
            FROM Case
            WHERE AccountId = :accountId
            AND Subject LIKE :('%' + subjectSearchTerm + '%')
        ];

    }

}