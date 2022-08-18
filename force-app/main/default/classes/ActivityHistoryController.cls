public class ActivityHistoryController { 
    
	@AuraEnabled
    public static List<MiddlewareUtil.Note> getNotes(String recordId) {
        String backendId = [select Enrollment_Backend_ID__c from Order where Id = :recordId].Enrollment_Backend_ID__c;
        String name = [select Name from Order where Id = :recordId].Name;

        System.debug('xxx backendId '+ backendId);
       	List<MiddlewareUtil.Note> notes = MiddlewareUtil.getNotes(backendId);
        for(MiddlewareUtil.Note n : Notes){
            n.enrollmentId = recordId;
            n.enrollmentName = name;
            n.enrollmentUrl = '/lightning/cmp/c__ActivityHistoryDetail?c__activityId='+n.BackendId+'&c__enrollmentId='+n.enrollmentId;
            n.Description = n.Description.replace('\n','');
        }
        System.debug('xxx notes '+ notes);
        return notes;
    }    

}