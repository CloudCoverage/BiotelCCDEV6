({
    searchField : function(component, event, helper) {
        console.log('xxx lookupController searchfields');
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBox');
        var objectName = component.get("v.objectName");
        component.set("v.LoadingText", true);
        //console.log('xxx lookupController objectName ' + objectName);
        //console.log('xxx lookupController currentText.length ' + currentText.length);
        if((currentText.length > 1) || (objectName == 'Billing_Status__c' && currentText.length > 0)) {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }
        var action = component.get("c.getResults");
        action.setParams({
            "ObjectName" : component.get("v.objectName"),
            "fieldName" : component.get("v.fieldName"),
            "moreWhere" : component.get("v.moreWhere"),
            "value" : currentText
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                component.set("v.searchRecords", response.getReturnValue());
                if(component.get("v.searchRecords").length == 0) {
                    console.log('000000');
                }
            }
            else if (STATE === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("xxx Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("xxx Unknown error");
                }
            }
            component.set("v.LoadingText", false);
        });
        
        $A.enqueueAction(action);
    },

    
    setSelectedRecord : function(component, event, helper) {
         console.log('xxx lookupController setSelectedRecord');
       
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        var label = component.get("v.Label");
        $A.util.removeClass(resultBox, 'slds-is-open');
        //component.set("v.selectRecordName", currentText);
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", currentText);
        component.find('formId').set("v.readonly", true);

        console.log('xxx label '+ label);
        console.log('xxx lookupEvent.setparms');
        //if(label == 'Practice Location'){
            var lookupEvent = component.getEvent("lookupEvent");
            lookupEvent.setParams({
                "objectName" : component.get("v.objectName"),
                "fieldName" : component.get("v.fieldName"),
                "selectRecordId" : currentText,
                "label" : label
            });
            console.log('xxx lookupEvent before fire');
            lookupEvent.fire();        
            console.log('xxx lookupEvent after fire');
        //}

    }, 
    
    resetData : function(component, event, helper) {
        console.log('xxx lookupController resetData');
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.find('formId').set("v.readonly", false);
    },
    checkBlank : function(component, event, helper) {
        console.log('xxx lookupController checkBlank');
        var inputField = component.find('formId');
        var value = inputField.get('v.value');
        if(value == null || value == '') {
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
        }
    }

})