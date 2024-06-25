import { LightningElement, track, wire } from 'lwc';
import postJoobleSearchRequest from '@salesforce/apex/JoobleAPIService.postJoobleSearchRequest';
import { MessageContext, publish } from 'lightning/messageService';
import JOOBLE_LMS from '@salesforce/messageChannel/joobleLMS__c';
// import saveToSalesforce from '@salesforce/apex/JoobleSaveToSalesforce.saveToSalesforce';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// const columns = [
//     { label: 'Title', fieldName: 'title' },
//     { label: 'Location', fieldName: 'location' },
//     { label: 'Description', fieldName: 'snippet' },
//     { label: 'Salary', fieldName: 'salary', type: 'currency' },
//     { label: 'Company', fieldName: 'company' },
//     { label: 'URL', fieldName: 'link' }
// ];

export default class JoobleJobSearch extends LightningElement {
    @wire (MessageContext) messageContext;
    // @track data = [];
    // columns = columns;
    keywords = '';
    location = '';
    // noResults = false;
    // savedRecords = [];
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

            // if (payload) {
            //     const responseData = JSON.parse(payload);
            //     this.data = responseData.jobs.map(job => ({
            //         company: job.company,
            //         id: job.id,
            //         link: job.link,
            //         location: job.location,
            //         salary: job.salary,
            //         snippet: this.getPlainTextFromHTML(job.snippet),
            //         source: job.source,
            //         title: job.title,
            //         type: job.type,
            //         updated: job.updated
            //     }));

            //     this.noResults = responseData.totalCount === 0 ? true : false;
            // }
        } catch (error) {
            console.error('Error in searchJobs:', error);
        }

    }

    // getPlainTextFromHTML(html) {
    //     const tempDivElement = document.createElement('div');
    //     tempDivElement.innerHTML = html;
    //     return tempDivElement.textContent || tempDivElement.innerText || '';
    // }

    // getSelectedRows(event) {
    //     this.savedRecords = event.detail.selectedRows;
    //     console.log('*** SAVED RECORDS:', this.savedRecords);
    // }

    // handleSave(event) {
    //     try {
    //         // function escapeJSON(jsonString) {
    //         //     return jsonString.replace(/[\n\r\t]/g, ' ').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
    //         // }
                    
    //         this.payload = JSON.stringify(this.savedRecords);
    //         console.log('*** SAVING PAYLOAD' + this.payload);

    //         saveToSalesforce({ payload: this.payload })
    //             .then(response => {
    //                 console.log('*** Save successful:', response);
    //                 this.showToast('Success', 'Records saved successfully', 'success');
    //             })
    //             .catch(error => {
    //                 console.error('*** Error in saveToSalesforce:', error);
    //                 this.showToast('Error', 'Error saving records', 'error');
    //             });
    //     } catch (error) {
    //         console.error('*** Error in handleSave:', error);
    //         this.showToast('Error', 'Error preparing payload', 'error');
    //     }
    // }

    // showToast(title, message, variant) {
    //     const event = new ShowToastEvent({
    //         title,
    //         message,
    //         variant
    //     });
    //     this.dispatchEvent(event);
    // }
}