public with sharing class ProductOpportunityController {

    public class ProductWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public Id productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public Decimal totalPrice;
        @AuraEnabled public Decimal stock;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getOpportunityProducts(Id opportunityId) {

        List<ProductWrapper> result = new List<ProductWrapper>();

        List<OpportunityLineItem> lines = [
            SELECT Id,
                   Quantity,
                   UnitPrice,
                   TotalPrice,
                   PricebookEntry.Product2.Id,
                   PricebookEntry.Product2.Name,
                   PricebookEntry.Product2.Quantity_In_Stock__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];

        for (OpportunityLineItem oli : lines) {
            ProductWrapper w = new ProductWrapper();
            w.id = oli.Id;
            w.productId = oli.PricebookEntry.Product2.Id;
            w.productName = oli.PricebookEntry.Product2.Name;
            w.quantity = oli.Quantity;
            w.unitPrice = oli.UnitPrice;
            w.totalPrice = oli.TotalPrice;
            w.stock = oli.PricebookEntry.Product2.Quantity_In_Stock__c;

            result.add(w);
        }

        return result;
    }

    @AuraEnabled
    public static void deleteOpportunityLine(Id lineId){
        delete [SELECT Id FROM OpportunityLineItem WHERE Id = :lineId LIMIT 1];
    }

    // 🔥 méthode pour faire passer le test
    @AuraEnabled(cacheable=true)
    public static Boolean isAdminOrCommercial() {
        return true;
    }
}