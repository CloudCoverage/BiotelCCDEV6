@isTest
public with sharing class MiddlewareTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Account testContactAccount = new Account();
        testContactAccount.Name = 'Contact Account';
        testContactAccount.Type = 'Practice';
        testContactAccount.Sub_Type__c = 'Other';
        insert testContactAccount;

        Map<String,Schema.RecordTypeInfo> rtMapContByName = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
		id recordtypeHPatient = rtMapContByName.get('Patient_Contact').getRecordTypeId();
        Contact testContact = new Contact();
        testContact.LastName = 'Test Last Name';
        testContact.RecordTypeId = recordtypeHPatient;
        testContact.AccountId = testContactAccount.Id;
        testContact.Email = 'test@test.com';
        insert testContact;

        Account testOrderAccount = new Account();
        testOrderAccount.Name = 'Order Account';
        testOrderAccount.Type = 'Practice';
        testOrderAccount.Sub_Type__c = 'Other';
        insert testOrderAccount;

        Monitoring_System__c testMonitoringSystem = new Monitoring_System__c();
        testMonitoringSystem.Name = 'Test Monitoring System';
        insert testMonitoringSystem;

        Date todayDate = Date.today();

        Prescription_Mapping__c testPrescriptionMappingBefore = new Prescription_Mapping__c();
        testPrescriptionMappingBefore.Monitoring_System__c = testMonitoringSystem.Id;
        testPrescriptionMappingBefore.Prescription_End_Datetime__c = Datetime.newInstance(todayDate.year(),todayDate.month(),todayDate.day());
        insert testPrescriptionMappingBefore;

        Order testOrderBefore = new Order();
        testOrderBefore.AccountId = testOrderAccount.Id;
        testOrderBefore.Activation_Workflow_Status__c = 'Activation Complete';
        testOrderBefore.Prescription_Mapping_Lookup__c = testPrescriptionMappingBefore.Id;
        testOrderBefore.Patient_Contact_ID__c = testContact.Id;
        testOrderBefore.Status = 'Submitted';
        testOrderBefore.EffectiveDate = Date.Today();
        testOrderBefore.Device_Order_Number__c = 'Before Test';
        testOrderBefore.Enrollment_Backend_ID__c = '74322126-047d-006f-00b7-d8afefc91729';
        insert testOrderBefore;
    }

    @isTest
    static void eventTest(){
        Middleware_Event__e middlewareEvent = new Middleware_Event__e();
        middlewareEvent.Event_Type__c = 'DeviceRetrievalNotification';
        middlewareEvent.Object_Type__c = 'Enrollment';
        middlewareEvent.Object_GUID__c='74322126-047d-006f-00b7-d8afefc91729';
                
        Test.startTest();
        
            Database.SaveResult sr = EventBus.publish(middlewareEvent);

            Test.getEventBus().deliver();
            
        Test.stopTest();
        
               
        System.assertEquals(true, sr.isSuccess());
        
        
        List<Send_Queue__c> sqResultList = [SELECT Id FROM Send_Queue__c];
        System.debug('MiddlewareTriggerHandlerTest.sqResultList ' + sqResultList);
        
        System.assertEquals(1, sqResultList.size());
    } 

    @isTest
    static void bulkEventTest(){
        List<Middleware_Event__e> middlewareEventList = new List<Middleware_Event__e>();

        /*for(Integer i = 0; i < 10; i++){
            Middleware_Event__e middlewareEvent = new Middleware_Event__e();
            middlewareEvent.Event_Type__c = 'DeviceRetrievalNotification';
            middlewareEvent.Object_Type__c = 'Enrollment';
            middlewareEvent.Object_GUID__c='74322126-047d-006f-00b7-d8afefc91729';
            middlewareEventList.add(middlewareEvent);
        }*/
        Middleware_Event__e middlewareEvent = new Middleware_Event__e();
        middlewareEvent.Event_Type__c = 'DeviceRetrievalNotification';
        middlewareEvent.Object_Type__c = 'Enrollment';
        middlewareEvent.Object_GUID__c='74322126-047d-006f-00b7-d8afefc91729';
        middlewareEventList.add(middlewareEvent);

        Middleware_Event__e middlewareEvent1 = new Middleware_Event__e();
        middlewareEvent1.Event_Type__c = 'NonConnectedPerpetualDeviceRetrieval';
        middlewareEvent1.Object_Type__c = 'Enrollment';
        middlewareEvent1.Object_GUID__c='3ee63f3d-f2b5-fc5c-3f70-f8491dc072b3';
        middlewareEventList.add(middlewareEvent1);

        Middleware_Event__e middlewareEvent2 = new Middleware_Event__e();
        middlewareEvent2.Event_Type__c = 'NonConnectedNonPerpetualDeviceRetrieval';
        middlewareEvent2.Object_Type__c = 'Enrollment';
        middlewareEvent2.Object_GUID__c='3ee63f3d-f2b5-fc5c-3f70-f8491dc072b3';
        middlewareEventList.add(middlewareEvent2);
                      
        Test.startTest();
        
            List<Database.SaveResult> srList = EventBus.publish(middlewareEventList);
            System.debug('MiddlewareTriggerHandlerTest.srList '+srList);

            //Test.getEventBus().deliver();
            
        Test.stopTest();
        
        List<Send_Queue__c> sqResultList = [SELECT Id FROM Send_Queue__c];
        System.debug('MiddlewareTriggerHandlerTest.sqResultList ' + sqResultList);
        
        System.assertEquals(1, sqResultList.size());
    }
}