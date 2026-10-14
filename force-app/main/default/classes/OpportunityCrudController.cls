
public with sharing class OpportunityCrudController {

    // CREATE : créer une opportunité
    @AuraEnabled
    public static Opportunity createOpportunity(
        String name,
        Id accountId,
        String stageName,
        Date closeDate,
        Decimal amount,
        String destination,
        Date startDate,
        Date endDate,
        Decimal numberOfParticipants
    ) {
        validateOpportunity(
            name,
            accountId,
            stageName,
            closeDate,
            startDate,
            endDate
        );

        Opportunity opportunity = new Opportunity(
            Name = name,
            AccountId = accountId,
            StageName = stageName,
            CloseDate = closeDate,
            Amount = amount,
            Destination__c = destination,
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Number_of_Participants__c = numberOfParticipants
        );

        try {
            insert opportunity;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de créer l’opportunité : ' +
                e.getDmlMessage(0)
            );
        }

        return opportunity;
    }

    // READ : récupérer les opportunités
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities() {
        try {
            return [
                SELECT Id,
                       Name,
                       AccountId,
                       Account.Name,
                       StageName,
                       CloseDate,
                       Amount,
                       Destination__c,
                       Start_Date__c,
                       End_Date__c,
                       Number_of_Participants__c
                FROM Opportunity
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                'Impossible de récupérer les opportunités : ' +
                e.getMessage()
            );
        }
    }

    // UPDATE : modifier une opportunité
    @AuraEnabled
    public static void updateOpportunity(Opportunity opportunity) {
        if (opportunity == null || opportunity.Id == null) {
            throw new AuraHandledException(
                'Impossible de modifier l’opportunité : ' +
                'l’opportunité sélectionnée est invalide.'
            );
        }

        validateOpportunity(
            opportunity.Name,
            opportunity.AccountId,
            opportunity.StageName,
            opportunity.CloseDate,
            opportunity.Start_Date__c,
            opportunity.End_Date__c
        );

        try {
            update opportunity;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de modifier l’opportunité : ' +
                e.getDmlMessage(0)
            );
        }
    }

    // DELETE : supprimer une opportunité
    @AuraEnabled
    public static void deleteOpportunity(Id opportunityId) {
        if (opportunityId == null) {
            throw new AuraHandledException(
                'Impossible de supprimer l’opportunité : ' +
                'aucune opportunité n’a été sélectionnée.'
            );
        }

        Opportunity opportunity;

        try {
            opportunity = [
                SELECT Id
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
            ];
        } catch (QueryException e) {
            throw new AuraHandledException(
                'Impossible de supprimer l’opportunité : ' +
                'l’opportunité demandée n’existe pas.'
            );
        }

        try {
            delete opportunity;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de supprimer l’opportunité : ' +
                e.getDmlMessage(0)
            );
        }
    }

    // VALIDATION : contrôles communs à la création et à la modification
    private static void validateOpportunity(
        String name,
        Id accountId,
        String stageName,
        Date closeDate,
        Date startDate,
        Date endDate
    ) {
        if (String.isBlank(name)) {
            throw new AuraHandledException(
                'Le nom de l’opportunité est obligatoire.'
            );
        }

        if (accountId == null) {
            throw new AuraHandledException(
                'Un compte doit être associé à l’opportunité.'
            );
        }

        if (String.isBlank(stageName)) {
            throw new AuraHandledException(
                'L’étape de l’opportunité est obligatoire.'
            );
        }

        if (closeDate == null) {
            throw new AuraHandledException(
                'La date de clôture est obligatoire.'
            );
        }

        if (startDate != null &&
            endDate != null &&
            endDate <= startDate) {
            throw new AuraHandledException(
                'La date de fin du voyage doit être postérieure ' +
                'à la date de début.'
            );
        }
    }
}