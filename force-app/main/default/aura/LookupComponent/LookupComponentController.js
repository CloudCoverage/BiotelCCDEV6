({
    searchField : function(component, event, helper) {
        console.log('xxx in searchField');
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBox');
        component.set("v.LoadingText", true);
        if(currentText.length > 2) {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }
        var action = component.get("c.getZipResults");
        console.log('xxx in searchField 111 > '+ currentText);
        action.setParams({
            "ObjectName" : component.get("v.objectName"),
            "fieldName" : component.get("v.fieldName"),
            "value" : currentText
        });
        console.log('xxx in searchField 222');

        action.setCallback(this, function(response){
            var STATE = response.getState();
            console.log('xxx in searchField 3333 > ' + currentText);

            if(STATE === "SUCCESS") {
                let responseArray = response.getReturnValue();
                component.set("v.sResult", responseArray);
                console.log('xxx responseArray > '+ JSON.stringify(responseArray))
                component.set("v.searchRecords", response.getReturnValue());
                if(component.get("v.searchRecords").length == 0) {
                    console.log('000000');
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.LoadingText", false);
        });
        
        $A.enqueueAction(action);
    },
    
    setSelectedRecord : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        let searchRecords = component.get("v.searchRecords");
        $A.util.removeClass(resultBox, 'slds-is-open'); 
        //component.set("v.selectRecordName", currentText);
        for(var i = 0; i < searchRecords.length; i++){
            console.log('xxx bbb '+ JSON.stringify(searchRecords[i]));
            if(searchRecords[i].Id == currentText){
                console.log('xxx ccc '+ JSON.stringify(searchRecords[i]));
                component.set("v.selectField1", searchRecords[i].City__c);                
                component.set("v.selectField2", searchRecords[i].State__c);                
            }
            console.log('xxx ccc v.selectField1' + component.get("v.selectField1"));
            console.log('xxx ccc v.selectField2' + component.get("v.selectField2"));
    
        }

        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", currentText);
        component.find('userinput').set("v.readonly", true);
    }, 
    
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.set("v.selectField1", "");
        component.set("v.selectField2", "");
        component.find('userinput').set("v.readonly", false);
    },
    checkBlank : function(component, event, helper) {
        console.log('xxx lookupController checkBlank');
        var inputField = component.find('userinput'); 
        var value = inputField.get('v.value');
        if(value == null || value == '') {
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
        }
    }    
})