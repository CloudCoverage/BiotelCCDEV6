@isTest(seeAllData=false)

public with sharing class BatchSendMessagesTest {
    static testmethod void test1() {

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

    @TestSetup 
    private static void setupData() {

        TestData.buildFoundation();
    }    
}