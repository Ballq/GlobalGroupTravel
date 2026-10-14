@IsTest
public class TripCrudControllerTest {

    // ============================================================
    // CREATE
    // ============================================================

    @IsTest
    static void testCreateTrip() {

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


    @IsTest
    static void testCreateTripWithEmptyDestination() {

        Boolean exceptionThrown = false;

        try {

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

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la destination est vide.'
        );
    }


    @IsTest
    static void testCreateTripWithNullStartDate() {

        Boolean exceptionThrown = false;

        try {

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

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de début est null.'
        );
    }


    @IsTest
    static void testCreateTripWithNullEndDate() {

        Boolean exceptionThrown = false;

        try {

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

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est null.'
        );
    }


    @IsTest
    static void testCreateTripWithInvalidDates() {

        Boolean exceptionThrown = false;

        try {

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

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est avant la date de début.'
        );
    }


    @IsTest
    static void testCreateTripWithNullParticipants() {

        Boolean exceptionThrown = false;

        try {

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

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque le nombre de participants est null.'
        );
    }


    // ============================================================
    // GET
    // ============================================================

    @IsTest
    static void testGetTrips() {

        Trip__c trip = TestDataFactory.createCrudTrip(
            'Paris'
        );

        insert trip;

        Test.startTest();

        List<Trip__c> trips =
            TripCrudController.getTrips();

        Test.stopTest();

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


    // ============================================================
    // UPDATE
    // ============================================================

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


    @IsTest
    static void testUpdateTripWithNullTrip() {

        Boolean exceptionThrown = false;

        try {

            Test.startTest();

            TripCrudController.updateTrip(null);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque le voyage est null.'
        );
    }


    @IsTest
    static void testUpdateTripWithEmptyDestination() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Destination__c = '';

        Boolean exceptionThrown = false;

        try {

            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la destination est vide.'
        );
    }


    @IsTest
    static void testUpdateTripWithNullStartDate() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Start_Date__c = null;

        Boolean exceptionThrown = false;

        try {

            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de début est null.'
        );
    }


    @IsTest
    static void testUpdateTripWithNullEndDate() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.End_Date__c = null;

        Boolean exceptionThrown = false;

        try {

            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est null.'
        );
    }


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

        try {

            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque la date de fin est avant la date de début.'
        );
    }


    @IsTest
    static void testUpdateTripWithNullParticipants() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

        trip.Number_of_Participants__c = null;

        Boolean exceptionThrown = false;

        try {

            Test.startTest();

            TripCrudController.updateTrip(trip);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque le nombre de participants est null.'
        );
    }


    // ============================================================
    // DELETE
    // ============================================================

    @IsTest
    static void testDeleteTrip() {

        Trip__c trip =
            TestDataFactory.createCrudTrip(
                'Paris'
            );

        insert trip;

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

        System.assertEquals(
            0,
            deletedTrips.size(),
            'Le voyage doit être supprimé.'
        );
    }


    @IsTest
    static void testDeleteTripWithNullId() {

        Boolean exceptionThrown = false;

        try {

            Test.startTest();

            TripCrudController.deleteTrip(null);

            Test.stopTest();

        } catch (AuraHandledException e) {

            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'Une exception devait être levée lorsque l’identifiant est null.'
        );
    }
}