({
    handleRecord : function(component, event, helper) {
        console.log('in handleRecord ')
        console.log('in handleRecord ' + JSON.stringify(component.get("v.record")))
        let rec = component.get("v.record")
        let showGreen = false
        let showRed = false
        if(rec.Activation_Workflow_Status__c == 'Stopped'){
            showGreen = true
        } 
        let validAtivationWorkflowStatus = rec.Activation_Workflow_Status__c == 'Awaiting Shipment' || rec.Activation_Workflow_Status__c == 'Awaiting Activation' || rec.Activation_Workflow_Status__c == 'Awaiting Baseline'
        let validSorianScenerio = rec.Service_Type__c == 'MCT' && rec.Activation_Workflow_Status__c == null && rec.Business_Model__c != 7 && rec.Device_Source__c == 'MTP'
        if(validAtivationWorkflowStatus || validSorianScenerio){
            showRed = true
        }
        console.log('showGreen ' + showGreen)
        console.log('showRed ' + showRed)
        
        component.set("v.showRed", showRed)
        component.set("v.showGreen", showGreen)
        
        component.set("v.isLoaded", true)


    },
    reverseCancellation : function(component, event, helper) {
        console.log('in h.reverseCancellation')
        component.set("v.cancelReason", "")
        component.set("v.cancelReasonOther", "")
        helper.makeCalloutHelper(component, event, helper, 'reverseCancellation')
    },
    cancelOrder : function(component, event, helper) {
        console.log('in h.reverseCancellation')
        if(component.get("v.cancelReason")){
            helper.makeCalloutHelper(component, event, helper, 'cancelOrder')
        } else {
            helper.showToastError('Please enter a Cancellation Reason')
        }
    },
})