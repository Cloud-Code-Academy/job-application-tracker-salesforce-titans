import { LightningElement, wire } from 'lwc';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import JOOBLE_LMS from '@salesforce/messageChannel/joobleLMS__c';
import saveToSalesforce from '@salesforce/apex/JoobleSaveToSalesforce.saveToSalesforce';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Title', fieldName: 'title' },
    { label: 'Location', fieldName: 'location' },
    { label: 'Description', fieldName: 'snippet', wrapText: true },
    // { label: 'Salary', fieldName: 'salary', type: 'currency' },
    { label: 'Company', fieldName: 'company' },
    // { label: 'URL', fieldName: 'link' }
];

export default class JoobleJobResults extends LightningElement {

    @wire (MessageContext) messageContext;
    subscription = null;
    noSubscription = true;
    data = [];
    columns = columns;
    noResults = false;
    savedRecords = [];
    payload = '';

    connectedCallback(){
        this.handleSubscribe();

        console.log('*** SUBSCRIPTION IN CALLBACK:', this.subscription);
        console.log('*** NO SUBSCRIPTION IN CALLBACK:', this.noSubscription);
    }

    disconnectedCallback(){
        this.handleUnsubscribe();
        
    }

    handleSubscribe() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext, 
                JOOBLE_LMS, 
                (message) => this.handleMessage(message)
            );

            
            console.log('*** SUBSCRIPTION IN HANDLE:', this.subscription);
            console.log('*** NO SUBSCRIPTION IN HANDLE:', this.noSubscription);
        }
    }

    handleMessage(message) {
        if (message) {
            const responseData = JSON.parse(message.payload);
            this.data = responseData.jobs.map(job => ({
                company: job.company,
                id: job.id,
                link: job.link,
                location: job.location,
                salary: job.salary,
                snippet: this.getPlainTextFromHTML(job.snippet),
                source: job.source,
                title: job.title,
                type: job.type,
                updated: job.updated
            }));

            console.log('*** RESPONSE DATA:', responseData);
            console.log('*** DATA:', this.data);

            this.noSubscription = false;
            this.noResults = responseData.totalCount === 0;
        }
    }

    handleUnsubscribe(){
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
            this.noSubscription = true;

            console.log('*** SUBSCRIPTION IN UNSUBSCRIBE:', this.subscription);
            console.log('*** NO SUBSCRIPTION IN UNSUBSCRIBE:', this.noSubscription);
        }
    }


    getPlainTextFromHTML(html) {
        const tempDivElement = document.createElement('div');
        tempDivElement.innerHTML = html;
        return tempDivElement.textContent || tempDivElement.innerText || '';
    }

    getSelectedRows(event) {
        this.savedRecords = event.detail.selectedRows;
        console.log('*** SAVED RECORDS:', this.savedRecords);
    }

    handleSave(event) {
        try {
                    
            this.payload = JSON.stringify(this.savedRecords);
            console.log('*** SAVING PAYLOAD' + this.payload);

            saveToSalesforce({ payload: this.payload })
                .then(response => {
                    console.log('*** Save successful:', response);
                    this.showToast('Success', 'Records saved successfully', 'success');
                })
                .catch(error => {
                    console.error('*** Error in saveToSalesforce:', error);
                    this.showToast('Error', 'Error saving records', 'error');
                });
        } catch (error) {
            console.error('*** Error in handleSave:', error);
            this.showToast('Error', 'Error preparing payload', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

}