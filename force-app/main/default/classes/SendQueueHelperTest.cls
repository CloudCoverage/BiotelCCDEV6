@isTest(seeAllData=false)
public with sharing class SendQueueHelperTest {
    static testmethod void test1() {
        SendQueueHelper sqh = new SendQueueHelper();
        SendQueueHelper sqh1 = new SendQueueHelper('Delivery_Confirmation');

        Send_Queue_Settings__mdt setting = [
            SELECT Label, Tepmplate_Id__c, From_Email__c, Template_Name__c, Test_To_Email__c, Test_Tracking_Number__c 
              FROM Send_Queue_Settings__mdt
            WHERE Label = 'Shipment_Confirmation'
              ];

        Order o = [Select Id, Patient_Contact_ID__c, Enrollment_Number__c from Order WHERE Enrollment_Number__c = 'test123'];
        Contact c = [Select Id from Contact WHERE LastName = 'Doe'];

        Send_Queue__c sq = new Send_Queue__c(
            Patient__c = c.Id,
            Enrollment__c = o.Id,
            Type__c = 'Email',
            Event__c = 'Shipment_Confirmation',
            Status__c = 'Ready to Process',
            Tracking_Number__c = 'abc123',
            From__c = setting.From_Email__c,
            Template_Name__c = setting.Template_Name__c,
            Estimated_Delivery_Date__c = System.today(),
            Shipment_Date__c = System.today()


        );
        //insert sq;

        List<Send_Queue__c> sqList = [SELECT Id, Patient__c, Enrollment__c, Event__c, Status__c, Type__c, Template_ID__c, Send_Successful__c, 
        Shipment_Date__c, Shipment_Delivery_Date__c, From__c, To__c, Error_Message__c, Sent_Timestamp__c, Tracking_Number__c, Name, Body__c  
        FROM Send_Queue__c];

        sqh.processEvents(sqList);
        sqh.createEmail(sqList[0]);
        SendQueueHelper.createTask('test', sqList[0], true, 'test');
        sqh.createSendQueRecord(o, 'asdfasdf');
        sqh.createSendQueRecord(sq, 'asdfasdf', 'Shipment_Confirmation', 'Shipment_Confirmation');
        sqh.createSendQueRecord(o, 'Shipment_Confirmation', 'test@test.com', 'Pending');
    }
    static testmethod void test2() {

        List<Send_Queue_Settings__mdt> settings = [
            SELECT Label, Tepmplate_Id__c, From_Email__c, Template_Name__c, Test_To_Email__c, Test_Tracking_Number__c 
              FROM Send_Queue_Settings__mdt
              ];        
        Order o = [Select Id from Order WHERE Enrollment_Number__c = 'test123'];
        Contact c = [Select Id from Contact WHERE LastName = 'Doe'];

        Send_Queue__c sq = new Send_Queue__c(
            Patient__c = c.Id,
            Enrollment__c = o.Id,
            Type__c = 'Email',
            Event__c = 'Shipment_Confirmation',
            Status__c = 'Ready to Process',
            Tracking_Number__c = 'abc123',
            From__c = settings[0].From_Email__c,
            Template_Name__c = settings[0].Template_Name__c
        );

        insert sq;        
        Test.startTest();
        BatchSendMessages sched = new BatchSendMessages();
            sched.execute(null);
        Test.stopTest();
    }
    
    static testmethod void test3() {

        List<Send_Queue_Settings__mdt> settings = [
            SELECT Label, Tepmplate_Id__c, From_Email__c, Template_Name__c, Test_To_Email__c, Test_Tracking_Number__c 
              FROM Send_Queue_Settings__mdt
              ];        
        Order o = [Select Id from Order WHERE Enrollment_Number__c = 'test123'];
        Contact c = [Select Id from Contact WHERE LastName = 'Doe'];

        Send_Queue__c sq = new Send_Queue__c(
            Patient__c = c.Id,
            Enrollment__c = o.Id,
            Type__c = 'Email',
            Event__c = 'Delivery_Confirmation',
            Status__c = 'Ready to Process',
            Tracking_Number__c = 'abc123',
            From__c = settings[0].From_Email__c,
            Template_Name__c = settings[0].Template_Name__c
        );

        insert sq;        
        Test.startTest();
        BatchSendMessages sched = new BatchSendMessages();
            sched.execute(null);
        Test.stopTest();
    }    

    @TestSetup 
    private static void setupData() {

        TestData.buildFoundation();
    }     
}