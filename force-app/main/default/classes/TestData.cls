@isTest
public class TestData {
    
    public static void buildFoundation() {
        User u = new User(Id = UserInfo.getUserId());
        Id patientRecordTypeId    = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Patient_Contact').getRecordTypeId();

        Account practiceLocation = new Account(
          Name = 'Practice Location',
          Backend_ID__c = 'L-11111'          
        );
        insert practiceLocation;
        System.debug('practiceLocation ' +practiceLocation);
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Jon',
            LastName = 'Doe',
            AccountId = practiceLocation.Id,
            Email = 'test@test.com',
            Type__c = 'Patient',
            RecordTypeId = patientRecordTypeId
        );
        System.debug('con ' +con);

        Contact con2 = new Contact(
            FirstName = 'Jon',
            LastName = 'Jon',
            AccountId = acc.Id,
            Email = 'abc@abc.com',
            Type__c = 'Patient',
            RecordTypeId = patientRecordTypeId
        );
        insert new List<Contact>{con, con2};        

        Order mtpOrder = new Order(
            Patient_Special_Instructions__c = 'MTP Order - TEST',
            AccountId = acc.Id,                                               
            Billing_Status__c = 'Pending',                                             
            //Activation_Workflow_Status__c = 'Awaiting Activation',                     
            Enrollment_Number__c = 'test123',                                  
            Visit_Date__c = System.today(),                 
            Device_Source__c = 'MTP',                                                  
            Name = 'TEST - MTP - 6/14/2021',                                    
            Patient_Contact_ID__c = con.Id,                                 
            Patient_Birthdate__c = System.today(),                           
            Patient_Gender__c = 'Female',                                              
            Patient_Home_Phone__c = '5553332222',                                      
            Order_Physician_Contact_ID__c = con.Id,                         
            Enrollment_Backend_ID__c = 'asdfasdfasdf2',                               
            EffectiveDate = System.today(),                                 
            Status = 'Submitted',                                                      
            Enrollment_Created_Date__c = System.today(),    
            Enrollment_Modified_Date__c = System.today(),   
            AD_Start_Date__c = System.today(),                              
            Reverse_Cancellation__c = false,                                           
            Activation_AD_Enabled__c = true,                                         
            Button_Disabled__c = false,                                                
            Exclude_from_Backfill__c = false,
            Service_Type__c = 'MCT'                                          
          );
          insert mtpOrder;
          System.debug('xxx order ' + mtpOrder);

          Order otsOrder = new Order(
            Patient_Special_Instructions__c = 'OTS Order - TEST',
            AccountId = acc.Id,                                               
            Billing_Status__c = 'Pending',                                             
            //Activation_Workflow_Status__c = 'Awaiting Activation',                     
            Enrollment_Number__c = 'ots123',                                  
            Visit_Date__c = System.today(),                 
            Device_Source__c = 'OTS',                                                  
            Name = 'TEST - OTS - 6/14/2021',                                    
            Patient_Contact_ID__c = con.Id,                                 
            Patient_Birthdate__c = System.today(),                           
            Patient_Gender__c = 'Female',                                              
            Patient_Home_Phone__c = '5553332222',                                      
            Order_Physician_Contact_ID__c = con.Id,                         
            Enrollment_Backend_ID__c = 'ots123',                               
            EffectiveDate = System.today(),                                 
            Status = 'Submitted',                                                      
            Enrollment_Created_Date__c = System.today(),    
            Enrollment_Modified_Date__c = System.today(),   
            AD_Start_Date__c = System.today(),                              
            Reverse_Cancellation__c = false,                                           
            Activation_AD_Enabled__c = true,                                         
            Button_Disabled__c = false,                                                
            Exclude_from_Backfill__c = false,
            Service_Type__c = 'MCT'                                          
          );
          insert otsOrder;
          System.debug('xxx order ' + otsOrder);          

          List<Send_Queue_Settings__mdt> settings = [
            SELECT Label, Tepmplate_Id__c, From_Email__c, Template_Name__c, Test_To_Email__c, Test_Tracking_Number__c 
              FROM Send_Queue_Settings__mdt
              ];

         
    }
    public static List<Order> buildOrderList(Integer numOfRecs){

      Id patientRecordTypeId    = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Patient_Contact').getRecordTypeId();
      User u = new User(Id = UserInfo.getUserId());

      Account practiceLocation = [SELECT Id FROM Account WHERE Name = 'Practice Location'];
      


      Contact con = [SELECT Id FROM Contact WHERE Email = 'test@test.com'];

      List<Order> orders = new List<Order>();
      List<Reimbursement_Mapping__c> rcms = new List<Reimbursement_Mapping__c>();


      for(Integer i = 0; i < numOfRecs; i++){

        orders.add(new Order(
          Enrollment_Special_Instructions__c = 'TEST',
          Patient_Special_Instructions__c = 'MTP Order - TEST',
          AccountId = practiceLocation.Id,                                               
          Billing_Status__c = 'Pending',                                             
          //Activation_Workflow_Status__c = 'Awaiting Activation',                     
          Enrollment_Number__c = '1000'+String.valueOf(i),
          EncounterNumber__c = '1000'+String.valueOf(i),
          Visit_Date__c = System.today(),                 
          Device_Source__c = 'MTP',                                                  
          Name = 'TEST'+String.valueOf(i),                                    
          Patient_Contact_ID__c = con.Id,                                 
          Patient_Birthdate__c = System.today().addYears(-50),                           
          Patient_Gender__c = 'Female',                                              
          Patient_Home_Phone__c = '5553332222',                                      
          Order_Physician_Contact_ID__c = con.Id,                         
          Enrollment_Backend_ID__c = 'f11c0e8e-2e69-40d9-be0e-a7c2385b7'+String.valueOf(i),                               
          EffectiveDate = System.today(),                                 
          Status = 'Submitted',                                                      
          Enrollment_Created_Date__c = System.today(),    
          Enrollment_Modified_Date__c = System.today(),   
          AD_Start_Date__c = System.today(),                              
          Reverse_Cancellation__c = false,                                           
          Activation_AD_Enabled__c = false,                                         
          Button_Disabled__c = false,                                                
          Exclude_from_Backfill__c = false,
          Service_Type__c = 'MCT'                                          
        ));

        rcms.add(new Reimbursement_Mapping__c(
          Soarian_Encounter_Id__c = '123abc', 
          EnrollmentID__c = 'f11c0e8e-2e69-40d9-be0e-a7c2385b7'+String.valueOf(i)
        ));

      }
      insert orders;
      insert rcms;
      System.debug('xxx testOrders rcms' + [SELECT Id, EnrollmentID__c, Soarian_Encounter_Id__c FROM Reimbursement_Mapping__c]);
      System.debug('xxx testOrders orders' + [SELECT Id, Enrollment_Backend_ID__c, Reimbursement_Mapping_Lookup__c, Reimbursement_Mapping_Lookup__r.Soarian_Encounter_Id__c FROM Order]);
      return orders;           
     
    }

    public static List<Fax_Enrollment__c> buildINRFaxEnrollmentList(Integer numOfRecs){
      Id recTypeINR = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByName().get('INR Enrollments').getRecordTypeId();
      return buildFaxEnrollmentList(numOfRecs, recTypeINR, 'INR');
    }

    public static List<Fax_Enrollment__c> buildBTHFaxEnrollmentList(Integer numOfRecs){
      Id recTypeBTH = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByName().get('BTH Enrollments').getRecordTypeId();
      return buildFaxEnrollmentList(numOfRecs, recTypeBTH, 'MCT');
    }    

    public static List<Fax_Enrollment__c> buildFaxEnrollmentList(Integer numOfRecs, Id recordTypeId, String serviceType){

      Zip_Code__c zip = new Zip_Code__c(
        Zip_Code__c = '00000',
        City__c = 'Aville', 
        Country__c = 'USA', 
        State__c = 'IL'        
      );
      insert zip;

      Diagnosis_Code__c diagnosisCode = new Diagnosis_Code__c(
        Name = 'Morbid (severe) obesity due to excess calories',
        Code__c = 'E66.01',                                       
        Backend_Id__c = 'E66.01'                                 
      );
      insert diagnosisCode; 
      
      Billing_Status__c billingStatus = new Billing_Status__c(
        Name = 'Pending - Ablation Follow Up'
      );
      insert billingStatus;


      Account practiceLocation = [SELECT Id FROM Account WHERE Name = 'Practice Location'];


      Payer_Info__c payerInfo = new Payer_Info__c(
        Name = 'Test Health',                           
        Payer_Id__c = '301f8969-7efd-456b-b19f-c78eb4a7a633'  
      );
      insert payerInfo;

      List<Fax_Enrollment__c> faxes = new List<Fax_Enrollment__c>();

      for(Integer i = 0; i < numOfRecs; i++){
        faxes.add(new Fax_Enrollment__c(
          Practice_Location__c = practiceLocation.Id,                        
          RecordTypeId = recordTypeId,                                      
          Results_Phone__c = '999-999-9999',                               
          Ordering_Physician__c = '1e2fa095-5275-4568-afda-2df2a2c6a1fc',  
          Results_Fax_Number__c = '999-999-9992',                          
          Notifying_Physician__c = '1e2fa095-5275-4568-afda-2df2a2c6a1fc', 
          Payer_Info__c = payerInfo.Id,                               
          Payer_Id__c = '4ea0f3af-a5b5-4bff-b8a5-aff72fd4a5ea',            
          Visit_Date__c = System.today(),                       
          STAT__c = 'Yes',                                                 
          Fax_Date__c = System.today(),                         
          Service_Type__c = serviceType,                                         
          Enrollment_Number__c = '1000'+String.valueOf(i),
          Encounter_Number__c =  '1000'+String.valueOf(i),                                
          Device_Source__c = 'MTP',                                        
          Diagnosis_Code_Text__c = 'Stupor',                               
          Enrollment_Duration__c = 1,                                    
          Testing_Frequency__c = '2-4',                                    
          Training_Type__c = 'Already Trained',                            
          Billing_Status_Text__c = 'Pending - Ablation Follow Up',         
          Submission_Id__c = 'f11c0e8e-2e69-40d9-be0e-a7c2385b7e'+String.valueOf(i),       
          Status__c = 'Submitted',                                         
          Low__c = '3',                                                    
          High__c = '8',                                                   
          Below__c = '2',                                                  
          Above__c = '9',                                                  
          Patient_First_Name__c = 'Kelly',                                 
          Patient_Last_Name__c = 'Zitka2022-0615v6 INR',                   
          Patient_Date_of_Birth__c = System.today().addYears(-30),             
          Patient_Gender__c = 'Male',                                      
          Patient_Home_Phone__c = '999-999-9999',                          
          Billing_Street__c = '100 Main',                                  
          Billing_Postal_Code_Text__c = '02302',                           
          Billing_City__c = 'Brockton',                                    
          Billing_State__c = 'MA',                                         
          Shipping_Street__c = '100 Main',                                 
          Shipping_Postal_Code_Text__c = '02302',                          
          Shipping_City__c = 'Brockton',                                   
          Shipping_State__c = 'MA',                                        
          LanguageId__c = '10',                                            
          Payer_not_in_List__c = false,                                    
          Policy_ID__c = '123',                                            
          Payer_Name__c = 'AdvcteMdGrpHaltdBhwk',                          
          Guarantor_Relationship_to_Patient__c = 'Self',
          Billing_Postal_Code__c = zip.Id,
          Diagnosis_Code__c = diagnosisCode.Id,
          Billing_Status__c = billingStatus.Id
        ));
      }


      insert faxes;
      return faxes;      
    }

   
}