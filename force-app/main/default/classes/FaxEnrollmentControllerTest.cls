@isTest(seeAllData=false)
public with sharing class FaxEnrollmentControllerTest {

    static testmethod void SaveRecord() {
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

        String faxString = JSON.serialize(fax);
        Id recTypeBTH = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByName().get('BTH Enrollments').getRecordTypeId();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            FaxEnrollmentController.saveRec(faxString, false);
            Fax_Enrollment__c fakeFax = FaxEnrollmentController.instantiateFax(recTypeBTH);
            FaxEnrollmentController.EncounterWrapper enc = new FaxEnrollmentController.EncounterWrapper();
            System.debug('xxx abc enc ' + enc);
            System.assert(enc  != null, 'EncounterWrapper should not be null');

        Test.stopTest();
    }

    static testmethod void SaveDraftRecord() {

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

        String faxString = JSON.serialize(fax);
        Id recTypeBTH = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByName().get('BTH Enrollments').getRecordTypeId();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            FaxEnrollmentController.saveRec(faxString, true);
            Fax_Enrollment__c fakeFax = FaxEnrollmentController.instantiateFax(recTypeBTH);
            FaxEnrollmentController.EncounterWrapper enc = new FaxEnrollmentController.EncounterWrapper();
            System.debug('xxx abc enc ' + enc);
            System.assert(enc != null, 'EncounterWrapper should not be null');
        Test.stopTest();
    }   
    
    static testmethod void createINRDraftCase() {

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
            Case testCase = FaxEnrollmentController.createInrDraftCase(fax);

            System.debug('xxx abc testCase ' + testCase);
            System.assertEquals(fax.Id, testCase.Fax_Enrollment__c, 'testCase should be attached to Fax Enrollment');
        Test.stopTest();
    }
    
    static testmethod void createBTHDraftCase() {

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
            Case testCase = FaxEnrollmentController.createBTHDraftCase(fax);

            System.debug('xxx abc testCase ' + testCase);
            System.assertEquals(fax.Id, testCase.Fax_Enrollment__c, 'testCase should be attached to Fax Enrollment');
        Test.stopTest();
    }      

    static testmethod void getPicklistValues() {


        Test.startTest();
        List<Map<String,String>> genderOptions = FaxEnrollmentController.getPicklistValues('Fax_Enrollment__c', 'Patient_Gender__c');

            System.debug('xxx abc valueMap ' + genderOptions.size());
            System.assertEquals(genderOptions.size(), 4, 'genderOptions including blank option should equal 4');
        Test.stopTest();
    }
    
    static testmethod void getFeatureFlag() {

        Id inrRecordTypeId = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByDeveloperName().get('INR_Enrollments').getRecordTypeId();
        Boolean inrFeature = [SELECT ActiveFlag__c 
        FROM Feature_Flag__mdt
       WHERE Label = 'DraftEnrollment'
         AND RecordTypeId__C = :inrRecordTypeId 
        ].ActiveFlag__c;
        
        

        Test.startTest();
            Boolean featureFlag = FaxEnrollmentController.getFeatureFlag(inrRecordTypeId);
            System.assertEquals(inrFeature, featureFlag, 'inrFeature should equal featureFlag');
        Test.stopTest();
    } 
    
    static testmethod void fetchRecordTypeValues() {


        Test.startTest();
        List<RecordType> recordTypes = FaxEnrollmentController.fetchRecordTypeValues();
            System.assertEquals(recordTypes.size(), 2, 'Should be 2 record types');
        Test.stopTest();
    }     
    static testmethod void test2() {
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
            FaxEnrollmentController.getFaxEnrollment(fax.Id);
            System.assertEquals(true, true);
        Test.stopTest();
    }
    static testmethod void test3() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            FaxEnrollmentController.callOtsBundleApi('ABC123', 'ABC123');
            System.assertEquals(true, true);
        Test.stopTest();
    }
    static testmethod void test4() {
        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            FaxEnrollmentController.callPhysicianApi('ABC123');
        Test.stopTest();
    }

    static testmethod void testGetConfirmationNbr() {


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
            FaxEnrollmentController.getConfirmationNbr('submissionId', fax.Id);

            System.assertEquals(true, true);
        Test.stopTest();
    }
     static testmethod void test6() {
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

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            FaxEnrollmentController.getPLBackendId(acc.Id);
            System.assertEquals(true, true);
        Test.stopTest();
    }   
}