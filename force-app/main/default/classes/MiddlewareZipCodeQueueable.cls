public class MiddlewareZipCodeQueueable implements Queueable {
    
    private List<MiddlewareUtil.ZipCode> zList;
    
    public MiddlewareZipCodeQueueable (List<MiddlewareUtil.ZipCode> records){
        this.zList = records;
    }
    
    public void execute(QueueableContext context) { 
        
        
        Database.UpsertResult[] dbResult;
        Schema.SObjectField externalId;    
        
        List<Zip_Code__c> updateList = new List<Zip_Code__c>();
        List<MiddlewareUtil.ZipCode> queueList = new List<MiddlewareUtil.ZipCode>();
        Integer cnt = 0;
        
        for(MiddlewareUtil.ZipCode z : zList){
            if(cnt < 10000){
                Zip_Code__c zipCode = new Zip_Code__c();
                zipCode.Name = z.ZipCode;
                zipCode.Zip_Code__c = z.ZipCode;
                zipCode.City__c = z.City;
                zipCode.State__c = z.State;
                zipCode.Country__c = z.Country;
                updateList.add(zipCode);
            }else{
               queueList.add(z); 
            }
            cnt++;
        }
        System.debug('updateList > '+ updateList.size());
        System.debug('queueList > '+ queueList.size());

        //externalId =  Zip_Code__c.Fields.Zip_Code__c;
        //dbResult = Database.Upsert(updateList, externalId, false);
        upsert updateList Fields.Zip_Code__c;
        if(queueList.size() > 0){
            MiddlewareZipCodeQueueable updateJob = new MiddlewareZipCodeQueueable(queueList);
            ID jobID = System.enqueueJob(updateJob);
        }
        
    }
    
}