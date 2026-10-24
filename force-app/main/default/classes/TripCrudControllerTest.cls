// Tests du controleur TripCrudController : creer, lire, modifier, supprimer un voyage, cas normaux et cas d erreur.
@IsTest
public class TripCrudControllerTest {

    // TEST : creation d un voyage valide.
    // On verifie qu il est bien enregistre avec les bonnes valeurs.
    @IsTest
    static void testCreateTrip() {

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        Trip__c trip = TripCrudController.createTrip(
            'Paris',
            Date.today().addDays(5),
            Date.today().addDays(10),
            20,
            5000,
            4000
        );

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(
            null,
            trip.Id,
            'Le voyage doit être créé.'
        );

        Trip__c createdTrip = [
            SELECT Id,
                   Status__c,
                   Destination__c,
                   Start_Date__c,
                   End_Date__c,
                   Number_of_Participants__c,
                   Total_Budget__c,
                   Total_Cost__c
            FROM Trip__c
            WHERE Id = :trip.Id
        ];

        System.assertEquals(
            'A venir',
            createdTrip.Status__c
        );

        System.assertEquals(
            'Paris',
            createdTrip.Destination__c
        );

        System.assertEquals(
            Date.today().addDays(5),
            createdTrip.Start_Date__c
        );

        System.assertEquals(
            Date.today().addDays(10),
            createdTrip.End_Date__c
        );

        System.assertEquals(
            20,
            createdTrip.Number_of_Participants__c
        );

        System.assertEquals(
            5000,
            createdTrip.Total_Budget__c
        );

        System.assertEquals(
            4000,
            createdTrip.Total_Cost__c
        );
    }

    // TEST : creation sans destination (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateTripWithEmptyDestination() {

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.createTrip(
                '',
                Date.today().addDays(5),
                Date.today().addDays(10),
                20,
                5000,
                4000
            );

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la destination est vide.'
        );
    }

    // TEST : creation sans date de debut (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateTripWithNullStartDate() {

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.createTrip(
                'Paris',
                null,
                Date.today().addDays(10),
                20,
                5000,
                4000
            );

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de début est null.'
        );
    }

    // TEST : creation sans date de fin (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateTripWithNullEndDate() {

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.createTrip(
                'Paris',
                Date.today().addDays(5),
                null,
                20,
                5000,
                4000
            );

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est null.'
        );
    }

    // TEST : creation avec des dates incoherentes (la fin n est pas apres le debut).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateTripWithInvalidDates() {

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.createTrip(
                'Paris',
                Date.today().addDays(10),
                Date.today().addDays(5),
                20,
                5000,
                4000
            );

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est avant la date de début.'
        );
    }

    // TEST : creation sans nombre de participants (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testCreateTripWithNullParticipants() {

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.createTrip(
                'Paris',
                Date.today().addDays(5),
                Date.today().addDays(10),
                null,
                5000,
                4000
            );

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque le nombre de participants est null.'
        );
    }

    // TEST : lecture de la liste des voyages.
    // On cree des donnees puis on verifie le contenu de la liste renvoyee.
    @IsTest
    static void testGetTrips() {

        Trip__c trip = TestDataFactory.createCrudTrip(
            'Paris'
        );

        insert trip;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        List<Trip__c> trips =
            TripCrudController.getTrips();

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            !trips.isEmpty(),
            'La liste des voyages ne doit pas être vide.'
        );

        Boolean foundTrip = false;

        for (Trip__c currentTrip : trips) {

            if (currentTrip.Id == trip.Id) {

                foundTrip = true;

                System.assertEquals(
                    'Paris',
                    currentTrip.Destination__c
                );
            }
        }

        System.assert(
            foundTrip,
            'Le voyage créé doit être présent dans la liste.'
        );
    }

    // TEST : modification d un voyage existant.
    // On verifie que les nouvelles valeurs sont bien enregistrees.
    @IsTest
    static void testUpdateTrip() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Destination__c = 'Lyon';
        trip.Number_of_Participants__c = 25;
        trip.Total_Budget__c = 7000;
        trip.Total_Cost__c = 6000;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        TripCrudController.updateTrip(trip);

        Test.stopTest();

        Trip__c updatedTrip = [
            SELECT Id,
                   Destination__c,
                   Number_of_Participants__c,
                   Total_Budget__c,
                   Total_Cost__c
            FROM Trip__c
            WHERE Id = :trip.Id
        ];

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            'Lyon',
            updatedTrip.Destination__c
        );

        System.assertEquals(
            25,
            updatedTrip.Number_of_Participants__c
        );

        System.assertEquals(
            7000,
            updatedTrip.Total_Budget__c
        );

        System.assertEquals(
            6000,
            updatedTrip.Total_Cost__c
        );
    }

    // TEST : modification avec un voyage null (objet vide).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateTripWithNullTrip() {

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.updateTrip(null);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque le voyage est null.'
        );
    }

    // TEST : modification sans destination (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateTripWithEmptyDestination() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Destination__c = '';

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la destination est vide.'
        );
    }

    // TEST : modification sans date de debut (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateTripWithNullStartDate() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Start_Date__c = null;

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de début est null.'
        );
    }

    // TEST : modification sans date de fin (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateTripWithNullEndDate() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.End_Date__c = null;

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est null.'
        );
    }

    // TEST : modification avec des dates incoherentes (la fin n est pas apres le debut).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateTripWithInvalidDates() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Start_Date__c =
            Date.today().addDays(10);

        trip.End_Date__c =
            Date.today().addDays(5);

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est avant la date de début.'
        );
    }

    // TEST : modification sans nombre de participants (valeur vide).
    // Le champ est obligatoire : on s attend a une erreur (AuraHandledException).
    @IsTest
    static void testUpdateTripWithNullParticipants() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Number_of_Participants__c = null;

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque le nombre de participants est null.'
        );
    }

    // TEST : suppression d un voyage existant.
    // On verifie qu il n existe plus apres.
    @IsTest
    static void testDeleteTrip() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        TripCrudController.deleteTrip(
            trip.Id
        );

        Test.stopTest();

        List<Trip__c> deletedTrips = [
            SELECT Id
            FROM Trip__c
            WHERE Id = :trip.Id
        ];

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertEquals(
            0,
            deletedTrips.size(),
            'Le voyage doit être supprimé.'
        );
    }

    // TEST : suppression sans identifiant (null).
    // On s attend a une erreur (AuraHandledException).
    @IsTest
    static void testDeleteTripWithNullId() {

        Boolean exceptionThrown = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {

            // startTest : ici commence la partie du test qui execute le code a tester.
            Test.startTest();

            TripCrudController.deleteTrip(null);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque l’identifiant est null.'
        );
    }
}