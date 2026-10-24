// Classe qui gere les comptes clients (Account) : creer, lire, modifier, supprimer (CRUD).
// Appelee par le composant LWC tripManager.
public with sharing class AccountCrudController {

    // METHODE createAccount : cree un nouveau compte client.
    // Role : verifier que le nom est rempli, puis enregistrer le compte.
    @AuraEnabled
    public static Account createAccount(
        String name,
        String phone,
        String website,
        String industry
    ) {
        // Le nom est obligatoire : s il est vide on renvoie une erreur.
        if (String.isBlank(name)) {
            throw new AuraHandledException(
                'Impossible de créer le compte : le nom du compte est obligatoire.'
            );
        }

        // On prepare le compte en memoire avec les valeurs recues.
        Account account = new Account(
            Name = name,
            Phone = phone,
            Website = website,
            Industry = industry
        );

        try {
            // insert = on enregistre le compte dans la base.
            insert account;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de créer le compte : ' + e.getDmlMessage(0)
            );
        }

        return account;
    }

    // METHODE getAccounts : lit tous les comptes tries par nom (de A a Z).
    // Pas de cacheable=true ici : sinon Salesforce renvoie d anciennes donnees gardees en cache et le bouton Actualiser ne marche pas.
    @AuraEnabled
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

    // METHODE updateAccount : modifie un compte qui existe deja.
    // Role : verifier le compte (Id et nom), puis mettre a jour.
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
            // update = on enregistre les modifications.
            update account;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de modifier le compte : ' + e.getDmlMessage(0)
            );
        }
    }

    // METHODE deleteAccount : supprime un compte grace a son Id.
    // Role : verifier que le compte existe, puis le supprimer.
    @AuraEnabled
    public static void deleteAccount(Id accountId) {

        if (accountId == null) {
            throw new AuraHandledException(
                'Impossible de supprimer le compte : aucun compte n’a été sélectionné.'
            );
        }

        // On declare la variable avant le try pour pouvoir l utiliser apres.
        Account account;

        try {
            account = [
                SELECT Id
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];
        // Si la requete ne trouve rien, c est que le compte n existe pas : on le dit a l utilisateur.
        } catch (QueryException e) {
            throw new AuraHandledException(
                'Impossible de supprimer le compte : le compte demandé n’existe pas.'
            );
        }

        try {
            // delete = on supprime le compte. Ca peut echouer s il est lie a d autres donnees.
            delete account;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de supprimer le compte : ce compte est probablement utilisé par d’autres données. ' +
                e.getDmlMessage(0)
            );
        }
    }
}