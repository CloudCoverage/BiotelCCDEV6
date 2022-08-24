@isTest(seeAllData=false)
public with sharing class FaxEnrollmentControllerTest {

    static testmethod void SaveRecord() {

        Fax_Enrollment__c fax = getTestFaxRecord();

        String faxString = JSON.serialize(fax);


        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            String result = FaxEnrollmentController.saveRec(faxString, false);
            System.debug('result ' + result);
            System.assertEquals(result, (String)fax.Id, 'should save and return a fax record');

        Test.stopTest();
    }
    static testmethod void instantiateFax() {
        Test.startTest();
            Id recTypeBTH = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByName().get('BTH Enrollments').getRecordTypeId();        
            Fax_Enrollment__c shellFax = FaxEnrollmentController.instantiateFax(recTypeBTH);
        Test.stopTest();
        System.assert(JSON.serialize(shellFax).startsWith('{"attributes":{"type":"Fax_Enrollment__c"},'), 'should be valid fax enrollment record');
    }

    static testmethod void EncounterWrapper() {
        Test.startTest();
            FaxEnrollmentController.EncounterWrapper enc = new FaxEnrollmentController.EncounterWrapper();
        Test.stopTest();  
        System.assertEquals(JSON.serialize(enc), '{"EncounterNumber":null}', 'EncounterWrapper should equal  {"EncounterNumber":null}');
    }

    static testmethod void EnrollmentWrapper() {
        Test.startTest();
            FaxEnrollmentController.EnrollmentWrapper enc = new FaxEnrollmentController.EnrollmentWrapper();
        Test.stopTest();    
        System.assertEquals(JSON.serialize(enc),  '{"EnrollmentNumber":null}', 'EnrollmentWrapper should equal {"EnrollmentNumber":null}');
    }
    
    static testmethod void createINRDraftCase() {

        Fax_Enrollment__c fax = getTestFaxRecord();

        Test.startTest();
            Case testCase = FaxEnrollmentController.createInrDraftCase(fax);

            System.debug('xxx abc testCase ' + testCase);
            System.assertEquals(fax.Id, testCase.Fax_Enrollment__c, 'testCase should be attached to Fax Enrollment');
        Test.stopTest();
    }
    
    static testmethod void createBTHDraftCase() {

        Fax_Enrollment__c fax = getTestFaxRecord();

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
    static testmethod void getFaxEnrollment() {

        Fax_Enrollment__c fax = getTestFaxRecord();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            Fax_Enrollment__c testFax = FaxEnrollmentController.getFaxEnrollment(fax.Id);
        Test.stopTest();
        System.assertEquals(fax.Id, testFax.Id, 'should return a fax record');

    }
    static testmethod void callOtsBundleApi() {

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            List<MiddlewareUtil.Bundle> bundles = FaxEnrollmentController.callOtsBundleApi('ABC123', '3');
            System.debug('xxx size ' +bundles.size());
        Test.stopTest();
        System.assertEquals(3, bundles.size(), 'should return 3 records');
    }
    static testmethod void getPhysicians() {

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            List<MiddlewareUtil.Physician> physicians = FaxEnrollmentController.callPhysicianApi('ABC123');
        Test.stopTest();
        System.assertEquals(3, physicians.size(), 'should return 3 records');
    }

    static testmethod void testGetConfirmationNbr() {


        Fax_Enrollment__c fax = getTestFaxRecord();
        System.debug('xxx testFax ' + fax);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            String response = FaxEnrollmentController.getConfirmationNbr('f11c0e8e-2e69-40d9-be0e-a7c2385b7e0', fax.Id);
            System.debug('xxx response ' + response);
        Test.stopTest();
        List<String> responseArray = response.split(',');
        System.assertEquals(3, responseArray.size(), 'response should contain 3 values');
    }
     static testmethod void getPLBackendId() {

        Account acc = [SELECT Name, Backend_ID__c FROM Account LIMIT 1];          

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            String backendId = FaxEnrollmentController.getPLBackendId(acc.Id);
        Test.stopTest();
        System.assertEquals('L-11111', backendId, 'backendId should equal L-11111');
    }

    static Fax_Enrollment__c getTestFaxRecord(){
        return [ SELECT Practice_Location__c, RecordTypeId, Results_Phone__c, Ordering_Physician__c, Results_Fax_Number__c, Notifying_Physician__c, Payer_Info__c, Payer_Id__c, Visit_Date__c, STAT__c, Fax_Date__c, Service_Type__c, Enrollment_Number__c, Encounter_Number__c, Device_Source__c, Diagnosis_Code_Text__c, Enrollment_Duration__c, Testing_Frequency__c, Training_Type__c, Billing_Status_Text__c, Submission_Id__c, Status__c, Low__c, High__c, Below__c, Above__c, Patient_First_Name__c, Patient_Last_Name__c, Patient_Date_of_Birth__c, Patient_Gender__c, Patient_Home_Phone__c, Billing_Street__c, Billing_Postal_Code_Text__c, Billing_City__c, Billing_State__c, Shipping_Street__c, Shipping_Postal_Code_Text__c, Shipping_City__c, Shipping_State__c, LanguageId__c, Payer_not_in_List__c, Policy_ID__c, Payer_Name__c, Email__c, Guarantor_Relationship_to_Patient__c, Billing_Postal_Code__c, Diagnosis_Code__c, Billing_Status__c
        FROM Fax_Enrollment__c LIMIT 1]; 

    }
    
    @testSetup private static void setup() {
        Account practiceLocation = new Account(
          Name = 'Practice Location',
          Backend_ID__c = 'L-11111'          
        );
        insert practiceLocation;

        Id recTypeBTH = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByName().get('BTH Enrollments').getRecordTypeId();

        List<Fax_Enrollment__c> faxEnrollmentList = TestData.buildFaxEnrollmentList(1, recTypeBTH, 'MCT');

        Middleware_Settings__c setting = new Middleware_Settings__c();
        setting.clientId__c = 'aaa';
        setting.clientSecret__c = 'bbb';
        setting.tokenEndPoint__c = 'AuthGood';
        setting.endpoint__c = 'Controller';
        insert setting;   
      }     
}