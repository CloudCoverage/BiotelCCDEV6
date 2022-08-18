@isTest(seeAllData=true)
public class ActivationWorkflowHelperTest {
	
    static testmethod void test1(){

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Jon',
            LastName = 'Doe',
            AccountId = acc.Id
        );
        insert con;
        
        Id CaseRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
        Case cs = new Case(
            Status = 'Awaiting Activation',                              
            //Order__c = order.Id,                                        
            Closed_Result__c = 'N/A',                                      
            ContactId = con.Id,                                       
            Activation_AD_Enabled__c = false,                              
            Initial_Case_Creation_Date__c = System.today(),      
            AD_Start_Date__c = System.today(),                  
            Subsequent_Case_Creation_Date__c = System.today(),  
            Priority = 'Medium',                                           
            Button_Disabled__c = false,                                    
            Origin = 'Workflow',                                           
            Subject = 'Activation Workflow Case',                          
            Flag_for_Supervisor_Review__c = false,                         
            Start_Pending_Cancellation__c = false                         
          );
        insert cs;
        List<Id> ids = new List<Id>();
        ids.add(cs.Id);
        ActivationWorkflowHelper.createPIC(ids);
        ActivationWorkflowHelper.createReverseCancellationPIC(ids);

    }

	static testmethod void test2(){
        Map<String, Date_Calculation_Setting__c> settingsMap = new Map<String, Date_Calculation_Setting__c>();
        settingsMap = CaseTriggerHandler.getSettings('Insert');
        List<Date> holidays = new List<Date>();
        holidays = CaseTriggerHandler.getHolidays();
        List<Date_Calculation_Setting__c> settings = settingsMap.values();
        Date testDate = Date.newInstance(2021, 12, 25);
        Date newDate = ActivationWorkflowHelper.adjustDateForHolidayAndWeekends(testDate, holidays, settingsMap, 'Pending_Cancellation_Date__cOTS');
        
        testDate = Date.newInstance(2021, 12, 22);
        newDate = ActivationWorkflowHelper.adjustDateForHolidayAndWeekends(testDate, holidays, settingsMap, 'AD_Start_Date__cOTS');
        
        testDate = Date.newInstance(2021, 08, 23);
        newDate = ActivationWorkflowHelper.adjustDateForHolidayAndWeekends(testDate, holidays, settingsMap, 'Initial_Estimated_Delivery_Date__cMTP');
        testDate = Date.newInstance(2021, 08, 23);
        newDate = ActivationWorkflowHelper.adjustDateForWeekend(testDate);
        /*
        testDate = Date.newInstance(2021, 08, 27);
        newDate = ActivationWorkflowHelper.adjustDateForHolidayAndWeekends(testDate, holidays, settingsMap, 'AD_Start_Date__cOTS');
        */
    }  
    static testmethod void test3(){

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Jon',
            LastName = 'Doe',
            AccountId = acc.Id
        );
        insert con;
        
        Order order = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v8',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf2',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
          );
          insert order;

        ActivationWorkflowHelper.createReverseCancellationPICFromOrder(order.Id);

    }      
}