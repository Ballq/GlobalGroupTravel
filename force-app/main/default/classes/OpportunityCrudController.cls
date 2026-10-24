
// Classe qui gere les opportunites (ventes) : creer, lire, modifier, supprimer (CRUD).
// Appelee par le composant LWC tripManager.
public with sharing class OpportunityCrudController {

    // METHODE createOpportunity : cree une opportunite de vente.
    // Role : valider les donnees avec validateOpportunity, puis enregistrer.
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
        // On appelle la methode de controle commune (nom, compte, etape, dates).
        validateOpportunity(
            name,
            accountId,
            stageName,
            closeDate,
            startDate,
            endDate
        );

        // On prepare l opportunite en memoire, avec les champs du voyage (destination, dates, participants).
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
            // insert = on enregistre l opportunite dans la base.
            insert opportunity;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de créer l’opportunité : ' +
                e.getDmlMessage(0)
            );
        }

        return opportunity;
    }

    // METHODE getOpportunities : lit toutes les opportunites, les plus recentes en premier.
    // Pas de cacheable=true ici : sinon Salesforce renvoie d anciennes donnees gardees en cache et le bouton Actualiser ne marche pas.
    @AuraEnabled
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

    // METHODE updateOpportunity : modifie une opportunite existante.
    // Role : verifier qu elle a un Id, valider les champs, puis mettre a jour.
    @AuraEnabled
    public static void updateOpportunity(Opportunity opportunity) {
        if (opportunity == null || opportunity.Id == null) {
            throw new AuraHandledException(
                'Impossible de modifier l’opportunité : ' +
                'l’opportunité sélectionnée est invalide.'
            );
        }

        // Meme controle que pour la creation.
        validateOpportunity(
            opportunity.Name,
            opportunity.AccountId,
            opportunity.StageName,
            opportunity.CloseDate,
            opportunity.Start_Date__c,
            opportunity.End_Date__c
        );

        try {
            // update = on enregistre les modifications.
            update opportunity;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de modifier l’opportunité : ' +
                e.getDmlMessage(0)
            );
        }
    }

    // METHODE deleteOpportunity : supprime une opportunite grace a son Id.
    // Role : verifier qu elle existe, puis la supprimer.
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
        // Si la requete ne trouve rien, l opportunite n existe pas.
        } catch (QueryException e) {
            throw new AuraHandledException(
                'Impossible de supprimer l’opportunité : ' +
                'l’opportunité demandée n’existe pas.'
            );
        }

        try {
            // delete = on supprime l opportunite.
            delete opportunity;
        } catch (DmlException e) {
            throw new AuraHandledException(
                'Impossible de supprimer l’opportunité : ' +
                e.getDmlMessage(0)
            );
        }
    }

    // METHODE validateOpportunity (private = utilisable seulement dans cette classe).
    // Role : eviter d ecrire deux fois les memes controles dans create et update.
    // Elle renvoie une erreur si le nom, le compte, l etape ou la date de cloture manque,
    // ou si la date de fin du voyage n est pas apres la date de debut.
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

        // On compare les dates du voyage seulement si les deux sont remplies.
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