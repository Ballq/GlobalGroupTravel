@IsTest
private class OrderTriggerTest {

    @TestSetup
    static void setup() {

        Id standardPricebook = Test.getStandardPricebookId();

        Account particulier = new Account(
            Name = 'Client Particulier',
            Customer_Type__c = 'Particulier'
        );
        insert particulier;

        Product2 product = new Product2(
            Name = 'Produit Test',
            IsActive = true
        );
        insert product;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Transporteur__c transporter = new Transporteur__c(
            Name = 'Chronopost',
            Customer_Type__c = 'Les deux'
        );
        insert transporter;

        Tarif_de_livraison__c tarif = new Tarif_de_livraison__c(
            Country__c = 'France',
            Price__c = 10,
            Delivery_Delay__c = 2,
            Transporteur__c = transporter.Id
        );
        insert tarif;
    }

    @IsTest
    static void testCountryChangeAssignsTransporter() {

        Account acc = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );
        insert ord;

        ord.Delivery_Country__c = 'France';

        Test.startTest();

        update ord;

        Test.stopTest();

        Order updatedOrder = [
            SELECT Cheapest_Transporter__c,
                   Fastest_Transporter__c,
                   Selected_Transporter__c
            FROM Order
            WHERE Id = :ord.Id
        ];

        System.assertNotEquals(
            null,
            updatedOrder.Cheapest_Transporter__c
        );

        System.assertNotEquals(
            null,
            updatedOrder.Fastest_Transporter__c
        );

        System.assertNotEquals(
            null,
            updatedOrder.Selected_Transporter__c
        );
    }

    @IsTest
    static void testActivationWithInsufficientProducts() {

        Account acc = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );
        insert ord;

        ord.Status = 'Activated';

        Test.startTest();

        try {

            update ord;

            System.assert(
                false,
                'La commande aurait dû être bloquée car elle ne contient pas assez de produits.'
            );

        } catch (DmlException e) {

            System.assert(
                e.getMessage().contains(
                    'Une commande particulière doit contenir au minimum 3 produits.'
                )
            );

        }

        Test.stopTest();
    }

    @IsTest
    static void testActivationWithEnoughProducts() {

        Account acc = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        PricebookEntry pbe = [
            SELECT Id,
                   UnitPrice
            FROM PricebookEntry
            LIMIT 1
        ];

        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );
        insert ord;

        List<OrderItem> items = new List<OrderItem>();

        for (Integer i = 0; i < 3; i++) {

            items.add(
                new OrderItem(
                    OrderId = ord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                )
            );

        }

        insert items;

        ord.Status = 'Activated';

        Test.startTest();

        update ord;

        Test.stopTest();

        Order updatedOrder = [
            SELECT Status
            FROM Order
            WHERE Id = :ord.Id
        ];

        System.assertEquals(
            'Activated',
            updatedOrder.Status
        );
    }

}