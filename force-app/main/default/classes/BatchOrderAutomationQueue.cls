Global class BatchOrderAutomationQueue  implements Schedulable, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
    public String query;


    Global BatchOrderAutomationQueue() {
        query = 'SELECT Order__c, Type__c, Status__c, Case__c, Object__c, Order__r.EncounterNumber__c, Order__r.AccountId,  Enrollment_Number__c, ' + 
                'Order__r.Enrollment_Backend_ID__c, Order__r.AD_Start_Date__c, Order__r.Activation_AD_Enabled__c, User_Name__c' +
                'FROM Automation_Queue__c ' +
                'WHERE Status__c = \'Ready to Process\'';        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('xxx query ' + query);      

        return Database.getQueryLocator(query);
    }

    global  void execute(Database.BatchableContext BC, List<Automation_Queue__c> recs){
        List<Id> awfOrdersIds = new List<Id>();
        Map<String, Id> encounterToOrderId = new Map<String, Id>();
        Map<String, Id> enrollmentToOrderId = new Map<String, Id>();

        List<Automation_Queue__c> InrWorkflowStatusCovered = new List<Automation_Queue__c>();

        for(Automation_Queue__c q : recs){
            switch on q.Type__c {
                when  'CreateActivationWorkflowCase' {
                    awfOrdersIds.add(q.Order__c);
                }
                when  'MiddlewareFollowupDateCall' {
                    MiddlewareUtil.FollowupDate(q.Order__r.Enrollment_Backend_ID__c, q.Order__r.AD_Start_Date__c, q.User_Name__c);
                }
                when  'MiddlewareAutoDialerCall' {
                    MiddlewareUtil.AutoDialerEnabled(q.Order__r.Enrollment_Backend_ID__c, q.Order__r.Activation_AD_Enabled__c, q.User_Name__c);
                }
                when  'UpdateFaxViaEncounter' {
                    encounterToOrderId.put(q.Order__r.EncounterNumber__c, q.Order__c);
                }
                when  'UpdateFaxViaEnrollment' {
                    enrollmentToOrderId.put(q.Order__r.Enrollment_Number__c, q.Order__c);
                }                
                when  'InrWorkflowStatusCovered' {
                    InrWorkflowStatusCovered.add(q);
                }                                                   
            }
        }
        System.debug('xxx enrollmentToOrderId '+ enrollmentToOrderId);

        if(awfOrdersIds.size() > 0)
            CreateActivationWorkflowCases.execute(awfOrdersIds);

        if(encounterToOrderId != new Map<String, Id>())
            processEncounterFaxUpdates(encounterToOrderId);

        if(enrollmentToOrderId != new Map<String, Id>())
            processEnrollmentFaxUpdates(enrollmentToOrderId);                

        if(InrWorkflowStatusCovered.size() > 0)
            processInrWorkflowStatusCovered(InrWorkflowStatusCovered);  
            
            
    }
    private static void processInrWorkflowStatusCovered(List<Automation_Queue__c> qs){
        List<Case> cases = new List<Case>();

        List<Group> queue = [
            SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'Financial_Responsibility_Calls_Queue' 
        ];
        String queueName =  queue[0].Id;

        Id psrt    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        for(Automation_Queue__c q : qs){
            Case c = new Case(
                RecordTypeId = psrt,
                OwnerId = queueName,
                Order__c = q.Order__c,
                Status = 'New',
                Origin = 'Phone',
                Priority = 'Medium',
                AccountId = q.Order__r.AccountId
            );
            cases.add(c);
        }
        INSERT cases;
    }

    private static void processEncounterFaxUpdates(Map<String, Id>encounterToOrderId){
        List<Fax_Enrollment__c> faxes = [
            SELECT Id, Encounter_Number__c 
            FROM Fax_Enrollment__c 
            WHERE Encounter_Number__c IN :encounterToOrderId.keySet()];

        for(Fax_Enrollment__c fax : faxes){
            fax.Order__c = encounterToOrderId.get(fax.Encounter_Number__c);
        }
        UPDATE faxes;
    }

    private static void processEnrollmentFaxUpdates(Map<String, Id>enrollmentToOrderId){
        System.debug('xxx processEnrollmentFaxUpdates '+ enrollmentToOrderId);
        
        List<Fax_Enrollment__c> faxes = [
            SELECT Id, Enrollment_Number__c 
            FROM Fax_Enrollment__c 
            WHERE Enrollment_Number__c IN :enrollmentToOrderId.keySet()];
            
            System.debug('xxx faxes '+ faxes);

        for(Fax_Enrollment__c fax : faxes){
            fax.Order__c = enrollmentToOrderId.get(fax.Enrollment_Number__c);
        }
        System.debug('xxx faxes '+ faxes);
        UPDATE faxes;
    }

    global void finish(Database.BatchableContext BC){

    }



	global void execute(SchedulableContext SC) 
	{		
		ID batchprocessid = Database.executeBatch(new BatchOrderAutomationQueue(), 10);
	}     
   
}