import { LightningElement } from 'lwc';
import postJoobleSearchRequest from '@salesforce/apex/JoobleAPIService.postJoobleSearchRequest';
import saveToSalesforce from '@salesforce/apex/JoobleSaveToSalesforce.saveToSalesforce';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
{ label: 'Title', fieldName: 'title' },
{ label: 'Location', fieldName: 'location' },
{ label: 'Description', fieldName: 'snippet'},
{ label: 'Salary', fieldName: 'salary', type: 'currency' },
{ label: 'Company', fieldName: 'company' },
];

export default class JoobleJobSearch extends LightningElement {
    data = [];
    columns = columns;
    keywords = "";
    location = "";
    noResults = false;
    savedRecords = [];

    handleKeyChange(event){
        this.keywords = event.detail.value;
    }

    handleLocChange(event){
        this.location = event.detail.value;
    }

    handleSearch(event) {
        this.searchJobs();
    }

    async searchJobs() {
        try {
            const result = await postJoobleSearchRequest({ keywords: this.keywords, location: this.location });

            if(result){
                const responseData = JSON.parse(result);
                this.data = responseData.jobs.map(job => {
                    return {
                        company: job.company,
                        id: job.id,
                        link: job.link,
                        location: job.location,
                        salary: job.salary,
                        snippet: job.snippet,
                        source: job.source,
                        title: job.title,
                        type: job.type,
                        updated: job.updated
                    };
                });
            } else {
                this.noResults = true;
            }
            
        } catch (error) {
            console.error('Error in searchJobs:', error);
        }
    }

    getSelectedRows(event){
        this.savedRecords = event.detail.selectedRows;
        console.log('*** SAVED RECORDS' + this.savedRecords);
    }

    handleSave(event){

        try {
                    
            const payload = JSON.stringify(this.savedRecords);
            console.log('*** SAVING PAYLOAD' + payload);
            saveToSalesforce({ selectedRows: payload })
                .then(response => {
                    console.log('Save successful:', response);
                })
                .catch(error => {
                    console.error('Error in saveToSalesforce:', error);
                });
        } catch (error) {
            console.error('Error in handleSave:', error);
        }
        
    }

}
    