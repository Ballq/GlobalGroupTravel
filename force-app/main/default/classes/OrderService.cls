public with sharing class OrderService {

    //VALIDATION COMMANDE
    

    public static void validateOrder(List<Order> orders) {

        for (Order currentOrder : orders) {

            Decimal totalProducts = getTotalProducts(currentOrder.Id);

            Account customer = AccountSelector.getAccountById(currentOrder.AccountId);

            if (customer == null) {
                continue;
            }

            if(customer.Customer_Type__c == 'Particulier' && totalProducts < 3){

                currentOrder.addError(
                    'Une commande particulière doit contenir au minimum 3 produits.'
                );

            }

            if(customer.Customer_Type__c == 'Professionnel' && totalProducts < 5){

                currentOrder.addError(
                    'Une commande professionnelle doit contenir au minimum 5 produits.'
                );

            }

        }

    }
   

    // SELECTION TRANSPORTEUR

    public static void assignTransporter(List<Order> orders) {

        Set<Id> accountIds = new Set<Id>();

        for (Order currentOrder : orders) {

            if (currentOrder.AccountId != null) {

                accountIds.add(currentOrder.AccountId);

            }

        }

        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id,
                   Customer_Type__c
            FROM Account
            WHERE Id IN :accountIds
        ]);

        for (Order currentOrder : orders) {

            if (
                currentOrder.Delivery_Country__c == null ||
                currentOrder.AccountId == null
            ) {

                continue;

            }

            Account account = accountsById.get(
                currentOrder.AccountId
            );

            if (account == null) {

                continue;

            }

            List<Tarif_de_livraison__c> transporters =
                TransporterSelector.getAvailableTransporters(
                    currentOrder.Delivery_Country__c,
                    account.Customer_Type__c
                );

            Tarif_de_livraison__c cheapestTransporter;
            Tarif_de_livraison__c fastestTransporter;

            for (
                Tarif_de_livraison__c transporter :
                transporters
            ) {

                if (
                    cheapestTransporter == null ||
                    transporter.Price__c <
                    cheapestTransporter.Price__c
                ) {

                    cheapestTransporter = transporter;

                }

                if (
                    fastestTransporter == null ||
                    transporter.Delivery_Delay__c <
                    fastestTransporter.Delivery_Delay__c
                ) {

                    fastestTransporter = transporter;

                }

            }

            if (cheapestTransporter != null) {

                currentOrder.Cheapest_Transporter__c =
                    cheapestTransporter.Transporteur__c;

                currentOrder.Selected_Transporter__c =
                    cheapestTransporter.Transporteur__c;

            }

            if (fastestTransporter != null) {

                currentOrder.Fastest_Transporter__c =
                    fastestTransporter.Transporteur__c;

            }

        }

    }


    // NOMBRE DE PRODUITS


    private static Decimal getTotalProducts(Id orderId){

        Decimal total = 0;

        for(OrderItem item : [

            SELECT Quantity

            FROM OrderItem

            WHERE OrderId = :orderId

        ]){

            total += item.Quantity;

        }

        return total;

    }


   

     // CREATION LIVRAISON

    @AuraEnabled
    public static void launchDelivery(
        Id orderId,
        Id transporterId
    ) {

        Order currentOrder = [
            SELECT
                Id,
                Status,
                AccountId,
                Account.Customer_Type__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        Decimal totalProducts = getTotalProducts(orderId);

        String customerType = currentOrder.Account.Customer_Type__c;

        // Vérification du nombre minimum de produits
        if (
            customerType == 'Particulier' &&
            totalProducts < 3
        ) {

            throw new AuraHandledException(
                'Une commande particulière doit contenir au minimum 3 produits avant de lancer la livraison.'
            );

        }

        if (
            customerType == 'Professionnel' &&
            totalProducts < 5
        ) {

            throw new AuraHandledException(
                'Une commande professionnelle doit contenir au minimum 5 produits avant de lancer la livraison.'
            );

        }

        // Vérifie qu'un transporteur a bien été sélectionné
        if (transporterId == null) {

            throw new AuraHandledException(
                'Veuillez sélectionner un transporteur avant de lancer la livraison.'
            );

        }

        // Création de la livraison
        Livraison__c delivery = new Livraison__c(
            Commande__c = orderId,
            Transporteur__c = transporterId,
            Statut__c = 'En cours',
            Date_estime__c = Date.today().addDays(2)
        );

        insert delivery;

        // Enregistre le transporteur choisi sur la commande
        update new Order(
            Id = orderId,
            Selected_Transporter__c = transporterId
        );

    }
    
    // RÉCUPÉRATION DES INFORMATIONS DE LA COMMANDE
    // INFORMATIONS DE LA COMMANDE

    @AuraEnabled(cacheable=true)
    public static Order getOrderInformations(Id orderId) {

        System.debug(
            'ORDER ID REÇU : ' + orderId
        );

        Order result = [
            SELECT
                Id,
                Delivery_Country__c,
                AccountId,
                Account.Name,
                Account.Customer_Type__c,
                Cheapest_Transporter__c,
                Cheapest_Transporter__r.Name,
                Fastest_Transporter__c,
                Fastest_Transporter__r.Name,
                Selected_Transporter__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        System.debug(
            'ORDER RÉCUPÉRÉ : ' + result
        );

        System.debug(
            'PAYS : ' + result.Delivery_Country__c
        );

        System.debug(
            'COMPTE : ' + result.Account.Name
        );

        System.debug(
            'TYPE CLIENT : ' + result.Account.Customer_Type__c
        );

        return result;

    }


    // TRANSPORTEURS DISPONIBLES

    @AuraEnabled(cacheable=true)
    public static List<Tarif_de_livraison__c> getAvailableTransporters(
        Id orderId
    ) {

        Order ord = [

            SELECT
                Delivery_Country__c,
                Account.Customer_Type__c

            FROM Order

            WHERE Id = :orderId

            LIMIT 1

        ];

        return TransporterSelector.getAvailableTransporters(

            ord.Delivery_Country__c,

            ord.Account.Customer_Type__c

        );

    }


    // HISTORIQUE LIVRAISONS

    @AuraEnabled(cacheable=true)
    public static List<Livraison__c> getDeliveries(Id orderId) {

        return [

            SELECT
                Id,
                Name,
                Statut__c,
                Date_estime__c,
                Transporteur__c,
                Transporteur__r.Name

            FROM Livraison__c

            WHERE Commande__c = :orderId

            ORDER BY CreatedDate DESC

        ];

    }

    // PRODUITS COMMANDE
    

    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(Id orderId){

        return [

            SELECT

                Id,

                Quantity,

                UnitPrice,

                Product2.Name

            FROM OrderItem

            WHERE OrderId=:orderId

        ];

    }

    // PRODUITS DISPONIBLES
   

    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(){

        Id standardPricebook = Test.isRunningTest()

            ? Test.getStandardPricebookId()

            : [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1].Id;

        return [

            SELECT

                Id,

                UnitPrice,

                Product2.Name

            FROM PricebookEntry

            WHERE Pricebook2Id=:standardPricebook

            AND IsActive=true

            AND Product2.IsActive=true

            ORDER BY Product2.Name

        ];

    }

    // AJOUT PRODUIT

    @AuraEnabled
    public static void addProductToOrder(
        Id orderId,
        Id pricebookEntryId,
        Decimal quantity
    ) {

        if (orderId == null) {
            throw new AuraHandledException(
                'L’identifiant de la commande est manquant.'
            );
        }

        if (pricebookEntryId == null) {
            throw new AuraHandledException(
                'L’identifiant du produit est manquant.'
            );
        }

        if (quantity == null || quantity <= 0) {
            throw new AuraHandledException(
                'La quantité doit être supérieure à zéro.'
            );
        }

        Order currentOrder = [
            SELECT Id, Pricebook2Id
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        // Récupère le Standard Pricebook
        Id standardPricebookId = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true
            LIMIT 1
        ].Id;

        // Si la commande n'a pas de Pricebook,
        // on lui associe automatiquement le Standard Pricebook
        if (currentOrder.Pricebook2Id == null) {

            currentOrder.Pricebook2Id = standardPricebookId;

            update currentOrder;

        }

        PricebookEntry pbe = [
            SELECT Id,
                   UnitPrice,
                   Pricebook2Id,
                   Product2.Name
            FROM PricebookEntry
            WHERE Id = :pricebookEntryId
            AND IsActive = true
            LIMIT 1
        ];

        // Vérifie que le produit appartient bien au Pricebook de la commande
        if (pbe.Pricebook2Id != currentOrder.Pricebook2Id) {

            throw new AuraHandledException(
                'Le produit sélectionné n’appartient pas au Pricebook de cette commande.'
            );

        }

        OrderItem newItem = new OrderItem(
            OrderId = currentOrder.Id,
            PricebookEntryId = pbe.Id,
            Quantity = quantity,
            UnitPrice = pbe.UnitPrice
        );

        insert newItem;
    }

    //MODIFICATION QUANTITE
    

    @AuraEnabled
    public static void updateOrderItems(List<OrderItem> items){

        update items;

    }

        // SUPPRESSION PRODUIT DE LA COMMANDE

    @AuraEnabled
    public static void deleteOrderItem(Id orderItemId) {

        OrderItem item = [
            SELECT Id
            FROM OrderItem
            WHERE Id = :orderItemId
            LIMIT 1
        ];

        delete item;
    }

}