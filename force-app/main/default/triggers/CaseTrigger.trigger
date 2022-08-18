trigger CaseTrigger on Case (before insert, before update) {
    Trigger_Switch__mdt caseActivation = [SELECT Active__c FROM Trigger_Switch__mdt WHERE Label = 'CaseTrigger'];
    CaseTriggerHandler handle = new CaseTriggerHandler(trigger.new, trigger.oldMap);

    System.debug('Trigger active value - ' + caseActivation.Active__c);
    if(caseActivation.Active__c){
        System.debug('CaseTrigger');

        if (trigger.isBefore) 
        {
            if (trigger.isInsert) 
                handle.beforeInsert();
            if (trigger.isUpdate) 
                handle.beforeUpdate();
        }
    }

}