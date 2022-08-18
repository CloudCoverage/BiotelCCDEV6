public with sharing class CaseBuilder {
    Map<String,Id> queueMap;
    Map<String,Id> caseReasonLookupMap; 

    public CaseBuilder() {
        this.queueMap = getQueueMap();
        this.caseReasonLookupMap = getCaseReasonLookupMap();
    }
    

    public Case createSpecialInstructionCase(Order order){
        System.debug('createSpecialInstructionCase ' + order);

            return new Case(
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Special_Instructions').getRecordTypeId(),
                OwnerId = queueMap.get('Enrollment_Special_Instructions_Queue'),
                Status = 'New',
                Order__c = order.Id,
                ContactId = order.Patient_Contact_ID__c,
                Origin = 'Workflow',
                AccountId = order?.AccountId,
                Priority = 'Medium',
                Enrollment_Number__c = order.Enrollment_Number__c,
                Case_Reason_Lookup__c = caseReasonLookupMap.get('Enrollment Special Instructions'),
                Subject = 'Enrollment Special Instructions'
            );
    }    

    
    public static Map<String,Id> getQueueMap(){
        List<Group> queues = [
            SELECT Id, DeveloperName FROM Group 
            WHERE DeveloperName IN ('Enrollment_Special_Instructions_Queue')
        ];
        Map<String, Id> queueMap = new Map<String,Id>();
        for(Group q: queues){
            queueMap.put(q.DeveloperName, q.Id);
        }
        return queueMap;
    }

    public static Map<String,Id> getCaseReasonLookupMap(){
        List <Case_Reason_Lookup__c> crls = [
            SELECT Id, Name 
              FROM Case_Reason_Lookup__c 
             WHERE (Name IN('Enrollment Special Instructions'))];

        Map<String, Id> reasonMap = new Map<String,Id>();
        for(Case_Reason_Lookup__c r: crls){
            reasonMap.put(r.Name, r.Id);
        } 
        return reasonMap; 
    }

}