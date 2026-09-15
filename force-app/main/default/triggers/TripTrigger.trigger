trigger TripTrigger on Trip__c (before insert, before update) {

TripService.validateDates(Trigger.new);

}
