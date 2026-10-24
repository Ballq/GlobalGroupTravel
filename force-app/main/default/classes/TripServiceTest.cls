// Tests de la classe TripService (methode validateDates).
@IsTest
private class TripServiceTest {

// TEST : dates correctes (debut avant fin).
// validateDates ne doit pas bloquer le voyage, les dates restent inchangees.
@IsTest
static void testValidDates() {

    Trip__c trip = TestDataFactory.createValidDateTrip();

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    TripService.validateDates(new List<Trip__c>{ trip });

    Test.stopTest();

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(
        Date.today().addDays(10),
        trip.Start_Date__c
    );

    System.assertEquals(
        Date.today().addDays(15),
        trip.End_Date__c
    );
}

// TEST : dates incorrectes (fin avant debut).
// validateDates est appelee avec un voyage invalide ; les dates restent celles du voyage.
@IsTest
static void testInvalidDates() {

    Trip__c trip = TestDataFactory.createInvalidDateTrip();

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    TripService.validateDates(new List<Trip__c>{ trip });

    Test.stopTest();

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(
        Date.today().addDays(15),
        trip.Start_Date__c
    );

    System.assertEquals(
        Date.today().addDays(10),
        trip.End_Date__c
    );
}
// TEST : voyage qui commence dans 3 jours avec 7 participants.
// On verifie que le voyage recoit une erreur (moins de 10 participants et depart dans moins de 7 jours).
@IsTest
static void testMinimumParticipantsBlocked() {

    Trip__c trip = TestDataFactory.createTrip('Paris', 7, 3, 10);

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    TripService.validateMinimumParticipants(new List<Trip__c>{ trip });

    Test.stopTest();

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(true, trip.hasErrors(), 'Le voyage doit etre refuse.');
}

// TEST : voyage qui commence dans 30 jours avec 7 participants, puis voyage proche avec 10 participants.
// On verifie qu aucun des deux n a d erreur.
@IsTest
static void testMinimumParticipantsAllowed() {

    Trip__c farTrip = TestDataFactory.createTrip('Paris', 7, 30, 35);
    Trip__c fullTrip = TestDataFactory.createTrip('Rome', 10, 3, 8);

    // startTest : ici commence la partie du test qui execute le code a tester.
    Test.startTest();

    TripService.validateMinimumParticipants(new List<Trip__c>{ farTrip, fullTrip });

    Test.stopTest();

    // assert : le test echoue si le resultat obtenu n est pas celui attendu.
    System.assertEquals(false, farTrip.hasErrors(), 'Un depart lointain est autorise.');
    System.assertEquals(false, fullTrip.hasErrors(), '10 participants suffisent.');
}

}
