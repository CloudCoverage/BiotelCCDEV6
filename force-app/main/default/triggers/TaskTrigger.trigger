trigger TaskTrigger on Task (before delete, before update, before insert) {
    TaskTriggerHandler handle = new TaskTriggerHandler(trigger.new, trigger.oldMap, trigger.old);

    
    Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId();
    if (trigger.isBefore) {
        if (trigger.isDelete){
            if(userInfo.getProfileId() != profileId){   
                for(Task t:Trigger.old){
                    if(t.RecordTypeId == recordTypeId){
                        t.addError('External Activities cannot be deleted in Salesforce.');
                    }
                }
            }
        }
        if (trigger.isUpdate) handle.beforeUpdate(); 
        if (trigger.isInsert) handle.beforeInsert(); 

    }


}