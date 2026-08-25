public with sharing class TransporterSelector {

    public static List<Tarif_de_livraison__c> getAvailableTransporters(
        String country,
        String customerType
    ) {

        return [
            SELECT Id,
                   Country__c,
                   Price__c,
                   Delivery_Delay__c,
                   Transporteur__c,
                   Transporteur__r.Name,
                   Transporteur__r.Customer_Type__c
            FROM Tarif_de_livraison__c
            WHERE Country__c = :country
            AND Transporteur__r.Customer_Type__c = :customerType
        ];

    }

}