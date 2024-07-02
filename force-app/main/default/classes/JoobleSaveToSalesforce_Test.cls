/**
 * Apex Class: JoobleSaveToSalesforce_Test
 * Description: This class is used to test the JoobleSaveToSalesforce class, validating the Account and Job_Application__c records
 * created from the JSON string returned from the joobleJobSearch lwc
 * Created Date: 2024-06-16
 * Last Modified: 
 */

@isTest
public with sharing class JoobleSaveToSalesforce_Test {
    
    @isTest
    static void testSaveToSalesforce_Positive(){

        Account testAccount = new Account(Name = 'Cloud Consulting');
        insert testAccount;

        String payload = '[{"company":"Data Dream","id":1988165115712216800,"link":"https://jooble.org","location":"Austin, TX","salary":"80000","snippet":"Tableau Admin, Locals Preferred","source":"appcast.io","title":"Tableau Admin","type":"","updated":"2024-06-13T00:00:00.0000000"},{"company":"Cloud Consulting","id":6975534765270566000,"link":"https://jooble.org","location":"Austin, TX","salary":"","snippet":"Salesforce Admin, you will be responsible for the administration, configuration, and ongoing maintenance of our Salesforce instance... ","source":"appcast.io","title":"Salesforce Admin","type":"Contractor","updated":"2024-06-15T00:00:00.0000000"}]';

        Test.startTest();
            JoobleSaveToSalesforce.saveToSalesforce(payload);
        Test.stopTest();

       
        List<Account> accountsCreated = [
            SELECT Id, Name FROM Account WHERE Id != :testAccount.Id
        ];

        Assert.areEqual(1, accountsCreated.size(), 'Expected only one account to be created');
        Assert.areEqual('Data Dream', accountsCreated[0].Name, 'Name of account does not match expected value');

        List<Job_Application__c> jobAppsCreated = [
            SELECT Id, Name, Position_Title__c, Location__c, Salary__c, Description__c, URL__c, Notes__c, Status__c, Company_Name__c
            FROM Job_Application__c
        ];

        Assert.areEqual(2, jobAppsCreated.size(), 'Expected two job application records to be created');
        
        for(Job_Application__c jobApp : jobAppsCreated){
            if(jobApp.Position_Title__c == 'Tableau Admin'){
                Assert.areEqual('Austin, TX', jobApp.Location__c, 'Location does not match expected value on Job Application');
                Assert.areEqual(80000, jobApp.Salary__c, 'Salary does not match expected value on Job Application');
                Assert.areEqual('Tableau Admin, Locals Preferred', jobApp.Description__c, 'Description does not match expected value on Job Application');
                Assert.areEqual('https://jooble.org', jobApp.URL__c, 'URL does not match expected value on Job Application');
                Assert.areEqual('Saved', jobApp.Status__c, 'Status does not match expected value on Job Application');
                Assert.areEqual(accountsCreated[0].Id, jobApp.Company_Name__c, 'Company Name does not match expected value on Job Application');
                Assert.areEqual('Source: appcast.io', jobApp.Notes__c, 'Notes do not match expected value on Job Application');
            }
        }

    }

    @isTest
    static void testSaveToSalesforce_Negative(){

        Account testAccount = new Account(Name = 'Cloud Consulting');
        insert testAccount;

        String payload = '';

        Test.startTest();
            JoobleSaveToSalesforce.saveToSalesforce(payload);
        Test.stopTest();

        List<Account> accountsCreated = [
            SELECT Id, Name FROM Account WHERE Id != :testAccount.Id
        ];

        Assert.areEqual(0, accountsCreated.size(), 'Expected no account records found');

        List<Job_Application__c> jobAppsCreated = [
            SELECT Id, Name, Position_Title__c, Location__c, Salary__c, Description__c, URL__c, Notes__c, Status__c, Company_Name__c
            FROM Job_Application__c
        ];

        Assert.areEqual(0, jobAppsCreated.size(), 'Expected no job application records found');

    }

}