Global class PendingCancellationBatch  implements Schedulable, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
    public String query;
    public Id activationWorkflowRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
    public Id patientInteractionRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
    public Date today = System.today();
    Global PendingCancellationBatch() {


        query = 'SELECT Id, Status, Pending_Cancellation_Date__c, Owner.Name, Order__r.Enrollment_Backend_ID__c FROM CASE' +
                ' WHERE recordTypeId = :activationWorkflowRT'+
                ' AND Pending_Cancellation_Date__c = :today' +
                ' AND Status = \'Pending Cancellation\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('xxx query ' + query);      

        return Database.getQueryLocator(query);
    }

    global  void execute(Database.BatchableContext BC, List<Case> cases){
        System.debug('size ' + cases.size());
        process(cases);

    }
    global void finish(Database.BatchableContext BC){

    }

    public static void process(List<Case> cases){
        System.debug('cases ' + cases);
        Set<Id> caseIds = new Set<Id>();
        //List<Order> orders = new List<Order>(); // TEMPFORTESTING
        for(Case cs : cases){
            MiddlewareUtil.CancelEnrollment(cs.Order__r.Enrollment_Backend_ID__c, cs.Owner.Name);
            cs.Activation_AD_Enabled__c  = false;

            //Order ord = new Order(); // TEMPFORTESTING
            //ord.Id = cs.Order__r.Id; // TEMPFORTESTING
            //ord.Activation_Workflow_Status__c = 'Stopped'; // TEMPFORTESTING
            //orders.add(ord); // TEMPFORTESTING
        }
        update cases;
        //update orders;  // TEMPFORTESTING
    }

	global void execute(SchedulableContext SC) 
	{		
		ID batchprocessid = Database.executeBatch(new PendingCancellationBatch(), 1);
	}     
   
}