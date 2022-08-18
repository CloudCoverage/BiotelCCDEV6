Global without sharing class BatchUPSTracker  implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful  {
    /*
    BatchUPSTracker sched = new BatchUPSTracker();
    sched.execute(null);

	//Everyday @ 1:00 AM
	System.Schedule('BatchUPSTracker Batch Job',  '0 0 1 * * ?', new BatchUPSTracker());
	
	//Every 15 minutes
	System.Schedule('BatchUPSTracker Batch Job @ 0 past the hour',  '0 0 * * * ?', new BatchUPSTracker());
	System.Schedule('BatchUPSTracker Batch Job @ 15 past the hour',  '0 15 * * * ?', new BatchUPSTracker());
	System.Schedule('BatchUPSTracker Batch Job @ 30 past the hour',  '0 30 * * * ?', new BatchUPSTracker());
	System.Schedule('BatchUPSTracker Batch Job @ 45 past the hour',  '0 45 * * * ?', new BatchUPSTracker());
    */

    public String query;
	private List<Send_Queue__c> newRecs;

    global BatchUPSTracker() {
        query = 'SELECT Id, Patient__c, Enrollment__c, Event__c, Status__c, Type__c, Template_ID__c, From__c, To__c, Error_Message__c, ' +
				'Sent_Timestamp__c, Tracking_Number__c, Name, Body__c, Shipment_Delivery_Time__c, Enrollment_Number__c ' + 
                'FROM Send_Queue__c ' +
                'WHERE Status__c = \'Pending\' AND Event__c IN(\'Shipment_Confirmation\', \'Delivery_Confirmation\') ';  
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('xxx query ' + query);      

        return Database.getQueryLocator(query);
    }

    global  void execute(Database.BatchableContext BC, List<Send_Queue__c> shipments){
        System.debug('size ' + shipments.size());
		this.newRecs = new List<Send_Queue__c>();
        for(Send_Queue__c ship : shipments){
			processRecord(ship);
        }
		update shipments;
		insert newRecs;
    }

	private void processRecord(Send_Queue__c ship){
		//SendQueueHelper deliveryHelper = new SendQueueHelper('Delivery_Confirmation');
		//SendQueueHelper shipmentHelper = new SendQueueHelper('Shipment_Confirmation');
		SendQueueHelper sendQueueHelper = new SendQueueHelper();


		HttpResponse res = new  HttpResponse();
		//if(!test.isRunningTest()){
		   res = makeCall(ship.Tracking_Number__c);
		//} else {
		//    res.setStatusCode(200);
		//    res.setBody(testResponsePayload);
	   // }
		Boolean arrayMode = false;
		Boolean shipped = false;
		Boolean delivered = false;
		if(res.getStatusCode() == 200 && !res.getBody().contains('Fault')){
			Integer cnt = 0;
			String bodyString = res.getBody();
			if(bodyString.contains('"Package":[')){
				bodyString = bodyString.replace('"Package"','"Package_Z" : {},"Package_Y"');
				arrayMode = true;
			}else{
				bodyString = bodyString.replace('"Package"','"Package_Z"');
			}
			bodyString = bodyString.replace('"Date"','"Date_Z"');
			bodyString = bodyString.replace('"Time"','"Time_Z"');
			if(bodyString.contains('"Activity":{')){
				bodyString = bodyString.replace ('"Activity":{', '"Activity":[{');
				bodyString = bodyString.replace (', "PackageWeight"', '], "PackageWeight"');
			}

			System.debug('bodyString ' + bodyString);

			TrackResponseWrapper response = (TrackResponseWrapper) JSON.deserialize(bodyString, TrackResponseWrapper.class);
			if(arrayMode)
				response.TrackResponse.Shipment.Package_Z = new Package_Z();
			else
				response.TrackResponse.Shipment.Package_Y = new List<Package_Z>();

			List<Activity> activity = new List<Activity>();
			if(!arrayMode) 
				activity = response.TrackResponse.Shipment.Package_Z.Activity;
			else
			//else if(response.TrackResponse != null && response.TrackResponse.Shipment!= null && response.TrackResponse.Shipment.Package_Y != null && response.TrackResponse.Shipment.Package_Y.size() > 0 && response.TrackResponse.Shipment.Package_Y[0].Activity.size() > 0)
				activity = response.TrackResponse.Shipment.Package_Y[0].Activity;

			System.debug('xxx activity ' + activity);
			if(activity != null && activity.size() > 0){
				for(Activity a : activity){
					if(a.Status.Type == 'I' || a.Status.Type == 'O'){
						shipped = true;
					}
					if(a.Status.Type == 'D'){
						System.debug('xxx PACKAGE DELIVERED ' + a);
						shipped = true;
						delivered = true;
						break;
					}
				}
				cnt++;						
			}
			if(shipped && ship.Event__c == 'Shipment_Confirmation' && ship.Status__c == 'Pending' && ship.Type__c == 'Email'){
				ship.Status__c = 'Ready to Process';
				ship.Send_Timestamp__c = System.now();
				Integer year = Integer.valueOf(activity[cnt-1].Date_Z.substring(0, 4));
				Integer month = Integer.valueOf(activity[cnt-1].Date_Z.substring(4, 6));
				Integer day = Integer.valueOf(activity[cnt-1].Date_Z.substring(6, 8));
				ship.Shipment_Date__c = Date.newInstance(year, month, day);

				if(response.TrackResponse.Shipment != null &&
				   response.TrackResponse.Shipment.DeliveryDetail != null &&
				   response.TrackResponse.Shipment.DeliveryDetail.Date_Z != null){
					
					year = Integer.valueOf(response.TrackResponse.Shipment.DeliveryDetail.Date_Z.substring(0, 4));
					month = Integer.valueOf(response.TrackResponse.Shipment.DeliveryDetail.Date_Z.substring(4, 6));
					day = Integer.valueOf(response.TrackResponse.Shipment.DeliveryDetail.Date_Z.substring(6, 8));
					ship.Estimated_Delivery_Date__c = Date.newInstance(year, month, day);
				}

				newRecs.add(sendQueueHelper.createSendQueRecord(ship, ship.Tracking_Number__c, 'Delivery_Confirmation', 'Email'));
			} else if(delivered && ship.Event__c == 'Delivery_Confirmation' && ship.Status__c == 'Pending' && ship.Type__c == 'Email'){
				ship.Status__c = 'Ready to Process';
				ship.Send_Timestamp__c = System.now();
				
				ship.Shipment_Delivery_Desc__c = activity[cnt-1].Status.Description;
				ship.Shipment_Delivery_Time__c = activity[cnt-1].Time_Z.subString(0,2) + ':' 
					+ activity[cnt-1].Time_Z.subString(2,4) + ':' + activity[cnt-1].Time_Z.subString(4,6);
				ship.Shipment_Delivery_Date_Text__c = activity[cnt-1].Date_Z;
				Integer year = Integer.valueOf(activity[cnt-1].Date_Z.substring(0, 4));
				Integer month = Integer.valueOf(activity[cnt-1].Date_Z.substring(4, 6));
				Integer day = Integer.valueOf(activity[cnt-1].Date_Z.substring(6, 8));
				ship.Shipment_Delivery_Date__c = Date.newInstance(year, month, day);

			}
		}

	}
    global void finish(Database.BatchableContext BC){

    }
    
	global void execute(SchedulableContext SC) 
	{		
		ID batchprocessid = Database.executeBatch(new BatchUPSTracker(), 10);
	}     


    public static HttpResponse makeCall(String trackingNumber){

        String userid = 'jlwhitfill';
        String password = '27@!mn62';
        String license = '1D0AEC7890D5D1B8';


        String payload = '{ "UPSSecurity": { "UsernameToken": { "Username": "' +
            userid + 
            '", "Password": "' +
            password + 
            '" }, "ServiceAccessToken": { "AccessLicenseNumber": "' +
            license +
            '" } }, "TrackRequest": { "Request": { "RequestOption": "1", "TransactionReference": { "CustomerContext": "" } }, "InquiryNumber": "' + 
            trackingNumber +
            '" }}';

        System.debug( 'xxx payload ' + payload);

		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
        //req.setEndpoint('https://wwwcie.ups.com/rest/Track');
        req.setEndpoint('https://onlinetools.ups.com/rest/Track');
		req.setHeader('Content-Type','application/json; charset=UTF-8');
		req.setHeader('Content-Length',String.valueOf(payload.length()));
        req.setTimeout(120000); // timeout in milliseconds

		req.setBody(payload);
		Http h = new Http();
		HttpResponse res = new HttpResponse();
		if(!test.isRunningTest()){
	    	res = h.send(req);
		} else {
			res.setStatusCode(200);
			res.setBody(testResponsePayload);
		}

		System.debug('xxx res' + res.getStatusCode());
		System.debug('xxx res' + res.getBody());

		return res;
    }

	public class TransactionReference {
		public String CustomerContext;
	}

	public UPSSecurity UPSSecurity;
	public TrackRequest TrackRequest;

	public class ServiceAccessToken {
		public String AccessLicenseNumber;
	}

	public class TrackRequest {
		public Request Request;
		public String InquiryNumber;
	}

	public class UPSSecurity {
		public UsernameToken UsernameToken;
		public ServiceAccessToken ServiceAccessToken;
	}

	public class UsernameToken {
		public String Username;
		public String Password;
	}

	public class Request {
		public String RequestOption;
		public TransactionReference TransactionReference;
	}
    //payload for GET Response
	public class TrackResponseWrapper {
		public TrackResponse TrackResponse;
	}

	public class TrackResponse {
		public Response Response;
		public Shipment Shipment;
		public String Disclaimer;	
	}
	public class Response {
		public ResponseStatus ResponseStatus;
		public TransactionReference TransactionReference;
	}
	public class ResponseStatus {
		public String Code;	//1
		public String Description;	//Success
	}
	public class Shipment {
		public InquiryNumber InquiryNumber;
		public ShipmentType ShipmentType;
		public String ShipperNumber;	//12345E
		public Service Service;
		public Package_Z Package_Z;
		public List<Package_Z> Package_Y;
		public DeliveryDetail DeliveryDetail;
	}
	public class DeliveryDetail {
		public String Date_Z;	//20100830
	}
	public class InquiryNumber {
		public String Code;	//01
		public String Description;	//ShipmentIdentificationNumber
		public String Value;	//1Z12345E6205277936
	}
	public class ShipmentType {
		public String Code;	//01
		public String Description;	//Small Package
	}
	public class Service {
		public String Code;	//13
		public String Description;	//NEXT DAY AIR SAVER
	}
	public class Package_Z {
		public String TrackingNumber;	//1Z12345E6205277936
		public Activity[] Activity;
		public PackageWeight PackageWeight;
	}
	public class Activity {
		//public ActivityLocation ActivityLocation;
		public Status Status;
		public String Date_Z;	//20100830
		public String Time_Z;	//103900
	}
	public class ActivityLocation {
		public Address Address;
	}
	public class Address {
		public String City;	//BONN
		public String CountryCode;	//DE
	}
	public class Status {
		public String Type;	//X
		public String Description;	//UPS INTERNAL ACTIVITY CODE
		public String Code;	//KB
	}
	public class PackageWeight {
		public UnitOfMeasurement UnitOfMeasurement;
		public String Weight;	//1.00
	}
	public class UnitOfMeasurement {
		public String Code;	//LBS
	}

	public static String testResponsePayload = '{ "TrackResponse": { "Response": { "ResponseStatus": { "Code": "1", "Description": "Success" }, "TransactionReference": { "CustomerContext": "Your Test Case Summary Description" } }, "Shipment": { "InquiryNumber": { "Code": "01", "Description": "ShipmentIdentificationNumber", "Value": "1ZAA30921328315067" }, "ShipperNumber": "AA3092", "ShipmentAddress": [ { "Type": { "Code": "01", "Description": "Shipper Address" }, "Address": { "AddressLine": "W 1333 BELMONT AVE", "City": "CHICAGO", "StateProvinceCode": "IL", "PostalCode": "606575785", "CountryCode": "US" } }, { "Type": { "Code": "02", "Description": "ShipTo Address" }, "Address": { "City": "JACKSON", "StateProvinceCode": "NJ", "PostalCode": "08527", "CountryCode": "US" } } ], "ShipmentWeight": { "UnitOfMeasurement": { "Code": "LBS" }, "Weight": "1.00" }, "Service": { "Code": "013", "Description": "UPS Next Day Air Saver" }, "ReferenceNumber": { "Code": "01", "Value": "7006309-0" }, "PickupDate": "20200122", "DeliveryDetail": { "Type": { "Code": "03", "Description": "Scheduled Delivery" }, "Date": "20200123", "Time": "150000" }, "Package": { "TrackingNumber": "1ZAA30921328315067", "PackageServiceOption": { "Type": { "Code": "010", "Description": "Hundredweight" } }, "Activity": [ { "ActivityLocation": { "Address": { "City": "JACKSON", "StateProvinceCode": "NJ", "PostalCode": "08527", "CountryCode": "US" }, "Code": "ML", "Description": "Front Door" }, "Status": { "Type": "D", "Description": "Delivered", "Code": "FS" }, "Date": "20200123", "Time": "120121" }, { "ActivityLocation": { "Address": { "City": "Lakewood", "StateProvinceCode": "NJ", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Out For Delivery Today", "Code": "OT" }, "Date": "20200123", "Time": "084708" }, { "ActivityLocation": { "Address": { "City": "Lakewood", "StateProvinceCode": "NJ", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Loaded on Delivery Vehicle", "Code": "OF" }, "Date": "20200123", "Time": "084042" }, { "ActivityLocation": { "Address": { "City": "Lakewood", "StateProvinceCode": "NJ", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Destination Scan", "Code": "DS" }, "Date": "20200123", "Time": "080649" }, { "ActivityLocation": { "Address": { "City": "Lakewood", "StateProvinceCode": "NJ", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Arrival Scan", "Code": "AR" }, "Date": "20200123", "Time": "043700" }, { "ActivityLocation": { "Address": { "City": "Philadelphia", "StateProvinceCode": "PA", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Departure Scan", "Code": "DP" }, "Date": "20200123", "Time": "023900" }, { "ActivityLocation": { "Address": { "City": "Philadelphia", "StateProvinceCode": "PA", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Arrival Scan", "Code": "AR" }, "Date": "20200122", "Time": "232700" }, { "ActivityLocation": { "Address": { "City": "Chicago", "StateProvinceCode": "IL", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Departure Scan", "Code": "DP" }, "Date": "20200122", "Time": "203400" }, { "ActivityLocation": { "Address": { "City": "Chicago", "StateProvinceCode": "IL", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Arrival Scan", "Code": "AR" }, "Date": "20200122", "Time": "185600" }, { "ActivityLocation": { "Address": { "City": "Chicago", "StateProvinceCode": "IL", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Departure Scan", "Code": "DP" }, "Date": "20200122", "Time": "180400" }, { "ActivityLocation": { "Address": { "City": "Chicago", "StateProvinceCode": "IL", "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "I", "Description": "Origin Scan", "Code": "OR" }, "Date": "20200122", "Time": "173441" }, { "ActivityLocation": { "Address": { "CountryCode": "US" }, "Description": "Front Door" }, "Status": { "Type": "M", "Description": "Order Processed: Ready for UPS", "Code": "MP" }, "Date": "20200122", "Time": "162601" } ], "PackageWeight": { "UnitOfMeasurement": { "Code": "LBS" }, "Weight": "1.00" }, "ReferenceNumber": { "Code": "01", "Value": "7006309-0" } } }, "Disclaimer": "You are using UPS tracking service on customer integration test environment, please switch to UPS production environment once you finish the test. The URL is https://onlinetools.ups.com/webservices/Track" }}';
}