({
    handleRecord : function(component, event, helper) {
        console.log('in handleRecord ')
        console.log('in handleRecord ' + JSON.stringify(component.get("v.record")))
        let rec = component.get("v.record")
        let showGreen = false
        let showRed = false

        if(rec.Order__c){
            if(rec.Order__c && rec.Order__r.Activation_Workflow_Status__c == 'Stopped'){
                showGreen = true
            } 
    
            if(rec.Order__c && rec.Order__r.Activation_Workflow_Status__c == 'Awaiting Shipment' || rec.Order__r.Activation_Workflow_Status__c == 'Awaiting Activation' || rec.Order__r.Activation_Workflow_Status__c == 'Awaiting Baseline'){
                showRed = true
            }
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