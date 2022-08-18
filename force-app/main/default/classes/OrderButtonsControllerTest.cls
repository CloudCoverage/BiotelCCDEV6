@isTest(seeAllData=false)
public class OrderButtonsControllerTest {
    static testmethod void test1(){
        Order o = [SELECT Id, Enrollment_Backend_ID__c From Order LIMIT 1];
        Case c = [SELECT Id From Case WHERE Order__c = :o.Id LIMIT 1];

        OrderButtonsController.MakeCallOut(o.Id, c.Id,  o.Enrollment_Backend_ID__c, 'reverseCancellation', null, 'Cost', null);
        OrderButtonsController.mockMiddlewareResponse();
    }
    static testmethod void test2(){
        Order o = [SELECT Id, Enrollment_Backend_ID__c From Order LIMIT 1];
        Case c = [SELECT Id From Case WHERE Order__c = :o.Id LIMIT 1];

        OrderButtonsController.MakeCallOut(o.Id, c.Id, o.Enrollment_Backend_ID__c, 'cancelOrder', null, 'Cost', null);
        OrderButtonsController.mockMiddlewareResponse();
    }    
    @TestSetup
    static void makeData(){
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
            
            Id CaseRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
            Case cs = new Case(
                Status = 'Awaiting Activation',                              
                Order__c = order.Id,                                        
                Closed_Result__c = 'N/A',                                      
                ContactId = con.Id,                                       
                Activation_AD_Enabled__c = false,                              
                Initial_Case_Creation_Date__c = System.today(),      
                AD_Start_Date__c = System.today(),                  
                Subsequent_Case_Creation_Date__c = System.today(),  
                Priority = 'Medium',                                           
                Button_Disabled__c = false,                                    
                //Case_Record_Type_Picklist__c = 'Activation Workflow Case',     
                Origin = 'Workflow',                                           
                Subject = 'Activation Workflow Case',                          
                Flag_for_Supervisor_Review__c = false,                         
                Start_Pending_Cancellation__c = false                         
            );
            insert cs; 
            
            Case_Reason_Lookup__c cl = new Case_Reason_Lookup__c(
                Case_Record_Type__c = 'Patient',                                   // Case Record Type
                Active__c = true,                                                                    // Active
                Department__c = 'Operations',                                                         // Department
                Notify_AE__c = false,                                                                 // Notify AE
                Category__c = 'Device Activation',                                                    // Category
                Definition__c = 'Parent Case used to monitor/manage the work to activate an order.',  // Definition
                Name = 'Complete Reverse Cancellation',                                                         // Case Reasons Name
                Case_Type__c = 'Workflow',                                                      // Case Type
                Interaction_Type__c = '',                                               // Interaction Type
                External_Id__c = 'a0Q0R000003bqUgUAI'                                                // External Id
              );
              insert cl;
            System.debug('cl '+ cl);            
    }
}