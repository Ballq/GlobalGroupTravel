public with sharing class AccountSelector {

    public static Account getAccountById(Id accountId) {

        return [
            SELECT Id,
                   Name,
                   Customer_Type__c
            FROM Account
            WHERE Id = :accountId
        ];

    }

}