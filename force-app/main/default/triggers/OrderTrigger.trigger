trigger OrderTrigger on Order (before insert, before update, after update, after insert) {
    Trigger_Switch__mdt orderActivation = [SELECT Active__c FROM Trigger_Switch__mdt WHERE Label = 'OrderTrigger'];
    OrderTriggerHandler handle = new OrderTriggerHandler(trigger.new, trigger.oldMap);

    System.debug('Trigger  active value - ' + orderActivation.Active__c);
    if (orderActivation.Active__c) {

        System.debug('xxx OrderTriggerHandler ');
        if (trigger.isBefore) 
        {
            if (trigger.isInsert) handle.beforeInsert();
            if (trigger.isUpdate) handle.beforeUpdate();
        }

        if (trigger.isAfter) 
        {
            if (trigger.isInsert) handle.afterInsert();
        }

        if (trigger.isAfter) 
        {
            if (trigger.isUpdate) handle.afterUpdate();
        }
    }

}