trigger CaseAutomationTrigger on Case_Automation__e (after insert) {
    CaseAutomationHandler handler = new CaseAutomationHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);

    if (trigger.isAfter && trigger.isInsert){
        handler.afterInsert();
    }           
}