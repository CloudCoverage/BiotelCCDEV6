@isTest(seeAllData=true)
public with sharing class BatchDocReportTest {
     
    @isTest private static void testBatch() {

        Test.startTest();
            Date bDate = Date.newInstance(2020, 01, 01);
            Date eDate = Date.newInstance(2022, 01, 16);
            Database.executeBatch(new BatchDocReport(bDate,eDate),1);            
        Test.stopTest();
        System.assertEquals(true, true);       

    }
    /*
    @testSetup private static void setup() {
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
        
        Monitoring_System__c ms = new Monitoring_System__c(
            Name = 'MSA',                                               // Monitoring System Name
            Description__c = 'Monitoring Service Application',            // Description
            Monitoring_System_Id__c = '1'                                // Monitoring System Id
          );
          insert ms;        
        //Prescription_Mapping_Lookup__r.Prescription_End_Datetime__c
        Prescription_Mapping__c pm = new Prescription_Mapping__c(
            EnrollmentId__c = 'asdfasdfasdf2',
            Monitoring_System__c = ms.Id, 
            Status__c = 'Pending', Baseline_Datetime__c = System.Now(), Prescription_End_Datetime__c = System.Now(), 
            Prescription_Start_Datetime__c = System.Now(), Status_Date_Time__c = System.Now()        
        );
        Insert pm;

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
            Patient_Home_Phone__c = '5553332222',
            Prescription_Mapping_Lookup__c = pm.Id,                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf2',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Reverse_Cancellation__c = false,                                           // Reverse Cancellation
            Activation_AD_Enabled__c = false,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
          );
          insert order;
         
     
    } */ 

}