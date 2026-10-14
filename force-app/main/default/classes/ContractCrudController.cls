public with sharing class ContractCrudController {

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

        Contract contractRecord = new Contract(
            AccountId = accountId,
            StartDate = startDate,
            ContractTerm = contractTerm,
            Status = status,
            Description = description
        );

        insert contractRecord;

        return contractRecord;
    }


    @AuraEnabled(cacheable=true)
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


        Contract contractRecord = new Contract(
            Id = contractId,
            AccountId = accountId,
            StartDate = startDate,
            ContractTerm = contractTerm,
            Status = status,
            Description = description
        );


        update contractRecord;
    }


    @AuraEnabled
    public static void deleteContract(Id contractId) {

        if (contractId == null) {
            throw new AuraHandledException(
                'L’identifiant du contrat est obligatoire.'
            );
        }


        Contract contractRecord = [
            SELECT Id
            FROM Contract
            WHERE Id = :contractId
            LIMIT 1
        ];


        delete contractRecord;
    }
}