@isTest(seeAllData=false)

public with sharing class BatchPullTrackingNumberTest {
    static testmethod void test1() {
       
        Test.startTest();
        BatchPullTrackingNumber sched = new BatchPullTrackingNumber();
            sched.execute(null);
        Test.stopTest();
    }

    @TestSetup 
    private static void setupData() {

        TestData.buildFoundation();
    }    


}