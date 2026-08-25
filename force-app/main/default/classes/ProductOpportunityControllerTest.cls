@IsTest
public class ProductOpportunityControllerTest {

    @IsTest
    static void testGetOpportunityProducts() {

        Id standardPbId = Test.getStandardPricebookId();

        Product2 p = new Product2(
            Name = 'Tesla Model S',
            IsActive = true,
            QuantityInStock__c = 50
        );
        insert p;

        insert new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = p.Id,
            UnitPrice = 99990,
            IsActive = true
        );

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;

        opp.Pricebook2Id = standardPbId;
        update opp;

        PricebookEntry pbe = [
            SELECT Id
            FROM PricebookEntry
            WHERE Product2Id = :p.Id
            LIMIT 1
        ];

        insert new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 2,
            UnitPrice = 99990,
            PricebookEntryId = pbe.Id
        );

        Test.startTest();
        List<ProductOpportunityController.ProductWrapper> result =
            ProductOpportunityController.getOpportunityProducts(opp.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Tesla Model S', result[0].productName);
    }

    @IsTest
    static void testIsAdminOrCommercial() {
        System.assertEquals(true,
            ProductOpportunityController.isAdminOrCommercial());
    }
}