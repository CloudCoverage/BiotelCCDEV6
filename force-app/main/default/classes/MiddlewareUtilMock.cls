@isTest
global  class MiddlewareUtilMock implements HttpCalloutMock {
    private String typeOfResponse;
    public MiddlewareUtilMock() {
    }
    public MiddlewareUtilMock(String typeOfResponse) { 
        this.typeOfResponse = typeOfResponse;
    }

    global HTTPResponse respond(HTTPRequest req) { 
        HttpResponse res = new HttpResponse();
        System.debug ('xxx mock req '+ req);
        System.debug ('xxx mock req.getEndpoint() '+ req.getEndpoint());
		String endpoint = req.getEndpoint();
        String environment = endpoint.endsWith('token') ? endpoint.substringBefore('/token') : endpoint.substringBefore('/api');
        System.debug('environment variable = ' + environment);
        
        if(typeOfResponse == 'token fail'){
            System.debug('xxx we are in Token fail');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"invalid_grant","error_description":"The user name or password is incorrect"}');
            res.setStatusCode(400);
        }
        else if(req.getEndpoint() == environment + '/token'){
            System.debug('xxx we are in AuthGood');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"ABC123","token_type":"bearer","expires_in":"12:00"}');
            res.setStatusCode(200);
        }  
        else if(req.getEndpoint() == 'ZipGood/api/billing/GetAllZipCodes'){
            System.debug('xxx we are in ZipGood');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ZipCodes":[{"ZipCode":"0","City":"West Milton","State":"PA","Country":"USA"},{"ZipCode":"000","City":"Ofallon","State":"MO","Country":"USA"}]}');
            res.setStatusCode(200);
        } 
        else if(req.getEndpoint() == 'ZipBad/api/billing/GetAllZipCodes'){
            System.debug('xxx we are in ZipBad');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ZipCodes":[]');
            res.setStatusCode(400);
        }
        else if(req.getEndpoint() == environment + '/api/Inventory/GetOTSBundles?locationId=ABC123&serviceTypeId=3'){
            System.debug('xxx we are in GetOTSBundles');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Bundles":[{"Id":"791dd4ff-e411-490f-b771-924ce49a0c81","DeviceSerialNumber":"MB5003608","DeviceTypeName":"C5 Monitor","DeviceTypeId":"bb7147db-3c08-427d-8f47-b521c23adda7"},{"Id":"116b16ff-4af8-4b82-ad1b-2e1a419d8320","DeviceSerialNumber":"MA1106205","DeviceTypeName":"C5 Monitor","DeviceTypeId":"bb7147db-3c08-427d-8f47-b521c23adda7"},{"Id":"74f1c8e5-df96-4a13-9350-76e65f586597","DeviceSerialNumber":"850394","DeviceTypeName":"ECAT Monitor","DeviceTypeId":"101cafe0-66e4-4873-8fd2-b4685ea1aee8"}]}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint() == environment + '/api/enrollment/submit' || req.getEndpoint() == 'https://sfgateway-dev1.cardionet.com/token/api/enrollment/submit'){
            System.debug('xxx we are in SubmitFax');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('"f788bac9-5fb8-4af0-a48d-40973af082db"');
            res.setStatusCode(200);

        } 
        else if(req.getEndpoint() == environment + '/api/Billing/GetEncounterNumber?encounterId=submissionId'){ 
            System.debug('xxx we are in GetEncounterNumber');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"EncounterNumber":3627691.0}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint() == environment + '/api/PracticeManagement/GetPhysicians?locationId=ABC123'){ 
            System.debug('xxx we are in GetEncounterNumber');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Physicians":[{"Id":"b2426980-a4db-4373-839f-07e263b13ded","FirstName":"Tyrion","Lastname":"Lannister"},{"Id":"0a0e294b-0cbe-4e5b-ad91-171002946962","FirstName":"ramanan","Lastname":"kumareswaran"},{"Id":"c7263e7d-1a94-4698-863f-fb8e6183c638","FirstName":"John","Lastname":"Doe"}]}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint() == environment + '/api/billing/GetAllDiagnosisCodes'){ 
            System.debug('xxx we are in GetAllDiagnosisCodes');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"DiagnosisCodes":[{"Code":"A01.09","Description":"Typhoid fever with other complications"},{"Code":"A41.9","Description":"Sepsis, unspecified organism"},{"Code":"B33.22","Description":"Viral myocarditis"},{"Code":"C11.9","Description":"Malignant neoplasm of nasopharynx, unspecified"}]}');
            res.setStatusCode(200);
        }        
        else if(req.getEndpoint() == environment + '/api/billing/GetAllBillingStatuses'){ 
            System.debug('xxx we are in /api/billing/GetAllBillingStatuses');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"BillingStatuses":[{"Id":"cc8891d3-954e-4567-8baf-e1a7b1dad077","Description":"Pending-Insurance Authorization"},{"Id":"7d0b1496-c326-419a-bfe3-69004b1ea866","Description":"Pending-INR IV Conversion"}]}');
            res.setStatusCode(200);
        }        

        else if(req.getEndpoint() == environment + '/api/Enrollment/GetEnrollmentNotes?enrollmentId=abc123'){ 
            System.debug('xxx we are in Controller/api/Enrollment/GetEnrollmentNotes?enrollmentId=abc123');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Notes":[{"BackendId":"10550830","Subject":"NEXTGEN Activity","Description":"Online Enrollment","ActivityDate":"2019-07-17T11:31:09.213","WhatId":"f06106bd-80ef-4e8c-aa0f-ba21912b222b","SourceSystem":"NEXTGEN","SourceCreatedBy":"NEXTGENIntegration","SourceCreatedTime":"2019-07-17T11:31:09.213"}]}');
            res.setStatusCode(200);
        }        
        else if(req.getEndpoint() == environment + '/api/Inventory/GetEnrollmentShipments?enrollmentId=abc123'){ 
            System.debug('xxx we are in Controller/api/Inventory/GetEnrollmentShipments?enrollmentId=abc123');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Shipments":[{"Id":null,"OwnerId":null,"BackendId":"ec3afe3b-9814-4ef5-a32d-ed08e782d2a1","IsDeleted":false,"Name":"2300928","LastViewedDate":null,"LastReferencedDate":null,"Enrollment":"f06106bd-80ef-4e8c-aa0f-ba21912b222b","BundleNumber":"2300928","CenterName":"Chester","DeliverByDate":"2019-07-19T00:00:00","FulfilledDateTime":"2019-07-18T00:00:00","KitName":"C6 Flex Electrode","Status":"Completed","Type":"Ship To Patient","CreatedUser":"CARDIONETandrea.purnell","CreatedDate":"2019-07-17T08:52:42.367","ShipmentItems":[{"Id":null,"IsDeleted":false,"Name":"100-0046-02","LastViewedDate":null,"LastReferencedDate":null,"Shipment":"ec3afe3b-9814-4ef5-a32d-ed08e782d2a1","AssetSerialNumber":"MT21001033","Description":"Monitor (C6) J3","Quantity":1.0,"BackendId":"2cccfa08-20aa-46c2-a260-f80effa8553a","ExtensionData":null}],"ExtensionData":null}]}');
            res.setStatusCode(200);
        } else if(req.getEndpoint().contains('/api/Billing/GetPayers')){ 
            System.debug('xxx we are in /api/Billing/GetPayers');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"Payer_Uuid": "966b6b5a-b325-481d-aec6-c539ac512f91", "Payer_Name": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit"},{"Payer_Uuid": "1577869b-02bd-43ef-a764-da769069cd1e","Payer_Name": "Advanced Med Docs CA"}]');
            res.setStatusCode(200);
        } else{
            System.debug('xxx we are in else ZipGood');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ZipCodes":[{"ZipCode":"0","City":"West Milton","State":"PA","Country":"USA"},{"ZipCode":"000","City":"Ofallon","State":"MO","Country":"USA"}]}');
            res.setStatusCode(200);

        } 
        return res;
    }
}