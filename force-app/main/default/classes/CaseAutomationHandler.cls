public with sharing class CaseAutomationHandler {
    final List<Case_Automation__e> newRecords;
    final List<Case_Automation__e> oldRecords;
    final Map<Id, Case_Automation__e> newMap;
    final Map<Id, Case_Automation__e> oldMap;
    public Map<Id, Case> caseMap;
    public Map<Id,Reimbursement_Mapping__c> bills;
    public Map<Id,Order> orders;
    public Map<Id,Case> parentCases;

    public CaseAutomationHandler(List<Case_Automation__e> newRecords, List<Case_Automation__e> oldRecords,Map<Id, Case_Automation__e> newMap, Map<Id, Case_Automation__e> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap = newMap;
        this.oldMap = oldMap;
        caseMap =  new Map<Id, Case>();
        bills = new Map<Id,Reimbursement_Mapping__c>();
        orders = new Map<Id,Order>();
        parentCases = new Map<Id,Case>();
    }

    public void afterInsert() {
        processCaseAutomationRecords();   
    }
    private void processCaseAutomationRecords(){
        Set<Id> caseIds = new Set<Id>();
        for(Case_Automation__e evnt : newRecords){ 
            if(evnt.Case_Id__c != null){
                caseIds.add(evnt.Case_Id__c);
            }
        }

        for(Case c : [
            SELECT Id, Order__c, INR_FC_Workflow_Status__c, Training_Confirmation_Closed_Date__c, ParentId, Order__r.Reimbursement_Mapping_Lookup__c
            , Training_Type__c, ClosedDate
            FROM Case
            WHERE Id in :caseIds ]){
                caseMap.put(c.Id,c);
        }

        for(Case_Automation__e evnt : newRecords){
            System.debug('xxx CaseAutomationHandler RECORD '+ evnt);
            switch on evnt.Type__c {
                when  'inrWorkflowStatusChange' {
                    inrWorkflowStatusChange(caseMap.get(evnt.Case_Id__c));
                }
                when  'trainingTypeChange' {
                    trainingTypeChange(caseMap.get(evnt.Case_Id__c));
                }
                when 'trainingConfirmationClosedDate' {
                    trainingConfirmationClosedDate(caseMap.get(evnt.Case_Id__c));
                }
                when 'updateShipmentClosedDate'{
                    updateShipmentClosedDate(caseMap.get(evnt.Case_Id__c));
                }
                when 'closeParentTrainingCase'{
                    closeParentTrainingCase(caseMap.get(evnt.Case_Id__c));
                }
                                                              
            }
        }

        if(bills.values().size() > 0){
            update bills.values();
        }
        if(parentCases.values().size() > 0)
            update parentCases.values();
    }

    private void closeParentTrainingCase(Case c){
        if(c.ParentId != null){
            if(parentCases.get(c.ParentId) == null){
                parentCases.put(c.ParentId, new Case(Id = c.ParentId, Status = 'Closed - Resolved'));
            } else {
                parentCases.get(c.ParentId).Status = 'Closed - Resolved';    
            }
        }
    }

    private void updateShipmentClosedDate(Case c){
        if(c.ParentId != null){
            if(parentCases.get(c.ParentId) == null){
                parentCases.put(c.ParentId, new Case(Id = c.ParentId, Shipment_Case_Closed_Date__c = Date.valueOf(c.ClosedDate)));
            } else {
                parentCases.get(c.ParentId).Shipment_Case_Closed_Date__c = Date.valueOf(c.ClosedDate);    
            }
        }
    }
    
    private void trainingConfirmationClosedDate(Case c){
        if(c.ParentId != null){
            if(parentCases.get(c.ParentId) == null){    
                parentCases.put(c.ParentId, new Case(Id = c.ParentId, Training_Confirmation_Closed_Date__c = System.today()));
            } else {
                parentCases.get(c.ParentId).Training_Confirmation_Closed_Date__c = System.today();    
            }
        }
    }

    private void inrWorkflowStatusChange(Case c){
        if(c.Order__r.Reimbursement_Mapping_Lookup__c != null){
            if(bills.get(c.ParentId) == null){    
                bills.put(c.Order__r.Reimbursement_Mapping_Lookup__c, new Reimbursement_Mapping__c(Id = c.Order__r.Reimbursement_Mapping_Lookup__c, INR_FC_Workflow_Status__c = c.INR_FC_Workflow_Status__c));
            } else {
                bills.get(c.Order__r.Reimbursement_Mapping_Lookup__c).INR_FC_Workflow_Status__c = c.INR_FC_Workflow_Status__c;    
            }
        }
    }

    private void trainingTypeChange(Case c){
        if(c.Order__c != null)
            if(orders.get(c.Order__c) == null){
                orders.put(c.Order__c, new Order(Id = c.Order__c, Training_Type__c = c.Training_Type__c));
            } else {
                orders.get(c.Order__c).Training_Type__c = c.Training_Type__c;
            }

        if(c.ParentId != null){
            if(parentCases.get(c.ParentId) == null){    
                parentCases.put(c.ParentId, new Case(Id = c.ParentId, Training_Type__c = c.Training_Type__c));
            } else {
                parentCases.get(c.ParentId).Training_Type__c = c.Training_Type__c;    
            }

        }

    }    

}