public class LookupController {
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, String moreWhere) {
        System.debug('xxx ObjectName' + ObjectName);
        System.debug('xxx fieldName' + fieldName);
        System.debug('xxx value' + value);
        String q1;
        if(ObjectName == 'Diagnosis_Code__c')
        {
            q1 = 'Select Id, Name, '+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\' ';

        } else if(ObjectName == 'Billing_Status__c'){
            q1 = 'Select Id, '+fieldName+' FROM '+ObjectName+' WHERE Id != null ';
            if(value != null){
                if(value.length() > 1){
                    System.debug('xxx value.length() '+ value.length());
                    q1 += 'AND ' + fieldName+' LIKE \'%' + value + '%\' ';   
                }
            }

        } else    
            q1 = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\' ';

        if(moreWhere != null)
            q1 += moreWhere;
         
        q1 += 'ORDER BY ' + fieldName + ' limit 30';
            
        System.debug('xxx q1' + q1);

        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(sObject so : Database.Query(q1)) {
            String fieldvalue = (String)so.get(fieldName);
            if(ObjectName == 'Diagnosis_Code__c')
                fieldvalue = fieldvalue + ' - ' + (String)so.get('Name');

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
    }
}