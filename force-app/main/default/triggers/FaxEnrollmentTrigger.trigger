trigger FaxEnrollmentTrigger on Fax_Enrollment__c ( before update) {
    FaxEnrollmentTriggerHandler handle = new FaxEnrollmentTriggerHandler(trigger.new, trigger.oldMap);

    System.debug('xxx FaxEnrollmentTriggerHandler ');
    if (trigger.isBefore) 
    {
        if (trigger.isUpdate) handle.beforeUpdate();
    }


}