import { LightningElement, wire } from 'lwc';
import postJoobleSearchRequest from '@salesforce/apex/JoobleAPIService.postJoobleSearchRequest';
import { MessageContext, publish } from 'lightning/messageService';
import JOOBLE_LMS from '@salesforce/messageChannel/joobleLMS__c';

export default class JoobleJobSearch extends LightningElement {
    @wire (MessageContext) messageContext;
    keywords = '';
    location = '';
    payload = '';

    handleKeyChange(event) {
        this.keywords = event.detail.value;
    }

    handleLocChange(event) {
        this.location = event.detail.value;
    }

    handleSearch() {
        this.searchJobs().then(payload => {
            console.log('*** PAYLOAD FROM JOB SEARCH', payload);
            publish(this.messageContext, JOOBLE_LMS, { payload });
        });
    }

    async searchJobs() {
        try {
            const payload = await postJoobleSearchRequest({ keywords: this.keywords, location: this.location });
            return payload;
        } catch (error) {
            console.error('Error in searchJobs:', error);
        }

    }

}