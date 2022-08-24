public with sharing class MiddlewareUtil {
//MiddlewareUtil.AutoDialerEnabled('80b13f26-a605-4637-96b7-f713367fde7c', true, 'TestUser');
//MiddlewareUtil.FollowupDate('80b13f26-a605-4637-96b7-f713367fde7c', System.now(), 'TestUser');
//MiddlewareUtil.CancelEnrollment('80b13f26-a605-4637-96b7-f713367fde7c', 'TestUser');
//MiddlewareUtil.RestartActivationProcess('80b13f26-a605-4637-96b7-f713367fde7c','TestUser');
    
    private static final Middleware__mdt settings = getSettings();

    /*Submit Fax Begin */
    //testing 123abc123
    
   // @Future(callout=true)
    public static HttpResponse SubmitFax(String jsonBody, String status){
        System.debug('xxx SubmitFax ' +jsonBody);
        String authToken = getAuthToken(); 
        String outcomeMsg;
        
       
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        String endpoint = status == 'Draft' ? settings.Endpoint__c + '/api/enrollment/submitdraftenrollment' : settings.Endpoint__c + '/api/enrollment/submit';
        System.debug('xxx SubmitFax endpoint '+endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(endpoint);
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('POST'); 
        req.setBody(jsonBody);
        
        try {
            if(!Test.isRunningTest()) {
                res = h.send(req);
            } else {
                res.setStatus('204');
                res.setStatusCode(204);
            }
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx SubmitFax SUCCESS res.getBody() > '+ res);
                System.debug('xxx MiddlewareUtil.SubmitFax SUCCESS res.getBody() > '+ res.getBody());

                //BundlesWrapper recsx = (BundlesWrapper) JSON.deserialize(res.getBody(), BundlesWrapper.class);		
                //recs = recsx.Bundles;
            } else {
                System.debug('xxx MiddlewareUtil.SubmitFax ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.SubmitFax ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.SubmitFax EXCEPTION > '+ + e.getMessage());
        }
  
        return res;

    }
    /* Submit Fax end */

        //@Future(callout=true)
     public static List<ZipCode> getZipCodes(){
     //public static void getZipCodes(){
        
        List<ZipCode> zips = new List<ZipCode>();

        String authToken = getAuthToken();
        //System.debug('xxxx au '+ authToken);
        String endPoint;
        String outcomeMsg;
        
        Middleware_Settings__c MW = Middleware_Settings__c.getInstance(); 
        endPoint = MW.endpoint__c;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(endPoint + '/api/billing/GetAllZipCodes');
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            if(!Test.isRunningTest()) {
                res = h.send(req);
            } else {
                res.setStatus('204');
                res.setStatusCode(204);
                res.setBody('{"ZipCodes":[{"ZipCode":"0","City":"West Milton","State":"PA","Country":"USA"},{"ZipCode":"000","City":"Ofallon","State":"MO","Country":"USA"}]}');
            }            
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getZipCodes res.getBody() > '+ res.getBody());
                ZipCodesWrapper zipsx = (ZipCodesWrapper) JSON.deserialize(res.getBody(), ZipCodesWrapper.class);		
                //System.debug('xxxx getZipCodes zips > '+ zipsx);
                zips = zipsx.ZipCodes;
            } else {
                System.debug('xxx MiddlewareUtil.getZipCodes ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getZipCodes ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getZipCodes EXCEPTION > '+ + e.getMessage());
        }
        return zips;        
    }

    /* Shipments code begin */
    public static List<Shipment> getShipments(String enrollmentId, String authToken){
            
        List<Shipment> recs = new List<Shipment>();

        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);

        req.setEndpoint(settings.Endpoint__c + '/api/Inventory/GetEnrollmentShipments?enrollmentId='+enrollmentId);
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            res = h.send(req);
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getShipments res.getBody() > '+ res.getBody());
                ShipmentsWrapper recsx = (ShipmentsWrapper) JSON.deserialize(res.getBody(), ShipmentsWrapper.class);		
                recs = recsx.Shipments;
                for(Shipment rec :recs){
                    if(rec.DeliverByDate != null){
                        //rec.DeliverByDate = rec.DeliverByDate.addHours(5); 
                        rec.DeliverByDateString = String.valueOf(rec.DeliverByDate).substring(5,7) + '/' +String.valueOf(rec.DeliverByDate).substring(8,10) + '/' +String.valueOf(rec.DeliverByDate).substring(0,4);
                    }
                    if(rec.FulfilledDateTime != null){
                    // rec.FulfilledDateTime = rec.FulfilledDateTime.addHours(5);                    
                        rec.FulfilledDateString = String.valueOf(rec.FulfilledDateTime).substring(5,7) + '/' +String.valueOf(rec.FulfilledDateTime).substring(8,10) + '/' +String.valueOf(rec.FulfilledDateTime).substring(0,4);
                    }
                }
            } else {
                System.debug('xxx MiddlewareUtil.getShipments ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getShipments ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getShipments EXCEPTION > '+ + e.getMessage());
        }
        System.debug('return Shipments ' + recs);
        return recs;        
    } 
     public static List<Shipment> getShipments(String enrollmentId){
        
        List<Shipment> recs = new List<Shipment>();

        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);

        req.setEndpoint(settings.Endpoint__c + '/api/Inventory/GetEnrollmentShipments?enrollmentId='+enrollmentId);
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            
            res = h.send(req);         
        
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getShipments res.getBody() > '+ res.getBody());
                ShipmentsWrapper recsx = (ShipmentsWrapper) JSON.deserialize(res.getBody(), ShipmentsWrapper.class);		
                recs = recsx.Shipments;
                for(Shipment rec :recs){
                    if(rec.DeliverByDate != null){
                    	//rec.DeliverByDate = rec.DeliverByDate.addHours(5); 
                    	rec.DeliverByDateString = String.valueOf(rec.DeliverByDate).substring(5,7) + '/' +String.valueOf(rec.DeliverByDate).substring(8,10) + '/' +String.valueOf(rec.DeliverByDate).substring(0,4);
                    }
                    if(rec.FulfilledDateTime != null){
	                   // rec.FulfilledDateTime = rec.FulfilledDateTime.addHours(5);                    
                    	rec.FulfilledDateString = String.valueOf(rec.FulfilledDateTime).substring(5,7) + '/' +String.valueOf(rec.FulfilledDateTime).substring(8,10) + '/' +String.valueOf(rec.FulfilledDateTime).substring(0,4);
                    }
                }
            } else {
                System.debug('xxx MiddlewareUtil.getShipments ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getShipments ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getShipments EXCEPTION > '+ + e.getMessage());
        }
        System.debug('return Shipments ' + recs);
        return recs;        
    }  
/* Shipments end */

    
/* External Notes code begin */

     public static List<Note> getNotes(String enrollmentId){
        
        List<Note> recs = new List<Note>();

        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);

        req.setEndpoint(settings.Endpoint__c + '/api/Enrollment/GetEnrollmentNotes?enrollmentId='+ enrollmentId);
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            if(!Test.isRunningTest()) {
                res = h.send(req);
            } else {
                res.setStatus('200');
                res.setStatusCode(200);
            }            
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getNotes res.getBody() > '+ res.getBody());
                NotesWrapper recsx = (NotesWrapper) JSON.deserialize(res.getBody(), NotesWrapper.class);		
                recs = recsx.Notes;
            } else {
                System.debug('xxx MiddlewareUtil.getNotes ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getNotes ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getNotes EXCEPTION > '+ + e.getMessage());
        }
        System.debug('Number of Notes ' + recs.size());
        if(recs.size() > 0){
            for(Note n : recs){
                if(n.SourceSystem == null){
                    n.SourceSystem = 'Enrollment Portal';
                }
                if(n.Subject.trim() == 'Activity'){
                    n.Subject = 'Enrollment Portal Activity';
                }                
            }
        }
         
        System.debug('return Notes list ' + recs);
        return recs;        
    }  
/* External Notes end */    

/* OTS Bundle code begin */

     public static List<Bundle> getBundles(String locationId, String serviceTypeId){
        
        List<Bundle> recs = new List<Bundle>();

        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        /*
        Event:1
        MCT:3
        */
        req.setEndpoint(settings.Endpoint__c + '/api/Inventory/GetOTSBundles?locationId='+ locationId +'&serviceTypeId=' +serviceTypeId);
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            res = h.send(req);
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getBundles res.getBody() > '+ res.getBody());
                BundlesWrapper recsx = (BundlesWrapper) JSON.deserialize(res.getBody(), BundlesWrapper.class);		
                recs = recsx.Bundles;
            } else {
                System.debug('xxx MiddlewareUtil.getBundles ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getBundles ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getBundles EXCEPTION > '+ + e.getMessage());
        }
        System.debug('Number of bundle ' + recs.size());
        System.debug('return bundle list ' + recs);
        return recs;        
    }  
/* OTS Bundle end */

/* Encounter Number code begin */

     public static HttpResponse getEncounterNumber(String submissionId){
        
        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);

        req.setEndpoint(settings.Endpoint__c + '/api/Billing/GetEncounterNumber?encounterId='+submissionId);
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            res = h.send(req);
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getEncounterNumber res.getBody() > '+ res.getBody());
            } else {
                System.debug('xxx MiddlewareUtil.getEncounterNumber ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getEncounterNumber ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getEncounterNumber EXCEPTION > '+ + e.getMessage());
        }

        return res;        
    }  
/* Encounter Number end */

/* Enrollment Number code begin */

public static HttpResponse getEnrollmentNumber(String submissionId){
    System.debug('xxx getEnrollmentNumber');
    String authToken = getAuthToken();
    String outcomeMsg;
    
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    String authorizationHeader = 'Bearer ' + authToken;
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', authorizationHeader);

    req.setEndpoint(settings.Endpoint__c + '/api/Enrollment/GetEnrollmentNumber?enrollmentId='+submissionId);
    req.setTimeout(120000); // timeout in milliseconds
    req.setMethod('GET'); 
    
    try {
        res = h.send(req);
        if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null) {
            System.debug('xxxx getEnrollmentNumber res.getBody() > '+ res.getBody());
        } else {
            System.debug('xxx MiddlewareUtil.getEnrollmentNumber ERROR res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxx MiddlewareUtil.getEnrollmentNumber ERROR res.getBody() > '+ res.getBody());
        }
        
    } catch (exception e) {
        System.debug('xxx MiddlewareUtil.getEnrollmentNumber EXCEPTION > '+ + e.getMessage());
    }

    return res;        
}  
/* Enrollment Number end */

/* Physicians code begin */

     public static List<Physician> getPhysicians(String locationId){
         
        system.debug('xxx getPhysicians locationId > '+ locationId);
        
        List<Physician> recs = new List<Physician>();

        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        /*
        Event:1
        MCT:3
        */
        req.setEndpoint(settings.Endpoint__c + '/api/PracticeManagement/GetPhysicians?locationId='+ locationId);
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            res = h.send(req);
         
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getPhysicians res.getBody() > '+ res.getBody());
                PhysiciansWrapper recsx = (PhysiciansWrapper) JSON.deserialize(res.getBody(), PhysiciansWrapper.class);		
                recs = recsx.Physicians;
            } else {
                System.debug('xxx MiddlewareUtil.getPhysicians ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getPhysicians ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getPhysicians EXCEPTION > '+ + e.getMessage());
        }
        System.debug('Number of Physicians ' + recs.size());
        System.debug('return Physicians list ' + recs);
        return recs;        
    }  
/* Physicians end */

	 @Future(callout=true)	
     public static void getDiagnosisCodes(){
        
        List<DiagnosisCode> dcs = new List<DiagnosisCode>();

        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(settings.Endpoint__c + '/api/billing/GetAllDiagnosisCodes');
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            if(!Test.isRunningTest()) {
                res = h.send(req);
            } else {
                res.setStatus('200');
                res.setStatusCode(200);
                res.setBody('{"DiagnosisCodes":[{"Code":"A01.09","Description":"Typhoid fever with other complications"},{"Code":"A41.9","Description":"Sepsis, unspecified organism"},{"Code":"B33.22","Description":"Viral myocarditis"},{"Code":"C11.9","Description":"Malignant neoplasm of nasopharynx, unspecified"}]}');

            }            
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getDiagnosisCodes res.getBody() > '+ res.getBody());
                DiagnosisCodesWrapper dcsx = (DiagnosisCodesWrapper) JSON.deserialize(res.getBody(), DiagnosisCodesWrapper.class);		
                dcs = dcsx.DiagnosisCodes;
            } else {
                System.debug('xxx MiddlewareUtil.getDiagnosisCodes ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getDiagnosisCodes ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getDiagnosisCodes EXCEPTION > '+ + e.getMessage());
        }
        System.debug('Number of diagnosis codes ' + dcs.size());
        System.debug('return diagnosis code list ' + dcs);
        List<Diagnosis_Code__c> updateList = new List<Diagnosis_Code__c>();
         
        for(MiddlewareUtil.DiagnosisCode d : dcs){
            Diagnosis_Code__c DiagnosisCode = new Diagnosis_Code__c();
            DiagnosisCode.Code__c = d.Code;
            if(d.Description.length() > 80)
                DiagnosisCode.Name = d.Description.substring(1,80);
            else    
                DiagnosisCode.Name = d.Description;
                
            DiagnosisCode.Backend_Id__c  = d.Code;

            updateList.add(DiagnosisCode);
        }

        System.debug('updateList > '+ updateList.size());

        List <Diagnosis_Code__c> deleteCodes = [SELECT ID FROM Diagnosis_Code__c];
        Delete deleteCodes;

        upsert updateList Fields.Backend_Id__c;
     }  

    //@Future(callout=true)	
    public static void getPayer(){
    
        List<Payer> payers = new List<Payer>();
    
        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(settings.Endpoint__c + '/api/Billing/GetPayers');
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('POST'); 
        req.setBody('');
        
        try {
            res = h.send(req);
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null ) {
                System.debug('xxxx getPayer res.getBody() > '+ res.getBody());
                payers = (List<Payer>) JSON.deserialize(res.getBody(), List<Payer>.class);		

                System.debug('Number of get payers ' + payers.size());
                System.debug('return get payer list ' + payers);
                List<Payer_Info__c> updateList = new List<Payer_Info__c>();
                Set<String> payerUuids = new Set<String>();    
                for(MiddlewareUtil.Payer p : payers){
                    Payer_Info__c pi = new Payer_Info__c();
                    pi.Payer_Id__c = p.Payer_Uuid;
                    if(p.Payer_Name.length() > 80)
                        pi.Name = p.Payer_Name.substring(0,80);
                    else    
                        pi.Name = p.Payer_Name;
                        
                    pi.Payer_Id__c  = p.Payer_Uuid;
                    payerUuids.add(p.Payer_Uuid);
                    System.debug('p.Payer_Uuid > '+ p.Payer_Uuid);
            
                    updateList.add(pi);
                }
                System.debug('updateList > '+ updateList.size());
           
                if(updateList.size() > 0){ 
                    List<Payer_Info__c> deleteRecs = [
                        SELECT Id 
                        FROM Payer_Info__c 
                        WHERE Payer_Id__c NOT IN :payerUuids]; 
                        
                        delete deleteRecs; 
                        System.debug('deleteRecs > '+ deleteRecs);
                }


                UPSERT updateList Fields.Payer_Id__c;
       

            } else {
                System.debug('xxx MiddlewareUtil.getPayer ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getPayer ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getPayer EXCEPTION > '+ + e.getMessage());
        }
    } 

/* billing status begin */
	 @Future(callout=true)
     public static void getBillingStatuses(){
        
        List<BillingStatus> bss = new List<BillingStatus>();

        String authToken = getAuthToken();
        String outcomeMsg;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String authorizationHeader = 'Bearer ' + authToken;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(settings.Endpoint__c + '/api/billing/GetAllBillingStatuses');
        req.setTimeout(120000); // timeout in milliseconds
        req.setMethod('GET'); 
        
        try {
            if(!Test.isRunningTest()) {
                res = h.send(req);
            } else {
                res.setStatus('204');
                res.setStatusCode(204);
            }            
            if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                System.debug('xxxx getBillingStatuses res.getBody() > '+ res.getBody());
                BillingStatusesWrapper bssx = (BillingStatusesWrapper) JSON.deserialize(res.getBody(), BillingStatusesWrapper.class);		
                bss = bssx.BillingStatuses;
            } else {
                System.debug('xxx MiddlewareUtil.getBillingStatuses ERROR res.getStatusCode() > '+ res.getStatusCode());
                System.debug('xxx MiddlewareUtil.getBillingStatuses ERROR res.getBody() > '+ res.getBody());
            }
            
        } catch (exception e) {
            System.debug('xxx MiddlewareUtil.getBillingStatuses EXCEPTION > '+ + e.getMessage());
        }
        System.debug('Number of Billing Status ' + bss.size());
        System.debug('return Billing Status list ' + bss);
         
        List<Billing_Status__c> updateList = new List<Billing_Status__c>();
        for(MiddlewareUtil.BillingStatus bs : bss){
            Billing_Status__c BillingStatus = new Billing_Status__c();
            BillingStatus.Id__c = bs.Id;
            BillingStatus.Name = bs.Description;
            BillingStatus.Backend_Id__c  = bs.Id;

            updateList.add(BillingStatus);
        }

        System.debug('updateList > '+ updateList.size());
 
        List <Billing_Status__c> deleteCodes = [SELECT ID FROM Billing_Status__c];
        Delete deleteCodes;

        upsert updateList Fields.Backend_Id__c;
     }  
/* billing status end */

/* UpdateAutoDialerFollowupDate begin */
public class FollowupDateObj {
    public String EnrollmentId; 
    public DateTime FollowupDate; 
    public String Username; 

}

public static String FollowupDate(String enrollmentId, Datetime followupDate, String userName){
        
    String authToken = getAuthToken();
    String outcomeMsg;
    
    FollowupDateObj obj = new FollowupDateObj();
    obj.EnrollmentId = enrollmentId;
    //obj.FollowupDate = '2020-06-18T16:37:20.7750793-04:00';
    obj.FollowupDate = followupDate;
    obj.UserName = userName;

    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    String authorizationHeader = 'Bearer ' + authToken;
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', authorizationHeader);
   // req.setHeader('Content-Length',String.valueOf(payload.length()));

    req.setEndpoint(settings.Endpoint__c + '/api/Enrollment/UpdateAutoDialerFollowupDate');
    req.setTimeout(120000); // timeout in milliseconds
    req.setMethod('POST'); 
    req.setBody(JSON.serialize(obj));

    System.debug('req > ' + req);
    System.debug('req body> ' + req.getBody());
    
    try {
        if(!Test.isRunningTest()) {
            res = h.send(req);
        } else {
            res.setStatus('204');
            res.setStatusCode(204);
        }

        middlewareLog('FollowupDate', enrollmentId, res, req);

        if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204)) {
            System.debug('xxxx UpdateAutoDialerFollowupDate res.getStatusCode() > '+ res.getStatusCode());
            outcomeMsg = 'Follup Date Successfully Updated';
        } else {
            System.debug('xxx MiddlewareUtil.FollowupDate ERROR res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxx MiddlewareUtil.FollowupDate ERROR res.getBody() > '+ res.getBody());
            outcomeMsg =  'ERROR Updating Follup Date - ' + res.getStatusCode() + ' ' + res.getBody();
        }
        
    } catch (exception e) {
        System.debug('xxx MiddlewareUtil.FollowupDate EXCEPTION > '+ + e.getMessage());
    }
    return outcomeMsg;
}

  
/* UpdateAutoDialerFollowupDate end */  

/* UpdateAutoDialerFollowupDate begin */

public class EnabledObj {
    public String EnrollmentId; 
    public Boolean Enable; 
    public String Username; 

}

public class ReInstateObj {
    public String EnrollmentId; 
    public String Username; 

}
public static String AutoDialerEnabled(String enrollmentId, Boolean enable, String userName){
        
    String authToken = getAuthToken();
    String outcomeMsg;
    
    EnabledObj obj = new EnabledObj();
    obj.EnrollmentId = enrollmentId;
    obj.Enable = enable;
    obj.UserName = userName;

    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    String authorizationHeader = 'Bearer ' + authToken;
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', authorizationHeader);
    //req.setHeader('Content-Length',String.valueOf(payload3.length()));

    req.setEndpoint(settings.Endpoint__c + '/api/Enrollment/UpdateAutoDialerEnabled');
    req.setTimeout(120000); // timeout in milliseconds
    req.setMethod('POST'); 
    req.setBody(JSON.serialize(obj));

    try {
        if(!Test.isRunningTest()) {
            res = h.send(req);
        } else {
            res.setStatus('204');
            res.setStatusCode(204);
        }        
        middlewareLog('AutoDialerEnabled', enrollmentId, res, req);
        if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201  || res.getStatusCode() == 204)) {
            System.debug('xxxx AutoDialerEnabled res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxxx AutoDialerEnabled res.getBody() > '+ res.getBody());
            outcomeMsg = 'AuotDialer Successfully Enabled';

        } else {
            System.debug('xxx MiddlewareUtil.AutoDialerEnabled ERROR res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxx MiddlewareUtil.AutoDialerEnabled ERROR res.getBody() > '+ res.getBody());
            outcomeMsg =  'ERROR Enabling Autodialer - ' + res.getStatusCode() + ' ' + res.getBody();
        }
        
    } catch (exception e) {
        System.debug('xxx MiddlewareUtil.AutoDialerEnabled EXCEPTION > '+ + e.getMessage());
    }
    return outcomeMsg;
}

//Re-Instate API
public static String RestartActivationProcess(String enrollmentId, String userName){
        
    String authToken = getAuthToken();
    String outcomeMsg;
    
    ReInstateObj obj = new ReInstateObj();
    obj.EnrollmentId = enrollmentId;
    obj.UserName = userName;

    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    String authorizationHeader = 'Bearer ' + authToken;
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', authorizationHeader);
    //req.setHeader('Content-Length',String.valueOf(payload3.length()));

    req.setEndpoint(settings.Endpoint__c + '/api/Enrollment/RestartActivationProcess');
    req.setTimeout(120000); // timeout in milliseconds
    req.setMethod('POST'); 
    req.setBody(JSON.serialize(obj));

    try {
        if(!Test.isRunningTest()) {
            res = h.send(req);
        } else {
            res.setStatus('204');
            res.setStatusCode(204);
        } 
        middlewareLog('RestartActivationProcess', enrollmentId, res, req);
        if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201  || res.getStatusCode() == 204)) {
            System.debug('xxxx AutoDialerEnabled res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxxx AutoDialerEnabled res.getBody() > '+ res.getBody());
            outcomeMsg = 'Reinstate Order Request Successful';

        } else {
            System.debug('xxx MiddlewareUtil.RestartActivation ERROR res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxx MiddlewareUtil.RestartActivation ERROR res.getBody() > '+ res.getBody());
            outcomeMsg =  'Reinstate Order Request Failed, Contact IT - ' + res.getStatusCode() + ' ' + res.getBody();
        }
        
    } catch (exception e) {
        System.debug('xxx MiddlewareUtil.RestartActivation EXCEPTION > '+ + e.getMessage());
    }
    return outcomeMsg;
}  

//CancelEnrollment API
public static String CancelEnrollment(String enrollmentId, String userName){
        
    String authToken = getAuthToken();
    String outcomeMsg;
    
    ReInstateObj obj = new ReInstateObj();
    obj.EnrollmentId = enrollmentId;
    obj.UserName = userName;

    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    String authorizationHeader = 'Bearer ' + authToken;
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', authorizationHeader);
    //req.setHeader('Content-Length',String.valueOf(payload3.length()));

    req.setEndpoint(settings.Endpoint__c + '/api/Enrollment/CancelEnrollment');
    req.setTimeout(120000); // timeout in milliseconds
    req.setMethod('POST'); 
    req.setBody(JSON.serialize(obj));

    try {
        if(!Test.isRunningTest()) {
            res = h.send(req);
        } else {
            res.setStatus('204');
            res.setStatusCode(204);
        }         
        middlewareLog('CancelEnrollment', enrollmentId, res, req);
        if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201  || res.getStatusCode() == 204)) {
            System.debug('xxxx AutoDialerEnabled res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxxx AutoDialerEnabled res.getBody() > '+ res.getBody());
            outcomeMsg = 'Cancel Order Request Successful';

        } else {
            System.debug('xxx MiddlewareUtil.AutoDialerEnabled ERROR res.getStatusCode() > '+ res.getStatusCode());
            System.debug('xxx MiddlewareUtil.AutoDialerEnabled ERROR res.getBody() > '+ res.getBody());
            outcomeMsg =  'Cancel Order Request Failed, Contact IT - ' + res.getStatusCode() + ' ' + res.getBody();
        }
        
    } catch (exception e) {
        System.debug('xxx MiddlewareUtil.CancelEnrollment EXCEPTION > '+ + e.getMessage());
    }
    return outcomeMsg;
}  

/* UpdateAutoDialerFollowupDate end */ 

    public static String getAuthToken(){

        String authHeaderString;
       
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        authResponse ar = new authResponse();    	
        
        Integer retryAmount = ((Integer)settings.Retry_Amount__c) == null ? 1 : ((Integer)settings.Retry_Amount__c);
        req.setEndpoint(settings.tokenEndPoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000); // timeout in milliseconds
        String bodyString = 'grant_type=password&username=' + EncodingUtil.urlEncode(settings.Username__c,'UTF-8') + '&password=' + EncodingUtil.urlEncode(settings.Password__c,'UTF-8');
        req.setBody(bodyString); 
        
        for(Integer i = 1; i <= retryAmount; i++){
            try {
                System.debug('Attempt #' + i);
                res = h.send(req);
             
                if ((res.getStatusCode() == 0 || res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                    System.debug('xxx MiddlewareUtil.getAuthToken: Status Code > '+ res.getStatusCode());
                   // System.debug('xxxx auth res.getBody() > '+ res.getBody());
                    ar = (authResponse) JSON.deserialize(res.getBody(), authResponse.class);		
                } else {
                    System.debug('xxx MiddlewareUtil.getAuthToken: res.getStatusCode() > '+ res.getStatusCode());
                    System.debug('xxx MiddlewareUtil.getAuthToken: res.getBody() > '+ res.getBody());
                }
            } catch (exception e) {
                System.debug('Attempt #' + i + 'failed');
                System.debug('xxx MiddlewareUtil.getAuthToken: exception > '+ e.getMessage());   
            }
            if(ar.access_token != null) {
                break;
            }
        }
        return ar.access_token;
    }
    private static void middlewareLog(String process, String backendId, HttpResponse res, HttpRequest req){
        Middleware_Log__c log = new Middleware_Log__c();
        
        List<Order> orders = new List<Order>();
        if(backendId != null){
            orders = [SELECT Id FROM Order WHERE Enrollment_Backend_ID__c = :backendId];
            if(orders.size() > 0)
                log.Order__c = orders[0].Id;
                log.Backend_Id__c = backendId; 
        }
        log.Process__c = process;
        log.Return_Code__c = res.getStatusCode();
        log.Response__c = res.getBody();
        log.Payload__c = req.getBody();
        
        INSERT log;
    }
    private static Middleware_Log__c middlewareLogRec(String process, String backendId, HttpResponse res, HttpRequest req){
        Middleware_Log__c log = new Middleware_Log__c();
        
        List<Order> orders = new List<Order>();
        if(backendId != null){
            orders = [SELECT Id FROM Order WHERE Enrollment_Backend_ID__c = :backendId];
            if(orders.size() > 0)
                log.Order__c = orders[0].Id;
                log.Backend_Id__c = backendId; 
        }
        log.Process__c = process;
        log.Return_Code__c = res.getStatusCode();
        log.Response__c = res.getBody();
        log.Payload__c = req.getBody();

        return log;
    }

    public static Middleware__mdt getSettings(){
        String instance = UserInfo.getUserName().substringAfterLast('.').toUpperCase();
        System.debug('xxx instance '+ instance);
        String env;
        switch on instance{
            when 'BIOTEL'
                {env = 'PROD';}
            when 'COM'
                {env = 'PROD';}
            when 'UAT'
                {env = 'UAT';}
            when 'QA'
                {env = 'QA';}
            when 'DEV1'
                {env = 'DEV';}
            when 'CCDEV4'
                {env = 'DEV';}
            when 'CCDEV5'
                {env = 'DEV';}
            when 'CCDEV6'
                {env = 'DEV';}
            when else
                {env = 'PROD';}
        }

        Middleware__mdt settings = [
            SELECT Endpoint__c, Instance__c, Password__c, tokenEndPoint__c, Username__c, Retry_Amount__c, Enrollment_Submission__c
              FROM Middleware__mdt
             WHERE Label = :env
              ];

         System.debug('getSettings settings ==> ' + settings);     
        return settings;
    }

    public static String  createRandomGuid(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        System.debug('createRandomGuid ' + guid);
        return guid;        
    }
    
    public class authResponse{
        public String refresh_token;
        public String token_type;
        public String access_token;
    }
    /*
    public class authResponseSF{
        public String access_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
        public String signature;
    } */

    public class ShipmentsWrapper{
        @AuraEnabled public List <Shipment> Shipments;
    }

    public class ShipmentWrapper{
        @AuraEnabled public Shipment Shipment;
    }
    public class Shipment{
        @AuraEnabled public String Id;
        @AuraEnabled public String OwnerId;
        @AuraEnabled public String BackendId;
        @AuraEnabled public String IsDeleted;
        @AuraEnabled public String Name;
        @AuraEnabled public String LastViewedDate;
        @AuraEnabled public String LastReferencedDate;
        @AuraEnabled public String Enrollment;
        @AuraEnabled public String BundleNumber;
        @AuraEnabled public String CenterName;
        @AuraEnabled public String DeliverByDate;
        @AuraEnabled public String FulfilledDateTime;
        @AuraEnabled public String KitName;
        @AuraEnabled public String Status;
        @AuraEnabled public String Type;
        @AuraEnabled public String CreatedUser;
        @AuraEnabled public DateTime CreatedDate;
        @AuraEnabled public List <ShipmentItem> ShipmentItems;
        @AuraEnabled public String EnrollmentNumber; //populated from shipment SOQL
        @AuraEnabled public String EnrollmentId; //populated from shipment SOQL
        @AuraEnabled public String FulfilledDateString;
        @AuraEnabled public String DeliverByDateString;
        @AuraEnabled public String TrackingNumber;
        @AuraEnabled public String ExtensionData;
    }

    public class ShipmentItem{
        @AuraEnabled public String Id;
        @AuraEnabled public Boolean IsDeleted;
        @AuraEnabled public String Name;
        @AuraEnabled public String LastViewedDate;
        @AuraEnabled public String LastReferencedDate;
        @AuraEnabled public String Shipment;
        @AuraEnabled public String AssetSerialNumber;
        @AuraEnabled public String Description;
        @AuraEnabled public String Quantity;
        @AuraEnabled public String BackendId;
		@AuraEnabled public String ReturnTrackingNumber;
        @AuraEnabled public String ExtensionData;
    }    

    public class NotesWrapper{
        @AuraEnabled public List <Note> Notes;
    }
    public class Note{
        @AuraEnabled public String BackendId;
        @AuraEnabled public String Subject;
        @AuraEnabled public String Description;
        @AuraEnabled public String ActivityDate;
        @AuraEnabled public String WhatId;
        @AuraEnabled public String SourceSystem;
        @AuraEnabled public String SourceCreatedBy;
        @AuraEnabled public DateTime SourceCreatedTime;
        @AuraEnabled public String enrollmentId;
        @AuraEnabled public String enrollmentName;
        @AuraEnabled public String enrollmentUrl;
    }
    
    public class ZipCodesWrapper{
        List <ZipCode> ZipCodes;
    }

    public class ZipCode{
        public String ZipCode;
        public String City;
        public String State;
        public String Country;
    }

    public class BundlesWrapper{
         @AuraEnabled  public List <Bundle> Bundles;
    }

    public class Bundle{
         @AuraEnabled public String Id;
         @AuraEnabled public String DeviceSerialNumber;
         @AuraEnabled public String DeviceTypeName;
         @AuraEnabled public String DeviceTypeId;
    }

    public class PhysiciansWrapper{
         @AuraEnabled  public List <Physician> Physicians;
    }

    public class Physician{
         @AuraEnabled public String Id;
         @AuraEnabled public String FirstName;
         @AuraEnabled public String Lastname;
    }


    public class BillingStatusesWrapper{
        List <BillingStatus> BillingStatuses;
    }

    public class BillingStatus{
        public String Id;
        public String Description;
    }

    public class DiagnosisCodesWrapper{
        List <DiagnosisCode> DiagnosisCodes;
    }

    public class DiagnosisCode{
        public String Code;
        public String Description;
    }
    public class PayerWrapper{
        List <Payer> Payers;
    }

    public class Payer{
        public String Payer_Uuid;
        public String Payer_Name;
    }
}