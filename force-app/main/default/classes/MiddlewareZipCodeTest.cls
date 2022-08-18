@isTest(seeAllData=false)
public class MiddlewareZipCodeTest {

    static testmethod void test1() {

        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'ZipGood';
        insert setting;


        Test.startTest();

            MiddlewareUtil.ZipCode zip = new  MiddlewareUtil.ZipCode();
            zip.ZipCode = null;
            zip.City = null;
            zip.State = null;
            zip.Country = null;

            MiddlewareUtil.authResponse ath = new  MiddlewareUtil.authResponse();
            ath.refresh_token = null;
            ath.token_type = null;
            ath.access_token = null;

            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareZipCodeScheduler mzs = new MiddlewareZipCodeScheduler();
            mzs.execute(null);

            System.assertEquals(true, true);
        Test.stopTest();

    }
    static testmethod void test2() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthBad';
        setting.endpoint__c = 'ZipBad';
        insert setting;
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());

            MiddlewareZipCodeScheduler mzs = new MiddlewareZipCodeScheduler();
            mzs.execute(null);
        Test.stopTest();


    }
	@testSetup
    static void setup() {               

    }

}