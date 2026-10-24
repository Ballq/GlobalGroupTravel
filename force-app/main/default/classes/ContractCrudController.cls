// Classe qui gere les contrats (Contract) : creer, lire, modifier, supprimer (CRUD).
// Appelee par le composant LWC tripManager.
public with sharing class ContractCrudController {

    // METHODE createContract : cree un contrat.
    // Role : verifier le compte, la date de debut, la duree et le statut, puis enregistrer.
    @AuraEnabled
    public static Contract createContract(
        Id accountId,
        Date startDate,
        Integer contractTerm,
        String status,
        String description
    ) {
        if (accountId == null) {
            throw new AuraHandledException(
                'Le compte est obligatoire.'
            );
        }

        if (startDate == null) {
            throw new AuraHandledException(
                'La date de début est obligatoire.'
            );
        }

        // La duree du contrat (en mois) doit etre superieure a 0.
        if (contractTerm == null || contractTerm <= 0) {
            throw new AuraHandledException(
                'La durée du contrat doit être supérieure à 0.'
            );
        }

        if (String.isBlank(status)) {
            throw new AuraHandledException(
                'Le statut du contrat est obligatoire.'
            );
        }

        // On prepare le contrat en memoire. On l appelle contractRecord pour ne pas le confondre avec le mot Contract.
        Contract contractRecord = new Contract(
            AccountId = accountId,
            StartDate = startDate,
            ContractTerm = contractTerm,
            Status = status,
            Description = description
        );

        // try/catch : si Salesforce refuse l enregistrement, on renvoie son message a l ecran
        // (sans ca, l utilisateur verrait seulement une erreur technique peu claire).
        try {
            // insert = on enregistre le contrat dans la base.
            insert contractRecord;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de créer le contrat : ' + e.getDmlMessage(0)
            );
        }

        return contractRecord;
    }

    // METHODE getContracts : lit tous les contrats tries par date de debut.
    // On recupere aussi le nom du compte (Account.Name) grace a la relation.
    // Pas de cacheable=true ici : sinon Salesforce renvoie d anciennes donnees gardees en cache et le bouton Actualiser ne marche pas.
    @AuraEnabled
    public static List<Contract> getContracts() {

        return [
            SELECT Id,
                   ContractNumber,
                   AccountId,
                   Account.Name,
                   StartDate,
                   EndDate,
                   ContractTerm,
                   Status,
                   Description
            FROM Contract
            ORDER BY StartDate ASC
        ];
    }

    // METHODE updateContract : modifie un contrat existant.
    // Role : on verifie les memes champs qu a la creation, plus l Id du contrat.
    @AuraEnabled
    public static void updateContract(
        Id contractId,
        Id accountId,
        Date startDate,
        Integer contractTerm,
        String status,
        String description
    ) {

        if (contractId == null) {
            throw new AuraHandledException(
                'L’identifiant du contrat est obligatoire.'
            );
        }

        if (accountId == null) {
            throw new AuraHandledException(
                'Le compte est obligatoire.'
            );
        }

        if (startDate == null) {
            throw new AuraHandledException(
                'La date de début est obligatoire.'
            );
        }

        if (contractTerm == null || contractTerm <= 0) {
            throw new AuraHandledException(
                'La durée du contrat doit être supérieure à 0.'
            );
        }

        if (String.isBlank(status)) {
            throw new AuraHandledException(
                'Le statut du contrat est obligatoire.'
            );
        }

        // On cree un contrat avec l Id du contrat existant : Salesforce sait ainsi quel contrat modifier.
        Contract contractRecord = new Contract(
            Id = contractId,
            AccountId = accountId,
            StartDate = startDate,
            ContractTerm = contractTerm,
            Status = status,
            Description = description
        );

        // try/catch : meme principe qu a la creation, on affiche le vrai message de Salesforce.
        try {
            // update = on enregistre les modifications.
            update contractRecord;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de modifier le contrat : ' + e.getDmlMessage(0)
            );
        }
    }

    // METHODE deleteContract : supprime un contrat grace a son Id.
    @AuraEnabled
    public static void deleteContract(Id contractId) {

        if (contractId == null) {
            throw new AuraHandledException(
                'L’identifiant du contrat est obligatoire.'
            );
        }

        // On declare la variable avant le try pour pouvoir l utiliser apres.
        Contract contractRecord;

        try {
            // On cherche le contrat avec son Id (LIMIT 1 = un seul resultat).
            contractRecord = [
                SELECT Id
                FROM Contract
                WHERE Id = :contractId
                LIMIT 1
            ];
        } catch (QueryException e) {
            // Si la requete ne trouve rien, le contrat n existe pas.
            throw new AuraHandledException(
                'Le contrat est introuvable.'
            );
        }

        try {
            // delete = on supprime le contrat.
            delete contractRecord;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de supprimer le contrat : ' + e.getDmlMessage(0)
            );
        }
    }
}