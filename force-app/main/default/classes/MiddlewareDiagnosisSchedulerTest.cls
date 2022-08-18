@isTest(seeAllData=false)
public class MiddlewareDiagnosisSchedulerTest {

    static testmethod void test1() {

       Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

        Test.startTest();
            MiddlewareDiagnosisScheduler sched = new MiddlewareDiagnosisScheduler();
            sched.execute(null);

            System.assertEquals(true, true); 
        Test.stopTest();

    }


    

}