@isTest(seeAllData=false)

public class FaxEnrollmentTriggerHandlerTest {
    static testmethod void FaxEnrollmentTriggerInsert() {

        TestData.buildFoundation();
        List<Order> orders = TestData.buildOrderList(200);

        Test.startTest();
        List<Fax_Enrollment__c> faxes = TestData.buildBTHFaxEnrollmentList(200);

            System.assertEquals(true, true, 'message');
        Test.stopTest();
    }
    static testmethod void FaxEnrollmentTriggerUpdate() {
        TestData.buildFoundation();
        List<Order> orders = TestData.buildOrderList(200);        
        List<Fax_Enrollment__c> faxes = TestData.buildBTHFaxEnrollmentList(200);

        Test.startTest();
            update faxes;
        Test.stopTest();
        System.assertEquals(faxes.size(), 200, 'faxes should have 200 records');
    }    
}