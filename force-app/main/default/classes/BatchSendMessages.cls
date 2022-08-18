Global class BatchSendMessages  implements Schedulable, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
    public String query;


    Global BatchSendMessages() {
        query = 'SELECT Id, Patient__c, Enrollment__c, Event__c, Status__c, Type__c, Template_ID__c, Send_Successful__c, Shipment_Delivery_Time__c, Estimated_Delivery_Date__c, ' +
        'Shipment_Date__c, Shipment_Delivery_Date__c, From__c, To__c, Error_Message__c, Sent_Timestamp__c, Tracking_Number__c, Name, Body__c ' + 
                'FROM Send_Queue__c ' +
                'WHERE Status__c = \'Ready to Process\'';        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('xxx query ' + query);      

        return Database.getQueryLocator(query);
    }

    global  void execute(Database.BatchableContext BC, List<Send_Queue__c> recs){
        System.debug('recs ' + recs);
        System.debug('recs size ' + recs.size());
		SendQueueHelper sqh = new SendQueueHelper();
        sqh.processEvents(recs);
        //List<Task> tasks = new List<Task>();
        //for(Send_Queue__c rec : recs){
        //    rec = sqh.processEvent(rec.Event__c, rec);
        //    tasks.add(SendQueueHelper.createTask(rec));
        //}
        //update recs;
        //insert tasks;
    }
    global void finish(Database.BatchableContext BC){

    }



	global void execute(SchedulableContext SC) 
	{		
		ID batchprocessid = Database.executeBatch(new BatchSendMessages(), 10);
	}     
   
}