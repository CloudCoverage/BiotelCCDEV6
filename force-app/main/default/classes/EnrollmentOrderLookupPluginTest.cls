@isTest
public class EnrollmentOrderLookupPluginTest {

    private static Case createCase(){
        Case record = new Case();
        record.Subject = 'Test';
        insert record;
        return record;
    }
    
    @testSetup
    static void setup() {
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Contact con = new Contact (
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'Test.Contact@salesforce.com'
        );
        insert con;
        
        Order ord = new Order(
            Name = 'Test Order',
            AccountId = acc.Id,
            //Enrollment_Start_Datetime__c = Date.today(),
            EffectiveDate = Date.today(),
            Status = 'Submitted',
            Enrollment_Number__c = '999999'
        );
        insert ord;
           
    }
    
    @isTest
    static void testOrderLookupPlugin() {
        
        Order ord = [
            SELECT Id, Name, Enrollment_Number__c 
            FROM Order
            WHERE Enrollment_Number__c = '999999'
            LIMIT 1
        ][0];
        
        EnrollmentOrderLookupPlugin plugin = new EnrollmentOrderLookupPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('enrollmentNumber', ord.Enrollment_Number__c);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        
        plugin.invoke(request);
        Process.PluginDescribeResult result = plugin.describe();
        
    }
    
    /*static testmethod void flowTaskTest(){
        Case record = createCase();
        flowTask plugin = new flowTask();
        Map<String, Object> inputParams = new Map<String, Object>();
        string taskNum = record.Id;     //50063000003AEik-SBX | 500o000000GCryb-PROD
        string taskSub = 'Test Class';
        
        inputParams.put('subject', taskSub);
        inputParams.put('CaseId', taskNum);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        
        plugin.invoke(request);
        Process.PluginDescribeResult result = plugin.describe();
    }*/

}