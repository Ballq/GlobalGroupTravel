public with sharing class AccountCrudController {

    @AuraEnabled
    public static Account createAccount(
        String name,
        String phone,
        String website,
        String industry
    ) {
        if (String.isBlank(name)) {
            throw new AuraHandledException(
                'Impossible de créer le compte : le nom du compte est obligatoire.'
            );
        }

        Account account = new Account(
            Name = name,
            Phone = phone,
            Website = website,
            Industry = industry
        );

        try {
            insert account;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de créer le compte : ' + e.getDmlMessage(0)
            );
        }

        return account;
    }


    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        try {
            return [
                SELECT Id,
                       Name,
                       Phone,
                       Website,
                       Industry
                FROM Account
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                'Impossible de récupérer les comptes : ' + e.getMessage()
            );
        }
    }


    @AuraEnabled
    public static void updateAccount(Account account) {

        if (account == null || account.Id == null) {
            throw new AuraHandledException(
                'Impossible de modifier le compte : le compte sélectionné est invalide.'
            );
        }

        if (String.isBlank(account.Name)) {
            throw new AuraHandledException(
                'Impossible de modifier le compte : le nom du compte est obligatoire.'
            );
        }

        try {
            update account;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de modifier le compte : ' + e.getDmlMessage(0)
            );
        }
    }


    @AuraEnabled
    public static void deleteAccount(Id accountId) {

        if (accountId == null) {
            throw new AuraHandledException(
                'Impossible de supprimer le compte : aucun compte n’a été sélectionné.'
            );
        }

        Account account;

        try {
            account = [
                SELECT Id
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];
        } catch (QueryException e) {
            throw new AuraHandledException(
                'Impossible de supprimer le compte : le compte demandé n’existe pas.'
            );
        }

        try {
            delete account;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de supprimer le compte : ce compte est probablement utilisé par d’autres données. ' +
                e.getDmlMessage(0)
            );
        }
    }
}