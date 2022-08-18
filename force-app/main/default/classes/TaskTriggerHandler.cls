public class TaskTriggerHandler {
    final List<Task> tasks;
    final Map<Id, Task> oldMap;
    final List<Task> old;
    final List<String> autoCloseCaseSubjects = new List<String>{'Ordering Physician', 'Ordering Practice Location', 'Patient Demographics', 'Diagnosis Code', 'Insurance Information'};
    
    public TaskTriggerHandler(List<Task> tasks, Map<Id, Task> oldMap, List<Task>old)
    {
        this.tasks = tasks;
        this.oldMap = oldMap;
        this.old = old;
    }

    public void beforeInsert()
    {
        populateBillingInfo();
    }    
    
    public void beforeUpdate()
    {
        System.debug('in beforeUpdate');
        closeNewPayerCase();
        statusChangeToUnresolved();
    }
    
    private void populateBillingInfo(){

        Map<Id, Task> caseIdToTask = new Map<Id,Task>();
        Map<Id, Task> billingToTask = new Map<Id,Task>();


        for(Task task : tasks){
            Boolean isCaseRecord = String.valueOf(task.WhatId).startsWith('500');
            if(isCaseRecord){
                caseIdToTask.put(task.WhatId, task);
            }
        }
        if(caseIdToTask.size() > 0){
            for(Case caseRec : [SELECT Id, Order__c, Order__r.Reimbursement_Mapping_Lookup__c FROM Case 
                WHERE Id IN : caseIdToTask.keySet() AND Order__c != null AND Order__r.Reimbursement_Mapping_Lookup__c != null]){
                    billingToTask.put(caseRec.Order__r.Reimbursement_Mapping_Lookup__c, caseIdToTask.get(caseRec.Id));
            }
    
            if(billingToTask.size() > 0){
                for(Reimbursement_Mapping__c bill : [SELECT Id, Soarian_Encounter_Id__c, Primary_Insurance_Payer_Name__c FROM Reimbursement_Mapping__c 
                    WHERE Id IN :billingToTask.keySet()]){

                    billingToTask.get(bill.Id).Soarian_Encounter_ID__c = bill?.Soarian_Encounter_Id__c;
                    billingToTask.get(bill.Id).Primary_Ins_Payer_Name__c = bill?.Primary_Insurance_Payer_Name__c;
                }
            }
        }

    }    

    private void closeNewPayerCase(){
        List<Case> cases = new List<Case>();
        for(Task task : tasks){
            Task old = oldMap.get(task.Id);
            Boolean isCaseRecord = String.valueOf(task.WhatId).startsWith('500');
            Boolean caseStatusChangedToComplete = autoCloseCaseSubjects.contains(task.Subject) && task.Status == 'Completed' && old.Status != task.Status && isCaseRecord;

            if(caseStatusChangedToComplete){
                cases.add(new Case(Id = task.WhatId, Status = 'Closed'));
            }
        }
        if(cases.size() > 0)
            update cases;
    }
    private void statusChangeToUnresolved(){
        List<Task> unresolvedTasks = new List<Task>();
        Map<Id,Id> caseIdToTaskIdMap = new Map<Id,Id>();
        Map<Id,List<String>> taskIdtoCaseOwnerMap = new Map<Id,List<String>>();
        for(Task task : tasks){
            Task old = oldMap.get(task.Id);
            Boolean isCaseRecord = String.valueOf(task.WhatId).startsWith('500');
            Boolean caseStatusChangedToUnResolved = autoCloseCaseSubjects.contains(task.Subject) && task.Status == 'Unresolved' && old.Status != task.Status && isCaseRecord;

            if(caseStatusChangedToUnResolved){
                unresolvedTasks.add(task);
                caseIdToTaskIdMap.put(task.WhatId, task.Id);
            }
        }

        if(unresolvedTasks.size() > 0){
            Map<String, List<String>> queueMembers = new Map<String, List<String>>();
            for(GroupMember groupMember : [SELECT UserOrGroupId, Group.Id from GroupMember where Group.Type = 'Queue']){
                if(queueMembers.get(groupMember.Group.Id) == null){
                    queueMembers.put(groupMember.Group.Id,new List<String>());
                }
                Boolean groupMemberIsUser = String.valueOf(groupMember.UserOrGroupId).startsWith('005');
                if(groupMemberIsUser){
                    queueMembers.get(groupMember.Group.Id).add(groupMember.UserOrGroupId);
                }
            }

            for(Case cas : [SELECT Id, OwnerId FROM Case WHERE Id IN:caseIdToTaskIdMap.keySet()]){
                Boolean caseOwnerIsUser = String.valueOf(cas.OwnerId).startsWith('005');
                Boolean caseOwnerIsQueue = String.valueOf(cas.OwnerId).startsWith('00G');
                if(caseOwnerIsUser){
                    taskIdtoCaseOwnerMap.put(caseIdToTaskIdMap.get(cas.Id), new List<String>{cas.OwnerId});
                } else if(caseOwnerIsQueue){
                    taskIdtoCaseOwnerMap.put(caseIdToTaskIdMap.get(cas.Id), queueMembers.get(cas.OwnerId));
                }
            }
            
            Id soarianEnrTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Soarian_Enrollment_Updates']?.Id;
            Id fromAddress = [select Id from OrgWideEmailAddress where Address = 'PE-NoReply@gobio.com']?.Id;
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();  
            List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
            for(Task task : unresolvedTasks){
                if(taskIdtoCaseOwnerMap.get(task.Id) != null){
                    Messaging.SingleEmailMessage render = 
                    Messaging.renderStoredEmailTemplate(
                        soarianEnrTemplateId, 
                        taskIdtoCaseOwnerMap.get(task.Id)[0], 
                        task.Id
                    );
                    String emailSubject = render.getSubject();
                    String emailTextBody = render.getPlainTextBody();

                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();   
                    message.setOrgWideEmailAddressId(fromAddress);
                    message.setTargetObjectId(taskIdtoCaseOwnerMap.get(task.Id)[0]); 
                    message.setToAddresses(taskIdtoCaseOwnerMap.get(task.Id)); 
                    message.optOutPolicy = 'FILTER'; 
                    message.setSaveAsActivity(false);   
                    message.setSubject(emailSubject);
                    message.setPlainTextBody(emailTextBody);
                    messages.add(message);   
                }
            }
            results = Messaging.sendEmail(messages,false);
            System.debug('email results ' + results);
        }

    }        
}