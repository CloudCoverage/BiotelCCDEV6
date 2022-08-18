@isTest(seeAllData=false)

public with sharing class OrderTriggerHandlerTest {

    static testmethod void testActivationAdEnabledFlag(){
        TestData.buildFoundation();
        Order order = [SELECT Id FROM Order WHERE Enrollment_Number__c = 'test123' LIMIT 1];
        order.AD_Start_Date__c = System.today().addDays(25);  
        order.Activation_AD_Enabled__c = false;                            // AD Start Date
        Database.SaveResult assert1 = Database.Update(order);
        System.assertEquals(true, assert1.isSuccess());

        order.Activation_AD_Enabled__c = true;
        Database.SaveResult assert2 = Database.Update(order);
        System.assertEquals(true, assert2.isSuccess());

    }
    static testmethod void updateFaxAndSpecialIntructionTest(){

        TestData.buildFoundation();
        Test.startTest();
            List<Fax_Enrollment__c> faxes = TestData.buildBTHFaxEnrollmentList(99);
            System.assertEquals(99, faxes.size(), 'fax list count should be 99');

            List<Order> orders = TestData.buildOrderList(99);
            System.assertEquals(99, orders.size(), 'order list count should be 99');

        Test.stopTest();

    }


}