import { LightningElement, wire } from 'lwc';
import getTrips from '@salesforce/apex/TripCrudController.getTrips';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
{
label: 'Nom',
fieldName: 'Name'
},
{
label: 'Destination',
fieldName: 'Destination__c'
},
{
label: 'Date de début',
fieldName: 'Start_Date__c',
type: 'date'
},
{
label: 'Date de fin',
fieldName: 'End_Date__c',
type: 'date'
},
{
label: 'Statut',
fieldName: 'Status__c'
},
{
label: 'Participants',
fieldName: 'Number_of_Participants__c',
type: 'number'
},
{
label: 'Budget',
fieldName: 'Total_Budget__c',
type: 'currency'
},
{
label: 'Coût total',
fieldName: 'Total_Cost__c',
type: 'currency'
}
];

export default class TripManager extends LightningElement {

columns = COLUMNS;
trips;
error;
wiredTripsResult;

@wire(getTrips)
wiredTrips(result) {

    this.wiredTripsResult = result;

    if (result.data) {
        this.trips = result.data;
        this.error = undefined;
    } else if (result.error) {
        this.error = result.error;
        this.trips = undefined;
    }
}

async handleRefresh() {

    await refreshApex(this.wiredTripsResult);
}


}
