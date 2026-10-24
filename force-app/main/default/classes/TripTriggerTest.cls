// Tests du trigger TripTrigger : il doit refuser un voyage dont la date de fin est avant la date de debut.
@IsTest
private class TripTriggerTest {

    // TEST : creation d un voyage dont la fin est avant le debut.
    // On s attend a une erreur : le trigger doit bloquer l enregistrement.
    @IsTest
    static void testInsertTripWithInvalidDates() {
        Trip__c trip = new Trip__c(
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(5),
            Status__c = 'A venir'
        );

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        Boolean errorCaught = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            insert trip;
        } catch (DmlException e) {
            errorCaught = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            errorCaught,
            'Le trigger doit empêcher la création d’un voyage dont la date de fin précède la date de début.'
        );
    }

    // TEST : on modifie un voyage existant pour que la fin soit avant le debut.
    // On s attend a une erreur : le trigger doit bloquer la modification.
    @IsTest
    static void testUpdateTripWithInvalidDates() {
        Trip__c trip = new Trip__c(
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10),
            Status__c = 'A venir'
        );
        insert trip;

        trip.End_Date__c = Date.today().addDays(3);

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        Boolean errorCaught = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            update trip;
        } catch (DmlException e) {
            errorCaught = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(
            errorCaught,
            'Le trigger doit empêcher la mise à jour si la date de fin précède la date de début.'
        );
    }

    // TEST : creation d un voyage avec des dates correctes.
    // Le voyage doit etre enregistre (il a un Id).
    @IsTest
    static void testInsertTripWithValidDates() {
        Trip__c trip = new Trip__c(
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10),
            Status__c = 'A venir'
        );

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();
        insert trip;
        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(
            null,
            trip.Id,
            'Un voyage avec des dates valides doit être créé.'
        );
    }
        // TEST : creation d un voyage qui commence demain avec 7 participants.
    // On s attend a une erreur : le trigger doit bloquer la creation (moins de 10 participants).
    @IsTest
    static void testInsertTripBlockedWhenCloseAndLessThan10() {
        Trip__c trip = TestDataFactory.createTrip('Paris', 7, 1, 9);

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        Boolean errorCaught = false;

        // try/catch : on attrape l erreur attendue pour verifier qu elle est bien levee.
        try {
            insert trip;
        } catch (DmlException e) {
            errorCaught = true;
        }

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assert(errorCaught, 'Le voyage doit etre refuse.');
    }

    // TEST : creation d un voyage avec 7 participants mais qui commence dans 30 jours.
    // Le voyage doit etre enregistre : il reste du temps pour atteindre 10 participants.
    @IsTest
    static void testInsertTripAllowedWhenFarAndLessThan10() {
        Trip__c trip = TestDataFactory.createTrip('Paris', 7, 30, 35);

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        insert trip;

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(null, trip.Id, 'Le voyage doit etre enregistre.');
    }

    // TEST : creation d un voyage qui commence demain avec 10 participants.
    // Le voyage doit etre enregistre : 10 participants suffisent.
    @IsTest
    static void testInsertTripAllowedWhenCloseAnd10Participants() {
        Trip__c trip = TestDataFactory.createTrip('Rome', 10, 1, 9);

        // startTest : ici commence la partie du test qui execute le code a tester.
        Test.startTest();

        insert trip;

        Test.stopTest();

        // assert : le test echoue si le resultat obtenu n est pas celui attendu.
        System.assertNotEquals(null, trip.Id, 'Le voyage doit etre enregistre.');
    }


}