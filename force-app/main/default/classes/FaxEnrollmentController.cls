public with sharing class FaxEnrollmentController { 
    @AuraEnabled
    public static Fax_Enrollment__c getFaxEnrollment(String recordId){
        List <Fax_Enrollment__c> fax = [
            SELECT Id, RecordTypeId, Name, Practice_Location__c, Practice_Location__r.Name, Practice_Location__r.Backend_ID__c, CreatedBy.Name,
                Ordering_Physician__c, Notifying_Physician__c, Case__c, Status__c, 
                Ordering_Physician_Text__c, Notifying_Physician_Text__c, OTS_Device_Text__c, Enrollment_Number__c, 
            	Device_Type__c, Patient_First_Name__c, Patient_Middle_Initial__c, 
            	Patient_Last_Name__c, Patient_Date_of_Birth__c, Patient_Gender__c, Enrollment_Duration__c, 
                Billing_Status__c, Billing_Status__r.Name, Billing_Status__r.Id__c,
                Billing_Street__c, Payer_Info__r.Name,
            	Billing_Street_2__c, Billing_City__c, Billing_State__c, Patient_Home_Phone__c, 
                Patient_Work_Phone__c, Patient_Cell_Phone__c, Visit_Date__c, STAT__c, 
            	Referring_Physician_First_Name__c, Referring_Physician_Last_Name__c, Prescription_Length__c, 
                Medical_Record_Number__c, Quick_Note_Subject__c, Quick_Note_Text__c, 
            	Billing_Postal_Code__c, Billing_Postal_Code__r.Name, Device_Source__c, 
                Service_Type__c, Event_Device_Type__c, OTS_Device__c, Shipping_City__c, Shipping_Postal_Code__c, 
                Shipping_Postal_Code__r.Name, Shipping_State__c, Fax_Date__c,
                Diagnosis_Code__c, Diagnosis_Code__r.Name, Diagnosis_Code__r.Code__c, 
                Diagnosis_Code_2__c, Diagnosis_Code_2__r.Name, Diagnosis_Code_2__r.Code__c,
                Diagnosis_Code_3__c, Diagnosis_Code_3__r.Name, Diagnosis_Code_3__r.Code__c,
                Diagnosis_Code_4__c, Diagnosis_Code_4__r.Name, Diagnosis_Code_4__r.Code__c,
                Diagnosis_Code_Text__c, Diagnosis_Code_2_Text__c, Diagnosis_Code_3_Text__c, Diagnosis_Code_4_Text__c, Billing_Status_Text__c,
            	Shipping_Street__c, Shipping_Street_2__c, LanguageId__c, Submission_Id__c, Encounter_Number__c, OTS_Device_Name__c,
                Shipping_Postal_Code_Text__c, Billing_Postal_Code_Text__c,Draft_Reason__c,Email__c,Low__c,High__c,Below__c,
            Above__c,Testing_Frequency__c,Results_Phone__c,Results_Fax_Number__c,Training_Type__c,Payer_Info__c,
            Guarantor_Relationship_to_Patient__c, Payer_not_in_List__c, Policy_ID__c, 
            Payer_Name__c,
            Order__r.OrderNumber,order__c
            FROM Fax_Enrollment__c
           WHERE Id = :recordId limit 1];
         
        if(fax.size() > 0)
            return fax[0];
        else
            return null;
    }
    
    @AuraEnabled
    public static List<MiddlewareUtil.Bundle> callOtsBundleApi(String backendId, String serviceTypeId){ 

        List<MiddlewareUtil.Bundle> recs = MiddlewareUtil.getBundles(backendId, serviceTypeId);
        System.debug('xxx recs' + recs);
        return recs;            
    }

    @AuraEnabled
    public static String getConfirmationNbr(String submissionId, String recordId){ 
        System.debug('getConfirmationNbr submissionId ' + submissionId);
        System.debug('getConfirmationNbr recordId ' + recordId);

        Middleware__mdt settings = MiddlewareUtil.getSettings();

        String returnStr;
        HttpResponse res = new HttpResponse();
        if(settings.Enrollment_Submission__c == 'Enrollment number API'){
            res = MiddlewareUtil.getEnrollmentNumber(submissionId);
        } else {
            res = MiddlewareUtil.getEncounterNumber(submissionId);
        }

        if(res.getStatusCode() == 200){
            System.debug('getConfirmationNbr getting 200 ' + res.getBody());
            returnStr = res.getBody();
            Fax_Enrollment__c faxObj = [SELECT Id, Encounter_Number__c, Enrollment_Number__c from Fax_Enrollment__c WHERE Submission_Id__c = :submissionId Limit 1];
            if(settings.Enrollment_Submission__c == 'Enrollment number API'){
                EnrollmentWrapper enrollmentWrapper = (EnrollmentWrapper) JSON.deserialize(res.getBody(), EnrollmentWrapper.class);		
                faxObj.Enrollment_Number__c = enrollmentWrapper.EnrollmentNumber;
                System.debug('xxx faxObj.Enrollment_Number__c '+ faxObj.Enrollment_Number__c);
                upsert faxObj;
                returnStr = 'Enrollment Number,'+ faxObj.Enrollment_Number__c +',' +faxObj.Id;   
            } else{
                EncounterWrapper encounterWrapper = (EncounterWrapper) JSON.deserialize(res.getBody(), EncounterWrapper.class);	
                faxObj.Encounter_Number__c = encounterWrapper.EncounterNumber.substring(0, (encounterWrapper.EncounterNumber.length()-2));
                System.debug('xxx faxObj.Encounter_Number__c '+ faxObj.Encounter_Number__c);
                upsert faxObj;
                returnStr = 'Encounter Number,'+ faxObj.Encounter_Number__c +',' +faxObj.Id;             
            }
        } else{
            System.debug('getConfirmationNumber BAD RESPONSE ' + res.getBody());
            returnStr = res.getBody();
        } 
        return returnStr;           
    }    

    @AuraEnabled
    public static List<MiddlewareUtil.Physician> callPhysicianApi(String backendId){ 

        List<MiddlewareUtil.Physician> recs = MiddlewareUtil.getPhysicians(backendId);
        System.debug('xxx recs' + recs);
        return recs;            
    }

    @AuraEnabled
    public static String getPLBackendId(String recordId){ 
        String backendId;
        System.debug('xxx getPLBackendId recordId ' + recordId);
        List <Account> aList = [SELECT Backend_ID__c FROM Account WHERE Id = :recordId];
        if(aList.size() > 0)
            backendId = aList[0].Backend_ID__c;

        System.debug('xxx getPLBackendId backendId ' + backendId);
        return backendId;    
    }

    @AuraEnabled
    public static String saveRec(String fax, Boolean draft){ 
        System.debug('xxx SaveRec ' + fax);
        Fax_Enrollment__c faxObj = (Fax_Enrollment__c)System.JSON.deserialize(fax, Fax_Enrollment__c.class);
        Id inrRT    = Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByDeveloperName().get('INR_Enrollments').getRecordTypeId();

        //Set text fields
        Set<id> diagnosisCodeIds = new Set<id>();
        if(faxObj.Diagnosis_Code__c!=null)diagnosisCodeIds.add(faxObj.Diagnosis_Code__c);
        if(faxObj.Diagnosis_Code_2__c!=null)diagnosisCodeIds.add(faxObj.Diagnosis_Code_2__c);
        if(faxObj.Diagnosis_Code_3__c!=null)diagnosisCodeIds.add(faxObj.Diagnosis_Code_3__c);
        if(faxObj.Diagnosis_Code_4__c!=null)diagnosisCodeIds.add(faxObj.Diagnosis_Code_4__c);

        for(Diagnosis_Code__c d:[Select id, Name, Code__c from Diagnosis_Code__c where id in: diagnosisCodeIds])
        {
            if(faxObj.Diagnosis_Code__c == d.id) faxObj.Diagnosis_Code_Text__c = d.Code__c + ' - ' + d.Name;
            if(faxObj.Diagnosis_Code_2__c == d.id) faxObj.Diagnosis_Code_2_Text__c = d.Code__c + ' - ' + d.Name;
            if(faxObj.Diagnosis_Code_3__c == d.id) faxObj.Diagnosis_Code_3_Text__c = d.Code__c + ' - ' + d.Name;
            if(faxObj.Diagnosis_Code_4__c == d.id) faxObj.Diagnosis_Code_4_Text__c = d.Code__c + ' - ' + d.Name;
        }

        for(Billing_Status__c bs:[Select id, Name from Billing_Status__c where id=:faxObj.Billing_Status__c]) {
            faxObj.Billing_Status_Text__c = bs.Name;
            break;
        }

        for(Zip_Code__c zc :[Select id, Zip_Code__c from Zip_Code__c where id=:faxObj.Billing_Postal_Code__c OR id=:faxObj.Shipping_Postal_Code__c])
        {
            if(faxObj.Billing_Postal_Code__c == zc.id) faxObj.Billing_Postal_Code_Text__c = zc.Zip_Code__c;
            if(faxObj.Shipping_Postal_Code__c == zc.id) faxObj.Shipping_Postal_Code_Text__c = zc.Zip_Code__c;
        }
        if(faxObj.Payer_not_in_List__c){
            faxObj.Payer_Id__c = MiddlewareUtil.createRandomGuid();
        } else {
            List<Payer_Info__c> payerInfoList = new List<Payer_Info__c>();
            if(faxObj.Payer_Info__c != null){
                payerInfoList = [SELECT Payer_Id__c, Name FROM Payer_Info__c WHERE Id = :faxObj.Payer_Info__c limit 1];
            }
            if(payerInfoList.size() > 0){
                faxObj.Payer_Name__c = payerInfoList[0].Name;
                faxObj.Payer_Id__c = payerInfoList[0].Payer_Id__c;
            }
        }


        String status;
        HttpResponse res = new HttpResponse();
        if(fax != null){
           res = MiddlewareEnrollment.process(faxObj);
            if(res.getStatusCode() == 200){
                faxObj.Submission_Id__c = res.getBody().replace('"','');
                upsert faxObj;
            }
            if(draft){
                upsert faxObj;
                status = faxObj.Id;
                Case caseRec = faxObj.RecordTypeId == inrRT ? createInrDraftCase(faxObj) : createBthDraftCase(faxObj);
                System.debug('draft case ' +  caseRec);
                if(caseRec != null && caseRec != new Case()){
                    insert caseRec;
                }
            }

           status = faxObj.Id + res.getBody().replace('"',''); //sending record id and submission id - will parse in JS

        }
        return status;
    }

    @AuraEnabled
    public static List<RecordType> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Fax_Enrollment__c.SObjectType.getDescribe().getRecordTypeInfos();
        System.debug('recordTypes List: ' + recordtypes);
		List<RecordType> rtList = new List<RecordType>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.isAvailable() && rt.isActive() && !rt.isMaster()){
                //rtMap.put(rt.getRecordTypeId(), rt.getName());
                RecordType newRT = new RecordType(Id=rt.getRecordTypeId(), Name=rt.getName());
                rtList.add(newRT);
            }
        }   
        System.debug('rtList: ' + rtList);
        return rtList;
    }
    
    @AuraEnabled
    public static Fax_Enrollment__c  instantiateFax(Id recordTypeId){
        
         return (Fax_Enrollment__c)Fax_Enrollment__c.sObjectType.newSObject(recordTypeId, true);
    }

    @AuraEnabled
    public static Boolean getFeatureFlag(Id recordTypeId){
        return [
            SELECT ActiveFlag__c 
              FROM Feature_Flag__mdt
             WHERE Label = 'DraftEnrollment'
               AND RecordTypeId__C = :recordTypeId 
              ].ActiveFlag__c;
    }

    public class EncounterWrapper{
         @AuraEnabled public String EncounterNumber;
    }

    public class EnrollmentWrapper{
        @AuraEnabled public String EnrollmentNumber;
   }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getPicklistValues(String objectName, String fieldName) { 
        Boolean hasDefault = false;
        List<Map<String,String>> values = new List<Map<String,String>>();
   
        
        for(PicklistEntry e: ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType()
        .getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()) 
        {
            if(e.isActive()) {
                values.add(
                    new Map<String, String> {
                        'label' => e.getLabel(),
                            'value' => e.getValue()
                            }
                );       
            }  
            
            if(e.isDefaultValue()) {
                hasDefault = true;
            }
        }
        // we need to add a blank picklist value if a field has no default value,
        // because that means the field is blank in the UI.       
        if(!hasDefault) { 
            values.add(0,
                        new Map<String, String> {
                            'label' => '',
                                'value' => null
                                }
                       );         
        }

        return values;
    } 

    public static Case createInrDraftCase(Fax_Enrollment__c fax){
        Case supportCase = new Case();
        List<Case> exists = [
            SELECT Id 
              FROM Case 
             WHERE Fax_Enrollment__c = :fax.Id
               AND Subject = 'INR Incomplete Enrollment'];
        if(exists.size() == 0){
            List<Group> queue = [
                SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'INR_Draft_Enrollment_Queue' 
            ];
            String queueName =  queue[0].Id;
    
            List <Case_Reason_Lookup__c> crls = [SELECT Id FROM Case_Reason_Lookup__c WHERE Name = 'Incomplete Enrollment'];
            Id patientSupportRecordTypeId    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
    
            supportCase = new Case(
                RecordTypeId = patientSupportRecordTypeId,
                OwnerId = queueName,
                Origin = 'Fax',
                Fax_Enrollment__c = fax.Id,
                AccountId = fax.Practice_Location__c,
                Phone__c = fax.Patient_Home_Phone__c,
                Fax_Results_Number__c = fax.Results_Fax_Number__c,
                Patient_Name__c = fax.Patient_First_Name__c + ' ' + fax.Patient_Last_Name__c,
                Email__c  = fax.Email__c,
                Status = 'New',
                Service_Type__c = 'INR',
                Case_Record_Type_Picklist__c = 'Patient Support',
                Case_Reason_Lookup__c = crls.size() > 0 ? crls[0].Id : null,
                Subject = 'INR Incomplete Enrollment'
            );
    
        }
        return supportCase;
    }
    
    public static Case createBthDraftCase(Fax_Enrollment__c fax){
        Case supportCase = new Case();
        List<Group> queue = [
            SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'BioTel_Heart_Draft_Enrollment_Queue'
        ];
        String queueName =  queue[0].Id;

        List<Case> exists = [
            SELECT Id 
              FROM Case 
             WHERE Fax_Enrollment__c = :fax.Id
               AND OwnerId = :queueName];
        if(exists.size() == 0){
            List <Case_Reason_Lookup__c> caseReasonLookupList = [SELECT Id FROM Case_Reason_Lookup__c WHERE Name = 'Incomplete Enrollment'];
            Id patientSupportRecordTypeId    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
    
            supportCase = new Case(
                RecordTypeId = patientSupportRecordTypeId,
                OwnerId = queueName,
                Fax_Enrollment__c = fax.Id,
                AccountId = fax.Practice_Location__c,
                Origin = 'Fax',
                Phone__c = fax.Patient_Home_Phone__c,
                Fax_Results_Number__c = fax.Results_Fax_Number__c,
                Patient_Name__c = fax.Patient_First_Name__c + ' ' + fax.Patient_Last_Name__c,
                Status = 'New',
                Service_Type__c = fax.Service_Type__c,
                Email__c  = fax.Email__c,
                Case_Record_Type_Picklist__c = 'Patient Support',
                Case_Reason_Lookup__c = caseReasonLookupList.size() > 0 ? caseReasonLookupList[0].Id : null,
                Subject = 'BTH Incomplete Enrollment'
            );
    
        }
        return supportCase;
    }    
}