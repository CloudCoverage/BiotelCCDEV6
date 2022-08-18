@isTest(seeAllData=false)
public class CreateOBManualFollowupPICsBatchTest {
    
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

        Order sobj = new Order(
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
            SF_Backfill_Date__c = System.today(),
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
          insert sobj;
          sobj.AD_Start_Date__c = System.today().addDays(25);  
          sobj.Activation_AD_Enabled__c = false;                            // AD Start Date
          update sobj;
          sobj.Activation_AD_Enabled__c = true;
          update sobj;       


        CaseTriggerHandler.beforeUpdateDateNotBeenCalled = true;
        CaseTriggerHandler.beforeInsertDateNotBeenCalled = true;
        //update cs;

        Case_Reason_Lookup__c cl = new Case_Reason_Lookup__c(
            Case_Record_Type__c = 'Activation Workflow Case',                                   // Case Record Type
            Active__c = true,                                                                    // Active
            Department__c = 'Operations',                                                         // Department
            Notify_AE__c = false,                                                                 // Notify AE
            Category__c = 'Device Activation',                                                    // Category
            Definition__c = 'Parent Case used to monitor/manage the work to activate an order.',  // Definition
            Name = 'Activation Workflow',                                                         // Case Reasons Name
            Case_Type__c = 'Workflow Group',                                                      // Case Type
            Interaction_Type__c = 'Workflow Group',                                               // Interaction Type
            External_Id__c = 'a0Q0R000003buIoUAI'                                                // External Id
          );
          insert cl;
        System.debug('cl '+ cl);

        Id CaseRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
        Case cs = new Case(
            Case_Reason_Lookup__c = cl.Id,
            Status = 'Awaiting Activation',                              
            Order__c = sobj.Id,                                        
            Closed_Result__c = 'N/A',                                      
            ContactId = con.Id,                                       
            Activation_AD_Enabled__c = false,                              
            Initial_Case_Creation_Date__c = System.today(),   
            SF_Backfill_Date__c = System.today(),

            AD_Start_Date__c = System.today(),                  
            Subsequent_Case_Creation_Date__c = System.today(),  
            Priority = 'Medium',                                           
            Button_Disabled__c = false,                                    
            Case_Record_Type_Picklist__c = 'Activation Workflow Case',     
            Origin = 'Workflow',                                           
            Subject = 'Activation Workflow Case',                          
            Flag_for_Supervisor_Review__c = false,                         
            Start_Pending_Cancellation__c = false,
            RecordTypeId = CaseRTID                         
        );
        insert cs;   
        System.debug('xxx Initial_Case_Creation_Date__c ' + cs.Initial_Case_Creation_Date__c);
        System.debug('xxx Subsequent_Case_Creation_Date__c ' + cs.Subsequent_Case_Creation_Date__c);


        ID batchprocessid = Database.executeBatch(new CreateOBManualFollowupPICsBatch(), 20);
        ReverseCancellationQueueable.futureCall('backendId', System.today(), 'userName');

    }
    @testSetup private static void setup() {
        Date bDate = Date.newInstance(2021, 01, 01);
        Date eDate = Date.newInstance(2021, 01, 5);

        Date hbegin = Date.newInstance(2021, 01, 01);
        Date hend = Date.newInstance(2021, 12, 31);
        Date christmas = Date.newInstance(2021, 12, 31);
        Date thanksgiving = Date.newInstance(2021, 12, 31);
        
        
        Holiday h1 = new Holiday(
            NAME= 'New Year',
            ISALLDAY = true,
            ACTIVITYDATE = christmas,
            ISRECURRENCE = true,	
            RECURRENCESTARTDATE = hbegin,
            RECURRENCEENDDATEONLY = hend,	
            RECURRENCETYPE = 'RecursYearly',	
            RECURRENCEDAYOFMONTH = 1,
            RECURRENCEMONTHOFYEAR = 'January'
        );  
        
        Holiday h2 = new Holiday(
            NAME= 'New Year',
            ISALLDAY = true,
            ACTIVITYDATE = thanksgiving,
            ISRECURRENCE = true,	
            RECURRENCESTARTDATE = hbegin,
            RECURRENCEENDDATEONLY = hend,	
            RECURRENCETYPE = 'RecursYearly',	
            RECURRENCEDAYOFMONTH = 27,
            RECURRENCEMONTHOFYEAR = 'November'
        );         

        List<Holiday> h = new List<Holiday>();
        h.add(h1);
        h.add(h2);
        insert h;
    
    }          
}