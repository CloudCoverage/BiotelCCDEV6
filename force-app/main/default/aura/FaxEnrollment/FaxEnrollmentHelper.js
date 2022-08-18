({ 
    getFaxEnrollment : function(c, e, h) {
        console.log('in h.getFaxEnrollment');

        var state;
        var action = c.get("c.getFaxEnrollment");
      
        this.showSpinner(c); 
        action.setParams({
           "recordId": c.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") {
                this.hideSpinner(c); 
                var fax = response.getReturnValue();
                c.set("v.fax", fax);
                console.log(JSON.stringify(fax))
                console.log(JSON.stringify(fax.Draft_Reason__c))
                
                c.set("v.recTypeId", fax.RecordTypeId);
                h.getFeatureFlagHelper(c, fax.RecordTypeId);

                let draftArray = fax.Draft_Reason__c ? fax.Draft_Reason__c.split(';') : [] ;
                c.set("v.draftReasonSelected", draftArray)
                if(fax.Practice_Location__c != null){
                    c.set("v.practiceLocationName", fax.Practice_Location__r.Name);
                }
                if(fax.Billing_Status__c != null){
                    c.set("v.billingStatusName", fax.Billing_Status__r.Name);
                }
                if(fax.Payer_Info__c != null){
                    c.set("v.payerName", fax.Payer_Info__r.Name)
                }
                if(fax.Diagnosis_Code__c != null){
                    c.set("v.diagnosisCodeName", fax.Diagnosis_Code__r.Code__c);
                }
                if(fax.Diagnosis_Code_2__c != null){
                    c.set("v.diagnosisCodeName2", fax.Diagnosis_Code_2__r.Code__c);
                }
                if(fax.Diagnosis_Code_3__c != null){
                    c.set("v.diagnosisCodeName3", fax.Diagnosis_Code_3__r.Code__c);
                }
                if(fax.Diagnosis_Code_4__c != null){
                    c.set("v.diagnosisCodeName4", fax.Diagnosis_Code_4__r.Code__c);
                }
                if(fax.Billing_Postal_Code__c != null){
                    c.set("v.billingZipName", fax.Billing_Postal_Code__r.Name);
                }
                if(fax.Shipping_Postal_Code__c != null){
                    c.set("v.shippingZipName", fax.Shipping_Postal_Code__r.Name);
                }
                if(fax.OTS_Device__c != null || fax.Device_Source__c == 'OTS'){
                    c.set("v.showOTS", true);
                }
                if(fax.Service_Type__c == 'EVENT' && fax.Device_Source__c == 'MTP'){
                    c.set("v.showDeviceType", "true");
                } else {
                    c.set("v.showDeviceType", "false");
                }                
                if(fax.Status__c != 'Submitted' ){
                    c.set("v.editing", true);
                }else{
                    c.set("v.editing", false);
                    c.set("v.sameAsBilling", false);
                }
                if(fax.RecordTypeId == '0120H000000u2NPQAY'){
                    c.set("v.isInrRecordType", true)
                }
                if(!fax.Status__c && fax.Submission_Id__c){
                    c.set("v.editing", false);
                }


                c.set("v.plBackendId", fax.Practice_Location__r.Backend_ID__c);
                this.getOtsBundleHelper(c, e, h);
                this.getPhysicianHelper(c, e, h);                
            }
        });
        $A.enqueueAction(action);
    },
   
    getRecordTypes : function(c, e, h) {
        console.log('in h.getRecordTypes');
        var action = c.get("c.fetchRecordTypeValues");
        this.showSpinner(c);

        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
                this.hideSpinner(c);
                var recTypeList = res.getReturnValue();
                var listOfRecTypes = [];

                for(var rti of recTypeList){
                    var rt = {
                        label: rti.Name,
                        value: rti.Id
                    };
                    if(rti.Name=='INR Enrollments'){
                        c.set("v.storedRecTypeId",rti.Id);  
                        c.set("v.inrRecTypeId",rti.Id);
                    }                    
                    listOfRecTypes.push(rt);
                }
                console.log('list of RecTypes: ' + JSON.stringify(listOfRecTypes));
                c.set("v.recTypes", listOfRecTypes);

                if(listOfRecTypes.length === 1){
                    c.set("v.isModalOpen", false);
                    c.set("v.recTypeId", listOfRecTypes[0].value);
                    
                    console.log('One record type found. recTypeId: ' + c.get("v.recTypeId"));
                }
                else{
                    c.set("v.isModalOpen", true);
                    console.log('Number of record types found: ' + listOfRecTypes.length);
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                var errorMsg = res.getError();
                console.log('There was an error: ' + JSON.stringify(errorMsg));
                toastEvent.setParams({
                    title: "Error getting Record Types",
                    message: "State: " + state + ", Body: " + JSON.stringify(errorMsg)
                });
                toastEvent.fire();
            }
            else {
                console.log('There was an unknown error. State: ' + state);
            }
        });
        console.log('fire the action');
        $A.enqueueAction(action);
    },

    instantiateFaxEnrollment : function(cmp, recTypeId) { 
        console.log('in h.instantiateFaxEnrollment'); 
        var state;
        var action = cmp.get("c.instantiateFax");
        this.showSpinner(cmp);

        action.setParams({
            "recordTypeId": recTypeId
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                this.hideSpinner(cmp);
                var fax = response.getReturnValue();
                fax.Visit_Date__c = new Date().toISOString().slice(0,10);
                if(fax.RecordTypeId && fax.RecordTypeId == '0120H000000u2NPQAY'){
                    fax.Enrollment_Duration__c = 1
                    fax.Device_Source__c = 'MTP'
                    fax.Service_Type__c = 'INR'
                }
                console.log(JSON.stringify(fax))
                cmp.set("v.fax", fax);
            }
        });
        $A.enqueueAction(action);
    },

    getFeatureFlagHelper : function(cmp, recTypeId) { 
        console.log('in h.getFeatureFlagHelper'); 
        var state;
        var action = cmp.get("c.getFeatureFlag");

        action.setParams({
            "recordTypeId": recTypeId
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                let draftEnrollmentFeature = response.getReturnValue();
                cmp.set("v.draftEnrollmentFeature", draftEnrollmentFeature);
            }
        });
        $A.enqueueAction(action);
    },    

    getOtsBundleHelper : function(c, e, h) {

        let backendId = c.get("v.plBackendId");
        let serviceType = c.get("v.fax.Service_Type__c");

        console.log('in h.getOtsBundleHelper backendId '+ backendId);

        if(backendId != null && serviceType != null && serviceType != 'INR'){
            var state;
            var action = c.get("c.callOtsBundleApi");
    
            action.setParams({
                "backendId": backendId,
                "serviceType": serviceType
             });        
    
            action.setCallback(this, function(response) {
                state = response.getState();
                if (state === "SUCCESS") { 
                    var bundle = response.getReturnValue();
                    
                    //sort begin
                    var field = 'DeviceTypeName';
                    var sortAsc = true;
                    bundle.sort(function(a,b){
                        var t1 = a[field] == b[field],
                            t2 = (!a[field] && b[field]) || (a[field] < b[field]);
                        return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
                    });
                    //sort end
                    c.set("v.otsBundle", bundle);                 
                    console.log('xxx bundle ' + JSON.stringify(bundle));
                }
            });
            $A.enqueueAction(action);
    
        }
    },    

    checkForChanges: function(cmp) {  

        console.log('in h.checkForChanges');    
    },

    getConfirmationNumberHelper : function(cmp, event, helper) { 

        let submissionId = cmp.get("v.fax.Submission_Id__c");

        console.log('in h.getConfirmationNumberHelper submissionId '+ submissionId);


        if(submissionId != null && submissionId != 'Pending'){
            console.log('in h.getConfirmationNumberHelper in if ');
            var state;
            var action = cmp.get("c.getConfirmationNbr");
    
            action.setParams({
                "submissionId": submissionId,
                "recordId": cmp.get("v.recordId")

             });        
    
             console.log('in h.getConfirmationNumberHelper after set parms ');

             action.setCallback(this, function(response) {
                state = response.getState();
                if (state === "SUCCESS") { 
                    console.log('in h.getConfirmationNumberHelper SUCCESS ' + response.getReturnValue());
                    this.hideSpinner(cmp);
                    let resp = response.getReturnValue() ? response.getReturnValue().split(',') : [] ;
                    let responseType = resp[0];
                    let responseNumber = resp.length > 1 ? resp[1] : 'ERROR';
                    let recordId =  resp.length > 2 ? resp[2] : null;
                    var message;
                    var messageType;
                    var mode; 
                    var title;
                    console.log('xxx responseNumber.length '+ responseNumber.length);
                    console.log('xxx responseNumber '+ responseNumber);

                    let encounterCounter = cmp.get("v.encounterCounter"); 
                    encounterCounter = encounterCounter + 1;
                    cmp.set("v.encounterCounter",encounterCounter);
                    console.log('xxx responseType '+ responseType);
                    if(responseType == 'Encounter Number' || responseType == 'Enrollment Number'){ 
                        if(responseType == 'Encounter Number'){ 
                            cmp.set("v.fax.Encounter_Number__c", responseNumber);
                        }else{
                            cmp.set("v.fax.Enrollment_Number__c", responseNumber);

                        }
                        message = 'The '+ responseType +' is: ' + responseNumber;
                        messageType = 'success';
                        mode = 'sticky'; 
                        title = 'Success!';
                        this.goToRec(recordId)
     
                    } else {
                        if(encounterCounter > 3){
                            message = 'Error: '+ responseType +'. Please try again later';
                            messageType = 'error';
                            mode = 'sticky';
                            title = 'Error!';  
                        }else{
                            message = 'Error: '+ responseType +'. Trying again ' + encounterCounter + ' of 3 times';
                            messageType = 'error';
                            mode = 'dismissible';
                            title = 'Error!'; 
                        }

                    }              
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({ 
                         "title": title,
                         "message": message,
                         "type": messageType,
                         "mode": mode
                     });
                     toastEvent.fire();
                     if(encounterCounter < 4 && responseNumber == 'ERROR'){
                        setTimeout(
                            $A.getCallback(function() {
                                helper.getFaxEnrollment(cmp, event, helper)
                            }), 5000
                        );
                    }


                } else{
                    console.log('xxx FAIL ' +response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
    
        }
    },     

    //get physician list
    getPhysicianHelper : function(c, e, h) {

        let backendId = c.get("v.plBackendId");
 
        console.log('in h.getPhysicianHelper backendId '+ backendId);
        if(backendId != null){
            var state;
            var action = c.get("c.callPhysicianApi");
    
            action.setParams({
                "backendId": backendId
             });        
    
            action.setCallback(this, function(response) {
                state = response.getState();
                if (state === "SUCCESS") { 
                    var physician = response.getReturnValue();

                    //sort begin
                    var field = 'Lastname';
                    var sortAsc = true;
                    physician.sort(function(a,b){
                        var t1 = a[field].toUpperCase() == b[field].toUpperCase(),
                            t2 = (!a[field].toUpperCase() && b[field].toUpperCase()) || (a[field].toUpperCase() < b[field].toUpperCase());
                        return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
                    });
                    //sort end

                    c.set("v.physician", physician);
                }
            });
            $A.enqueueAction(action);
    
        }
    },   
    //get physician list end
    
    getPLbackendIdHelper : function(c, e, h) {
        console.log('in h.getPLbackendIdHelper');
        var state;
        var action = c.get("c.getPLBackendId");

        action.setParams({
            "recordId": c.get("v.fax.Practice_Location__c")
         });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                var backendId = response.getReturnValue();
                c.set("v.plBackendId", backendId);

                var physician = c.get("v.physician");
                if(backendId != null && physician.length == 0){
                    this.getPhysicianHelper(c, e, h);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    onSubmitHelper : function(c, e, h) {
        console.log('in h.onSubmitHelper');

        var state;
        let fax = c.get("v.fax");
        console.log('in h.onSubmitHelper ' + JSON.stringify(fax));

        let draft = c.get("v.draft") ? c.get("v.draft") : false

        console.log('fax2');
         console.log('data---->'+fax.above__c);
        console.log('xxx draft ' + draft)
        if(!draft){
            c.set("v.isInrRequiredFields", true)
            c.set("v.isRequiredFields", true)
        }

        delete fax.Practice_Location__r;
        delete fax.Ordering_Physician__r;
        delete fax.Billing_Postal_Code__r;
        delete fax.Notifying_Physician__r;
        delete fax.Shipping_Postal_Code__r;
        delete fax.Diagnosis_Code__r;
        delete fax.Diagnosis_Code_2__r;
        delete fax.Diagnosis_Code_3__r;
        delete fax.Diagnosis_Code_4__r;
        delete fax.Billing_Status__r;

        //2019-04-29T00:00:00.000Z
        if(fax.Patient_Date_of_Birth__c && fax.Patient_Date_of_Birth__c.includes("/")){
            fax.Patient_Date_of_Birth__c =  moment(fax.Patient_Date_of_Birth__c ).format('YYYY-MM-DD');
        }
        if(fax.Visit_Date__c.includes("/")){
            fax.Visit_Date__c =  moment(fax.Visit_Date__c ).format('YYYY-MM-DD');
        }
        console.log('fax date--->'+fax.Fax_Date__c);
        if( fax.Fax_Date__c && fax.Fax_Date__c != '' && fax.Fax_Date__c !='undefined'){
            if(fax.Fax_Date__c.includes("/")){
            fax.Fax_Date__c =  moment(fax.Fax_Date__c ).format('YYYY-MM-DD');
            }
        }
        if(fax.OTS_Device__c != null){
            let ots = c.get("v.otsBundle");
            let ot = ots.find(x => x.Id == fax.OTS_Device__c);
            if(ot){
                fax.Event_Device_Type__c = ot.DeviceTypeId;
                fax.OTS_Device_Name__c = ot.DeviceTypeName + ' - ' + ot.DeviceSerialNumber;
            }
        }

        var draftReasonSelected = c.get("v.draftReasonSelected");
        fax.Draft_Reason__c = draftReasonSelected;
        if(fax.Draft_Reason__c != '[]' && fax.Draft_Reason__c != null && fax.Draft_Reason__c != '' && fax.Draft_Reason__c !='undefined'){
            
            var sp = fax.Draft_Reason__c;
            var faxdraft='';
            for(var i =0;i<sp.length;i++){
                faxdraft =faxdraft+sp[i]+';';
            }
            faxdraft = faxdraft.substring(0, faxdraft.length - 1);
            fax.Draft_Reason__c = faxdraft;
            console.log(fax.Draft_Reason__c);
            console.log('draft reason--->'+fax.Draft_Reason__c);
        } else {
            fax.Draft_Reason__c = null
        }
        let sFax = JSON.stringify(fax);
        var action = c.get("c.saveRec"); 
       this.showSpinner(c);

        action.setParams({
           "fax": sFax,
           "draft" : draft
        });

        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
               this.hideSpinner(c);
               console.log('SUCCESS ' );

               var result = response.getReturnValue();
               var message;
               var messageType;
               var mode; 
               var title;
               console.log('SUCCESS ' + JSON.stringify(result));
               if(result && result.length == 18){
                message = 'Draft saved successfully'; 
                messageType = 'success';
                mode = 'dismissible'; 
                title = 'Success!';
                c.set("v.recordId", result); 
               } else if(result.length == 54){ 
                   message = 'Fax Submission was successful.'; 
                   messageType = 'success';
                   mode = 'dismissible'; 
                   title = 'Success!';
                   
                   c.set("v.fax.Submission_Id__c", result.substring(18, 54));
                   c.set("v.recordId", result.substring(0, 18)); 
                   this.goToRec(result.substring(0, 18)) 
               } else {
                   console.log('xxx message '+ result);
                    if(result!= null && result.includes("error occurred while executing the command definition")){
                        message = 'Unable to submit enrollment. Please try again later.';
                    }else{
                        message = result.replace(/:/g, "\n      ")
                    }

                   messageType = 'error'; 
                   mode = 'sticky';
                   title = 'Error!'; 
               }              
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({ 
                    "title": title,
                    "message": message,
                    "type": messageType,
                    "mode": mode
                });
                toastEvent.fire();
            } else {
                this.hideSpinner(c);
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                if (errors) {
                    if (errors) {
                        errors.forEach( function (error){
                            if (error.message){
                                h.toastThis(error.message);					
                            }
                            if (error.pageErrors){
                                error.pageErrors.forEach( function(pageError) {
                                    h.toastThis(pageError.message)						
                                });					
                            }
                            if (error.fieldErrors){
                                for (var fieldName in error.fieldErrors) {
                                    error.fieldErrors[fieldName].forEach( function (errorList){	
                                        h.toastThis(errorList.message, "Field Error on " + fieldName + " : ")							
                                    });                                
                                };  					
                            } 
                        }); 
                    }
            
                } else {
                    this.showToastError('Unknown error');
                }                    
            }
        });
        $A.enqueueAction(action);
    },

    goToRec : function(recordId) {
        
  
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId,
          "slideDevName": "detail"
        });
        navEvt.fire();        
  
    },

    showSpinner : function(c) {
        console.log('in h.showSpinner');
        c.set("v.dataLoaded", false);
        $A.util.removeClass(
            c.find('spinner'), 
            "slds-hide"
        );
        console.log('done with h.showSpinner');
    },
    
    hideSpinner : function(c) {
        console.log('in h.hideSpinner');
        $A.util.addClass(
            c.find('spinner'), 
            "slds-hide"
        );
        c.set("v.dataLoaded", true);
    },

	toastThis : function(message, title) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title || "Error:",
			"message": message,
			"type": "error",
			"mode": "sticky"
		});
		toastEvent.fire();
	},                    
    showToast: function(message, type, title, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type,
            mode
        });
        toastEvent.fire();
    },
    showToastError: function(errors) {
        console.log(errors);
        if (errors) {
            errors.length == 1 ? this.showToast(errors[0].message, 'error', 'Error', 'sticky') : this.showToast(errors, 'error', 'Error', 'sticky');
        } else {
            this.showToast('Unknown error, contact support', 'error', 'Error', 'dismissible');
        }
    },

    errorToast : function(c, message) {
        c.set("v.inError","true");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({ 
            "title": 'Error:',
            "message": message,
            "type": 'error',
            "mode": 'dismissible'
        });
        toastEvent.fire();                 
        c.set("v.inError","true");  
    },

    closeModal : function (c, e, h){
        c.set("v.storedRecTypeId", c.get("v.recTypeId"));
        c.set("v.isModalOpen", false);
    },
     onSubmitData : function(c, e, h) {
        let allValid = true;
        let isValid = true;
        let isINR = c.get("v.isInrRecordType")

        let sameAsBilling = c.get("v.sameAsBilling"); 
        let fax = c.get("v.fax");
        if(sameAsBilling){

            if((fax.Shipping_Street__c == null || fax.Shipping_Street__c == "") && fax.Billing_Street__c != null){
                fax.Shipping_Street__c = fax.Billing_Street__c; 
            }
            if((fax.Shipping_Street_2__c == null || fax.Shipping_Street_2__c == "") && fax.Billing_Street_2__c != null){
                fax.Shipping_Street_2__c = fax.Billing_Street_2__c; 
            }
            if((fax.Shipping_City__c == null || fax.Shipping_City__c == "") && fax.Billing_City__c != null){
                fax.Shipping_City__c = fax.Billing_City__c; 
            }
            if((fax.Shipping_State__c == null || fax.Shipping_State__c == "") && fax.Billing_State__c != null){
                fax.Shipping_State__c = fax.Billing_State__c; 
            }
            if((fax.Shipping_Postal_Code__c == null || fax.Shipping_Postal_Code__c == "") && fax.Billing_Postal_Code__c != null){
                fax.Shipping_Postal_Code__c = fax.Billing_Postal_Code__c; 
            }
        }
        var message;
        console.log('xxx fax '+ JSON.stringify(fax));
        var pcLocation = c.find("pcLocation");
        var diagnosis = c.find("diagnosis");
        var billingStatus = c.find("billingStatus");
        var zipCode = c.find("zipCode");
        let draftEnrollmentFeature = c.get("v.draftEnrollmentFeature")
        pcLocation.checkForBlanks();
        diagnosis.checkForBlanks();
        billingStatus.checkForBlanks();
        zipCode.checkForBlanks();
        if(!sameAsBilling){
            var shippingZipCode = c.find("shippingZipCode");
            shippingZipCode.checkForBlanks();
        }
        if(fax.Practice_Location__c == ""  || fax.Practice_Location__c == null){
            allValid = false;
        }       
        if(fax.Diagnosis_Code__c == ""  || fax.Diagnosis_Code__c == null){
            console.log('xxx in diag edit if');
            allValid = false;
        }        
        if(!draftEnrollmentFeature && (fax.Billing_Status__c == ""  || fax.Billing_Status__c == null)){
            allValid = false;
        }        
        if(fax.Billing_Postal_Code__c == ""  || fax.Billing_Postal_Code__c == null){
            allValid = false;
        }        
        if(fax.Shipping_Postal_Code__c == ""  || fax.Shipping_Postal_Code__c == null){
            allValid = false;
        } 

        var faxDate = c.find("faxDate");
        var faxDateValue    = faxDate.get('v.value');

        if(faxDateValue == null || faxDateValue == '' || !moment(faxDateValue, 'YYYY-MM-DD', true).isValid()){
            faxDate.set("v.errors", [{message:"Complete this field."}]);
            allValid = false;
        }        

        var dobDate = c.find("dobDate");
        var dobDateValue    = dobDate.get('v.value');
        
        console.log('dobDateValue before if '+ dobDateValue);

        if(dobDate == null || dobDate == '' || dobDateValue == null || dobDateValue == ''){
            dobDate.set("v.errors", [{message:"Complete this field."}]);
            allValid = false;
        } else if(dobDateValue.includes('-') && moment(dobDateValue, 'YYYY-MM-DD', true).isValid()){
            dobDate.set("v.errors", null);
        }else if(dobDateValue == null || dobDateValue == ''  || !moment(dobDateValue, 'MM/DD/YYYY', true).isValid()){
            console.log('IN ELSE FAIL');
            dobDate.set("v.errors", [{message:"Complete this field."}]);
            allValid = false;
        }else{
            dobDate.set("v.errors", null);
        }        

        var homePhone = c.find("homePhone");
        if(fax.Patient_Home_Phone__c != null){
            if(fax.Patient_Home_Phone__c.length != 12 || fax.Patient_Home_Phone__c.substring(3, 4) != '-'  || fax.Patient_Home_Phone__c.substring(7, 8) != '-'){
                allValid = false;
            }
        }else{
            homePhone.set('v.validity', {valid:false, badInput :true});
            homePhone.showHelpMessageIfInvalid();
            allValid = false;
        }

        var cellPhone = c.find("cellPhone");
        if(fax.Patient_Cell_Phone__c != null && fax.Patient_Cell_Phone__c != ''){
            if(fax.Patient_Cell_Phone__c.length != 12 || fax.Patient_Cell_Phone__c.substring(3, 4) != '-'  || fax.Patient_Cell_Phone__c.substring(7, 8) != '-'){
                cellPhone.set('v.validity', {valid:false, badInput :true});
                cellPhone.showHelpMessageIfInvalid();
                allValid = false;
            }
        }
         var workPhone = c.find("workPhone");
         if(fax.Patient_Work_Phone__c != null && fax.Patient_Work_Phone__c != ''){
            if(fax.Patient_Work_Phone__c.length != 12 || fax.Patient_Work_Phone__c.substring(3, 4) != '-'  || fax.Patient_Work_Phone__c.substring(7, 8) != '-'){
                workPhone.set('v.validity', {valid:false, badInput :true});
                workPhone.showHelpMessageIfInvalid();
                allValid = false;
            }
        }

        var resultPhone = c.find("resultPhone");
        if(fax.Results_Phone__c != null && fax.Results_Phone__c != ''){
           if(fax.Results_Phone__c.length != 12 || fax.Results_Phone__c.substring(3, 4) != '-'  || fax.Results_Phone__c.substring(7, 8) != '-'){
                resultPhone.set('v.validity', {valid:false, badInput :true});
                resultPhone.showHelpMessageIfInvalid();
                allValid = false;
           }
       }
       var resultFax = c.find("resultFax");
       if(fax.Results_Fax_Number__c != null && fax.Results_Fax_Number__c != ''){
          if(fax.Results_Fax_Number__c.length != 12 || fax.Results_Fax_Number__c.substring(3, 4) != '-'  || fax.Results_Fax_Number__c.substring(7, 8) != '-'){
                resultFax.set('v.validity', {valid:false, badInput :true});
                resultFax.showHelpMessageIfInvalid();
              allValid = false;
          }
      }               

        isValid = c.find('formId').reduce(function (validSoFar, inputCmp) { 

            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
 
        if ((allValid && isValid) || c.get("v.isRequiredDraft")) {
            this.onSubmitHelper(c, e, h);
        } else {
            this.errorToast(c, 'One or more required fields are blank or in error');
        }

    },
    getData : function(c, actionName, params, attributeName) {
        var action = c.get(actionName);
        
        if(params) {
            action.setParams(params);
        }
        
        action.setStorable();            
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                c.set(attributeName, response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
            } else {
            }
        });
        
        $A.enqueueAction(action);		
    },     
})