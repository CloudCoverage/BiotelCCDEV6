({
    makeCalloutHelper : function(c, e, h, process) {
        console.log('makeCalloutHelper begin ' + c.get("v.recordId"))
        console.log('makeCalloutHelper process ' + process)
        c.set("v.isLoaded", false)
        var state;
        var action = c.get("c.MakeCallOut");
        let record = c.get("v.record")
        console.log('makeCalloutHelper caseId ' + record.Activation_Workflow_Case__c)
        var caseId
        var agency
        if(record.Activation_Workflow_Case__c){
            caseId = record.Activation_Workflow_Case__c
            agency = record.Activation_Workflow_Case__r.Agency_Requested__c
        }


        action.setParams({
            "recordId": c.get("v.recordId"),
            "caseId": caseId,
            "backendId": record.Enrollment_Backend_ID__c,
            "process": process,
            "agency" : agency,
            "cancelReason" : c.get("v.cancelReason"),
            "cancelReasonOther" : c.get("v.cancelReasonOther")
         });        

        console.log('after action ' + action.getParams());
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                var resp = response.getReturnValue();
                console.log('xxx Response '+ resp);
                if(resp.includes('Success')){
                    this.showToast(resp, 'Success', 'Success', null);
                    c.set("v.buttonPressed", true)
                    let rec = c.get("v.record")
                    console.log('xxx rec '+ JSON.stringify(rec));
                    rec.Button_Disabled__c = true;
                    c.set("v.record", rec)
                    //$A.get('e.force:refreshView').fire();
                } else {
                    this.showToast(resp, 'error', 'Error', 'sticky');
                }
                c.set("v.isLoaded", true)
            } else if (state === "ERROR") {
                var message = ''
                var errors = response.getError();
                console.log(JSON.stringify(errors))
                if (errors) {
                    for(var i=0; i < errors.length; i++) {
                        for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                        }
                        if(errors[i].fieldErrors) {
                            for(var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                message += (message.length > 0 ? '\n' : '') + fieldError;
                                for(var j=0; j < thisFieldError.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].statusCode;
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if(errors[i].message) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                } else {
                    message += (message.length > 0 ? '\n' : '') + 'Unknown error';
                }
                this.showToastError(message);
                c.set("v.isLoaded", true)
            } 
        });
        $A.enqueueAction(action);

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
})