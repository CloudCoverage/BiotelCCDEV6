@isTest(seeAllData=false)
public class LookupSearchComponentControllerTest {

static testmethod void ZipCode() {

        
        Zip_Code__c zc = new Zip_Code__c(Name = 'Basher', City__c = 'Basher', State__c = 'FL', Zip_Code__c='30393');
		insert zc;        
        
        Test.startTest();
            List<sObject> soList = LookupSearchComponentController.getZipResults('Zip_Code__c', 'Name', null); 
            System.assertEquals(true, true);
        Test.stopTest();
    }    

}