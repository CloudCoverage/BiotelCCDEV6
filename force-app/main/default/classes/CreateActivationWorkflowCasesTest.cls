@isTest(seeAllData=true)

public with sharing class CreateActivationWorkflowCasesTest {

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

            Order sobj1 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'EMW2021-06.14v80',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'asdfasdfasdf20',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
    
        Order sobj2 = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v81',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf21',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
            );
        Order sobj3 = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v82',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf22',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
            );
        Order sobj4 = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v83',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf23',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
            );

            Order sobj5 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'EMW2021-06.14v85',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'asdfasdfasdf25',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
        Order sobj6 = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v86',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf26',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
            );
        Order sobj7 = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v87',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf27',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
            );                                        
            Order sobj8 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'EMW2021-06.14v88',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'asdfasdfasdf28',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
        Order sobj9 = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v89',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf29',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
            );
        Order sobj10 = new Order(
            Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
            Service_Type__c = 'OTS',    
            AccountId = acc.Id,                                               // Service Type
            Billing_Status__c = 'Pending',                                             // NextGen Status
            Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
            Enrollment_Number__c = 'EMW2021-06.14v810',                                  // Enrollment Number
            Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
            Device_Source__c = 'OTS',                                                  // Device Source
            Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
            Patient_Contact_ID__c = con.Id,                                 // Patient Contact
            Patient_Birthdate__c = System.today(),                           // Patient Birthdate
            Patient_Gender__c = 'Female',                                              // Patient Gender
            Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
            Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
            Enrollment_Backend_ID__c = 'asdfasdfasdf210',                                // Enrollment Backend ID
            EffectiveDate = System.today(),                                 // Order Start Date
            Status = 'Submitted',                                                      // Status
            Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
            Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
            AD_Start_Date__c = System.today(),                              // AD Start Date
            Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
            Button_Disabled__c = false,                                                // Button Disabled
            Exclude_from_Backfill__c = false                                          // Exclude from Backfill
            );
            Order sobj1x = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v8',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf2',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
            
                Order sobj11 = new Order(
                    Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                    Service_Type__c = 'OTS',    
                    AccountId = acc.Id,                                               // Service Type
                    Billing_Status__c = 'Pending',                                             // NextGen Status
                    Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                    Enrollment_Number__c = 'xxW2021-06.14v80',                                  // Enrollment Number
                    Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                    Device_Source__c = 'OTS',                                                  // Device Source
                    Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                    Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                    Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                    Patient_Gender__c = 'Female',                                              // Patient Gender
                    Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                    Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                    Enrollment_Backend_ID__c = 'xxdfasdfasdf20',                                // Enrollment Backend ID
                    EffectiveDate = System.today(),                                 // Order Start Date
                    Status = 'Submitted',                                                      // Status
                    Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                    Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                    AD_Start_Date__c = System.today(),                              // AD Start Date
                    Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                    Button_Disabled__c = false,                                                // Button Disabled
                    Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                    );
            
            Order sobj12 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v81',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf21',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
            Order sobj13 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v82',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf22',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
            Order sobj14 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v83',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf23',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
            
                Order sobj15 = new Order(
                    Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                    Service_Type__c = 'OTS',    
                    AccountId = acc.Id,                                               // Service Type
                    Billing_Status__c = 'Pending',                                             // NextGen Status
                    Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                    Enrollment_Number__c = 'xxW2021-06.14v85',                                  // Enrollment Number
                    Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                    Device_Source__c = 'OTS',                                                  // Device Source
                    Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                    Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                    Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                    Patient_Gender__c = 'Female',                                              // Patient Gender
                    Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                    Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                    Enrollment_Backend_ID__c = 'xxdfasdfasdf25',                                // Enrollment Backend ID
                    EffectiveDate = System.today(),                                 // Order Start Date
                    Status = 'Submitted',                                                      // Status
                    Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                    Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                    AD_Start_Date__c = System.today(),                              // AD Start Date
                    Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                    Button_Disabled__c = false,                                                // Button Disabled
                    Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                    );
            Order sobj16 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v86',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf26',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
            Order sobj17 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v87',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf27',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );                                        
                Order sobj18 = new Order(
                    Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                    Service_Type__c = 'OTS',    
                    AccountId = acc.Id,                                               // Service Type
                    Billing_Status__c = 'Pending',                                             // NextGen Status
                    Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                    Enrollment_Number__c = 'xxW2021-06.14v88',                                  // Enrollment Number
                    Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                    Device_Source__c = 'OTS',                                                  // Device Source
                    Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                    Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                    Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                    Patient_Gender__c = 'Female',                                              // Patient Gender
                    Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                    Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                    Enrollment_Backend_ID__c = 'xxdfasdfasdf28',                                // Enrollment Backend ID
                    EffectiveDate = System.today(),                                 // Order Start Date
                    Status = 'Submitted',                                                      // Status
                    Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                    Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                    AD_Start_Date__c = System.today(),                              // AD Start Date
                    Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                    Button_Disabled__c = false,                                                // Button Disabled
                    Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                    );
            Order sobj19 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v89',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf29',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );
            Order sobj110 = new Order(
                Patient_Special_Instructions__c = 'OTS Order - EMW Created 6/14/2021 v8',// Patient Special Instructions
                Service_Type__c = 'OTS',    
                AccountId = acc.Id,                                               // Service Type
                Billing_Status__c = 'Pending',                                             // NextGen Status
                Activation_Workflow_Status__c = 'Awaiting Activation',                     // Activation Workflow Status
                Enrollment_Number__c = 'xxW2021-06.14v810',                                  // Enrollment Number
                Visit_Date__c = System.today(),                 // Enrollment Submitted Date/Time
                Device_Source__c = 'OTS',                                                  // Device Source
                Name = 'Kelly Zitka - OTS - 6/14/2021',                                    // Order Name
                Patient_Contact_ID__c = con.Id,                                 // Patient Contact
                Patient_Birthdate__c = System.today(),                           // Patient Birthdate
                Patient_Gender__c = 'Female',                                              // Patient Gender
                Patient_Home_Phone__c = '5553332222',                                      // Patient Home Phone
                Order_Physician_Contact_ID__c = con.Id,                         // Order Physician Contact
                Enrollment_Backend_ID__c = 'xxdfasdfasdf210',                                // Enrollment Backend ID
                EffectiveDate = System.today(),                                 // Order Start Date
                Status = 'Submitted',                                                      // Status
                Enrollment_Created_Date__c = System.today(),    // Enrollment Created Date
                Enrollment_Modified_Date__c = System.today(),   // Enrollment Modified Date
                AD_Start_Date__c = System.today(),                              // AD Start Date
                Activation_AD_Enabled__c = true,                                          // Activation AD Enabled
                Button_Disabled__c = false,                                                // Button Disabled
                Exclude_from_Backfill__c = false                                          // Exclude from Backfill
                );                         

        List<Order> sobjs = new List<Order>();
        sobjs.add(sobj);
        sobjs.add(sobj1);
        sobjs.add(sobj2);
        sobjs.add(sobj3);
        sobjs.add(sobj4);
        sobjs.add(sobj5);
        sobjs.add(sobj6);
        sobjs.add(sobj7);
        sobjs.add(sobj8);
        sobjs.add(sobj9);
        sobjs.add(sobj10);

        sobjs.add(sobj1x);
        sobjs.add(sobj11);
        sobjs.add(sobj12);
        sobjs.add(sobj13);
        sobjs.add(sobj14);
        sobjs.add(sobj15);
        sobjs.add(sobj16);
        sobjs.add(sobj17);
        sobjs.add(sobj18);
        sobjs.add(sobj19);
        sobjs.add(sobj110);        

            insert sobjs;
            //sobj.AD_Start_Date__c = System.today().addDays(25);  
            //sobj.Activation_AD_Enabled__c = false;                            // AD Start Date
            //update sobj;
            //sobj.Activation_AD_Enabled__c = true;
            //update sobj;

    }


}