global class BatchDocReport implements Database.Batchable<sObject>, Database.Stateful  {

    List<String> rpts = new List<String>();
    
    
    public String query;
    public Date beginDt;    
    public Date endDt;    

/*
Date bDate = Date.newInstance(2021, 04, 14);
Date eDate = Date.newInstance(2021, 09, 10);
Database.executeBatch(new BatchDocReport(bDate,eDate),50);
*/

    //only include last 45 days
    //add order id to spreadsheet
    //add doc id to spreadsheet
    //run in production
    Date runDate = System.today().addMonths(-3);

    public BatchDocReport(Date beginDt, Date endDt){

        this.beginDt = beginDt;
        this.endDt = endDt;

        query = 'Select Id, Enrollment_Backend_ID__c, Prescription_End_Date__c, Patient_Special_Instructions__c ' +
                'FROM Order ' + 
                'WHERE Prescription_End_Date__c >= :beginDt' + 
                '  AND Prescription_End_Date__c <= :endDt';

        if(Test.isRunningTest()) { 
            query += ' AND ID = \'8010H000004FJgRQAW\'';
        }
        query += ' ORDER BY Prescription_End_Date__c ASC';

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('controller query '+ query);

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Order> batches) {
        /*
        List<ContentVersion> tester = [SELECT Id, ContentDocumentId, IsLatest, ContentUrl, ContentBodyId, VersionNumber, Title, Description, ReasonForChange, SharingOption, SharingPrivacy, PathOnClient, RatingCount, IsDeleted, ContentModifiedDate, ContentModifiedById, PositiveRatingCount, NegativeRatingCount, FeaturedContentBoost, FeaturedContentDate, OwnerId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp, TagCsv, FileType, PublishStatus, VersionData, ContentSize, FileExtension, FirstPublishLocationId, Origin, NetworkId, ContentLocation, TextPreview, ExternalDocumentInfo1, ExternalDocumentInfo2, ExternalDataSourceId, Checksum, IsMajorVersion, IsAssetEnabled FROM ContentVersion WHERE ContentDocumentId = '0690H000009GU7ZQAW'         
        ];
        System.debug(tester);
        */
        System.debug('query '+ query);
        System.debug('beginDate '+ this.beginDt);
        System.debug('endDate '+this.endDt);

        Map<Id, String> mp = new Map<Id, String>();
        Map<String, String> mp2 = new Map<String, String>();
        Map<Id, Order> orderMap = new Map<Id, Order>();
        Set<Id> orders = new Set<Id>();
        for(Order o :batches){
            System.debug('Prescription_End_Date__c '+o.Prescription_End_Date__c);

            List<ContentDocumentLink> cdls = [Select Id,ContentDocumentId,ContentDocument.Title,LinkedEntity.Name,ContentDocument.ContentAssetId, ContentDocument.FileType, ContentDocument.ContentSize, LinkedEntityId 
            FROM ContentDocumentLink WHERE ContentDocument.FileType = 'SNOTE' AND LinkedEntityId = :o.Id];
    
            String specialInstruction;
            Boolean exceeds255 = false;
            String x5;
            Date lDate = Date.newInstance(2021, 9, 10);
            for(ContentDocumentLink cd : cdls) {
                System.debug('id ' + cd.ContentDocumentId);
                System.debug('title ' + cd.ContentDocument.Title);
    
                List<ContentVersion> cvs = [SELECT Id, ContentDocumentId, Title, FileType, FileExtension, CreatedDate, ContentBodyId, TextPreview 
                FROM ContentVersion 
               WHERE ContentDocumentId = :cd.ContentDocumentId
                 AND IsLatest = true
                 AND LastModifiedDate >=  :lDate
               order by ContentDocumentId];
       
               System.debug('cvs ' + cvs);
               for(ContentVersion c : cvs){
                String t2 = c.Title;
                String t3 = String.valueOf(c.TextPreview);
                specialInstruction = specialInstruction != null ? specialInstruction + '; ' + t2 + '-' +  t3 : t2 + '-' + t3;
               }
               String x1 = o.Id;
               //String x2 = c.Title + ': ';
               String x3 = specialInstruction;
               if(specialInstruction != null && specialInstruction.length() > 255)
                   exceeds255 = true;
               String x4 = exceeds255 ? 'Note greater than 255 chars' : '';
               x5 = x1 + '\t' + o.Enrollment_Backend_ID__c +  '\t' + o.Prescription_End_Date__c + '\t' + x3 + '\t' + x4 + '\t' + o.Patient_Special_Instructions__c;
        }
        if(x5 != null)
            this.rpts.add(x5);
        }
    }  
    
    global void finish(Database.BatchableContext bc){
        // do nothing
        //System.debug('rpts ' + rpts);

        for(String r :rpts){
            System.debug(r);
        }
    }
}