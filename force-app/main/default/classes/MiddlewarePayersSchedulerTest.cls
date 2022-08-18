@isTest(seeAllData=false)

public class MiddlewarePayersSchedulerTest {
    static testmethod void getPayerTest() {

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewarePayersScheduler middlewarePayers = new MiddlewarePayersScheduler();
            middlewarePayers.execute(null);

            List<Payer_Info__c> payerList = [SELECT Id FROM Payer_Info__c];
        Test.stopTest();
        System.assertEquals(payerList.size(), 2, 'Payer List should have 2 records');

    }
}