public inherited sharing class ClosePatientCases {

    @InvocableMethod(label='Close Patient Cases')
    public static void execute(List<Id> ids) {
        Id patientInteractionRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();

        List<Case> cases = [
                    SELECT Id, Case_Reason_Lookup__r.External_Id__c, Order__r.Activation_Workflow_Status__c 
                      FROM Case
                     WHERE ParentId IN :ids 
                       AND Status = 'New'
                       AND RecordTypeId = :patientInteractionRT
                       AND Case_Reason_Lookup__c != null
                       AND Order__c != null  
                       AND (
                           (Case_Reason_Lookup__r.External_Id__c IN ('a0Q0R000003cbkUUAQ','a0Q0R000003cbkWUAQ') AND Order__r.Activation_Workflow_Status__c IN ('Awaiting Activation','Awaiting Baseline','Activation Complete','Stopped'))
                        OR 
                            (Case_Reason_Lookup__r.External_Id__c = 'a0Q0R000003bqUgUAI' AND Order__r.Activation_Workflow_Status__c = 'Stopped')
                        )                    
                       
        ];

        for(Case c : cases){ switch on c.Order__r.Activation_Workflow_Status__c{
                when 'Awaiting Activation'  { c.Status = 'Closed - Automation';  c.Closed_Result__c = 'Replaced with new case'; } when 'Awaiting Baseline' { c.Status = 'Closed - Automation';c.Closed_Result__c = 'Replaced with new case'; } when 'Activation Complete' { c.Status = 'Closed - Automation';  c.Closed_Result__c = 'Baseline Received'; } when 'Stopped' { c.Status = 'Closed - Automation'; c.Closed_Result__c = 'Enrollment Cancelled'; } }
        } UPDATE cases;

    }
}