Global class BatchDailyCaseAutomation  implements Schedulable, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
    public String query;
    Date today = System.today();
    /*
    # Auto create Training Follow-Up child Case if Training Follow-Up Case Create Date = TODAY
    */
    Global BatchDailyCaseAutomation() {
        query = 'SELECT OwnerId, Order__c, Status, ParentId, Training_Follow_Up_Case_Create_Date__c,  Training_Confirmation_Create_Date__c, Order__r.AccountId, Order__r.Patient_First_Name__c, Order__r.Patient_Last_Name__c, Training_Type__c, Order__r.Patient_Contact_ID__c, Shipment_Case_Create_Date__c ' +
                'FROM Case ' +
                'WHERE (Training_Follow_Up_Case_Create_Date__c = :today OR Training_Confirmation_Create_Date__c = :today) ' +
                'AND Status != \'Closed\'';        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('xxx query ' + query);      

        return Database.getQueryLocator(query);
    }

    global  void execute(Database.BatchableContext BC, List<Case> recs){

        Map<String, Id> queueMap = CaseBuilder.getQueueMap();
        Map<String, Id> reasonMap = CaseBuilder.getCaseReasonLookupMap();
        Id psrt = CaseBuilder.getRecordTypeId('Patient_Support');


        List<Case> newCases = new List<Case>();
        for(Case c :recs){
            if(c.Training_Follow_Up_Case_Create_Date__c == System.today()){
                newCases.add(CaseBuilder.trainingFollowUpCase(c, queueMap.get('INR_Training_Follow_Up_Queue'),reasonMap.get('Training Follow-Up'), psrt));
            }

            if(c.Training_Confirmation_Create_Date__c == System.today()){
                newCases.add(CaseBuilder.trainingConfirmationCase(c, queueMap.get('INR_Training_Confirmation_Queue'),reasonMap.get('Training Confirmation'), psrt));                
            }

            if(c.Shipment_Case_Create_Date__c == System.today() && c.OwnerId == queueMap.get('INR_Onboarding_Queue')){
                newCases.add(CaseBuilder.inrTrainingWorkflowChild(c, queueMap.get('INR_Shipment_Case_Queue'),reasonMap.get('Training Coordination'), psrt));                
            }
        }
        if(newCases.size() > 0 ){
            INSERT newCases;
        }



    }

    global void finish(Database.BatchableContext BC){

    }

	global void execute(SchedulableContext SC) 
	{		
		ID batchprocessid = Database.executeBatch(new BatchDailyCaseAutomation(), 10);
	}     
   
}