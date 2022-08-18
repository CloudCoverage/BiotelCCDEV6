public without sharing class CaseButtonsController {
    @AuraEnabled
    public static String MakeCallOut(String recordId, String orderId, String backendId, String process, Boolean agency, String cancelReason, String cancelReasonOther) {
        System.debug('xxx MakeCallOut ' + orderId);
        System.debug('xxx process ' + process);
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String response;

        if(process == 'reverseCancellation'){
            if(!mockMiddlewareResponse())
                response = MiddlewareUtil.RestartActivationProcess(backendId, userName);  
            else    
                response = 'Successful';  // TEMPFORTESTING

            if(response.contains('Successful')){
                Case c = new Case();
                c.Id = recordId;
                c.Bypass_Validation_for_Process_Builder__c = true;
                update c;
               // c.Activation_AD_Enabled__c = !agency;
                c.Status = 'Reinstating';
                if(mockMiddlewareResponse()) c.Status = 'Awaiting Baseline'; // TEMPFORTESTING
                c.Cancellation_Reason_picklist__c = null;
                c.Cancellation_Reason__c = null;
                c.Button_Disabled__c = true;                
                System.debug('xxx reverseCancellation case ' + c);
                Update c;
                c = new Case();
                c.Id = recordId;
                c.Bypass_Validation_for_Process_Builder__c = false;
                Update c;  
                
                Order o = new Order();
                o.Id = orderId;
                o.Button_Disabled__c = true;                
                if(mockMiddlewareResponse()) o.Activation_Workflow_Status__c = 'Awaiting Baseline'; // TEMPFORTESTING
                update o;

                List<Id> ids = new List<Id>();
                ids.add(c.Id);
                ActivationWorkflowHelper.createReverseCancellationPIC(ids);                 
            }

        } else if(process == 'cancelOrder'){
            if(!mockMiddlewareResponse())
                response = MiddlewareUtil.CancelEnrollment(backendId, userName);
            else
                response = 'Successful';  // TEMPFORTESTING

             if(response.contains('Successful')){
                Case c = new Case();
                c.Id = recordId;
                c.Bypass_Validation_for_Process_Builder__c = true;
                update c; 

                Order o = new Order(); 
                o.Id = orderId; 
                o.Button_Disabled__c = true;
                if(cancelReason != null){
                    o.Cancellation_Reason__c = cancelReason;
                    if(cancelReason == 'Other'){
                        o.Other_Cancellation_Reason__c = cancelReasonOther;
                    } else {
                        o.Other_Cancellation_Reason__c = null;
                    }
                }
                if(mockMiddlewareResponse()) o.Activation_Workflow_Status__c = 'Stopped'; // TEMPFORTESTING
                System.debug('xxxa o '+ o);
                update o; 
                System.debug('xxxa o '+ o);


                c.Button_Disabled__c = true;
               // c.Activation_AD_Enabled__c  = false;
                c.Status = 'Cancelling';
                c.Closed_Result__c = 'N/A';
                if(cancelReason != null){
                    c.Cancellation_Reason_picklist__c = cancelReason;
                    if(cancelReason == 'Other'){
                        c.Cancellation_Reason__c = cancelReasonOther;
                    } else {
                        c.Cancellation_Reason__c = null;
                    }
                }

                System.debug('xxxa cancelOrder Case ' + C);
                Update c;
                System.debug('xxxa cancelOrder Case ' + C);
                c = new Case();
                c.Id = recordId;
                c.Bypass_Validation_for_Process_Builder__c = false;
                Update c;                


             }
         }

        return response;       
    }

    public static Boolean mockMiddlewareResponse(){
        String instance = UserInfo.getUserName().substringAfterLast('.').toUpperCase();
        if(instance == 'CCDEV4')
            return true;
        else
            return false;
    }
        
}