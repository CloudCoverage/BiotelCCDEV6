@isTest(seeAllData=false)
public class TaskTriggerHandlerTest {
    
    static testmethod void testCaseCloseLogic(){

         List<Order> testOrders = [
            SELECT Id FROM Order WHERE Patient_Home_Phone__c = '5553332222' limit 2
            ];

        Id patientInteractionRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        Contact testContact = [SELECT Id FROM Contact Limit 1];

        Case parentCase = new Case(
            Status = 'New',                                  
            Order__c = testOrders[1].Id,                                        
            ContactId = testContact.Id,                          
            Subject = 'Complete Reverse Cancellation',         
            Service_Type__c = 'All/None',                      
            Activation_AD_Enabled__c = false,                  
            Origin = 'Workflow',                              
            Flag_for_Special_Tracking__c = 'None',             
            Priority = 'Medium',                              
            Case_Record_Type_Picklist__c = 'Patient Support',
            recordTypeId = patientInteractionRT  
          ); 
          INSERT parentCase;       

        Case case1 = new Case(
            Status = 'New',                                  
            ParentId = parentCase.Id,                            
            Order__c = testOrders[1].Id,                                        
            ContactId = testContact.Id,                          
            Subject = 'Complete Reverse Cancellation',         
            Service_Type__c = 'All/None',                      
            Activation_AD_Enabled__c = false,                  
            Origin = 'Workflow',                              
            Flag_for_Special_Tracking__c = 'None',             
            Priority = 'Medium',                              
            Case_Record_Type_Picklist__c = 'Patient Support',
            recordTypeId = patientInteractionRT  
          );

          Case case2 = new Case(
            Status = 'New',                                  
            ParentId = parentCase.Id,                            
            Order__c = testOrders[1].Id,                                        
            ContactId = testContact.Id,                          
            Subject = 'Complete Reverse Cancellation',         
            Service_Type__c = 'All/None',                      
            Activation_AD_Enabled__c = false,                  
            Origin = 'Workflow',                              
            Flag_for_Special_Tracking__c = 'None',             
            Priority = 'Medium',                              
            Case_Record_Type_Picklist__c = 'Patient Support',
            recordTypeId = patientInteractionRT  
          ); 

          insert new List<Case>{case1, case2};   
  
          Profile profile= [
            SELECT Id 
            FROM Profile 
            WHERE Name != 'System Administrator' LIMIT 1]; 
    
          String orgId=UserInfo.getOrganizationId(); 
          String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
      
          Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
          String uniqueName=orgId+dateString+RandomId; 
          
          User testUser = new User(firstname = 'ABC', 
                           lastName = 'XYZ', 
                           email = uniqueName + '@test' + orgId + '.org', 
                           Username = uniqueName + '@test' + orgId + '.org', 
                           EmailEncodingKey = 'ISO-8859-1', 
                           Alias = uniqueName.substring(18, 23), 
                           TimeZoneSidKey = 'America/Los_Angeles', 
                           LocaleSidKey = 'en_US', 
                           LanguageLocaleKey = 'en_US', 
                           ProfileId = profile.Id); 
          
          insert testUser;        
  
          Task task1 = new Task(
              RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId(),
              Status = 'Not Started',
              OwnerId = testUser.Id,
              Subject = 'Ordering Physician',
              WhatId = case1.Id
          );

          Task task2 = new Task(
              RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId(),
              Status = 'Not Started',
              OwnerId = testUser.Id,
              Subject = 'Ordering Physician',
              WhatId = case2.Id
          );          
          List<Task> testTasks = new List<Task>{task1, task2};
          insert testTasks;

          Test.startTest();

            for(Task task : testTasks){
                task.Status = 'Completed';
            }
            update testTasks;
            List<Case> caseResults = [SELECT Id FROM Case WHERE Status = 'Closed' AND ContactId = :testContact.Id]; 
            System.assertEquals(2, caseResults.size());
            Boolean exceptionOccurred = false;
            try{
                System.runAs(testUser){
                DELETE testTasks;
                }
            } catch(Exception e){
                exceptionOccurred = true;
            }  
            System.assert(exceptionOccurred, 'Exception was not Thrown');
         Test.stopTest();
    }   

    static testmethod void testCaseUnresolvedLogic(){

         List<Order> testOrders = [
            SELECT Id FROM Order WHERE Patient_Home_Phone__c = '5553332222' limit 2
            ];

        Id patientInteractionRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        Contact testContact = [SELECT Id FROM Contact Limit 1];

        Case parentCase = new Case(
            Status = 'New',                                  
            Order__c = testOrders[1].Id,                                        
            ContactId = testContact.Id,                          
            Subject = 'Complete Reverse Cancellation',         
            Service_Type__c = 'All/None',                      
            Activation_AD_Enabled__c = false,                  
            Origin = 'Workflow',                              
            Flag_for_Special_Tracking__c = 'None',             
            Priority = 'Medium',                              
            Case_Record_Type_Picklist__c = 'Patient Support',
            recordTypeId = patientInteractionRT  
          ); 
          INSERT parentCase;       

        Case case1 = new Case(
            Status = 'New',                                  
            ParentId = parentCase.Id,                            
            Order__c = testOrders[1].Id,                                        
            ContactId = testContact.Id,                          
            Subject = 'Complete Reverse Cancellation',         
            Service_Type__c = 'All/None',                      
            Activation_AD_Enabled__c = false,                  
            Origin = 'Workflow',                              
            Flag_for_Special_Tracking__c = 'None',             
            Priority = 'Medium',                              
            Case_Record_Type_Picklist__c = 'Patient Support',
            recordTypeId = patientInteractionRT  
          );

          Case case2 = new Case(
            Status = 'New',                                  
            ParentId = parentCase.Id,                            
            Order__c = testOrders[1].Id,                                        
            ContactId = testContact.Id,                          
            Subject = 'Complete Reverse Cancellation',         
            Service_Type__c = 'All/None',                      
            Activation_AD_Enabled__c = false,                  
            Origin = 'Workflow',                              
            Flag_for_Special_Tracking__c = 'None',             
            Priority = 'Medium',                              
            Case_Record_Type_Picklist__c = 'Patient Support',
            recordTypeId = patientInteractionRT  
          ); 

          insert new List<Case>{case1, case2};   
  
          Profile profile= [
            SELECT Id 
            FROM Profile 
            WHERE Name != 'System Administrator' LIMIT 1]; 
    
          String orgId=UserInfo.getOrganizationId(); 
          String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
      
          Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
          String uniqueName=orgId+dateString+RandomId; 
          
          User testUser = new User(firstname = 'ABC', 
                           lastName = 'XYZ', 
                           email = uniqueName + '@test' + orgId + '.org', 
                           Username = uniqueName + '@test' + orgId + '.org', 
                           EmailEncodingKey = 'ISO-8859-1', 
                           Alias = uniqueName.substring(18, 23), 
                           TimeZoneSidKey = 'America/Los_Angeles', 
                           LocaleSidKey = 'en_US', 
                           LanguageLocaleKey = 'en_US', 
                           ProfileId = profile.Id); 
          
          insert testUser;        
  
          Task task1 = new Task(
              RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId(),
              Status = 'Not Started',
              OwnerId = testUser.Id,
              Subject = 'New Payer',
              WhatId = case1.Id
          );

          Task task2 = new Task(
              RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId(),
              Status = 'Not Started',
              OwnerId = testUser.Id,
              Subject = 'Ordering Physician',
              WhatId = case2.Id
          );          
          List<Task> testTasks = new List<Task>{task1, task2};
          insert testTasks;

          Test.startTest();

            for(Task task : testTasks){
                task.Status = 'Unresolved';
            }
            update testTasks;
            Integer emailInvocations = Limits.getEmailInvocations();
            system.assertEquals(1, emailInvocations, 'An email should be sent');

         Test.stopTest();
    }
    static testmethod void testPopulateBillingInfo(){

       List<Order> testOrders = [
          SELECT Id, Enrollment_Backend_ID__c, Reimbursement_Mapping_Lookup__c FROM Order WHERE Enrollment_Backend_ID__c like 'f11c0e8e-2e69-40d9-be0e-a7c2385b7%' limit 2
          ];
        System.debug('xxx testOrders ' + testOrders);

      Id patientInteractionRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
      Contact testContact = [SELECT Id FROM Contact Limit 1];

      Case parentCase = new Case(
          Status = 'New',                                  
          Order__c = testOrders[1].Id,                                        
          ContactId = testContact.Id,                          
          Subject = 'Complete Reverse Cancellation',         
          Service_Type__c = 'All/None',                      
          Activation_AD_Enabled__c = false,                  
          Origin = 'Workflow',                              
          Flag_for_Special_Tracking__c = 'None',             
          Priority = 'Medium',                              
          Case_Record_Type_Picklist__c = 'Patient Support',
          recordTypeId = patientInteractionRT  
        ); 
        INSERT parentCase;       

      Case case1 = new Case(
          Status = 'New',                                  
          ParentId = parentCase.Id,                            
          Order__c = testOrders[0].Id,                                        
          ContactId = testContact.Id,                          
          Subject = 'Complete Reverse Cancellation',         
          Service_Type__c = 'All/None',                      
          Activation_AD_Enabled__c = false,                  
          Origin = 'Workflow',                              
          Flag_for_Special_Tracking__c = 'None',             
          Priority = 'Medium',                              
          Case_Record_Type_Picklist__c = 'Patient Support',
          recordTypeId = patientInteractionRT  
        );

        Case case2 = new Case(
          Status = 'New',                                  
          ParentId = parentCase.Id,                            
          Order__c = testOrders[1].Id,                                        
          ContactId = testContact.Id,                          
          Subject = 'Complete Reverse Cancellation',         
          Service_Type__c = 'All/None',                      
          Activation_AD_Enabled__c = false,                  
          Origin = 'Workflow',                              
          Flag_for_Special_Tracking__c = 'None',             
          Priority = 'Medium',                              
          Case_Record_Type_Picklist__c = 'Patient Support',
          recordTypeId = patientInteractionRT  
        ); 

        insert new List<Case>{case1, case2};   

        Profile profile= [
          SELECT Id 
          FROM Profile 
          WHERE Name != 'System Administrator' LIMIT 1]; 
  
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User testUser = new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = profile.Id); 
        
        insert testUser;        

        Task task1 = new Task(
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId(),
            Status = 'Not Started',
            OwnerId = testUser.Id,
            Subject = 'Ordering Physician',
            WhatId = case1.Id
        );

        Task task2 = new Task(
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId(),
            Status = 'Not Started',
            OwnerId = testUser.Id,
            Subject = 'Ordering Physician',
            WhatId = case2.Id
        );          
        List<Task> testTasks = new List<Task>{task1, task2};

        Test.startTest();

          insert testTasks;

       Test.stopTest();
       List<Task> resultTasks = [SELECT Id FROM Task WHERE Soarian_Encounter_ID__c != null];
       system.assertEquals(2, resultTasks.size(), '2 Tasks should have a Sorian Encounter Id');

  }         

    @testSetup private static void setup() {

      TestData.buildFoundation();
      TestData.buildOrderList(2);    
    }        
}