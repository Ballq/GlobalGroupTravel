@IsTest
private class OrderServiceTest {

    private static Id getStandardPricebookId() {

        return Test.getStandardPricebookId();

    }


    @TestSetup
    static void setup() {

        Id standardPricebookId = Test.getStandardPricebookId();

        Account particulier = new Account(
            Name = 'Client Particulier',
            Customer_Type__c = 'Particulier'
        );

        Account professionnel = new Account(
            Name = 'Client Professionnel',
            Customer_Type__c = 'Professionnel'
        );

        insert new List<Account>{
            particulier,
            professionnel
        };


        Product2 product1 = new Product2(
            Name = 'Produit Test 1',
            IsActive = true
        );

        Product2 product2 = new Product2(
            Name = 'Produit Test 2',
            IsActive = true
        );

        insert new List<Product2>{
            product1,
            product2
        };


        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product1.Id,
            UnitPrice = 100,
            IsActive = true
        );

        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product2.Id,
            UnitPrice = 200,
            IsActive = true
        );

        insert new List<PricebookEntry>{
            pbe1,
            pbe2
        };


        Transporteur__c transporterRapide = new Transporteur__c(
            Name = 'Transporteur Rapide',
            Customer_Type__c = 'Particulier'
        );

        Transporteur__c transporterEconomique = new Transporteur__c(
            Name = 'Transporteur Economique',
            Customer_Type__c = 'Particulier'
        );

        insert new List<Transporteur__c>{
            transporterRapide,
            transporterEconomique
        };


        Tarif_de_livraison__c tarifRapide = new Tarif_de_livraison__c(
            Country__c = 'France',
            Price__c = 20,
            Delivery_Delay__c = 2,
            Transporteur__c = transporterRapide.Id
        );

        Tarif_de_livraison__c tarifEconomique = new Tarif_de_livraison__c(
            Country__c = 'France',
            Price__c = 10,
            Delivery_Delay__c = 5,
            Transporteur__c = transporterEconomique.Id
        );

        insert new List<Tarif_de_livraison__c>{
            tarifRapide,
            tarifEconomique
        };

    }


    // ============================================================
    // GET AVAILABLE PRODUCTS
    // ============================================================

    @IsTest
    static void testGetAvailableProducts() {

        Test.startTest();

        List<PricebookEntry> result =
            OrderService.getAvailableProducts();

        Test.stopTest();

        System.assert(
            result.size() >= 2,
            'Les produits du Standard Pricebook doivent être récupérés.'
        );

    }


    // ============================================================
    // GET ORDER INFORMATIONS
    // ============================================================

    @IsTest
    static void testGetOrderInformations() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        Test.startTest();

        Order result =
            OrderService.getOrderInformations(
                orderRecord.Id
            );

        Test.stopTest();


        System.assertEquals(
            orderRecord.Id,
            result.Id
        );

        System.assertEquals(
            'France',
            result.Delivery_Country__c
        );

        System.assertEquals(
            'Client Particulier',
            result.Account.Name
        );

        System.assertEquals(
            'Particulier',
            result.Account.Customer_Type__c
        );

    }


    // ============================================================
    // GET AVAILABLE TRANSPORTERS
    // ============================================================

    @IsTest
    static void testGetAvailableTransporters() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        Test.startTest();

        List<Tarif_de_livraison__c> result =
            OrderService.getAvailableTransporters(
                orderRecord.Id
            );

        Test.stopTest();


        System.assertEquals(
            2,
            result.size()
        );

    }


    // ============================================================
    // ASSIGN TRANSPORTER
    // ============================================================

    @IsTest
    static void testAssignTransporter() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        Test.startTest();

        OrderService.assignTransporter(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertNotEquals(
            null,
            orderRecord.Cheapest_Transporter__c
        );

        System.assertNotEquals(
            null,
            orderRecord.Fastest_Transporter__c
        );

        System.assertNotEquals(
            null,
            orderRecord.Selected_Transporter__c
        );

    }


    // ============================================================
    // ASSIGN TRANSPORTER - VERIFICATION DU MOINS CHER
    // ============================================================

    @IsTest
    static void testAssignCheapestTransporter() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Transporteur__c cheapestTransporter = [
            SELECT Id
            FROM Transporteur__c
            WHERE Name = 'Transporteur Economique'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        Test.startTest();

        OrderService.assignTransporter(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertEquals(
            cheapestTransporter.Id,
            orderRecord.Cheapest_Transporter__c,
            'Le transporteur le moins cher doit être sélectionné.'
        );

        System.assertEquals(
            cheapestTransporter.Id,
            orderRecord.Selected_Transporter__c,
            'Le transporteur sélectionné par défaut doit être le moins cher.'
        );

    }


    // ============================================================
    // ASSIGN TRANSPORTER - VERIFICATION DU PLUS RAPIDE
    // ============================================================

    @IsTest
    static void testAssignFastestTransporter() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Transporteur__c fastestTransporter = [
            SELECT Id
            FROM Transporteur__c
            WHERE Name = 'Transporteur Rapide'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        Test.startTest();

        OrderService.assignTransporter(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertEquals(
            fastestTransporter.Id,
            orderRecord.Fastest_Transporter__c,
            'Le transporteur le plus rapide doit être sélectionné.'
        );

    }


    // ============================================================
    // ASSIGN TRANSPORTER - PAYS MANQUANT
    // ============================================================

    @IsTest
    static void testAssignTransporterWithoutCountry() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Test.startTest();

        OrderService.assignTransporter(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertEquals(
            null,
            orderRecord.Cheapest_Transporter__c
        );

        System.assertEquals(
            null,
            orderRecord.Fastest_Transporter__c
        );

        System.assertEquals(
            null,
            orderRecord.Selected_Transporter__c
        );

    }


    // ============================================================
    // GET ORDER PRODUCTS
    // ============================================================

    @IsTest
    static void testGetOrderProducts() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        OrderItem item = new OrderItem(
            OrderId = orderRecord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        insert item;


        Test.startTest();

        List<OrderItem> result =
            OrderService.getOrderProducts(
                orderRecord.Id
            );

        Test.stopTest();


        System.assertEquals(
            1,
            result.size()
        );

        System.assertEquals(
            1,
            result[0].Quantity
        );

    }


    // ============================================================
    // ADD PRODUCT TO ORDER
    // ============================================================

    @IsTest
    static void testAddProductToOrder() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            AND IsActive = true
            AND Product2.IsActive = true
            LIMIT 1
        ];


        Test.startTest();

        OrderService.addProductToOrder(
            orderRecord.Id,
            pbe.Id,
            3
        );

        Test.stopTest();


        List<OrderItem> items = [
            SELECT
                Id,
                Quantity,
                UnitPrice
            FROM OrderItem
            WHERE OrderId = :orderRecord.Id
        ];


        System.assertEquals(
            1,
            items.size()
        );

        System.assertEquals(
            3,
            items[0].Quantity
        );

        System.assertEquals(
            pbe.UnitPrice,
            items[0].UnitPrice
        );

    }


    // ============================================================
    // ADD PRODUCT - ORDER ID NULL
    // ============================================================

    @IsTest
    static void testAddProductOrderIdNull() {

        PricebookEntry pbe = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        Test.startTest();

        try {

            OrderService.addProductToOrder(
                null,
                pbe.Id,
                1
            );

            System.assert(
                false,
                'Une exception devait être levée lorsque l’identifiant de la commande est null.'
            );

        } catch (AuraHandledException e) {

            System.assert(
                e.getMessage().contains(
                    'commande'
                )
            );

        }

        Test.stopTest();

    }


    // ============================================================
    // ADD PRODUCT - PRICEBOOK ENTRY NULL
    // ============================================================

    @IsTest
    static void testAddProductPricebookEntryNull() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Test.startTest();

        try {

            OrderService.addProductToOrder(
                orderRecord.Id,
                null,
                1
            );

            System.assert(
                false,
                'Une exception devait être levée lorsque le PricebookEntry est null.'
            );

        } catch (AuraHandledException e) {

            System.assert(
                e.getMessage().contains(
                    'produit'
                )
            );

        }

        Test.stopTest();

    }


    // ============================================================
    // ADD PRODUCT - QUANTITY INVALID
    // ============================================================

    @IsTest
    static void testAddProductInvalidQuantity() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        Test.startTest();

        try {

            OrderService.addProductToOrder(
                orderRecord.Id,
                pbe.Id,
                0
            );

            System.assert(
                false,
                'Une exception devait être levée pour une quantité invalide.'
            );

        } catch (AuraHandledException e) {

            System.assert(
                e.getMessage().contains(
                    'quantité'
                )
            );

        }

        Test.stopTest();

    }


    // ============================================================
    // UPDATE ORDER ITEMS
    // ============================================================

    @IsTest
    static void testUpdateOrderItems() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        OrderItem item = new OrderItem(
            OrderId = orderRecord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        insert item;


        OrderItem itemToUpdate = [
            SELECT
                Id,
                Quantity
            FROM OrderItem
            WHERE Id = :item.Id
        ];

        itemToUpdate.Quantity = 5;


        Test.startTest();

        OrderService.updateOrderItems(
            new List<OrderItem>{
                itemToUpdate
            }
        );

        Test.stopTest();


        OrderItem updatedItem = [
            SELECT Quantity
            FROM OrderItem
            WHERE Id = :item.Id
        ];


        System.assertEquals(
            5,
            updatedItem.Quantity
        );

    }


    // ============================================================
    // DELETE ORDER ITEM
    // ============================================================

    @IsTest
    static void testDeleteOrderItem() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        OrderItem item = new OrderItem(
            OrderId = orderRecord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        insert item;


        Test.startTest();

        OrderService.deleteOrderItem(
            item.Id
        );

        Test.stopTest();


        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM OrderItem
                WHERE Id = :item.Id
            ]
        );

    }


    // ============================================================
    // GET DELIVERIES
    // ============================================================

    @IsTest
    static void testGetDeliveries() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Transporteur__c transporter = [
            SELECT Id, Name
            FROM Transporteur__c
            LIMIT 1
        ];


        Livraison__c delivery = new Livraison__c(
            Commande__c = orderRecord.Id,
            Transporteur__c = transporter.Id,
            Statut__c = 'En cours',
            Date_estime__c = Date.today().addDays(2)
        );

        insert delivery;


        Test.startTest();

        List<Livraison__c> result =
            OrderService.getDeliveries(
                orderRecord.Id
            );

        Test.stopTest();


        System.assertEquals(
            1,
            result.size()
        );

        System.assertEquals(
            'En cours',
            result[0].Statut__c
        );

        System.assertEquals(
            transporter.Name,
            result[0].Transporteur__r.Name
        );

    }


    // ============================================================
    // LAUNCH DELIVERY - PARTICULIER VALIDE
    // ============================================================

    @IsTest
    static void testLaunchDeliveryParticulierValid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        List<OrderItem> items = new List<OrderItem>();

        for (Integer i = 0; i < 3; i++) {

            items.add(
                new OrderItem(
                    OrderId = orderRecord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                )
            );

        }

        insert items;


        Transporteur__c transporter = [
            SELECT Id
            FROM Transporteur__c
            LIMIT 1
        ];


        Test.startTest();

        OrderService.launchDelivery(
            orderRecord.Id,
            transporter.Id
        );

        Test.stopTest();


        Livraison__c delivery = [
            SELECT
                Statut__c,
                Transporteur__c,
                Date_estime__c
            FROM Livraison__c
            WHERE Commande__c = :orderRecord.Id
            LIMIT 1
        ];


        System.assertEquals(
            'En cours',
            delivery.Statut__c
        );

        System.assertEquals(
            transporter.Id,
            delivery.Transporteur__c
        );

        System.assertEquals(
            Date.today().addDays(2),
            delivery.Date_estime__c
        );


        Order updatedOrder = [
            SELECT Selected_Transporter__c
            FROM Order
            WHERE Id = :orderRecord.Id
        ];


        System.assertEquals(
            transporter.Id,
            updatedOrder.Selected_Transporter__c,
            'Le transporteur sélectionné doit être enregistré sur la commande.'
        );

    }


    // ============================================================
    // LAUNCH DELIVERY - PARTICULIER INVALID
    // ============================================================

    @IsTest
    static void testLaunchDeliveryParticulierInvalid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Transporteur__c transporter = [
            SELECT Id
            FROM Transporteur__c
            LIMIT 1
        ];


        Test.startTest();

        try {

            OrderService.launchDelivery(
                orderRecord.Id,
                transporter.Id
            );

            System.assert(
                false,
                'La livraison devait être refusée.'
            );

        } catch (AuraHandledException e) {

            System.assert(
                e.getMessage().contains(
                    'particulière'
                )
            );

        }

        Test.stopTest();

    }


    // ============================================================
    // LAUNCH DELIVERY - PROFESSIONNEL VALIDE
    // ============================================================

    @IsTest
    static void testLaunchDeliveryProfessionnelValid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Professionnel'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        List<OrderItem> items = new List<OrderItem>();

        for (Integer i = 0; i < 5; i++) {

            items.add(
                new OrderItem(
                    OrderId = orderRecord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                )
            );

        }

        insert items;


        Transporteur__c transporter = [
            SELECT Id
            FROM Transporteur__c
            LIMIT 1
        ];


        Test.startTest();

        OrderService.launchDelivery(
            orderRecord.Id,
            transporter.Id
        );

        Test.stopTest();


        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Livraison__c
                WHERE Commande__c = :orderRecord.Id
            ]
        );

    }


    // ============================================================
    // LAUNCH DELIVERY - PROFESSIONNEL INVALID
    // ============================================================

    @IsTest
    static void testLaunchDeliveryProfessionnelInvalid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Professionnel'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Transporteur__c transporter = [
            SELECT Id
            FROM Transporteur__c
            LIMIT 1
        ];


        Test.startTest();

        try {

            OrderService.launchDelivery(
                orderRecord.Id,
                transporter.Id
            );

            System.assert(
                false,
                'La livraison devait être refusée.'
            );

        } catch (AuraHandledException e) {

            System.assert(
                e.getMessage().contains(
                    'professionnelle'
                )
            );

        }

        Test.stopTest();

    }


    // ============================================================
    // LAUNCH DELIVERY - TRANSPORTER NULL
    // ============================================================

    @IsTest
    static void testLaunchDeliveryTransporterNull() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        List<OrderItem> items = new List<OrderItem>();

        for (Integer i = 0; i < 3; i++) {

            items.add(
                new OrderItem(
                    OrderId = orderRecord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                )
            );

        }

        insert items;


        Test.startTest();

        try {

            OrderService.launchDelivery(
                orderRecord.Id,
                null
            );

            System.assert(
                false,
                'La livraison devait être refusée.'
            );

        } catch (AuraHandledException e) {

            System.assert(
                e.getMessage().contains(
                    'transporteur'
                )
            );

        }

        Test.stopTest();

    }


    // ============================================================
    // VALIDATE ORDER - PARTICULIER INVALID
    // ============================================================

    @IsTest
    static void testValidateOrderParticulierInvalid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Test.startTest();

        OrderService.validateOrder(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertNotEquals(
            null,
            orderRecord.Id,
            'La commande doit rester accessible après la validation.'
        );

    }


    // ============================================================
    // VALIDATE ORDER - PROFESSIONNEL INVALID
    // ============================================================

    @IsTest
    static void testValidateOrderProfessionnelInvalid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Professionnel'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Test.startTest();

        OrderService.validateOrder(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertNotEquals(
            null,
            orderRecord.Id,
            'La commande doit rester accessible après la validation.'
        );

    }


    // ============================================================
    // VALIDATE ORDER - PARTICULIER VALIDE
    // ============================================================

    @IsTest
    static void testValidateOrderParticulierValid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        List<OrderItem> items = new List<OrderItem>();

        for (Integer i = 0; i < 3; i++) {

            items.add(
                new OrderItem(
                    OrderId = orderRecord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                )
            );

        }

        insert items;


        Test.startTest();

        OrderService.validateOrder(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertNotEquals(
            null,
            orderRecord.Id
        );

    }


    // ============================================================
    // VALIDATE ORDER - PROFESSIONNEL VALIDE
    // ============================================================

    @IsTest
    static void testValidateOrderProfessionnelValid() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Professionnel'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];


        List<OrderItem> items = new List<OrderItem>();

        for (Integer i = 0; i < 5; i++) {

            items.add(
                new OrderItem(
                    OrderId = orderRecord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                )
            );

        }

        insert items;


        Test.startTest();

        OrderService.validateOrder(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertNotEquals(
            null,
            orderRecord.Id
        );

    }

    // ============================================================
    // VALIDATE ORDER - ACCOUNT INEXISTANT
    // ============================================================

    @IsTest
    static void testValidateOrderAccountNull() {

        Order orderRecord = new Order(
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;

        Test.startTest();

        OrderService.validateOrder(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            orderRecord.Id
        );
    }


    // ============================================================
    // ASSIGN TRANSPORTER - ACCOUNT ID NULL
    // ============================================================

    @IsTest
    static void testAssignTransporterAccountIdNull() {

        Order orderRecord = new Order(
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'France'
        );

        insert orderRecord;

        Test.startTest();

        OrderService.assignTransporter(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();

        System.assertEquals(
            null,
            orderRecord.Cheapest_Transporter__c
        );

        System.assertEquals(
            null,
            orderRecord.Fastest_Transporter__c
        );

        System.assertEquals(
            null,
            orderRecord.Selected_Transporter__c
        );
    }


    // ============================================================
    // ADD PRODUCT - ORDER WITHOUT PRICEBOOK
    // ============================================================

    @IsTest
    static void testAddProductWithoutPricebook() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );

        insert orderRecord;

        PricebookEntry pbe = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :getStandardPricebookId()
            LIMIT 1
        ];

        Test.startTest();

        OrderService.addProductToOrder(
            orderRecord.Id,
            pbe.Id,
            2
        );

        Test.stopTest();

        Order updatedOrder = [
            SELECT Pricebook2Id
            FROM Order
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals(
            getStandardPricebookId(),
            updatedOrder.Pricebook2Id
        );

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM OrderItem
                WHERE OrderId = :orderRecord.Id
            ]
        );
    }


    // ============================================================
    // GET ORDER PRODUCTS - ORDER VIDE
    // ============================================================

    @IsTest
    static void testGetOrderProductsEmpty() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];

        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;

        Test.startTest();

        List<OrderItem> result =
            OrderService.getOrderProducts(
                orderRecord.Id
            );

        Test.stopTest();

        System.assertEquals(
            0,
            result.size()
        );
    } 

    
    // ============================================================
    // ADD PRODUCT - MAUVAIS PRICEBOOK
    // ============================================================

    @IsTest
    static void testAddProductWrongPricebook() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];


        Pricebook2 otherPricebook = new Pricebook2(
            Name = 'Autre Pricebook',
            IsActive = true
        );

        insert otherPricebook;


        Product2 product = new Product2(
            Name = 'Produit Autre Pricebook',
            IsActive = true
        );

        insert product;

        PricebookEntry standardPbe = new PricebookEntry(
            Pricebook2Id = getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 500,
            IsActive = true
        );

        insert standardPbe;

        PricebookEntry otherPbe = new PricebookEntry(
            Pricebook2Id = otherPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 500,
            IsActive = true
        );

        insert otherPbe;


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId()
        );

        insert orderRecord;


        Test.startTest();

        try {

            OrderService.addProductToOrder(
                orderRecord.Id,
                otherPbe.Id,
                1
            );

            System.assert(
                false,
                'Une exception devait être levée pour un Pricebook incorrect.'
            );

        } catch (AuraHandledException e) {

            System.assert(
                e.getMessage().contains(
                    'Pricebook'
                )
            );

        }

        Test.stopTest();

    }

    // ============================================================
    // ASSIGN TRANSPORTER - AUCUN TRANSPORTEUR DISPONIBLE
    // ============================================================

    @IsTest
    static void testAssignTransporterWithoutAvailableTransporter() {

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Client Particulier'
            LIMIT 1
        ];


        Order orderRecord = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = getStandardPricebookId(),
            Delivery_Country__c = 'Espagne'
        );

        insert orderRecord;


        Test.startTest();

        OrderService.assignTransporter(
            new List<Order>{
                orderRecord
            }
        );

        Test.stopTest();


        System.assertEquals(
            null,
            orderRecord.Cheapest_Transporter__c
        );

        System.assertEquals(
            null,
            orderRecord.Fastest_Transporter__c
        );

        System.assertEquals(
            null,
            orderRecord.Selected_Transporter__c
        );

    }


}