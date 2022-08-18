trigger OrderAutomationTrigger on Order_Automation__e (after insert) {
    OrderAutomationHandler handler = new OrderAutomationHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);

    if (trigger.isAfter && trigger.isInsert){
        handler.afterInsert();
    }           
}