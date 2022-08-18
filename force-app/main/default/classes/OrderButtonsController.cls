public without sharing class OrderButtonsController {
    @AuraEnabled
    public static String MakeCallOut(String recordId, String caseId, String backendId, String process, Boolean agency, String cancelReason, String cancelReasonOther) {
        System.debug('xxx MakeCallOut ' + recordId);
        System.debug('xxx process ' + process);
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String response;
        List<Id> ids = new List<Id>();

        if(process == 'reverseCancellation'){ 
            if(!mockMiddlewareResponse())
                response = MiddlewareUtil.RestartActivationProcess(backendId, userName);  
            else    
                response = 'Successful';  // TEMPFORTESTING

            System.debug('xxx aaa response ' + response);    
            if(response.contains('Successful')){
                System.debug('xxx aaa caseId ' + caseId);    
                if(caseId != null){
                    Case c = new Case();
                    c.Id = caseId;
                    c.Bypass_Validation_for_Process_Builder__c = true;
                    update c;

                    //c.Activation_AD_Enabled__c = !agency;
                    c.Status = 'Reinstating';
                    c.Cancellation_Reason_picklist__c = null;
                    c.Cancellation_Reason__c = null;
                    c.Button_Disabled__c = true;

                    System.debug('xxx reverseCancellation case ' + c);
                    Update c;
                    ids.add(c.Id);

                }
    
                Order o = new Order();
                o.Id = recordId;
                o.Button_Disabled__c = true;
                if(mockMiddlewareResponse())
                    o.Activation_Workflow_Status__c = 'Awaiting Activation'; // TEMPFORTESTING
                update o;

                if(caseId != null){
                    Case c = new Case();
                    c.Id = caseId;
                    c.Bypass_Validation_for_Process_Builder__c = false;
                    Update c;
                    ActivationWorkflowHelper.createReverseCancellationPIC(ids);
                } else {
                    ActivationWorkflowHelper.createReverseCancellationPICFromOrder(o.Id);
                }
            }

        } else if(process == 'cancelOrder'){
            if(!mockMiddlewareResponse())
                response = MiddlewareUtil.CancelEnrollment(backendId, userName);
            else
                response = 'Successful';  // TEMPFORTESTING

             if(response!= null && response.contains('Successful')){
                Case c = new Case();
                if(caseId != null){
                    c.Id = caseId;
                    c.Bypass_Validation_for_Process_Builder__c = true;
                    update c;
                }

                Order o = new Order(); 
                o.Id = recordId; 
                if(cancelReason != null){
                    o.Cancellation_Reason__c = cancelReason;
                    if(cancelReason == 'Other'){
                        o.Other_Cancellation_Reason__c = cancelReasonOther;
                    } else {
                        o.Other_Cancellation_Reason__c = null;
                    }
                }
                if(mockMiddlewareResponse())
                    o.Activation_Workflow_Status__c = 'Stopped'; // TEMPFORTESTING
                //o.Activation_AD_Enabled__c  = false;
                o.Button_Disabled__c = true;
                System.debug('xxxxxxxxxxxxxxxxxxx o '+ o);
                update o;

                if(caseId != null){
                    c.Id = caseId;
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
                    System.debug('xxx cancelOrder Case ' + C);
                    Update c;
                    System.debug('xxx cancelOrder Case ' + C);
                    c = new Case();
                    c.Id = caseId;
                    c.Bypass_Validation_for_Process_Builder__c = false;
                    Update c;                        
                }
        
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