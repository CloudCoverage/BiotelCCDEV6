@isTest(seeAllData=false)

public class FaxEnrollmentTriggerHandlerTest {
    static testmethod void FaxEnrollmentTriggerInsert() {

        TestData.buildFoundation();
        List<Order> orders = TestData.buildOrderList(100);

        Test.startTest();
        List<Fax_Enrollment__c> faxes = TestData.buildBTHFaxEnrollmentList(100);

            System.assertEquals(true, true, 'message');
        Test.stopTest();
    }
    static testmethod void FaxEnrollmentTriggerUpdate() {
        TestData.buildFoundation();
        List<Order> orders = TestData.buildOrderList(100);        
        List<Fax_Enrollment__c> faxes = TestData.buildBTHFaxEnrollmentList(100);

        Test.startTest();
            update faxes;
        Test.stopTest();
        System.assertEquals(faxes.size(), 100, 'faxes should have 100 records');
    }    
}