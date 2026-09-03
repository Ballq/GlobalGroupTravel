trigger OpportunityTrigger on Opportunity (after update) {

    List<Trip__c> tripsToCreate = new List<Trip__c>();

    Set<Id> opportunityIds = new Set<Id>();

    for (Opportunity opp : Trigger.new) {

        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        if (opp.StageName == 'Closed Won' &&
            oldOpp.StageName != 'Closed Won') {

            opportunityIds.add(opp.Id);
        }
    }

    if (opportunityIds.isEmpty()) {
        return;
    }

    Set<Id> opportunitiesWithTrip = new Set<Id>();

    for (Trip__c trip : [
        SELECT Opportunity__c
        FROM Trip__c
        WHERE Opportunity__c IN :opportunityIds
    ]) {
        opportunitiesWithTrip.add(trip.Opportunity__c);
    }

    for (Opportunity opp : Trigger.new) {

        if (opportunityIds.contains(opp.Id) &&
            !opportunitiesWithTrip.contains(opp.Id)) {

            Trip__c trip = new Trip__c(
                Status__c = 'A venir',
                Destination__c = opp.Destination__c,
                Start_Date__c = opp.Start_Date__c,
                End_Date__c = opp.End_Date__c,
                Number_of_Participants__c = opp.Number_of_Participants__c,
                Total_Cost__c = opp.Amount,
                Account__c = opp.AccountId,
                Opportunity__c = opp.Id
            );

            tripsToCreate.add(trip);
        }
    }

    if (!tripsToCreate.isEmpty()) {
        insert tripsToCreate;
    }
}
