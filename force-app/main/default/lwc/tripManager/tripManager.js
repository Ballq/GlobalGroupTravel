// On importe LightningElement (la base d un composant LWC) et track (l ecran se met a jour quand ces variables changent).
import { LightningElement, track } from 'lwc';

// Imports des methodes Apex des voyages : lire, creer, modifier, supprimer.
import getTrips from '@salesforce/apex/TripCrudController.getTrips';
import createTrip from '@salesforce/apex/TripCrudController.createTrip';
import updateTrip from '@salesforce/apex/TripCrudController.updateTrip';
import deleteTrip from '@salesforce/apex/TripCrudController.deleteTrip';

// Imports des methodes Apex des comptes.
import getAccounts from '@salesforce/apex/AccountCrudController.getAccounts';
import createAccount from '@salesforce/apex/AccountCrudController.createAccount';
import updateAccount from '@salesforce/apex/AccountCrudController.updateAccount';
import deleteAccount from '@salesforce/apex/AccountCrudController.deleteAccount';

// Imports des methodes Apex des opportunites.
import getOpportunities from '@salesforce/apex/OpportunityCrudController.getOpportunities';
import createOpportunity from '@salesforce/apex/OpportunityCrudController.createOpportunity';
import updateOpportunity from '@salesforce/apex/OpportunityCrudController.updateOpportunity';
import deleteOpportunity from '@salesforce/apex/OpportunityCrudController.deleteOpportunity';

// Imports des methodes Apex des contrats.
import getContracts from '@salesforce/apex/ContractCrudController.getContracts';
import createContract from '@salesforce/apex/ContractCrudController.createContract';
import updateContract from '@salesforce/apex/ContractCrudController.updateContract';
import deleteContract from '@salesforce/apex/ContractCrudController.deleteContract';

// Composant principal : il affiche et gere les voyages, comptes, opportunites et contrats (formulaires + listes).
export default class TripManager extends LightningElement {

    // Listes affichees a l ecran (elles viennent de Salesforce).
    @track trips = [];
    @track accounts = [];
    @track opportunities = [];
    @track contracts = [];

    // Messages d erreur affiches en haut de l ecran.
    @track error = '';
    @track errorMessage = '';

    // --- Voyages --- isEditMode = true quand on modifie un voyage existant.
    @track isEditMode = false;

    // Id du voyage en cours de modification.
    @track editingTripId = null;

    // Valeurs saisies dans le formulaire des voyages.
    @track destination = '';
    @track startDate = null;
    @track endDate = null;
    @track participants = null;
    @track budget = null;
    @track cost = null;

    // --- Comptes --- mode modification, Id du compte modifie et valeurs du formulaire.
    @track isAccountEditMode = false;

    @track editingAccountId = null;

    @track accountName = '';
    @track accountPhone = '';
    @track accountWebsite = '';
    @track accountIndustry = '';

    // --- Opportunites --- mode modification, Id de l opportunite modifiee et valeurs du formulaire.
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

    // --- Contrats --- mode modification, Id du contrat modifie et valeurs du formulaire.
    @track isContractEditMode = false;

    @track editingContractId = null;

    @track contractAccountId = null;
    @track contractStartDate = null;
    @track contractTerm = null;
    @track contractStatus = '';
    @track contractDescription = '';

    // Choix de la liste deroulante Etape d une opportunite.
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

    // Choix de la liste deroulante Statut d un contrat.
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

    // METHODE connectedCallback : se lance automatiquement quand le composant s affiche a l ecran.
    // Role : charger toutes les donnees (voyages, comptes, opportunites, contrats).
    connectedCallback() {
        this.loadAllData();
    }

    // METHODE loadAllData : recharge les 4 listes en meme temps (Promise.all = on attend que tout soit fini).
    // Elle est utilisee au demarrage et par le bouton Actualiser.
    async loadAllData() {
        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {
            await Promise.all([
                this.loadTrips(),
                this.loadAccounts(),
                this.loadOpportunities(),
                this.loadContracts()
            ]);
        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {
            this.setError(error);
        }
    }

    // METHODE clearError : efface le message d erreur affiche a l ecran.
    clearError() {
        this.error = '';
        this.errorMessage = '';
    }

    // METHODE setError : affiche une erreur a l ecran.
    // Role : on extrait un message lisible avec getErrorMessage et on l affiche (et on l ecrit aussi dans la console du navigateur).
    setError(error) {
        const message = this.getErrorMessage(error);

        this.error = message;
        this.errorMessage = message;

        console.error('Erreur Salesforce :', error);
        console.error('Message extrait :', message);
    }

    // METHODE getErrorMessage : transforme une erreur Salesforce en texte simple.
    // Salesforce peut renvoyer l erreur sous plusieurs formes (body.message, liste, pageErrors, fieldErrors...).
    // On teste chaque forme l une apres l autre et on renvoie le premier message trouve.
    getErrorMessage(error) {

        if (!error) {
            return 'Une erreur inconnue est survenue.';
        }

        if (
            error.body &&
            typeof error.body.message === 'string' &&
            error.body.message.trim() !== ''
        ) {
            return error.body.message;
        }

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

        if (
            typeof error.message === 'string' &&
            error.message.trim() !== ''
        ) {
            return error.message;
        }

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

    // METHODE loadTrips : demande a Salesforce (Apex) la liste des voyages et la garde dans la variable de la classe.
    // Si Apex renvoie une erreur, on l affiche puis on la relance (throw) pour que l appelant le sache.
    async loadTrips() {

        try {

            // On recupere la liste depuis Salesforce (appel Apex).
            this.trips = await getTrips();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // METHODE handleDestinationChange : appelee quand l utilisateur change la destination dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleDestinationChange(event) {
        this.destination = event.target.value;
    }

    // METHODE handleStartDateChange : appelee quand l utilisateur change la date de debut dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    // METHODE handleEndDateChange : appelee quand l utilisateur change la date de fin dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    // METHODE handleParticipantsChange : appelee quand l utilisateur change le nombre de participants dans le formulaire.
    // Pour un nombre : champ vide = null, sinon on convertit le texte avec Number().
    handleParticipantsChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.participants = null;
            return;
        }

        this.participants = Number(value);
    }

    // METHODE handleBudgetChange : appelee quand l utilisateur change le budget dans le formulaire.
    // Pour un nombre : champ vide = null, sinon on convertit le texte avec Number().
    handleBudgetChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.budget = null;
            return;
        }

        this.budget = Number(value);
    }

    // METHODE handleCostChange : appelee quand l utilisateur change le cout dans le formulaire.
    // Pour un nombre : champ vide = null, sinon on convertit le texte avec Number().
    handleCostChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.cost = null;
            return;
        }

        this.cost = Number(value);
    }

    // METHODE handleCreate : appelee quand on clique sur le bouton pour creer un voyage.
    // Role : envoyer les valeurs du formulaire a Apex, vider le formulaire, puis recharger la liste.
    async handleCreate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
            await createTrip({
                destination: this.destination,
                startDate: this.startDate,
                endDate: this.endDate,
                numberOfParticipants: this.participants,
                totalBudget: this.budget,
                totalCost: this.cost
            });

            // On vide le formulaire.
            this.resetTripForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadTrips();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleSelectTrip : appelee quand on clique sur Modifier pour un voyage de la liste.
    // Role : retrouver le voyage grace a son Id, passer en mode modification et remplir le formulaire avec ses valeurs.
    handleSelectTrip(event) {

        // On lit l Id de la ligne cliquee (il est stocke dans data-id dans le HTML).
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

    // METHODE handleUpdate : appelee quand on enregistre la modification d un voyage.
    // Role : envoyer les nouvelles valeurs a Apex, quitter le mode modification, puis recharger la liste.
    async handleUpdate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
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

            // On vide le formulaire.
            this.resetTripForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadTrips();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleDelete : appelee quand on clique sur Supprimer pour un voyage.
    // Role : lire l Id de la ligne, demander a Apex de supprimer, puis recharger la liste.
    async handleDelete(event) {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        // On lit l Id de la ligne cliquee (il est stocke dans data-id dans le HTML).
        const tripId = event.currentTarget.dataset.id;

        if (!tripId) {
            return;
        }

        try {

            // Appel a la methode Apex qui supprime l enregistrement dans Salesforce.
            await deleteTrip({
                tripId: tripId
            });

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadTrips();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleCancelEdit : appelee quand on clique sur Annuler pendant une modification.
    // Role : quitter le mode modification et vider le formulaire.
    handleCancelEdit() {
        // On vide le formulaire.
        this.resetTripForm();
    }

    // METHODE resetTripForm : remet le formulaire du voyage a zero (mode creation, champs vides).
    resetTripForm() {

        this.isEditMode = false;

        // On oublie l Id de l enregistrement qui etait modifie.
        this.editingTripId = null;

        this.destination = '';
        this.startDate = null;
        this.endDate = null;
        this.participants = null;
        this.budget = null;
        this.cost = null;
    }

    // METHODE handleRefresh : appelee quand on clique sur le bouton Actualiser.
    // Role : recharger toutes les donnees depuis Salesforce.
    async handleRefresh() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadAllData();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE loadAccounts : demande a Salesforce (Apex) la liste des comptes et la garde dans la variable de la classe.
    // Si Apex renvoie une erreur, on l affiche puis on la relance (throw) pour que l appelant le sache.
    async loadAccounts() {

        try {

            // On recupere la liste depuis Salesforce (appel Apex).
            this.accounts = await getAccounts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // METHODE handleAccountNameChange : appelee quand l utilisateur change le nom du compte dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleAccountNameChange(event) {
        this.accountName = event.target.value;
    }

    // METHODE handleAccountPhoneChange : appelee quand l utilisateur change le telephone du compte dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleAccountPhoneChange(event) {
        this.accountPhone = event.target.value;
    }

    // METHODE handleAccountWebsiteChange : appelee quand l utilisateur change le site web du compte dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleAccountWebsiteChange(event) {
        this.accountWebsite = event.target.value;
    }

    // METHODE handleAccountIndustryChange : appelee quand l utilisateur change le secteur du compte dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleAccountIndustryChange(event) {
        this.accountIndustry = event.target.value;
    }

    // METHODE handleAccountCreate : appelee quand on clique sur le bouton pour creer un compte.
    // Role : envoyer les valeurs du formulaire a Apex, vider le formulaire, puis recharger la liste.
    async handleAccountCreate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
            await createAccount({
                name: this.accountName,
                phone: this.accountPhone,
                website: this.accountWebsite,
                industry: this.accountIndustry
            });

            // On vide le formulaire.
            this.resetAccountForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadAccounts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleSelectAccount : appelee quand on clique sur Modifier pour un compte de la liste.
    // Role : retrouver le compte grace a son Id, passer en mode modification et remplir le formulaire avec ses valeurs.
    handleSelectAccount(event) {

        // On lit l Id de la ligne cliquee (il est stocke dans data-id dans le HTML).
        const accountId = event.currentTarget.dataset.id;

        const account = this.accounts.find(
            item => item.Id === accountId
        );

        if (!account) {
            return;
        }

        // On passe en mode modification.
        this.isAccountEditMode = true;

        this.editingAccountId = account.Id;

        this.accountName = account.Name || '';
        this.accountPhone = account.Phone || '';
        this.accountWebsite = account.Website || '';
        this.accountIndustry = account.Industry || '';
    }

    // METHODE handleAccountUpdate : appelee quand on enregistre la modification d un compte.
    // Role : envoyer les nouvelles valeurs a Apex, quitter le mode modification, puis recharger la liste.
    async handleAccountUpdate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
            await updateAccount({
                account: {
                    Id: this.editingAccountId,
                    Name: this.accountName,
                    Phone: this.accountPhone,
                    Website: this.accountWebsite,
                    Industry: this.accountIndustry
                }
            });

            // On vide le formulaire.
            this.resetAccountForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadAccounts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleAccountDelete : appelee quand on clique sur Supprimer pour un compte.
    // Role : lire l Id de la ligne, demander a Apex de supprimer, puis recharger la liste.
    async handleAccountDelete(event) {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        // On lit l Id de la ligne cliquee (il est stocke dans data-id dans le HTML).
        const accountId = event.currentTarget.dataset.id;

        if (!accountId) {
            return;
        }

        try {

            // Appel a la methode Apex qui supprime l enregistrement dans Salesforce.
            await deleteAccount({
                accountId: accountId
            });

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadAccounts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleCancelAccountEdit : appelee quand on clique sur Annuler pendant une modification.
    // Role : quitter le mode modification et vider le formulaire.
    handleCancelAccountEdit() {
        // On vide le formulaire.
        this.resetAccountForm();
    }

    // METHODE resetAccountForm : remet le formulaire du compte a zero (mode creation, champs vides).
    resetAccountForm() {

        // On quitte le mode modification.
        this.isAccountEditMode = false;

        // On oublie l Id de l enregistrement qui etait modifie.
        this.editingAccountId = null;

        this.accountName = '';
        this.accountPhone = '';
        this.accountWebsite = '';
        this.accountIndustry = '';
    }

    // METHODE loadOpportunities : demande a Salesforce (Apex) la liste des opportunites et la garde dans la variable de la classe.
    // Si Apex renvoie une erreur, on l affiche puis on la relance (throw) pour que l appelant le sache.
    async loadOpportunities() {

        try {

            // On recupere la liste depuis Salesforce (appel Apex).
            this.opportunities = await getOpportunities();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // METHODE handleOpportunityNameChange : appelee quand l utilisateur change le nom de l opportunite dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleOpportunityNameChange(event) {
        this.opportunityName = event.target.value;
    }

    // METHODE handleOpportunityAccountChange : appelee quand l utilisateur change le compte de l opportunite dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleOpportunityAccountChange(event) {
        this.opportunityAccountId = event.detail.value;
    }

    // METHODE handleOpportunityStageChange : appelee quand l utilisateur change l etape de l opportunite dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleOpportunityStageChange(event) {
        this.opportunityStage = event.detail.value;
    }

    // METHODE handleOpportunityCloseDateChange : appelee quand l utilisateur change la date de cloture dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleOpportunityCloseDateChange(event) {
        this.opportunityCloseDate = event.target.value;
    }

    // METHODE handleOpportunityAmountChange : appelee quand l utilisateur change le montant dans le formulaire.
    // Pour un nombre : champ vide = null, sinon on convertit le texte avec Number().
    handleOpportunityAmountChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.opportunityAmount = null;
            return;
        }

        this.opportunityAmount = Number(value);
    }

    // METHODE handleOpportunityDestinationChange : appelee quand l utilisateur change la destination dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleOpportunityDestinationChange(event) {
        this.opportunityDestination = event.target.value;
    }

    // METHODE handleOpportunityStartDateChange : appelee quand l utilisateur change la date de debut du voyage dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleOpportunityStartDateChange(event) {
        this.opportunityStartDate = event.target.value;
    }

    // METHODE handleOpportunityEndDateChange : appelee quand l utilisateur change la date de fin du voyage dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleOpportunityEndDateChange(event) {
        this.opportunityEndDate = event.target.value;
    }

    // METHODE handleOpportunityParticipantsChange : appelee quand l utilisateur change le nombre de participants dans le formulaire.
    // Pour un nombre : champ vide = null, sinon on convertit le texte avec Number().
    handleOpportunityParticipantsChange(event) {

        const value = event.target.value;

        if (value === '') {
            this.opportunityParticipants = null;
            return;
        }

        this.opportunityParticipants = Number(value);
    }

    // METHODE handleOpportunityCreate : appelee quand on clique sur le bouton pour creer un opportunite.
    // Role : envoyer les valeurs du formulaire a Apex, vider le formulaire, puis recharger la liste.
    async handleOpportunityCreate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
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

            // On vide le formulaire.
            this.resetOpportunityForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadOpportunities();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleSelectOpportunity : appelee quand on clique sur Modifier pour un opportunite de la liste.
    // Role : retrouver le opportunite grace a son Id, passer en mode modification et remplir le formulaire avec ses valeurs.
    handleSelectOpportunity(event) {

        const opportunityId =
            event.currentTarget.dataset.id;

        const opportunity = this.opportunities.find(
            item => item.Id === opportunityId
        );

        if (!opportunity) {
            return;
        }

        // On passe en mode modification.
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

    // METHODE handleOpportunityUpdate : appelee quand on enregistre la modification d un opportunite.
    // Role : envoyer les nouvelles valeurs a Apex, quitter le mode modification, puis recharger la liste.
    async handleOpportunityUpdate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
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

            // On vide le formulaire.
            this.resetOpportunityForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadOpportunities();

            await this.loadTrips();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleOpportunityDelete : appelee quand on clique sur Supprimer pour un opportunite.
    // Role : lire l Id de la ligne, demander a Apex de supprimer, puis recharger la liste.
    async handleOpportunityDelete(event) {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        const opportunityId =
            event.currentTarget.dataset.id;

        if (!opportunityId) {
            return;
        }

        try {

            // Appel a la methode Apex qui supprime l enregistrement dans Salesforce.
            await deleteOpportunity({
                opportunityId: opportunityId
            });

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadOpportunities();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleCancelOpportunityEdit : appelee quand on clique sur Annuler pendant une modification.
    // Role : quitter le mode modification et vider le formulaire.
    handleCancelOpportunityEdit() {
        // On vide le formulaire.
        this.resetOpportunityForm();
    }

    // METHODE resetOpportunityForm : remet le formulaire du opportunite a zero (mode creation, champs vides).
    resetOpportunityForm() {

        // On quitte le mode modification.
        this.isOpportunityEditMode = false;

        // On oublie l Id de l enregistrement qui etait modifie.
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

    // METHODE loadContracts : demande a Salesforce (Apex) la liste des contrats et la garde dans la variable de la classe.
    // Si Apex renvoie une erreur, on l affiche puis on la relance (throw) pour que l appelant le sache.
    async loadContracts() {

        try {

            // On recupere la liste depuis Salesforce (appel Apex).
            this.contracts = await getContracts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);
            throw error;

        }
    }

    // METHODE handleContractAccountChange : appelee quand l utilisateur change le compte du contrat dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleContractAccountChange(event) {
        this.contractAccountId = event.detail.value;
    }

    // METHODE handleContractStartDateChange : appelee quand l utilisateur change la date de debut du contrat dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleContractStartDateChange(event) {
        this.contractStartDate = event.target.value;
    }

    // METHODE handleContractTermChange : appelee quand l utilisateur change la duree du contrat (en mois) dans le formulaire.
    // Pour un nombre : champ vide = null, sinon on convertit le texte avec Number().
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

    // METHODE handleContractStatusChange : appelee quand l utilisateur change le statut du contrat dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleContractStatusChange(event) {
        this.contractStatus = event.detail.value;
    }

    // METHODE handleContractDescriptionChange : appelee quand l utilisateur change la description du contrat dans le formulaire.
    // On garde la nouvelle valeur saisie dans la variable correspondante.
    handleContractDescriptionChange(event) {
        this.contractDescription = event.target.value;
    }

    // METHODE handleContractCreate : appelee quand on clique sur le bouton pour creer un contrat.
    // Role : envoyer les valeurs du formulaire a Apex, vider le formulaire, puis recharger la liste.
    async handleContractCreate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            const contractTermInteger =
                this.contractTerm == null
                    ? null
                    : parseInt(
                        this.contractTerm,
                        10
                    );

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
            await createContract({
                accountId: this.contractAccountId,
                startDate: this.contractStartDate,
                contractTerm: contractTermInteger,
                status: this.contractStatus,
                description: this.contractDescription
            });

            // On vide le formulaire.
            this.resetContractForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadContracts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleSelectContract : appelee quand on clique sur Modifier pour un contrat de la liste.
    // Role : retrouver le contrat grace a son Id, passer en mode modification et remplir le formulaire avec ses valeurs.
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

        // On passe en mode modification.
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

    // METHODE handleContractUpdate : appelee quand on enregistre la modification d un contrat.
    // Role : envoyer les nouvelles valeurs a Apex, quitter le mode modification, puis recharger la liste.
    async handleContractUpdate() {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        try {

            const contractTermInteger =
                this.contractTerm == null
                    ? null
                    : parseInt(
                        this.contractTerm,
                        10
                    );

            // Appel a la methode Apex (cote serveur) : l enregistrement se fait dans Salesforce.
            await updateContract({
                contractId: this.editingContractId,
                accountId: this.contractAccountId,
                startDate: this.contractStartDate,
                contractTerm: contractTermInteger,
                status: this.contractStatus,
                description: this.contractDescription
            });

            // On vide le formulaire.
            this.resetContractForm();

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadContracts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleContractDelete : appelee quand on clique sur Supprimer pour un contrat.
    // Role : lire l Id de la ligne, demander a Apex de supprimer, puis recharger la liste.
    async handleContractDelete(event) {

        // On efface l ancien message d erreur avant de commencer.
        this.clearError();

        const contractId =
            event.currentTarget.dataset.id;

        if (!contractId) {
            return;
        }

        try {

            // Appel a la methode Apex qui supprime l enregistrement dans Salesforce.
            await deleteContract({
                contractId: contractId
            });

            // On recharge la liste pour voir les changements a l ecran.
            await this.loadContracts();

        // Si Apex renvoie une erreur, on l affiche a l ecran.
        } catch (error) {

            this.setError(error);

        }
    }

    // METHODE handleCancelContractEdit : appelee quand on clique sur Annuler pendant une modification.
    // Role : quitter le mode modification et vider le formulaire.
    handleCancelContractEdit() {
        // On vide le formulaire.
        this.resetContractForm();
    }

    // METHODE resetContractForm : remet le formulaire du contrat a zero (mode creation, champs vides).
    resetContractForm() {

        // On quitte le mode modification.
        this.isContractEditMode = false;

        // On oublie l Id de l enregistrement qui etait modifie.
        this.editingContractId = null;

        this.contractAccountId = null;
        this.contractStartDate = null;
        this.contractTerm = null;
        this.contractStatus = '';
        this.contractDescription = '';
    }
}