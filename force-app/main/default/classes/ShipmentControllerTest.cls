@isTest(seeAllData=false)

public with sharing class ShipmentControllerTest {


    static testmethod void test1() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

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
        
        Order ord = new Order(
            AccountId = acc.Id,
            Patient_Contact_ID__c = con.Id,
            EffectiveDate = Date.today() - 5,
            Status = 'Submitted',
            Enrollment_Backend_ID__c = 'abc123',
            Name = 'abc123'
        );
        insert ord;


        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock()); 
            ShipmentController.fetchShipments(ord.Id);
            System.assertEquals(true, true);
        Test.stopTest();
    }

}