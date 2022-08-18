@isTest
public class TaskTriggerTest{

    @isTest static void TestTaskDelete() { 
    
        Profile pf= [Select Id from profile where Name != 'System Administrator' LIMIT 1]; 
    
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id); 
        
		insert uu;        

        Task t = new Task(
        	RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('External_Activities').getRecordTypeId(),
            Status = 'Not Started',
            OwnerId = uu.Id
        );
        
        insert t;
        
        System.runAs(uu){
            try{
                delete t;
            } catch(Exception e){
                
            }
        }
    
    } 
}