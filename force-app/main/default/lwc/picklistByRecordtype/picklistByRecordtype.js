import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//import FAX_ENROLLMENT_OBJECT from '@salesforce/schema/Fax_Enrollment__c';

export default class PicklistByRecordtype extends LightningElement {
    @api rtId;
    @api objectName;
    @api fieldName;
    @track lstServiceTypes;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: '$objectName',
        recordTypeId: '$rtId'
    })
    wiredRecordTypeInfo({data, error }){
        if (data){
            //console.log('data.picklistFieldValues.Service_Type__c.values: ' + JSON.stringify(data.picklistFieldValues.Service_Type__c.values));
            //this.lstServiceTypes = data.picklistFieldValues.Service_Type__c.values;
            this.lstServiceTypes = data.picklistFieldValues[this.fieldName].values;
            let dependentList = []
            for(let stv of this.lstServiceTypes){
                dependentList.push(stv.value);
            }
            console.log('dependentList: ' + JSON.stringify(dependentList));
            //Create a CustomEvent to pass the service Type picklist up to the Aura cmp
            var pLEvent = new CustomEvent('dependentpicklist', {
                detail: {dependentList}
            });
            //Fire the event
            this.dispatchEvent(pLEvent);
        }
        else if (error){
            console.log('field Error Occured ---> ' + JSON.stringify(error));
        }
    }
}