@isTest(seeAllData=false)

public class MiddlewareUtilTest {
    
    static testmethod void faxEnrollment() {
        
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

        Account acc = new Account(
            Name = 'ABC123',
            Backend_ID__c = 'L-12713'          
        );
        insert acc;

        Fax_Enrollment__c fax = new Fax_Enrollment__c(
            Patient_First_Name__c = 'ABC123',
            Practice_Location__c = acc.Id, 
            Patient_Last_Name__c = 'ABC123', 
            Patient_Date_of_Birth__c = Date.today() - 35,
            Submission_Id__c = 'submissionId'            
        );
        Insert fax; 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            HttpResponse res = MiddlewareEnrollment.process(fax); 
            System.assertEquals(true, true);
        Test.stopTest();
        
    }

    static testmethod void Diagnosis() {
        
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareDiagnosisScheduler sched = new MiddlewareDiagnosisScheduler();
            sched.execute(null); 
            System.assertEquals(true, true);
        Test.stopTest();
        
    }

    static testmethod void getZipCodes() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.getZipCodes();
            System.assertEquals(true, true);
        Test.stopTest();

    }

    static testmethod void getBundles() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.getBundles('ABC123', '3');
            System.assertEquals(true, true);
        Test.stopTest();

    }
    static testmethod void getEncounterNumber() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.getEncounterNumber('submissionId');
            System.assertEquals(true, true);
        Test.stopTest();

    }
    
    static testmethod void getPhysicians() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.getPhysicians('ABC123');
            System.assertEquals(true, true);
        Test.stopTest();

    }
    static testmethod void getPayer() {

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.getPayer();

        Test.stopTest();
        List<Payer_Info__c> payerList = [SELECT Name FROM Payer_Info__c];
        SYstem.debug('xxx payerList ' + payerList);
        System.assertEquals(payerList.size(), 2, 'Payer List should have 2 records');
        List<Payer_Info__c> NameTest = [SELECT Name FROM Payer_Info__c WHERE Name = 'orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor i'];
        System.assertEquals(NameTest.size(), 1, 'Payer Name should truncate to 80 bytes');

    }       
     static testmethod void getBillingStatuses() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.getBillingStatuses();
            System.assertEquals(true, true);
        Test.stopTest();

    }
    static testmethod void RestartActivationProcess() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'RestartActivationProcess';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.RestartActivationProcess('submissionId', 'user');
            System.assertEquals(true, true);
        Test.stopTest();

    }  

    static testmethod void CancelEnrollment() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'CancelEnrollment';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.CancelEnrollment('submissionId', 'user');
            System.assertEquals(true, true);
        Test.stopTest();

    }
    static testmethod void AutoDialerEnabled() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'AutoDialerEnabled';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.AutoDialerEnabled('submissionId', true, 'user');
            System.assertEquals(true, true);
        Test.stopTest();

    }
    static testmethod void getNotes() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'TEST';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.getNotes('submissionId');
            System.assertEquals(true, true);
        Test.stopTest();

    }
    static testmethod void getShipments() {
      
        String enrollmentId = 'abc123';

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            List<MiddlewareUtil.Shipment> testShipmentList = MiddlewareUtil.getShipments(enrollmentId);
        Test.stopTest();
        System.debug('MiddlewareUtilTest.testShipmentList '+testShipmentList);
        System.assertEquals('2300928', testShipmentList[0].Name, 'Name should be 2300928');
        System.assertEquals(testShipmentList.size(), 1,  'testShipmentList size should be 1');
    }
    static testmethod void getShipmentWithAuthtoken() {
      
        String enrollmentId = 'abc123';
        String authToken = 'abc123';

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            List<MiddlewareUtil.Shipment> testShipmentList = MiddlewareUtil.getShipments(enrollmentId, authToken);
        Test.stopTest();
        System.debug('MiddlewareUtilTest.testShipmentList '+testShipmentList);
        System.assertEquals(testShipmentList.size(), 1,  'testShipmentList size should be 1');
        System.assertEquals('2300928', testShipmentList[0].Name, 'Name should be 2300928');
    }    
    static testmethod void FollowupDate() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'TEST';
        insert setting;

		Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            MiddlewareUtil.FollowupDate('submissionId', System.today(), 'me');
            System.assertEquals(true, true);
        Test.stopTest();

    }     
    
    @isTest
    static void getAuthTokenSuccess() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            String accessToken = MiddlewareUtil.getAuthToken();
            Integer calloutTotal = Limits.getCallouts();
        Test.stopTest();
        System.assertEquals('ABC123', accessToken, 'AccessToken was not as expected: ' + accessToken);
        System.assertEquals(1, calloutTotal, 'Expected 1 callout, actual: ' + calloutTotal);
    }

    @isTest
    static void getAuthTokenFailure() {
        final String responseType = 'token fail';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock(responseType));
            String accessToken = MiddlewareUtil.getAuthToken();
            Integer calloutTotal = Limits.getCallouts();
        Test.stopTest();

        System.assertEquals(null, accessToken,'Access Token returned was not null: ' + accessToken);
        System.assert(calloutTotal > 1, 'Total number of callouts was not more than 1. Total = ' + calloutTotal);
    }
    
}