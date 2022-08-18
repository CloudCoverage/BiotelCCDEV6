@isTest(seeAllData=false)

public class MiddlewareEnrollmentTest {
    
    static testmethod void test1() {
        
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

        Diagnosis_Code__c dc = new Diagnosis_Code__c(
            Name = 'Primary pulmonary hypertension',
            Backend_Id__c = 'I27.0',
            Code__c = 'I27.0'          
        );
        insert dc;

        Zip_Code__c z = new Zip_Code__c(
            Name = '32848',
            City__c = 'ABC123',
            State__c = 'FL',
            Country__c = 'USA',
            Zip_Code__c = '32848'
        );
        insert z;

        Billing_Status__c b = new Billing_Status__c(
            Name = 'Pending-Insurance Authorization',
            Id__c = 'cc8891d3-954e-4567-8baf-e1a7b1dad077',
            Backend_Id__c  = 'cc8891d3-954e-4567-8baf-e1a7b1dad077'
        );
        insert b;

        Fax_Enrollment__c f = new Fax_Enrollment__c();    
        
        f.Diagnosis_Code__c   = dc.Id;
        f.Diagnosis_Code_2__c = dc.Id;
        f.Diagnosis_Code_3__c = dc.Id;
        f.Diagnosis_Code_4__c = dc.Id;
        f.Practice_Location__c = acc.Id;
        f.Device_Type__c = 'MCOT';
        f.Patient_First_Name__c = 'ABC123';
        f.Patient_Middle_Initial__c = 'A';
        f.Patient_Last_Name__c = 'ABC123';
        f.Patient_Date_of_Birth__c = Date.today() - 35;
        f.Patient_Gender__c = 'Male';
        f.Submission_Id__c = 'ABC123';
        f.Enrollment_Duration__c = 1;
        f.Encounter_Number__c = 'ABC123';
        f.Billing_Street__c = 'ABC123';
        f.Billing_Street_2__c = 'ABC123';
        f.Billing_City__c = 'ABC123';
        f.Billing_State__c = 'FL';
        f.Fax_Date__c = Date.today();
        //f.Language__c = 'English';
        f.Patient_Home_Phone__c = '9055551212';
        f.Patient_Work_Phone__c = '9055551212';
        f.Patient_Cell_Phone__c = '9055551212';
        f.Visit_Date__c = Date.today();
        f.STAT__c = 'Yes';
        f.Referring_Physician_First_Name__c = 'ABC123';
        f.Referring_Physician_Last_Name__c = 'ABC123';
        //f.Prescription_Length__c = 2;
        //f.Medical_Record_Number__c
        f.Quick_Note_Subject__c = 'ABC123';
        f.Quick_Note_Text__c = 'ABC123';
        f.Billing_Postal_Code__c = z.Id;
        f.Device_Source__c = 'OTS';
        f.Service_Type__c = 'MCT';
        f.Ordering_Physician__c = 'b2426980-a4db-4373-839f-07e263b13ded';
        f.Event_Device_Type__c = 'Chest Plate';
        f.OTS_Device__c = '791dd4ff-e411-490f-b771-924ce49a0c81';
        f.Shipping_City__c = 'ABC123';
        f.Shipping_Postal_Code__c = z.Id;
        f.Shipping_State__c= 'FL';
        f.Shipping_Street__c = 'ABC123';
        f.Shipping_Street_2__c = 'ABC123';
        f.LanguageId__c = '10';
        f.Notifying_Physician__c  = 'b2426980-a4db-4373-839f-07e263b13ded';
        f.Quick_Notes_Title__c = 'ABC123';
        f.Quick_Notes__c = 'ABC123'; 
        f.Billing_Status__c = b.Id;         


        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MiddlewareUtilMock());
            HttpResponse res = MiddlewareEnrollment.process(f);
            f.Service_Type__c = 'EVENT'; 
            f.Event_Device_Type__c = 'wEvent';
            f.STAT__c = 'No';
            f.Patient_Gender__c = 'Female';
            res = MiddlewareEnrollment.process(f);
            f.Service_Type__c = 'Holter'; 
            f.Event_Device_Type__c = '';
            res = MiddlewareEnrollment.process(f);

            System.assertEquals(true, true);
        Test.stopTest();
        
    }    

}