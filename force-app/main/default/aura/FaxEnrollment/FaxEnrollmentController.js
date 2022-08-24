({
    init : function(cmp, event, helper) {
        //test
        let inError = cmp.get("v.inError");
        if(!inError){
            let recordId = cmp.get("v.recordId");
            cmp.set("v.isInrRequiredFields", false)
            cmp.set("v.isRequiredFields", false)
            cmp.set("v.isRequiredDraft", false)
            cmp.set("v.isRequiredSubmit", false)
            cmp.set("v.reqSubmit", 'req')

            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Device_Source__c"}, "v.oDeviceSource");
            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Event_Device_Type__c"}, "v.oEventDeviceType");
            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Patient_Gender__c"}, "v.oPatientGender");
            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "STAT__c"}, "v.oSTAT");
            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Testing_Frequency__c"}, "v.testFrequency");
            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Training_Type__c"}, "v.trainingType");
            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Guarantor_Relationship_to_Patient__c"}, "v.oRelationship");
            helper.getData(cmp, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Status__c"}, "v.statuses");

            
            if(recordId == null || recordId == ""){
                helper.getRecordTypes(cmp, event, helper);
            }else{
                console.log('init getFax')
                helper.getFaxEnrollment(cmp, event, helper);
            }
        }
        
       
    }, 

    openRecord : function(cmp, event, helper) {
        console.log('in goToDetail')
        var url = '/'+event.target.id;
        var urlEvent = $A.get("e.force:navigateToURL")
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();     
    },
    
    initiateFax : function(cmp, event, helper) {
        if(!cmp.get("v.recordId")){
            var rtId = cmp.get("v.recTypeId");
            helper.instantiateFaxEnrollment(cmp, rtId);
            helper.getFeatureFlagHelper(cmp, rtId);
            console.log('v.oDeviceSource ' + JSON.stringify(cmp.get("v.oDeviceSource")))
            console.log('v.oEventDeviceType ' + JSON.stringify(cmp.get("v.oEventDeviceType")))            
        }
    },

    getConfirmationNumber : function(cmp, event, helper) {
        console.log('getConfirmationNumber')

        let fax = cmp.get("v.fax");
        console.log('getConfirmationNumber fax.Status__c ' + fax.Status__c)
        let subId = cmp.get("v.fax.Submission_Id__c");
        let encNum = cmp.get("v.fax.Encounter_Number__c");
        let enrNum = cmp.get("v.fax.Enrollment_Number__c");
        if(subId != null){
            cmp.set("v.showSubmission", true);
        }

        if(subId != null && !encNum && !enrNum){
            helper.getConfirmationNumberHelper(cmp, event, helper);
        }


    },
    
    getBackendId : function(c, e, h) {
        /*
        need to pass an identifier to the lookup component, that we can pass back through the event
        Call specific helper method based on the identifier
        */
        var objectName = e.getParam("objectName");
        var fieldName = e.getParam("fieldName");
        var selectRecordId = e.getParam("selectRecordId");
        var label = e.getParam("label");

        switch(label){
            case 'Practice Location':    
                let practiceLocation = c.get("v.fax.Practice_Location__c");
                if(practiceLocation != null){
                    h.getPLbackendIdHelper(c, e, h);
                    h.getOtsBundleHelper(c, e, h);
                    h.getPhysicianHelper(c, e, h);
                    break;
                }
            case 'Ordering Physician':
                //let notifyingPhysician = c.get("v.fax.Notifying_Physician__c");
                //if(notifyingPhysician == null || notifyingPhysician == ''){
                    let orderingPhysicianid = c.get("v.fax.Ordering_Physician__c");
                    let orderingPhysicianName = c.get("v.fax.Ordering_Physician__r.Name");
                    c.set("v.fax.Notifying_Physician__c", orderingPhysicianid);
                    c.set("v.fax.Notifying_Physician__r.Name", orderingPhysicianName);
                //}
        }    
    },
    changedBackendId : function(c, e, h) {
        h.getOtsBundleHelper(c, e, h);
        h.getPhysicianHelper(c, e, h);
    },    
    populageNotifyingPhysician : function(c, e, h) {
        let notifyingPhysician = c.get("v.fax.Notifying_Physician__c");

        if(notifyingPhysician == null || notifyingPhysician == ''){
            let orderingPhysician = c.get("v.fax.Ordering_Physician__c");
            c.set("v.fax.Notifying_Physician__c", orderingPhysician);
        }
    },

    onSubmit : function(cmp, event, helper) {
        console.log('onSubmit')
        if(cmp.get("v.reqSubmit")){
            cmp.set("v.reqSubmit", '')
        }
        cmp.set("v.draft", false);
        cmp.set("v.isRequiredDraft",false);
        cmp.set("v.isInrRequiredFields",true);
        let fax = cmp.get("v.fax")
        fax.Status__c = 'Submitted'
        cmp.set("v.fax", fax)

      helper.onSubmitData(cmp, event, helper);
    },  
    
    onSaveAsDraft : function(cmp, event, helper){
         
        cmp.set("v.isRequiredDraft",true);
        cmp.set("v.isRequiredFields",false);
        cmp.set("v.isInrRequiredFields",false);
        cmp.set("v.draft", true);
        cmp.set("v.reqDraft", null)
        var isValid = true;
        
        let fax = cmp.get("v.fax");     
        fax.Status__c = 'Draft'
    
        var draftReasonSelected = cmp.get("v.draftReasonSelected");
        console.log(draftReasonSelected.length);
        if(draftReasonSelected.length > 0){
            fax.Draft_Reason__c = "'" + draftReasonSelected + "'"
        }
        if(!fax.Patient_First_Name__c){
            var firstName = cmp.find("firstName");
            firstName.set('v.validity', {valid:false, badInput :true});
            firstName.showHelpMessageIfInvalid();
            isValid = false
        } 
        if(!fax.Patient_Last_Name__c){
            var lastName = cmp.find("lastName");
            lastName.set('v.validity', {valid:false, badInput :true});
            lastName.showHelpMessageIfInvalid();
            isValid = false
        } 
        if(!fax.Patient_Date_of_Birth__c){
            var dobDate = cmp.find("dobDate");
            dobDate.set("v.errors", [{message:"Complete this field."}]);
            isValid = false
    
    
        } 
        if(!fax.Practice_Location__c){
            var pcLocation = cmp.find("pcLocation");
            pcLocation.checkForBlanks();
            isValid = false
        } 
        if(fax.Draft_Reason__c == ""  || fax.Draft_Reason__c == null || draftReasonSelected.length ==0){
            var DraftReason = cmp.find("DraftReason");
            DraftReason.set('v.validity', {valid:false, badInput :true});
            DraftReason.showHelpMessageIfInvalid();        
            isValid = false
        }
        if(!fax.Service_Type__c){
            var servType = cmp.find("servType");
            isValid = false
        } 
        if(!fax.Device_Source__c){
            var devSrc = cmp.find("devSrc");
            isValid = false
        }                 
        if(isValid){
            helper.onSubmitData(cmp, event, helper);
        } else {
            helper.errorToast(cmp, 'Please enter required fields');
    
        }
        
    },
   
    validateDob : function(c, e, h) {
        console.log('validateDob');
        let dobDate = c.find("dobDate");
        let date_val = c.find("dobDate").get("v.value");
        console.log('validateDob ' + date_val);
         
        if(date_val != null){
            if(date_val.length == 8){
                //var res = str.substring(1, 4);
                var dt = date_val.substring(0,2) + '/' + date_val.substring(2,4)+ '/' + date_val.substring(4,8);
                date_val = dt;
                c.find("dobDate").set("v.value",date_val);
            }
            //var date_formatter = new Date(date_val);
            console.log('validateDob ' + date_val);
            //console.log('date_formatter ' + date_formatter);

            if(date_val.includes('-') && moment(date_val, 'YYYY-MM-DD', true).isValid()){
                console.log('FIRST IF VALID');
                dobDate.set("v.errors", null);
            } else if(date_val.includes('//') || !moment(date_val, 'MM/DD/YYYY', true).isValid()){
                //h.errorToast(c, "invalid date please enter in MM/DD/YYYY format");
                dobDate.set("v.errors", [{message:"Complete this field MM/DD/YYYY"}]);
                console.log('SECOND IF validateDob error ');
            }else{
                dobDate.set("v.errors", null); 
                console.log('THIRD IF validateDob no error ');
            }
    
        }else{
            dobDate.set("v.errors", [{message:"Complete this field."}]);
        }
    },  

    validateFax : function(c, e, h) {
        let faxdate = c.find("faxDate");
        let date_val = c.find("faxDate").get("v.value");
         
        if(date_val != null){
            if(date_val.length == 8){
                //var res = str.substring(1, 4);
                var dt = date_val.substring(0,2) + '/' + date_val.substring(2,4)+ '/' + date_val.substring(4,8);
                date_val = dt;
                c.find("faxDate").set("v.value",date_val);
            }
            //var date_formatter = new Date(date_val);
            console.log('validate fax date_val '+ date_val);

            if(date_val.includes('//') || !moment(date_val, 'YYYY-MM-DD', true).isValid()){
                //h.errorToast(c, "invalid date please enter in MM/DD/YYYY format");
                faxdate.set("v.errors", [{message:"Complete this field MM/DD/YYYY"}]);
                console.log('validate fax date_val ERROR '+ date_val);
            }else{
                faxdate.set("v.errors", null); 
                console.log('validate fax date_val NO ERROR'+ date_val);
            }
    
        }else{
            faxdate.set("v.errors", [{message:"Complete this field."}]);
        }

    },

 
    onCheck : function(cmp, event, helper) {
    },

    areAllFieldsPopulated : function(cmp, event, helper){
        console.log('areAllFieldsPopulated ' + cmp.get("v.isInrRecordType"))
        let fax = cmp.get("v.fax")
        let draftEnrollmentFeature = cmp.get("v.draftEnrollmentFeature")

        let featureInrEnabledFields =  ['Practice_Location__c', 'Device_Source__c', 'Service_Type__c', 'Fax_Date__c', 'Diagnosis_Code__c', 'Enrollment_Duration__c', 'Visit_Date__c', 'LanguageId__c', 'STAT__c', 'Patient_First_Name__c', 'Patient_Last_Name__c', 'Patient_Date_of_Birth__c', 'Patient_Gender__c', 'Patient_Home_Phone__c', 'Billing_Street__c', 'Billing_Postal_Code__c', 'Billing_City__c', 'Billing_State__c', 'Low__c', 'High__c', 'Below__c', 'Above__c', 'Testing_Frequency__c', 'Training_Type__c', 'Results_Phone__c', 'Results_Fax_Number__c', 'Ordering_Physician__c','Notifying_Physician__c','Policy_ID__c' ]
        let featureInrDisabledFields = ['Practice_Location__c', 'Device_Source__c', 'Service_Type__c', 'Fax_Date__c', 'Billing_Status__c', 'Diagnosis_Code__c', 'Enrollment_Duration__c', 'Visit_Date__c', 'LanguageId__c', 'STAT__c', 'Patient_First_Name__c', 'Patient_Last_Name__c', 'Patient_Date_of_Birth__c', 'Patient_Gender__c', 'Patient_Home_Phone__c', 'Billing_Street__c', 'Billing_Postal_Code__c', 'Billing_City__c', 'Billing_State__c', 'Ordering_Physician__c','Notifying_Physician__c']
        let inrFields = draftEnrollmentFeature ? featureInrEnabledFields : featureInrDisabledFields

        let featureBthEnabledFields =  ['Practice_Location__c', 'Device_Source__c', 'Service_Type__c', 'Fax_Date__c', 'Diagnosis_Code__c', 'Enrollment_Duration__c', 'Visit_Date__c', 'LanguageId__c', 'STAT__c', 'Patient_First_Name__c', 'Patient_Last_Name__c', 'Patient_Date_of_Birth__c', 'Patient_Gender__c', 'Patient_Home_Phone__c', 'Billing_Street__c', 'Billing_Postal_Code__c', 'Billing_City__c', 'Billing_State__c', 'Ordering_Physician__c','Notifying_Physician__c','Policy_ID__c']       
        let featureBthDisabledFields =  ['Practice_Location__c', 'Device_Source__c', 'Service_Type__c', 'Fax_Date__c', 'Billing_Status__c', 'Diagnosis_Code__c', 'Enrollment_Duration__c', 'Visit_Date__c', 'LanguageId__c', 'STAT__c', 'Patient_First_Name__c', 'Patient_Last_Name__c', 'Patient_Date_of_Birth__c', 'Patient_Gender__c', 'Patient_Home_Phone__c', 'Billing_Street__c', 'Billing_Postal_Code__c', 'Billing_City__c', 'Billing_State__c', 'Ordering_Physician__c','Notifying_Physician__c']       
        let bthFields = draftEnrollmentFeature ? featureBthEnabledFields : featureBthDisabledFields

        //
        let fields = cmp.get("v.isInrRecordType") ? inrFields : bthFields

        let emptyFieldFound = false;
        fields.forEach(function(field) {    
            if(fax[field] == null || fax[field] == '' || fax[field] == ' '){
                console.log(field)
                emptyFieldFound = true;   
            }
        })

        if(cmp.get("v.eventDeviceTypeRequired") && !fax.Event_Device_Type__c){
            emptyFieldFound = true
        }
        if(fax.Device_Source__c == 'OTS' && !fax.OTS_Device__c){
            emptyFieldFound = true

        }
        console.log('emptyFieldFound ' + emptyFieldFound)

        if(!emptyFieldFound && (!draftEnrollmentFeature || fax.Payer_Info__c || fax.Payer_Name__c)){
            cmp.set("v.showSubmit", true)
        } else {
            cmp.set("v.showSubmit", false)
        } 


    },
 
    serviceTypeChange : function(cmp, event, helper) {
        var value = event.getSource().get("v.value");
        var dSource = cmp.get("v.fax").Device_Source__c;
    
        if(value == 'EVENT'){ 
            cmp.set("v.showDeviceType", "true");
        }else{
            cmp.set("v.showDeviceType", "false");
            cmp.set("v.fax.Event_Device_Type__c", null);
        }
        helper.setDeviceTypeRequired(cmp, dSource, value)
        helper.getOtsBundleHelper(cmp, event, helper);
    },     
    
    showOTS : function(cmp, event, helper) {
        var value = event.getSource().get("v.value");
    
        if(value == 'OTS'){
            cmp.set("v.showOTS", "true");
        }else{
            cmp.set("v.showOTS", "false");
            cmp.set("v.fax.OTS_Device__c", null);
        }
    
        var st = cmp.get("v.fax.Service_Type__c");
    
        if(st == 'EVENT'){ 
            cmp.set("v.showDeviceType", "true");
        }else{
            cmp.set("v.showDeviceType", "false");
            cmp.set("v.fax.Event_Device_Type__c", null);
        }
        cmp.set("v.eventDeviceTypeRequired", value == 'OTS' && st == 'EVENT')
        helper.setDeviceTypeRequired(cmp, value, st)
        helper.getOtsBundleHelper(cmp, event, helper);
    },

    deviceTypeChange : function(cmp, event, helper) {
        let fax = cmp.get("v.fax")
        helper.setDeviceTypeRequired(cmp, fax.Device_Source__c, fax.Service_Type__c)
        helper.getOtsBundleHelper(cmp, event, helper);
    },        

    showDiag2 : function(c, e, h) {
        let fax = c.get("v.fax");
        if(fax.Diagnosis_Code__c != null){
            c.set("v.showDiagnosisCode2", "true");
        }

    },  

    showDiag3 : function(c, e, h) { 
        let fax = c.get("v.fax");
        if(fax.Diagnosis_Code_2__c != null){
            c.set("v.showDiagnosisCode3", "true");
        }

    },  

    showDiag4 : function(c, e, h) {
        let fax = c.get("v.fax");
        if(fax.Diagnosis_Code_3__c != null){
            c.set("v.showDiagnosisCode4", "true");
        }

    },  

    sentenceCase : function(c, e, h) {
        var value = e.getSource().get("v.value");
        if(value != null){
            if(value.length == 1){
                var valueUpper = value.toUpperCase();
                e.getSource().set("v.value", valueUpper);
            }
        }
    },     

    formatPhone : function(c, e, h) {
        var value = e.getSource().get("v.value");
        var re = /^\d+(-\d+)*$/;
        if(value.substring(0, 1) == 1 || !re.test(value) || value.length > 12){
            value = value.substring(0, value.length - 1);
        }else{
            if(value.length == 3 || value.length == 7){
                value = value + '-';
            }
        }
        if(value.includes('--')){
            var val = value.replace('--', '-');
            value = val;
        }
        e.getSource().set("v.value", value);
    },      

    handleServiceTypes : function(cmp, event, helper) {
        var serviceTypes = event.getParam('dependentList');
        console.log('in c.handleServiceTypes, serviceTypes: ' + JSON.stringify(serviceTypes));
        cmp.set("v.oServiceType", serviceTypes);
        cmp.set("v.showServiceType", true);
    },
    handleDraftReasons : function(cmp, event, helper) {
        var draftReasons = event.getParam('dependentList');
        console.log('in c.handleDraftReasons, draftReasons: ' + JSON.stringify(draftReasons));
        cmp.set("v.draftReasonOptions", draftReasons);
        var plValues = [];
        for (var i = 0; i < draftReasons.length; i++) {
            plValues.push({
                label: draftReasons[i],
                value: draftReasons[i]
            });
        }
        cmp.set("v.draftReasonOptions", plValues);

    },
    saveRecordTypeId : function(cmp, event, helper){
        let validInput = cmp.find("selectedRT").get('v.validity').valid;
        if(validInput){            
            cmp.set("v.recTypeId", cmp.get("v.storedRecTypeId"));
            console.log('The recTypeId is currently set to: ' + cmp.get("v.recTypeId"));
            if(cmp.get("v.inrRecTypeId") == cmp.get("v.recTypeId")){
                cmp.set("v.isInrRecordType",true);
            }
            cmp.set("v.isModalOpen", false);
        }
        else{
            console.log('invalid selection for saveRecordTypeId');
            cmp.find("selectedRT").showHelpMessageIfInvalid();
        }

    },

    closeModal : function(c, e, h) {
        let recTypeSet = c.get("v.recTypeId");
        if (recTypeSet == null || recTypeSet == ""){
            window.history.back();
        }
        else{
            c.set("v.storedRecTypeId", "v.recTypeId");
            c.set("v.isModalOpen", false);
        }
    },
    updatePolicyIdRequired : function(cmp, event, helper) {
        console.log('updatePolicyIdRequired ' + cmp.get("v.payerName"))
        if(cmp.get("v.payerName") == 'Self Pay' || cmp.get("v.payerName") == 'PPM' || cmp.get("v.payerName") == 'VA Medical Center'){
            cmp.set("v.policyIdRequired", false);
            let fax = cmp.get("v.fax")
            fax.Policy_ID__c = 'Self'
            cmp.set("v.fax", fax)
        } else if(cmp.get("v.payerName") == 'Fee For Service'){
            cmp.set("v.policyIdRequired", false);
            let fax = cmp.get("v.fax")
            fax.Policy_ID__c = 'Invoice'
            cmp.set("v.fax", fax)            
        } else {
            cmp.set("v.policyIdRequired", true);
            let fax = cmp.get("v.fax")
            if(fax.Policy_ID__c == 'Invoice' || fax.Policy_ID__c == 'Self'){
                fax.Policy_ID__c = null
            }
            cmp.set("v.fax", fax)             
        }

    }
})