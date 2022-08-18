trigger MiddlewareTrigger on Middleware_Event__e (after insert) {
    MiddlewareTriggerHandler handler = new MiddlewareTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);

    if (trigger.isAfter && trigger.isInsert){
        handler.afterInsert();
    }           
}