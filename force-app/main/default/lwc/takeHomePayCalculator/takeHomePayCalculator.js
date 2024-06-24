/**
 * 2 ways to calculate take home pay - one from Salary retrived from Salary field of Job application record and other one
 * is from salary input change introdued by user on the input field
 */
import { LightningElement, api, wire } from "lwc";
/* Wire adapter to fetch record data */
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Job_Application_OBJECT from "@salesforce/schema/Job_Application__c";
import Salary_FIELD from "@salesforce/schema/Job_Application__c.Salary__c";

export default class takeHomePayCalculator extends LightningElement {
  /** Id of record to display. */
  @api recordId;

  filingStatusSelect = "";
  salaryInput = 0;

  federalTax = 0;
  takeHomeSalary = 0;
  biweeklyTakeHome = 0;
  monthlyTakeHome = 0;
  sixMonthsTakeHome = 0;
  socialSecurityDeduction = 0;
  medicareDeduction = 0;

  /* Expose schema objects/fields to the template. */
  jobApplicationName = Job_Application_OBJECT;

  /* Load Job application Salary.Name for custom rendering */
  @wire(getRecord, { recordId: "$recordId", fields: [Salary_FIELD] }) //commented out [Salary_FIELD]
  record;

  /** Get the Job application.Salary value. */
  get salaryValue() {
    return this.record.data
      ? getFieldValue(this.record.data, Salary_FIELD)
      : "";
  }

  // get salaryCalculateValue() {
  //   console.log("*** SALARY CALCULATE VALUE" + this.salaryCalculateValue);
  //   //return this.salaryInput ? this.salaryInput : this.salaryValue;
  // }

  handleSalaryInputChange(event) {
    this.salaryInput = event.target.value;

    console.log("*** HANDLE SALARY INPUT CHANGE");
    console.log("*** HANDLE SALARY INPUT" + this.salaryInput);
  }

  get filingStatusOptions() {
    return [
      { label: "Single", value: "Single" },
      { label: "Head Of HouseHold", value: "HOH" },
      { label: "Married Filing Separately", value: "MFS" },
      { label: "Married Filing Jointly", value: "MFJ" }
    ];
  }

  handleFilingStatusChange(event) {
    this.filingStatusSelect = event.target.value;

    console.log("*** HANDLE FILING STATUS CHANGE");
    console.log("*** FILING STATUS" + this.filingStatusSelect);
  }

  calculateTakeHomeSalary() {
    console.log("*** INSIDE CALCULATE METHOD");
    // console.log("*** SALARY CALCULATE VALUE " + this.salaryCalculateValue);
    console.log("*** FILING STATUS SELECT" + this.filingStatusSelect);
    if (!this.salaryInput) {
      this.salaryInput = this.salaryValue;
    }
    console.log("*** SALARY INPUT" + this.salaryInput);

    if (!this.salaryInput || !this.filingStatusSelect) {
      console.log("*** INSIDE CALCULATE NULL IF");
      this.takeHomeSalary = "Please provide both income and filing status.";
      return;
    }

    //Social Security and Medicare Deductions

    const socialSecurityRate = 0.062;
    const medicareRate = 0.0145;

    //Calculate Standard deduction
    const standardDeduction = {
      Single: 14600,
      HOH: 21900,
      MFS: 14600,
      MFJ: 29200
    };

    //Deduct Social Security & Medicare

    let taxableIncome =
      this.salaryInput - standardDeduction[this.filingStatusSelect];
    console.log("***" + standardDeduction[this.filingStatusSelect]);
    console.log("***" + taxableIncome);

    //- socialSecurityDeduction - medicareDeduction;

    //Define tax brackets for differnt filing statuses

    const taxBrackets = {
      Single: [
        { rate: 0.37, threshold: 609350 },
        { rate: 0.35, threshold: 243725 },
        { rate: 0.32, threshold: 191950 },
        { rate: 0.24, threshold: 100525 },
        { rate: 0.22, threshold: 47150 },
        { rate: 0.12, threshold: 11600 },
        { rate: 0.1, threshold: 0 }
      ],
      HOH: [
        { rate: 0.37, threshold: 731200 },
        { rate: 0.35, threshold: 487450 },
        { rate: 0.32, threshold: 383900 },
        { rate: 0.24, threshold: 201050 },
        { rate: 0.22, threshold: 94300 },
        { rate: 0.12, threshold: 23200 },
        { rate: 0.1, threshold: 0 }
      ],
      MFS: [
        { rate: 0.37, threshold: 365600 },
        { rate: 0.35, threshold: 243725 },
        { rate: 0.32, threshold: 191950 },
        { rate: 0.24, threshold: 100525 },
        { rate: 0.22, threshold: 47150 },
        { rate: 0.12, threshold: 11600 },
        { rate: 0.1, threshold: 0 }
      ],
      MFJ: [
        { rate: 0.37, threshold: 731200 },
        { rate: 0.35, threshold: 487450 },
        { rate: 0.32, threshold: 383900 },
        { rate: 0.24, threshold: 201050 },
        { rate: 0.22, threshold: 94300 },
        { rate: 0.12, threshold: 23200 },
        { rate: 0.1, threshold: 0 }
      ]
    };

    if (!taxBrackets[this.filingStatusSelect]) {
      this.takeHomeSalary = "Invalid filing status.";
      console.log(this.takeHomeSalary);
      return;
    }
    // Calculate tax using progressive tax brackets
    let tax = 0;
    let remainingIncome = taxableIncome;

    for (const bracket of taxBrackets[this.filingStatusSelect]) {
      if (remainingIncome > bracket.threshold) {
        tax += (remainingIncome - bracket.threshold) * bracket.rate;
        remainingIncome = bracket.threshold;
      }
    }
    this.federalTax = tax;

    this.socialSecurityDeduction = this.salaryInput * socialSecurityRate;
    this.medicareDeduction = this.salaryInput * medicareRate;

    // Calculate take home salary after tax
    const takeHomeSalary =
      this.salaryInput -
      this.federalTax -
      this.socialSecurityDeduction -
      this.medicareDeduction;

    // Update takeHomeSalary property
    this.takeHomeSalary = takeHomeSalary;

    console.log("*** TAKE HOME" + this.takeHomeSalary);

    this.calculateTakeHomeSalaryBiWeeklyMonthlySixMonths();
  }

  calculateTakeHomeSalaryBiWeeklyMonthlySixMonths() {
    const calculateBiweeklyTakeHome = this.takeHomeSalary / 26.07;
    const calculateMonthlyTakeHome = this.takeHomeSalary / 12;
    const calculateSixMonthsTakeHome = this.takeHomeSalary / 2;

    this.biweeklyTakeHome = calculateBiweeklyTakeHome.toFixed(2);
    this.monthlyTakeHome = calculateMonthlyTakeHome.toFixed(2);
    this.sixMonthsTakeHome = calculateSixMonthsTakeHome.toFixed(2);
  }
}
