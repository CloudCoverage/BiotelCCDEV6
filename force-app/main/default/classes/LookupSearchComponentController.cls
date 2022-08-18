public class LookupSearchComponentController {

    @AuraEnabled
    public static List<sObject> getZipResults(String ObjectName, String fieldName, String value) {
        List<sObject> sObjectList = Database.Query('Select Id,'+fieldName+', City__c, State__c FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'' + value + '%\' limit 50');
        return sObjectList;
    }
/*
    @AuraEnabled
    public static List<sObject> getResults(String ObjectName, String fieldName, String value) {
        List<sObject> sObjectList = Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\' limit 50');
        return sObjectList;
    }


    @AuraEnabled
    public static List<SObJectResult> getResultsxxx(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\' limit 50')) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }*/
}