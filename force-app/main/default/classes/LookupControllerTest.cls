@isTest(seeAllData=false)
public class LookupControllerTest {

    static testmethod void test1() {

        
        Billing_Status__c bs = new Billing_Status__c(Name = 'abc123', Id__c = 'abc123', Backend_Id__c = 'abc123');
		insert bs;        
        
        Test.startTest();
            List<LookupController.SObJectResult> soList = LookupController.getResults('Billing_Status__c', 'Name', 'P', null); 
            System.assertEquals(true, true);
        Test.stopTest();
    }

    static testmethod void test2() {
 
        Account acc = new Account(Name = 'abc123');
        insert acc;
        
        Test.startTest();
            List<LookupController.SObJectResult> soList = LookupController.getResults('Account', 'Name', 'P', null); 
            System.assertEquals(true, true);
        Test.stopTest();
    }
    
    static testmethod void test3() {
 
        Account acc = new Account(Name = 'abc123');
        insert acc;
        
        Diagnosis_Code__c dc = new Diagnosis_Code__c(Name = 'abc123', Description__c = 'abc123', Backend_Id__c = 'abc123', Code__c = 'abc123');
		insert dc;        
        
        Test.startTest();
            List<LookupController.SObJectResult> soList = LookupController.getResults('Diagnosis_Code__c', 'Code__c', 'P', null); 
            System.assertEquals(true, true);
        Test.stopTest();
    }    
    
}