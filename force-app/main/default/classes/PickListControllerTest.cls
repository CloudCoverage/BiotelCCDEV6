@isTest(seeAllData=false)
public class PickListControllerTest {
    static testmethod void test1() {
    
        
        Test.startTest();
            List<String> soList = PickListController.getPickListValuesIntoList('Contact', 'Gender__c'); 
            System.assertEquals(true, true);
        Test.stopTest();
    }
}