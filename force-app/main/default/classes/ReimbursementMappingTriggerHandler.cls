public with sharing class ReimbursementMappingTriggerHandler {
    final List<Reimbursement_Mapping__c> records;
    final Map<Id, Reimbursement_Mapping__c> newMap;
    final Map<Id, Reimbursement_Mapping__c> oldMap;
 
    public ReimbursementMappingTriggerHandler(List<Reimbursement_Mapping__c> records, Map<Id, Reimbursement_Mapping__c> newMap, Map<Id, Reimbursement_Mapping__c> oldMap) {
        this.records = records;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        System.debug('xxx ReimbursementMappingTriggerHandler beforeInsert');
        InrStatusChange();
    }
  
    public void beforeUpdate() {
        System.debug('xxx ReimbursementMappingTriggerHandler beforeUpdate');
        InrStatusChange();
    }


    private void InrStatusChange(){
        Boolean isInsert = oldMap != null ? false : true;
        Map<Id,String> newCases = new Map<Id,String>();
        List<String> detailsNeeded = new List<String>{'Invalid Insurance','Missing Diagnosis', 'Dx not covered'};
        List<String> payerValues = new List<String>{'Medicaid','Secondary Ins.'};
        for(Reimbursement_Mapping__c rec : records){
            Reimbursement_Mapping__c old = oldMap.get(rec.Id);
            if(rec.INR_FC_Workflow_Status__c  == 'Covered' && (isInsert || old.INR_FC_Workflow_Status__c != 'Covered')){
                newCases.put(rec.Id, 'createInrStatusCoveredCases');
            } else if(detailsNeeded.contains(rec.INR_FC_Workflow_Status__c) && (isInsert || rec.INR_FC_Workflow_Status__c != old.INR_FC_Workflow_Status__c )){
                newCases.put(rec.Id, 'createInsuranceDetailsNeededCases');
            } else if(rec.INR_FC_Workflow_Status__c == 'Declined' && !payerValues.contains(rec.Primary_Insurance_Payer_Name__c) && (isInsert || rec.INR_FC_Workflow_Status__c != old.INR_FC_Workflow_Status__c )){
                newCases.put(rec.Id, 'createInrStatusDeclinedCases');
            } else if(rec.INR_FC_Workflow_Status__c == 'Accepted' && (isInsert || rec.INR_FC_Workflow_Status__c != old.INR_FC_Workflow_Status__c )){
                newCases.put(rec.Id, 'createInrTrainingWorkflow');
            }

        }
        if(newCases.size() > 0){
            //List<Case> cs = CaseBuilder.createInrCasesForReimbursement(newCases);
            //INSERT cs;
        }

    }



}