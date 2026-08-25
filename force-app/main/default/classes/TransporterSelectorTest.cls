@IsTest
private class TransporterSelectorTest {

    @IsTest
    static void testGetAvailableTransporters() {

        // Création du transporteur pour un client particulier
        Transporteur__c transporter = new Transporteur__c(
            Name = 'Chronopost',
            Customer_Type__c = 'Particulier'
        );
        insert transporter;

        // Création du tarif de livraison
        Tarif_de_livraison__c tarif = new Tarif_de_livraison__c(
            Country__c = 'France',
            Price__c = 15,
            Delivery_Delay__c = 2,
            Transporteur__c = transporter.Id
        );
        insert tarif;

        Test.startTest();

        List<Tarif_de_livraison__c> result =
            TransporterSelector.getAvailableTransporters(
                'France',
                'Particulier'
            );

        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('France', result[0].Country__c);
        System.assertEquals(15, result[0].Price__c);
        System.assertEquals(2, result[0].Delivery_Delay__c);
        System.assertEquals(transporter.Id, result[0].Transporteur__c);
        System.assertEquals(
            'Particulier',
            result[0].Transporteur__r.Customer_Type__c
        );

    }


    @IsTest
    static void testGetAvailableTransportersEmpty() {

        Test.startTest();

        List<Tarif_de_livraison__c> result =
            TransporterSelector.getAvailableTransporters(
                'Espagne',
                'Particulier'
            );

        Test.stopTest();

        System.assertEquals(0, result.size());

    }


    @IsTest
    static void testGetAvailableTransportersWrongCustomerType() {

        // Transporteur réservé aux particuliers
        Transporteur__c transporter = new Transporteur__c(
            Name = 'Chronopost Particulier',
            Customer_Type__c = 'Particulier'
        );
        insert transporter;

        // Tarif disponible en France
        Tarif_de_livraison__c tarif = new Tarif_de_livraison__c(
            Country__c = 'France',
            Price__c = 15,
            Delivery_Delay__c = 2,
            Transporteur__c = transporter.Id
        );
        insert tarif;

        Test.startTest();

        // Recherche pour un client professionnel
        List<Tarif_de_livraison__c> result =
            TransporterSelector.getAvailableTransporters(
                'France',
                'Professionnel'
            );

        Test.stopTest();

        // Le transporteur particulier ne doit pas être proposé
        System.assertEquals(0, result.size());

    }

}