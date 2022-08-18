@isTest(seeAllData=false)

public class CaseBuilderTest {
    static testmethod void updateFaxAndSpecialIntructionTest(){
        TestData.buildFoundation();
        List<Order> orders = TestData.buildOrderList(2);
        CaseBuilder caseBuilder = new CaseBuilder();
        Test.startTest();
            Case testCase = caseBuilder.createSpecialInstructionCase(orders[0]);
            INSERT testCase;
            System.assertEquals(testCase.Subject, 'Enrollment Special Instructions', 'Case should be a Special Instruction Case');
        Test.stopTest();


    }
}