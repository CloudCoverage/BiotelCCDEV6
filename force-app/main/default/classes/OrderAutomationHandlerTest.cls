@isTest(seeAllData=false)

public with sharing class OrderAutomationHandlerTest {
       
    @isTest
    static void bulkFaxToOrderWithSpecialInstructCases(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        List<Fax_Enrollment__c> bulkFaxes = new List<Fax_Enrollment__c>();
        for(Integer i = 0; i < 200; i++){
            Fax_Enrollment__c fax = new Fax_Enrollment__c();
            fax.Patient_First_Name__c = 'TestFirst' + i;
            fax.Patient_Last_Name__c = 'TestLast';
            fax.Patient_Date_of_Birth__c = Date.today();
            fax.Practice_Location__c = acc.Id;
            fax.Submission_Id__c = 'enrollmentid' + i;
            fax.Enrollment_Number__c = '' + i;
            bulkFaxes.add(fax);
        }
        insert bulkFaxes;
        
        List<Order> bulkOrders = new List<Order>();
        for(Integer i = 0; i < 200; i++){
            Order ord = new Order();
            ord.AccountId = acc.Id;
            ord.Status = 'Submitted';
            ord.EffectiveDate = Date.today();
            ord.Enrollment_Backend_ID__c = 'enrollmentid' + i;
            ord.Enrollment_Number__c = '' + i;
            ord.Enrollment_Special_Instructions__c = 'specialist instructions';
            bulkOrders.add(ord);
        }
        Test.startTest();
        	insert bulkOrders;
        Test.stopTest();
        
        List<Fax_Enrollment__c> updatedFaxes = [SELECT Id, Order__c, Practice_Location__c
                                               FROM Fax_Enrollment__c
                                                WHERE Practice_Location__c = :acc.Id
                                               AND Order__c != NULL];
        System.assertEquals(200, updatedFaxes.size(), 'All 200 Faxes should have been associated to Orders');
        List<Id> orderIds = new List<Id>();
        for(Fax_Enrollment__c fax : updatedFaxes){
            orderIds.add(fax.Order__c);
        }
        
        List<Case> enrollmentSpecialInstCases = [SELECT Id 
                                                 FROM Case 
                                                 WHERE Subject = 'Enrollment Special Instructions'
                                                 AND Order__c IN :orderIds];
        System.assertEquals(200, enrollmentSpecialInstCases.size(), 'Each order should have had a special instructions Case');
    }

    static testmethod void insertPlatformEventsTest(){
        TestData.buildFoundation();
        List<Fax_Enrollment__c> faxes = TestData.buildBTHFaxEnrollmentList(2);
        List<Order> orders = TestData.buildOrderList(2);

        List<Order_Automation__e> orderEvents = new List<Order_Automation__e>();

        Test.startTest();

            for(Order order : orders){
                orderEvents.add(createQueue(order.Id, 'UpdateFaxViaEncounter'));
                orderEvents.add(createQueue(order.Id, 'UpdateFaxViaEnrollment'));
                orderEvents.add(createQueue(order.Id, 'createSpecialInstructionCase'));
            }
        
            List<Database.SaveResult> saveResult = EventBus.publish(orderEvents);

            Test.getEventBus().deliver();
            
        Test.stopTest();
        
               
        System.assertEquals(true, saveResult[0].isSuccess());
        System.assertEquals(true, saveResult[1].isSuccess());
        List<Case> enrollmentSpecialInstCases = [SELECT Id FROM Case WHERE Subject = 'Enrollment Special Instructions'];
        System.assertEquals(2, enrollmentSpecialInstCases.size());
        
        
        List<Fax_Enrollment__c> faxList = [SELECT Id FROM Fax_Enrollment__c Where Order__c != null];
        System.debug('OrderAutomationHandlerTest.sqResultList ' + faxList);
        
        System.assertEquals(2, faxList.size(), 'enrollmentSpecialInstCases list count should be 2');
    }
    
    private static Order_Automation__e createQueue(Id id, String type){
        return new Order_Automation__e(Order_Id__c = id, Type__c = type, User_Name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName());

    }    
}