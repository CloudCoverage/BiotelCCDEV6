public without sharing class CancelOrderMWcalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	/*
	  CancelOrderMWcalloutBatch b = new CancelOrderMWcalloutBatch();
	  Database.executeBatch(b, 1);
	 */

	/* 
	  String mtpString = 'MTP';
	  String testId = '8010R000000tyNSQAY';
	  Datetime goliveDate = Datetime.newInstance(2021, 5, 31);
	  Datetime maxOldestDateFilter = goliveDate.addDays(-150);
	  Datetime ninetyDaysOld = goliveDate.addDays(-90);
	  String stoppedString = 'Stopped';
	 
	  Datetime startEnrollmentDateFilter = Datetime.newInstance(2021,4, 1); //for QA only
	  Datetime endEnrollmentDateFilter = Datetime.newInstance(2021, 4, 30); //for QA only
	 
	  String query = 'SELECT Shipment_Date__c, AD_Start_Date__c, Enrollment_Backend_ID__c FROM Order WHERE ((AD_Start_Date__c >= ' + maxOldestDateFilter+  'AND AD_Start_Date__c < ' + ninetyDaysOld + ') OR (Shipment_Date__c >= ' + maxOldestDateFilter + ' AND Shipment_Date__c < ' + ninetyDaysOld + ')) AND Enrollment_Backend_ID__c != null AND';
	  query += '(Activation_Workflow_Status__c = \'Awaiting Shipment\' OR Activation_Workflow_Status__c = \'Awaiting Activation\' OR Activation_Workflow_Status__c = \'Awaiting Baseline\') AND Device_Source__c = '+ mtpString; //UAT only
	  System.debug(query);
	 */
	private String query;
	public List<String> processedRecordListString;
	public Integer failCalloutCount;
	private List<Order> ordersToUpdate;
	private Set<Id> failedIdSet;
	private Map<Id, Id> orderIdToOppIdMap;
	private Map<Id, Id> orderIdToAccountIdMap;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		String mtpString = 'MTP';
		String testId = '8010R000000tyNSQAY';
		Date goliveDate = Datetime.newInstance(2021, 9, 10).date(); //go live prod sept 10th
		Date maxOldestDateFilter = goliveDate.addDays(- 149); //apr 14th
		Date ninetyDaysOld = goliveDate.addDays(- 90); //jun 12th
		String stoppedString = 'Stopped';
		processedRecordListString = new List<String> ();
		failCalloutCount = 0;
		failedIdSet = new Set<Id> ();
		
		 
		System.debug('goliveDate - ' + goliveDate);
		System.debug('maxOldestDateFilter(should be 150s ago) - ' + maxOldestDateFilter);
		System.debug('ninetyDaysOld(should be 90 days ago) - ' + ninetyDaysOld);
		//orderIdToOppIdMap = new Map<Id, Id> ();
		//orderIdToAccountIdMap = new Map<Id, Id> ();

		//Datetime startEnrollmentDateFilter = Datetime.newInstance(2021,4, 1); //for QA only
		//Datetime endEnrollmentDateFilter = Datetime.newInstance(2021, 4, 30); //for QA only

		//List<Order> oList = [SELECT Shipment_Date__c, Enrollment_Backend_ID__c FROM Order WHERE Activation_Workflow_Status__c != null AND Device_Source__c = 'MTP' AND Enrollment_Backend_ID__c != null];
		//only query those where AD_Start_Date__c or Shipment_Date__c is less than 150 days old.
		//query = 'SELECT Shipment_Date__c, AD_Start_Date__c, Enrollment_Backend_ID__c, OpportunityId, AccountId, Device_Source__c FROM Order WHERE ((AD_Start_Date__c >= :maxOldestDateFilter AND AD_Start_Date__c <= :ninetyDaysOld) OR (Shipment_Date__c >= :maxOldestDateFilter AND Shipment_Date__c <= :ninetyDaysOld)) AND Enrollment_Backend_ID__c != null AND'; //first push to prod for backup run
		//query += '(Activation_Workflow_Status__c = \'Awaiting Shipment\' OR Activation_Workflow_Status__c = \'Awaiting Activation\' OR Activation_Workflow_Status__c = \'Awaiting Baseline\')'; //first push to prod for backup run

		query = 'SELECT Shipment_Date__c, AD_Start_Date__c, Enrollment_Backend_ID__c, OpportunityId, AccountId, Device_Source__c FROM Order WHERE ((AD_Start_Date__c >= :maxOldestDateFilter AND AD_Start_Date__c <= :ninetyDaysOld) OR (Shipment_Date__c >= :maxOldestDateFilter AND Shipment_Date__c <= :ninetyDaysOld)) AND Enrollment_Backend_ID__c != null AND';  //second push to prod for actual callouts and DML
		query += '(Activation_Workflow_Status__c = \'Awaiting Shipment\' OR Activation_Workflow_Status__c = \'Awaiting Activation\' OR Activation_Workflow_Status__c = \'Awaiting Baseline\') AND Checkbox_TO_Delete__c = true'; //second push to prod for actual callouts and DML

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<Order> scope) {
		System.debug('scope - ' + scope);
		Date goliveDate = Datetime.newInstance(2021, 9, 10).date(); //go live prod sept 10th
		Date maxOldestDateFilter = goliveDate.addDays(- 149); //apr 14th
		Date ninetyDaysOld = goliveDate.addDays(- 90); //jun 12th
		ordersToUpdate = new List<Order> ();

		//Datetime maxOldestDateFilter = Datetime.newInstance(2021, 4, 1); // UAT only
		//Datetime ninetyDaysOld = Datetime.newInstance(2021, 4, 30);// UAT only
		String response; 
		 
		System.debug('goliveDate - ' + goliveDate);
		System.debug('maxOldestDateFilter(should be 150s ago) - ' + maxOldestDateFilter);
		System.debug('ninetyDaysOld(should be 90 days ago) - ' + ninetyDaysOld); 
		for (Order orderRecord : scope) {
			//if OTS use AD_start_date__c only.
			if (orderRecord.Device_Source__c != 'OTS' && orderRecord.Shipment_Date__c != null && orderRecord.Shipment_Date__c > orderRecord.AD_Start_Date__c && orderRecord.Shipment_Date__c >= maxOldestDateFilter && orderRecord.Shipment_Date__c<=ninetyDaysOld) { //Shipment_Date__c is more recent, //order is 91-150 days old
				//cancel the order
				//System.debug('Shipment_Date__c is more recent and matches filter criteria');
				String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
				response = MiddlewareUtil.CancelEnrollment(orderRecord.Enrollment_Backend_ID__c, userName);  //comment out for first push to prod
				processedRecordListString.add(orderRecord.Id);
				finishProcessing(orderRecord, response); 
			}
			else { //AD_Start_Date__c is more recent
				//System.debug('AD_Start_Date__c is more recent');
				if (orderRecord.AD_Start_Date__c != null && orderRecord.AD_Start_Date__c >= maxOldestDateFilter && orderRecord.AD_Start_Date__c<=ninetyDaysOld) { //order is 91-150 days old
					//cancel the order
					//System.debug('AD_Start_Date__c matches filter criteria');
					String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
					response = MiddlewareUtil.CancelEnrollment(orderRecord.Enrollment_Backend_ID__c, userName); //comment out for first push to prod
					processedRecordListString.add(orderRecord.Id);
					finishProcessing(orderRecord, response);
				}
			}
		}

		UPDATE ordersToUpdate;  //comment out for first push to prod
	}

	public void finishProcessing(Order orderRecord, String response) {
		//System.debug('Response from callout - ' + response);

		orderRecord.Coastal_Cancel_Order_Callout_Status__c = response;
		if (response != null && response.containsIgnoreCase('Successful')) {
			orderRecord.SF_Initial_Backfill_Date__c = Date.today();
			orderRecord.Cancellation_Reason__c = 'No Contact/Non Compliant';
		}
		else {
			//System.debug('cancel callout was not successful');
			failCalloutCount += 1;
			failedIdSet.add(orderRecord.Id);
		}
		//orderIdToOppIdMap.put(orderRecord.Id, orderRecord.OpportunityId);
		//orderIdToAccountIdMap.put(orderRecord.Id, orderRecord.AccountId);
		ordersToUpdate.add(orderRecord);
	}
	public void finish(Database.BatchableContext BC) {
		System.debug('processedRecordListString, Count - ' + processedRecordListString.size());
		//debug trims if too many so parse it our and debug multiple times

		System.debug('processedRecordListString Start');
		for (Integer i = 0; i<JSON.serialize(processedRecordListString).length(); i += 10000) {

			System.debug(JSON.serialize(processedRecordListString).mid(i, 10000));

		}
		System.debug('processedRecordListString End');

		System.debug('failCalloutCount - ' + failCalloutCount);
		System.debug('failedIdSet Start');
		for (Integer i = 0; i<JSON.serialize(failedIdSet).length(); i += 10000) {

			System.debug(JSON.serialize(failedIdSet).mid(i, 10000));

		}
		System.debug('failedIdSet End');

		/*
		  System.debug('orderIdToOppIdMap Start');
		  for (Integer i = 0; i<JSON.serialize(orderIdToOppIdMap).length(); i += 10000) {
		 
		  System.debug(JSON.serialize(orderIdToOppIdMap).mid(i, 10000));
		 
		  }
		  System.debug('orderIdToOppIdMap End');
		 */
		/*
		  System.debug('orderIdToAccountIdMap Start');
		  for (Integer i = 0; i<JSON.serialize(orderIdToAccountIdMap).length(); i += 10000) {
		 
		  System.debug(JSON.serialize(orderIdToAccountIdMap).mid(i, 10000));
		 
		  }
		  System.debug('orderIdToAccountIdMap End');
		 */
	}
}