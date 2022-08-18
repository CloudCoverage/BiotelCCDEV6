({
    
    init : function(c, e, h) {
        let inError = c.get("v.inError");
        if(!inError){
            let recordId = c.get("v.recordId");
            h.getData(c, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Patient_Gender__c"}, "v.oPatientGender");
            h.getData(c, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "STAT__c"}, "v.oSTAT");
            h.getData(c, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Testing_Frequency__c"}, "v.testFrequency");
            h.getData(c, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Training_Type__c"}, "v.trainingType");
            h.getData(c, "c.getPicklistValues", {objectName: "Fax_Enrollment__c", fieldName: "Insurance_Payer__c"}, "v.insurance");
            if(recordId == null || recordId == ""){
                h.getRecordTypes(c, e, h);
                 h.getPicklistvalues(c,e,h);
            }else{
                h.getPicklistvalues(c,e,h);
                h.getFaxEnrollment(c, e, h);
            }
        }
        
       
    }, 
    handleDraftReason : function(c,e,h){
        
    },
    openRecord : function(c, e, h) {
        console.log('in goToDetail')
        var url = '/'+e.target.id;
        var urlEvent = $A.get("e.force:navigateToURL")
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();     
    },
    
    initiateFax : function(c, e, h) {
        if(!c.get("v.recordId")){
            var rtId = c.get("v.recTypeId");
            h.instantiateFaxEnrollment(c, e, h, rtId);
        }
    },

    getEncounterNumber : function(c, e, h) {

        let subId = c.get("v.fax.Submission_Id__c");
        let encNum = c.get("v.fax.Encounter_Number__c");
        if(subId != null){
            c.set("v.showSubmission", true);
        }

        if(subId != null && encNum == null){
            h.getEncounterNumberHelper(c, e, h);
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

    onSubmit : function(c, e, h) {
        c.set("v.draft", false);
        c.set("v.isRequiredDraft",false);
        c.set("v.isRequiredSubmit",true);
        c.set("v.isInrRequiredFields",true);

        c.set("v.isRequired",false);


        c.set("v.reqSubmit", null)
        c.set("v.reqSubmitInr", null)

        let fax = c.get("v.fax")
        fax.Status__c = 'Submitted'
        c.set("v.fax", fax)

      h.onSubmitData(c, e, h);
    },  
    
    onSaveAsDraft : function(c, e, h){
         
        c.set("v.isRequiredDraft",true);
        c.set("v.isRequiredSubmit",false);
        c.set("v.isInrRequiredFields",false);
        c.set("v.draft", true);

        c.set("v.reqDraft", null)


        var isValid = true;
        
        let fax = c.get("v.fax");     
        fax.Status__c = 'Draft'

        var draftReasonSelected = c.get("v.draftReasonSelected");
        console.log(draftReasonSelected.length);
        if(draftReasonSelected.length > 0){
            fax.Draft_Reason__c = "'" + draftReasonSelected + "'"
        }
        if(!fax.Patient_First_Name__c){
            var firstName = c.find("firstName");
            firstName.set('v.validity', {valid:false, badInput :true});
            firstName.showHelpMessageIfInvalid();
            isValid = false
        } 
        if(!fax.Patient_Last_Name__c){
            var lastName = c.find("lastName");
            lastName.set('v.validity', {valid:false, badInput :true});
            lastName.showHelpMessageIfInvalid();
            isValid = false
        } 
        if(!fax.Patient_Date_of_Birth__c){
            var dobDate = c.find("dobDate");
            dobDate.set("v.errors", [{message:"Complete this field."}]);
            isValid = false
        } 
        if(!fax.Practice_Location__c){
            var pcLocation = c.find("pcLocation");
            pcLocation.checkForBlanks();
            isValid = false
        } 
        if(fax.Draft_Reason__c == ""  || fax.Draft_Reason__c == null || draftReasonSelected.length ==0){
            var DraftReason = c.find("DraftReason");
            DraftReason.set('v.validity', {valid:false, badInput :true});
            DraftReason.showHelpMessageIfInvalid();        
            isValid = false
        }
        if(isValid){
            h.onSubmitData(c, e, h);
        } else {
            h.errorToast(c, 'Please enter required fields');

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
    /*
    checkIfNotNumber : function(component, event, helper) {
        console.log('checkIfNotNumber');
        if(isNaN(component.get("v.fax.Enrollment_Duration__c"))){
            alert("Duration must be a numeric value");
           component.set("v.fax.Enrollment_Duration__c","");
        }
    },*/ 
 
    onCheck : function(component, event, helper) {
        let sameAs = component.find("sameAsBilling").get("v.value");
    }, 
 
    serviceTypeChange : function(c, e, h) {
        var value = e.getSource().get("v.value");
        var dSource = c.get("v.fax.Device_Source__c");

        if(value == 'EVENT' && dSource == 'MTP'){ 
            c.set("v.showDeviceType", "true");
        }else{
            c.set("v.showDeviceType", "false");
            c.set("v.fax.Event_Device_Type__c", null);
        }

        h.getOtsBundleHelper(c, e, h);
    },     

    showOTS : function(c, e, h) {
        var value = e.getSource().get("v.value");

        if(value == 'OTS'){
            c.set("v.showOTS", "true");
        }else{
            c.set("v.showOTS", "false");
            c.set("v.fax.OTS_Device__c", null);
        }

        var st = c.get("v.fax.Service_Type__c");

        if(st == 'EVENT' && value == 'MTP'){ 
            c.set("v.showDeviceType", "true");
        }else{
            c.set("v.showDeviceType", "false");
            c.set("v.fax.Event_Device_Type__c", null);
        }        
        h.getOtsBundleHelper(c, e, h);
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

    handleServiceTypes : function(c, e, h) {
        var serviceTypes = e.getParam('servTypesList');
        console.log('in c.handleServiceTypes, serviceTypes: ' + JSON.stringify(serviceTypes));
        c.set("v.oServiceType", serviceTypes);
        let fax = c.get("v.fax")
        console.log('in c.handleServiceTypes, fax: ' + JSON.stringify(fax));
        if(fax && fax.RecordTypeId && fax.RecordTypeId == '0120H000000u2NPQAY'){
            fax.Service_Type__c = 'INR'
        }
        c.set("v.fax", fax)        
    },

    saveRecordTypeId : function(c, e, h){
        let validInput = c.find("selectedRT").get('v.validity').valid;
        if(validInput){            
            c.set("v.recTypeId", c.get("v.storedRecTypeId"));
            console.log('The recTypeId is currently set to: ' + c.get("v.recTypeId"));
            if(c.get("v.draftReasonSelected") == c.get("v.recTypeId")){
                c.set("v.isInrRecordType",true);
            }
            c.set("v.isModalOpen", false);
        }
        else{
            console.log('invalid selection for saveRecordTypeId');
            c.find("selectedRT").showHelpMessageIfInvalid();
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
    }
})