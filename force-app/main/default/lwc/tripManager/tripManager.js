import { LightningElement, wire } from 'lwc';

import getTrips from '@salesforce/apex/TripCrudController.getTrips';
import createTrip from '@salesforce/apex/TripCrudController.createTrip';
import updateTrip from '@salesforce/apex/TripCrudController.updateTrip';
import deleteTrip from '@salesforce/apex/TripCrudController.deleteTrip';

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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

destination = '';
startDate;
endDate;
participants;
budget;
cost;

selectedTripId;
isEditMode = false;

@wire(getTrips)
wiredTrips(result) {

    this.wiredTripsResult = result;

    if (result.data) {
        this.trips = result.data;
        this.error = undefined;
    } else if (result.error) {
        this.handleError(result.error);
        this.trips = undefined;
    }
}

handleDestinationChange(event) {
    this.destination = event.target.value;
}

handleStartDateChange(event) {
    this.startDate = event.target.value;
}

handleEndDateChange(event) {
    this.endDate = event.target.value;
}

handleParticipantsChange(event) {
    this.participants = event.target.value;
}

handleBudgetChange(event) {
    this.budget = event.target.value;
}

handleCostChange(event) {
    this.cost = event.target.value;
}

validateForm() {

    const errors = [];

    if (!this.destination || this.destination.trim() === '') {
        errors.push(
            'La destination est obligatoire.'
        );
    }

    if (!this.startDate) {
        errors.push(
            'La date de début est obligatoire.'
        );
    }

    if (!this.endDate) {
        errors.push(
            'La date de fin est obligatoire.'
        );
    }

    if (this.startDate && this.endDate) {

        if (this.endDate < this.startDate) {
            errors.push(
                'La date de fin doit être postérieure ou égale à la date de début.'
            );
        }
    }

    if (
        this.participants === undefined ||
        this.participants === null ||
        this.participants === '' ||
        Number(this.participants) <= 0
    ) {
        errors.push(
            'Le nombre de participants doit être supérieur à 0.'
        );
    }

    if (
        this.budget !== undefined &&
        this.budget !== null &&
        this.budget !== '' &&
        this.cost !== undefined &&
        this.cost !== null &&
        this.cost !== ''
    ) {

        if (Number(this.budget) < Number(this.cost)) {
            errors.push(
                'Le budget total doit être supérieur ou égal au coût total.'
            );
        }
    }

    if (errors.length > 0) {

        this.showToast(
            'Données invalides',
            errors.join(' '),
            'error'
        );

        return false;
    }

    return true;
}

async handleCreate() {

    if (!this.validateForm()) {
        return;
    }

    try {

        await createTrip({
            destination: this.destination,
            startDate: this.startDate,
            endDate: this.endDate,
            numberOfParticipants: this.participants,
            totalBudget: this.budget,
            totalCost: this.cost
        });

        this.showToast(
            'Succès',
            'Le voyage a été créé.',
            'success'
        );

        this.resetForm();

        await refreshApex(this.wiredTripsResult);

    } catch (error) {

        this.handleError(error);
    }
}

handleSelectTrip(event) {

    const tripId = event.target.dataset.id;

    const trip = this.trips.find(
        currentTrip => currentTrip.Id === tripId
    );

    if (!trip) {
        return;
    }

    this.selectedTripId = trip.Id;

    this.destination = trip.Destination__c;
    this.startDate = trip.Start_Date__c;
    this.endDate = trip.End_Date__c;
    this.participants = trip.Number_of_Participants__c;
    this.budget = trip.Total_Budget__c;
    this.cost = trip.Total_Cost__c;

    this.isEditMode = true;
}

async handleUpdate() {

    if (!this.validateForm()) {
        return;
    }

    try {

        const trip = {
            Id: this.selectedTripId,
            Destination__c: this.destination,
            Start_Date__c: this.startDate,
            End_Date__c: this.endDate,
            Number_of_Participants__c: this.participants,
            Total_Budget__c: this.budget,
            Total_Cost__c: this.cost
        };

        await updateTrip({
            trip: trip
        });

        this.showToast(
            'Succès',
            'Le voyage a été modifié.',
            'success'
        );

        this.resetForm();

        await refreshApex(this.wiredTripsResult);

    } catch (error) {

        this.handleError(error);
    }
}

async handleDelete(event) {

    const tripId = event.target.dataset.id;

    try {

        await deleteTrip({
            tripId: tripId
        });

        this.showToast(
            'Succès',
            'Le voyage a été supprimé.',
            'success'
        );

        if (this.selectedTripId === tripId) {
            this.resetForm();
        }

        await refreshApex(this.wiredTripsResult);

    } catch (error) {

        this.handleError(error);
    }
}

async handleRefresh() {

    await refreshApex(this.wiredTripsResult);
}

handleCancelEdit() {

    this.resetForm();
}

resetForm() {

    this.destination = '';
    this.startDate = undefined;
    this.endDate = undefined;
    this.participants = undefined;
    this.budget = undefined;
    this.cost = undefined;

    this.selectedTripId = undefined;
    this.isEditMode = false;
}

handleError(error) {

    let message = 'Une erreur est survenue.';

    if (error?.body?.message) {
        message = error.body.message;
    } else if (error?.message) {
        message = error.message;
    }

    this.error = message;

    this.showToast(
        'Erreur',
        message,
        'error'
    );
}

showToast(title, message, variant) {

    this.dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        })
    );
}

}
