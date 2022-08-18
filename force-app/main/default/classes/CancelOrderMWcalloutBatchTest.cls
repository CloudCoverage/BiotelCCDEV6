@isTest(seealldata=false)
public class CancelOrderMWcalloutBatchTest  {
	static testMethod void cancelOrderTest() {
		//Shipment_Date__c, AD_Start_Date__c, Enrollment_Backend_ID__c 
		//FROM Order 
		//WHERE ((AD_Start_Date__c >= :maxOldestDateFilter AND AD_Start_Date__c < :ninetyDaysOld)
		// OR (Shipment_Date__c >= :maxOldestDateFilter AND Shipment_Date__c < :ninetyDaysOld)) 
		// AND Enrollment_Backend_ID__c != null 
		// AND Activation_Workflow_Status__c != 'Stopped'
		// AND Device_Source__c = 'MTP'
		
		Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());

		 Id patientInteractionRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        Date today = System.today();

        Case_Reason_Lookup__c cr = new Case_Reason_Lookup__c(
            Case_Record_Type__c = patientInteractionRT,
            Case_Type__c = 'Problem/Issue',
            Category__c = 'Activation',
            Department__c = 'Clinical',
            Name = 'Outbound Awaiting Activation/Baseline'
        );

        INSERT cr;
		/*
        Workflow_Setting__c aws = new Workflow_Setting__c(
            //Duration_Type__c = 'Calendar Days', 
            Close_Days__c = 7, 
            Subsequent_Days__c = 7, 
            Initial_of_Days__c = 1, 
            Device_Source__c = 'MTP', 
            Setting_Type__c = 'Case Create/Close', 
            Name = 'Case Create MTP'          
        );
        INSERT aws;

        Workflow_Setting__c aws2 = new Workflow_Setting__c(
            //Duration_Type__c = 'Calendar Days', 
            Close_Days__c = 7, 
            Subsequent_Days__c = 7, 
            Initial_of_Days__c = 1, 
            Device_Source__c = 'OTS', 
            Setting_Type__c = 'Case Create/Close', 
            Name = 'Case Create OTS'          
        );
        INSERT aws2;        
		*/
        Account acc = new Account( 
            Name = 'Test Account'
        );
        INSERT acc;
        
        Contact con = new Contact(
            FirstName = 'Jon',
            LastName = 'Doe',
            AccountId = acc.Id
        );
        INSERT con;

		
		Date todaysDate = Date.today();
		Date shipmentDate = todaysDate.addDays(-95);
		Date adStartDate = todaysDate.addDays(-95);

		Order ord = new Order(
            Name = 'Test Order',
            AccountId = acc.Id,
            //Enrollment_Start_Datetime__c = Date.today(),
            EffectiveDate = Date.today(),
            Status = 'Submitted',
			Activation_Workflow_Status__c = 'Awaiting Activation',
            Enrollment_Number__c = '999999',
			Shipment_Date__c = shipmentDate, 
			AD_Start_Date__c = adStartDate,
			Device_Source__c = 'MTP',
            Enrollment_Backend_ID__c = 'abc123',
			Checkbox_TO_Delete__c = true

        );
		
        INSERT ord;

		/*
		Order ord2 = new Order(
            Name = 'Test Order2',
            AccountId = acc.Id,
            //Enrollment_Start_Datetime__c = Date.today(),
            EffectiveDate = Date.today(),
            Status = 'Submitted',
			Activation_Workflow_Status__c = 'Awaiting Activation',
            Enrollment_Number__c = '99999922',
			Shipment_Date__c = adStartDate, 
			AD_Start_Date__c = shipmentDate,
			Device_Source__c = 'MTP',
            Enrollment_Backend_ID__c = 'abc12322',
			Checkbox_TO_Delete__c = true

        );
        INSERT ord2;*/

		CancelOrderMWcalloutBatch b = new CancelOrderMWcalloutBatch();
		Database.executeBatch(b, 1);

	}

}