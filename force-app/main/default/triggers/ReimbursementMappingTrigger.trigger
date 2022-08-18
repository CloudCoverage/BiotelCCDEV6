trigger ReimbursementMappingTrigger on Reimbursement_Mapping__c (before insert, before update) {

    ReimbursementMappingTriggerHandler ReimbursementMappingTriggerHandler = new ReimbursementMappingTriggerHandler(trigger.new, trigger.newMap, trigger.oldMap);

    System.debug('ReimbursementMappingTrigger');

    if (trigger.isBefore){
        //if (trigger.isInsert) 
            //ReimbursementMappingTriggerHandler.beforeInsert();
        //if (trigger.isUpdate) 
            //ReimbursementMappingTriggerHandler.beforeUpdate();
    }

}