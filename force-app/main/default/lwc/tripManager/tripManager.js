import { LightningElement, track } from 'lwc';

// =========================
// TRIPS
// =========================
import getTrips from '@salesforce/apex/TripCrudController.getTrips';
import createTrip from '@salesforce/apex/TripCrudController.createTrip';
import updateTrip from '@salesforce/apex/TripCrudController.updateTrip';
import deleteTrip from '@salesforce/apex/TripCrudController.deleteTrip';

// =========================
// ACCOUNTS
// =========================
import getAccounts from '@salesforce/apex/AccountCrudController.getAccounts';
import createAccount from '@salesforce/apex/AccountCrudController.createAccount';
import updateAccount from '@salesforce/apex/AccountCrudController.updateAccount';
import deleteAccount from '@salesforce/apex/AccountCrudController.deleteAccount';

// =========================
// OPPORTUNITIES
// =========================
import getOpportunities from '@salesforce/apex/OpportunityCrudController.getOpportunities';
import createOpportunity from '@salesforce/apex/OpportunityCrudController.createOpportunity';
import updateOpportunity from '@salesforce/apex/OpportunityCrudController.updateOpportunity';
import deleteOpportunity from '@salesforce/apex/OpportunityCrudController.deleteOpportunity';

// =========================
// CONTRACTS
// =========================
import getContracts from '@salesforce/apex/ContractCrudController.getContracts';
import createContract from '@salesforce/apex/ContractCrudController.createContract';
import updateContract from '@salesforce/apex/ContractCrudController.updateContract';
import deleteContract from '@salesforce/apex/ContractCrudController.deleteContract';


export default class TripManager extends LightningElement {

    // ============================================================
    // GENERAL
    // ============================================================

    @track trips = [];
    @track accounts = [];
    @track opportunities = [];
    @track contracts = [];

    @track error = '';
    @track errorMessage = '';

    // ============================================================
    // TRIP STATE
    // ============================================================

    @track isEditMode = false;

    @track editingTripId = null;

    @track destination = '';
    @track startDate = null;
    @track endDate = null;
    @track participants = null;
    @track budget = null;
    @track cost = null;

    // ============================================================
    // ACCOUNT STATE
    // ============================================================

    @track isAccountEditMode = false;

    @track editingAccountId = null;

    @track accountName = '';
    @track accountPhone = '';
    @track accountWebsite = '';
    @track accountIndustry = '';

    // ============================================================
    // OPPORTUNITY STATE
    // ============================================================

    @track isOpportunityEditMode = false;

    @track editingOpportunityId = null;

    @track opportunityName = '';
    @track opportunityAccountId = null;
    @track opportunityStage = '';
    @track opportunityCloseDate = null;
    @track opportunityAmount = null;
    @track opportunityDestination = '';
    @track opportunityStartDate = null;
    @track opportunityEndDate = null;
    @track opportunityParticipants = null;

    // ============================================================
    // CONTRACT STATE
    // ============================================================

    @track isContractEditMode = false;

    @track editingContractId = null;

    @track contractAccountId = null;
    @track contractStartDate = null;
    @track contractTerm = null;
    @track contractStatus = '';
    @track contractDescription = '';

    // ============================================================
    // OPPORTUNITY OPTIONS
    // ============================================================

    opportunityStageOptions = [
        {
            label: 'Prospecting',
            value: 'Prospecting'
        },
        {
            label: 'Qualification',
            value: 'Qualification'
        },
        {
            label: 'Needs Analysis',
            value: 'Needs Analysis'
        },
        {
            label: 'Value Proposition',
            value: 'Value Proposition'
        },
        {
            label: 'Id. Decision Makers',
            value: 'Id. Decision Makers'
        },
        {
            label: 'Perception Analysis',
            value: 'Perception Analysis'
        },
        {
            label: 'Proposal/Price Quote',
            value: 'Proposal/Price Quote'
        },
        {
            label: 'Negotiation/Review',
            value: 'Negotiation/Review'
        },
        {
            label: 'Closed Won',
            value: 'Closed Won'
        },
        {
            label: 'Closed Lost',
            value: 'Closed Lost'
        }
    ];

    // ============================================================
    // CONTRACT STATUS OPTIONS
    // ============================================================

    contractStatusOptions = [
        {
            label: 'Draft',
            value: 'Draft'
        },
        {
            label: 'Activated',
            value: 'Activated'
        },
        {
            label: 'Expired',
            value: 'Expired'
        }
    ];

    // ============================================================
    // LIFECYCLE
    // ============================================================

    connectedCallback() {
        this.loadAllData();
    }

    // ============================================================
    // LOAD ALL DATA
    // ============================================================

    async loadAllData() {
        this.clearError();

        try {
            await Promise.all([
                this.loadTrips(),
                this.loadAccounts(),
                this.loadOpportunities(),
                this.loadContracts()
            ]);
        } catch (error) {
            this.setError(error);
        }
    }

    // ============================================================
    // ERROR MANAGEMENT
    // ============================================================

    clearError() {
        this.error = '';
        this.errorMessage = '';
    }

    setError(error) {
        const message = this.getErrorMessage(error);

        this.error = message;
        this.errorMessage = message;

        console.error('Erreur Salesforce :', error);
        console.error('Message extrait :', message);
    }

    getErrorMessage(error) {

        if (!error) {
            return 'Une erreur inconnue est survenue.';
        }

        // --------------------------------------------
        // Cas classique AuraHandledException
        // --------------------------------------------

        if (
            error.body &&
            typeof error.body.message === 'string' &&
            error.body.message.trim() !== ''
        ) {
            return error.body.message;
        }

        // --------------------------------------------
        // Tableau d'erreurs
        // --------------------------------------------

        if (
            error.body &&
            Array.isArray(error.body) &&
            error.body.length > 0
        ) {
            const messages = error.body
                .map(item => item.message)
                .filter(message => message);

            if (messages.length > 0) {
                return messages.join(' | ');
            }
        }

        // --------------------------------------------
        // Erreurs Apex / UI API
        // --------------------------------------------

        if (
            error.body &&
            error.body.output &&
            Array.isArray(error.body.output.errors) &&
            error.body.output.errors.length > 0
        ) {
            const messages = error.body.output.errors
                .map(item => item.message)
                .filter(message => message);

            if (messages.length > 0) {
                return messages.join(' | ');
            }
        }

        // --------------------------------------------
        // Page Errors
        // --------------------------------------------

        if (
            error.body &&
            error.body.output &&
            Array.isArray(error.body.output.pageErrors) &&
            error.body.output.pageErrors.length > 0
        ) {
            const messages = error.body.output.pageErrors
                .map(item => item.message)
                .filter(message => message);

            if (messages.length > 0) {
                return messages.join(' | ');
            }
        }

        // --------------------------------------------
        // Field Errors
        // --------------------------------------------

        if (
            error.body &&
            error.body.output &&
            error.body.output.fieldErrors
        ) {
            const fieldErrors = error.body.output.fieldErrors;

            const messages = [];

            Object.keys(fieldErrors).forEach(fieldName => {

                const fieldErrorList = fieldErrors[fieldName];

                if (Array.isArray(fieldErrorList)) {

                    fieldErrorList.forEach(fieldError => {

                        if (fieldError && fieldError.message) {
                            messages.push(
                                `${fieldName} : ${fieldError.message}`
                            );
                        }

                    });
                }

            });

            if (messages.length > 0) {
                return messages.join(' | ');
            }
        }

        // --------------------------------------------
        // Error.message
        // --------------------------------------------

        if (
            typeof error.message === 'string' &&
            error.message.trim() !== ''
        ) {
            return error.message;
        }

        // --------------------------------------------
        // Tentative JSON
        // --------------------------------------------

        try {

            const json = JSON.stringify(error);

            if (
                json &&
                json !== '{}' &&
                json !== 'null'
            ) {
                return json;
            }

        } catch (jsonError) {
            console.error(
                'Impossible de convertir l’erreur en JSON.',
                jsonError
            );
        }

        return 'Une erreur est survenue.';
    }

    // ============================================================
    // TRIPS - LOAD
    // ============================================================

    async loadTrips() {

        try {

            this.trips = await getTrips();

        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // ============================================================
    // TRIPS - INPUTS
    // ============================================================

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

        const value = event.target.value;

        if (value === '') {
            this.participants = null;
            return;
        }

        this.participants = Number(value);
    }

    handleBudgetChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.budget = null;
            return;
        }

        this.budget = Number(value);
    }

    handleCostChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.cost = null;
            return;
        }

        this.cost = Number(value);
    }

    // ============================================================
    // TRIPS - CREATE
    // ============================================================

    async handleCreate() {

        this.clearError();

        try {

            await createTrip({
                destination: this.destination,
                startDate: this.startDate,
                endDate: this.endDate,
                numberOfParticipants: this.participants,
                totalBudget: this.budget,
                totalCost: this.cost
            });

            this.resetTripForm();

            await this.loadTrips();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // TRIPS - SELECT
    // ============================================================

    handleSelectTrip(event) {

        const tripId = event.currentTarget.dataset.id;

        const trip = this.trips.find(
            item => item.Id === tripId
        );

        if (!trip) {
            return;
        }

        this.isEditMode = true;

        this.editingTripId = trip.Id;

        this.destination = trip.Destination__c || '';
        this.startDate = trip.Start_Date__c || null;
        this.endDate = trip.End_Date__c || null;

        this.participants =
            trip.Number_of_Participants__c == null
                ? null
                : Number(trip.Number_of_Participants__c);

        this.budget =
            trip.Total_Budget__c == null
                ? null
                : Number(trip.Total_Budget__c);

        this.cost =
            trip.Total_Cost__c == null
                ? null
                : Number(trip.Total_Cost__c);
    }

    // ============================================================
    // TRIPS - UPDATE
    // ============================================================

    async handleUpdate() {

        this.clearError();

        try {

            await updateTrip({
                trip: {
                    Id: this.editingTripId,
                    Destination__c: this.destination,
                    Start_Date__c: this.startDate,
                    End_Date__c: this.endDate,
                    Number_of_Participants__c: this.participants,
                    Total_Budget__c: this.budget,
                    Total_Cost__c: this.cost
                }
            });

            this.resetTripForm();

            await this.loadTrips();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // TRIPS - DELETE
    // ============================================================

    async handleDelete(event) {

        this.clearError();

        const tripId = event.currentTarget.dataset.id;

        if (!tripId) {
            return;
        }

        try {

            await deleteTrip({
                tripId: tripId
            });

            await this.loadTrips();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // TRIPS - CANCEL EDIT
    // ============================================================

    handleCancelEdit() {
        this.resetTripForm();
    }

    resetTripForm() {

        this.isEditMode = false;

        this.editingTripId = null;

        this.destination = '';
        this.startDate = null;
        this.endDate = null;
        this.participants = null;
        this.budget = null;
        this.cost = null;
    }

    // ============================================================
    // TRIPS - REFRESH
    // ============================================================

    async handleRefresh() {

        this.clearError();

        try {

            await this.loadAllData();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // ACCOUNTS - LOAD
    // ============================================================

    async loadAccounts() {

        try {

            this.accounts = await getAccounts();

        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // ============================================================
    // ACCOUNTS - INPUTS
    // ============================================================

    handleAccountNameChange(event) {
        this.accountName = event.target.value;
    }

    handleAccountPhoneChange(event) {
        this.accountPhone = event.target.value;
    }

    handleAccountWebsiteChange(event) {
        this.accountWebsite = event.target.value;
    }

    handleAccountIndustryChange(event) {
        this.accountIndustry = event.target.value;
    }

    // ============================================================
    // ACCOUNTS - CREATE
    // ============================================================

    async handleAccountCreate() {

        this.clearError();

        try {

            await createAccount({
                name: this.accountName,
                phone: this.accountPhone,
                website: this.accountWebsite,
                industry: this.accountIndustry
            });

            this.resetAccountForm();

            await this.loadAccounts();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // ACCOUNTS - SELECT
    // ============================================================

    handleSelectAccount(event) {

        const accountId = event.currentTarget.dataset.id;

        const account = this.accounts.find(
            item => item.Id === accountId
        );

        if (!account) {
            return;
        }

        this.isAccountEditMode = true;

        this.editingAccountId = account.Id;

        this.accountName = account.Name || '';
        this.accountPhone = account.Phone || '';
        this.accountWebsite = account.Website || '';
        this.accountIndustry = account.Industry || '';
    }

    // ============================================================
    // ACCOUNTS - UPDATE
    // ============================================================

    async handleAccountUpdate() {

        this.clearError();

        try {

            await updateAccount({
                account: {
                    Id: this.editingAccountId,
                    Name: this.accountName,
                    Phone: this.accountPhone,
                    Website: this.accountWebsite,
                    Industry: this.accountIndustry
                }
            });

            this.resetAccountForm();

            await this.loadAccounts();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // ACCOUNTS - DELETE
    // ============================================================

    async handleAccountDelete(event) {

        this.clearError();

        const accountId = event.currentTarget.dataset.id;

        if (!accountId) {
            return;
        }

        try {

            await deleteAccount({
                accountId: accountId
            });

            await this.loadAccounts();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // ACCOUNTS - CANCEL
    // ============================================================

    handleCancelAccountEdit() {
        this.resetAccountForm();
    }

    resetAccountForm() {

        this.isAccountEditMode = false;

        this.editingAccountId = null;

        this.accountName = '';
        this.accountPhone = '';
        this.accountWebsite = '';
        this.accountIndustry = '';
    }

    // ============================================================
    // OPPORTUNITIES - LOAD
    // ============================================================

    async loadOpportunities() {

        try {

            this.opportunities = await getOpportunities();

        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // ============================================================
    // OPPORTUNITIES - INPUTS
    // ============================================================

    handleOpportunityNameChange(event) {
        this.opportunityName = event.target.value;
    }

    handleOpportunityAccountChange(event) {
        this.opportunityAccountId = event.detail.value;
    }

    handleOpportunityStageChange(event) {
        this.opportunityStage = event.detail.value;
    }

    handleOpportunityCloseDateChange(event) {
        this.opportunityCloseDate = event.target.value;
    }

    handleOpportunityAmountChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.opportunityAmount = null;
            return;
        }

        this.opportunityAmount = Number(value);
    }

    handleOpportunityDestinationChange(event) {
        this.opportunityDestination = event.target.value;
    }

    handleOpportunityStartDateChange(event) {
        this.opportunityStartDate = event.target.value;
    }

    handleOpportunityEndDateChange(event) {
        this.opportunityEndDate = event.target.value;
    }

    handleOpportunityParticipantsChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.opportunityParticipants = null;
            return;
        }

        this.opportunityParticipants = Number(value);
    }

    // ============================================================
    // OPPORTUNITIES - CREATE
    // ============================================================

    async handleOpportunityCreate() {

        this.clearError();

        try {

            await createOpportunity({
                name: this.opportunityName,
                accountId: this.opportunityAccountId,
                stageName: this.opportunityStage,
                closeDate: this.opportunityCloseDate,
                amount: this.opportunityAmount,
                destination: this.opportunityDestination,
                startDate: this.opportunityStartDate,
                endDate: this.opportunityEndDate,
                numberOfParticipants: this.opportunityParticipants
            });

            this.resetOpportunityForm();

            await this.loadOpportunities();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // OPPORTUNITIES - SELECT
    // ============================================================

    handleSelectOpportunity(event) {

        const opportunityId =
            event.currentTarget.dataset.id;

        const opportunity = this.opportunities.find(
            item => item.Id === opportunityId
        );

        if (!opportunity) {
            return;
        }

        this.isOpportunityEditMode = true;

        this.editingOpportunityId = opportunity.Id;

        this.opportunityName =
            opportunity.Name || '';

        this.opportunityAccountId =
            opportunity.AccountId || null;

        this.opportunityStage =
            opportunity.StageName || '';

        this.opportunityCloseDate =
            opportunity.CloseDate || null;

        this.opportunityAmount =
            opportunity.Amount == null
                ? null
                : Number(opportunity.Amount);

        this.opportunityDestination =
            opportunity.Destination__c || '';

        this.opportunityStartDate =
            opportunity.Start_Date__c || null;

        this.opportunityEndDate =
            opportunity.End_Date__c || null;

        this.opportunityParticipants =
            opportunity.Number_of_Participants__c == null
                ? null
                : Number(
                    opportunity.Number_of_Participants__c
                );
    }

    // ============================================================
    // OPPORTUNITIES - UPDATE
    // ============================================================

    async handleOpportunityUpdate() {

        this.clearError();

        try {

            await updateOpportunity({
                opportunity: {
                    Id: this.editingOpportunityId,
                    Name: this.opportunityName,
                    AccountId: this.opportunityAccountId,
                    StageName: this.opportunityStage,
                    CloseDate: this.opportunityCloseDate,
                    Amount: this.opportunityAmount,
                    Destination__c: this.opportunityDestination,
                    Start_Date__c: this.opportunityStartDate,
                    End_Date__c: this.opportunityEndDate,
                    Number_of_Participants__c:
                        this.opportunityParticipants
                }
            });

            this.resetOpportunityForm();

            await this.loadOpportunities();

            await this.loadTrips();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // OPPORTUNITIES - DELETE
    // ============================================================

    async handleOpportunityDelete(event) {

        this.clearError();

        const opportunityId =
            event.currentTarget.dataset.id;

        if (!opportunityId) {
            return;
        }

        try {

            await deleteOpportunity({
                opportunityId: opportunityId
            });

            await this.loadOpportunities();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // OPPORTUNITIES - CANCEL
    // ============================================================

    handleCancelOpportunityEdit() {
        this.resetOpportunityForm();
    }

    resetOpportunityForm() {

        this.isOpportunityEditMode = false;

        this.editingOpportunityId = null;

        this.opportunityName = '';
        this.opportunityAccountId = null;
        this.opportunityStage = '';
        this.opportunityCloseDate = null;
        this.opportunityAmount = null;
        this.opportunityDestination = '';
        this.opportunityStartDate = null;
        this.opportunityEndDate = null;
        this.opportunityParticipants = null;
    }

    // ============================================================
    // CONTRACTS - LOAD
    // ============================================================

    async loadContracts() {

        try {

            this.contracts = await getContracts();

        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // ============================================================
    // CONTRACTS - INPUTS
    // ============================================================

    handleContractAccountChange(event) {
        this.contractAccountId = event.detail.value;
    }

    handleContractStartDateChange(event) {
        this.contractStartDate = event.target.value;
    }

    handleContractTermChange(event) {

        const value = event.target.value;

        if (value === '') {

            this.contractTerm = null;

            return;
        }

        this.contractTerm = parseInt(
            value,
            10
        );
    }

    handleContractStatusChange(event) {
        this.contractStatus = event.detail.value;
    }

    handleContractDescriptionChange(event) {
        this.contractDescription = event.target.value;
    }

    // ============================================================
    // CONTRACTS - CREATE
    // ============================================================

    async handleContractCreate() {

        this.clearError();

        try {

            const contractTermInteger =
                this.contractTerm == null
                    ? null
                    : parseInt(
                        this.contractTerm,
                        10
                    );

            await createContract({
                accountId: this.contractAccountId,
                startDate: this.contractStartDate,
                contractTerm: contractTermInteger,
                status: this.contractStatus,
                description: this.contractDescription
            });

            this.resetContractForm();

            await this.loadContracts();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // CONTRACTS - SELECT
    // ============================================================

    handleSelectContract(event) {

        const contractId =
            event.currentTarget.dataset.id;

        const contractRecord =
            this.contracts.find(
                item => item.Id === contractId
            );

        if (!contractRecord) {
            return;
        }

        this.isContractEditMode = true;

        this.editingContractId =
            contractRecord.Id;

        this.contractAccountId =
            contractRecord.AccountId || null;

        this.contractStartDate =
            contractRecord.StartDate || null;

        this.contractTerm =
            contractRecord.ContractTerm == null
                ? null
                : parseInt(
                    contractRecord.ContractTerm,
                    10
                );

        this.contractStatus =
            contractRecord.Status || '';

        this.contractDescription =
            contractRecord.Description || '';
    }

    // ============================================================
    // CONTRACTS - UPDATE
    // ============================================================

    async handleContractUpdate() {

        this.clearError();

        try {

            const contractTermInteger =
                this.contractTerm == null
                    ? null
                    : parseInt(
                        this.contractTerm,
                        10
                    );

            await updateContract({
                contractId: this.editingContractId,
                accountId: this.contractAccountId,
                startDate: this.contractStartDate,
                contractTerm: contractTermInteger,
                status: this.contractStatus,
                description: this.contractDescription
            });

            this.resetContractForm();

            await this.loadContracts();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // CONTRACTS - DELETE
    // ============================================================

    async handleContractDelete(event) {

        this.clearError();

        const contractId =
            event.currentTarget.dataset.id;

        if (!contractId) {
            return;
        }

        try {

            await deleteContract({
                contractId: contractId
            });

            await this.loadContracts();

        } catch (error) {

            this.setError(error);

        }
    }

    // ============================================================
    // CONTRACTS - CANCEL
    // ============================================================

    handleCancelContractEdit() {
        this.resetContractForm();
    }

    resetContractForm() {

        this.isContractEditMode = false;

        this.editingContractId = null;

        this.contractAccountId = null;
        this.contractStartDate = null;
        this.contractTerm = null;
        this.contractStatus = '';
        this.contractDescription = '';
    }
}