public with sharing class BillingHandler {
    public BillingHandler() {

    /*    
        List<Order> InrWorkflowStatusCovered = new List<Order>();
        when  'InrWorkflowStatusCovered' {
            InrWorkflowStatusCovered.add(orderMap.get(q.Order_Id__c));
        }   
        if(InrWorkflowStatusCovered.size() > 0)
            processInrWorkflowStatusCovered(InrWorkflowStatusCovered);    
    
    private static void processInrWorkflowStatusCovered(List<Order> orders){
        List<Case> cases = new List<Case>();

        List<Group> queue = [
            SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'Financial_Responsibility_Calls' 
        ];
        String queueName =  queue[0].Id;

        Id psrt    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        for(Order order : orders){
            Case c = new Case(
                RecordTypeId = psrt,
                OwnerId = queueName,
                Order__c = order.Id,
                Status = 'New',
                Origin = 'Phone',
                Priority = 'Medium',
                AccountId = order.AccountId
            );
            cases.add(c);
        }
        INSERT cases;
        System.debug('xxx OrderAutomationHandler processInrWorkflowStatusCovered cases '+ cases);

    }     */
    
    }
    
    
}