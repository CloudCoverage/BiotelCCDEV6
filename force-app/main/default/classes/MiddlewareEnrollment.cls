public with sharing class MiddlewareEnrollment {

    public static HttpResponse process(Fax_Enrollment__c fax) { 

        HttpResponse res = new HttpResponse();

        if(fax != null){
            Enrollment_Z enrz = new Enrollment_Z();
            //if(fax.Status__c == 'Submitted')
            enrz.Username = UserInfo.getUserName();
            enrz.Enrollment = populateJSON(fax);
            enrz.EnrollmentSource = populateEnrollmentSource(fax);
            System.debug('xxx enrz > ' + JSON.serialize(enrz, true));
            res = MiddlewareUtil.SubmitFax(JSON.serialize(enrz, true), fax.Status__c);
        }
        return res;
    }

    public static EnrollmentSource populateEnrollmentSource(Fax_Enrollment__c faxEnr) {
        EnrollmentSource ens = new EnrollmentSource();
        if(faxEnr.Service_Type__c == 'INR'){
            ens.SourceEntity = 'INR Fax';
        }
        else{
            ens.SourceEntity = 'Fax';
        }
        return ens;
    }

    public static Enrollment populateJSON(Fax_Enrollment__c fax) {
        Enrollment enr = new Enrollment(); 
        enr.Id =  fax?.Submission_Id__c;
        enr.DiagnosisCodes = new List<String>();
        
        if(isValidId(fax.Diagnosis_Code__c))
            enr.DiagnosisCodes.add(getDiagnosisCode(fax.Diagnosis_Code__c));

        if(isValidId(fax.Diagnosis_Code_2__c))
            enr.DiagnosisCodes.add(getDiagnosisCode(fax.Diagnosis_Code_2__c)); 

        if(isValidId(fax.Diagnosis_Code_3__c))
            enr.DiagnosisCodes.add(getDiagnosisCode(fax.Diagnosis_Code_3__c)); 

        if(isValidId(fax.Diagnosis_Code_4__c))
            enr.DiagnosisCodes.add(getDiagnosisCode(fax.Diagnosis_Code_4__c));  

        Datetime tempDt = System.now();
        enr.StartTime = gmt(tempDt, 'America/New_York');

        if(fax.Enrollment_Duration__c != null)
            enr.Duration = fax.Enrollment_Duration__c.intValue();
        if(fax.OTS_Device__c != null)    
            enr.CurrentBundleId = fax.OTS_Device__c;
        
        if(fax.Event_Device_Type__c != null){
            if(fax.Event_Device_Type__c == 'Chest Plate')
        //      enr.DeviceTypeId = 'A1BC9AA1-0875-4CFB-B1EF-E043F0E7BDE5';
                enr.DeviceTypeId = 'a1bc9aa1-0875-4cFb-b1ef-e043f0e7bde5';
            else if(fax.Event_Device_Type__c == 'wEvent')
                enr.DeviceTypeId = 'ee5f0602-d8bc-49ce-81b1-dcc5121e3fc0'; 
            else
            enr.DeviceTypeId = fax.Event_Device_Type__c;       
        }else{
            if(fax.Service_Type__c == 'INR'){
                enr.DeviceTypeId = '9FDDF35F-1411-485B-BBE6-111267A0B235';
            }
            else{
                //Set device Type to C6
                enr.DeviceTypeId = '9233abb7-f671-4326-87e6-3d4077c0dada';
            }
        }    
        //1 - MTP, 2 - OTS
        if(fax.Device_Source__c != null){
            if(fax.Device_Source__c == 'MTP')
                enr.DeviceSource = 1;
             else if(fax.Device_Source__c == 'OTS')
                enr.DeviceSource = 2;
        }    

        if(fax.Referring_Physician_First_Name__c != null)    
            enr.ReferringPhysicianFirstName = fax.Referring_Physician_First_Name__c;

        if(fax.Referring_Physician_Last_Name__c != null)    
            enr.ReferringPhysicianLastName = fax.Referring_Physician_Last_Name__c;
            
        if(fax.Notifying_Physician__c != null)    
            enr.NotificationPhysicianId = fax.Notifying_Physician__c;

        if(fax.Ordering_Physician__c != null)    
            enr.OrderingPhysicianId = fax.Ordering_Physician__c;

        if(fax.Practice_Location__c != null)    
            enr.LocationId = getBackendId(fax.Practice_Location__c);
		
        enr.Patient = populatePatient(fax);
        enr.PrimaryInsurance = populatePrimaryInsurance(fax);

        if(fax.Service_Type__c != null){
            //Event = 1, Holter = 2, MCT = 3
            switch on fax.Service_Type__c{
                when 'EVENT'
                    {enr.ServiceTypeId = 1;}
                when 'Holter'
                    {enr.ServiceTypeId =  2;}
                when 'MCT'
                    {enr.ServiceTypeId =  3;}
                when 'INR'
                    {enr.ServiceTypeId = 4;}
            }

            
        }
        if(fax.STAT__c == 'Yes')
            enr.Stat = true;
        else if(fax.STAT__c == 'No')
            enr.Stat = false;

        if(fax.Billing_Status__c != null)    
            enr.BillingStatus = getBillingStatusId(fax.Billing_Status__c);

        if(fax.Quick_Note_Subject__c != null || fax.Quick_Note_Text__c != null){
            Notes notes = new Notes();
            enr.Notes = new List<Notes>();
            notes.Header = fax.Quick_Note_Subject__c;
            notes.Content = fax.Quick_Note_Text__c + ' - ' + getUserName(fax.OwnerId);
            enr.Notes.add(notes);
        }
        if(fax.Status__c == 'Draft')
            enr.Username = UserInfo.getUserName();
            

        return enr;
    }

    public Static Insurance populatePrimaryInsurance(Fax_Enrollment__c fax){
        Insurance insurance = new Insurance();
        insurance.PayerId = fax?.Payer_Id__c;
        insurance.PayerName = fax?.Payer_Name__c;                 

        if(fax.Guarantor_Relationship_to_Patient__c != null)
            insurance.RelationshipId = getRelationship(fax.Guarantor_Relationship_to_Patient__c); 
        if(insurance.RelationshipId == 1){
            insurance.SubscriberFirstName = fax.Patient_First_Name__c;            
            insurance.SubscriberLastName = fax.Patient_Last_Name__c;            
        }
        if(fax.Policy_ID__c != null)
            insurance.InsuranceId = fax.Policy_ID__c;

        return insurance;
    }
    
    public Static Integer getRelationship(String rel){
        Integer relValue = 1;
        switch on rel {
            when 'Self' {
                relValue = 1;   
            }
            //when more relationship are added, this will need to be built out
        }
        return relValue;
    }

    public Static Patient populatePatient(Fax_Enrollment__c fax){
        Patient patient = new Patient();
        if(fax.Patient_First_Name__c != null)
            patient.FirstName = fax.Patient_First_Name__c; 
        if(fax.Patient_Last_Name__c != null)
            patient.LastName = fax.Patient_Last_Name__c; 
        if(fax.Patient_Middle_Initial__c != null)
            patient.MiddleName = fax.Patient_Middle_Initial__c; 
        if(fax.Billing_Street__c != null)
            patient.AddressLine1 = fax.Billing_Street__c; 
        if(fax.Billing_Street_2__c != null)
            patient.AddressLine2 = fax.Billing_Street_2__c; 
        if(fax.Billing_City__c != null)
            patient.City = fax.Billing_City__c; 
        if(fax.Billing_State__c != null)
            patient.State = fax.Billing_State__c; 
        if(fax.Billing_Postal_Code__c != null)
            patient.Zip = getPostalCode(fax.Billing_Postal_Code__c);
        if(fax.Shipping_Street__c != null)
            patient.ShippingAddressLine1 = fax.Shipping_Street__c; 
        if(fax.Shipping_Street_2__c != null)
            patient.ShippingAddressLine2 = fax.Shipping_Street_2__c; 
        if(fax.Shipping_City__c != null)
            patient.ShippingCity = fax.Shipping_City__c; 
        if(fax.Shipping_State__c != null)
            patient.ShippingState = fax.Shipping_State__c; 
        if(fax.Shipping_Postal_Code__c != null)
            patient.ShippingZip = getPostalCode(fax.Shipping_Postal_Code__c); 
        if(fax.Patient_Gender__c == 'Female')
            patient.GenderId  = 1;
        else if(fax.Patient_Gender__c == 'Male')
            patient.GenderId  = 2;
        else if(fax.Patient_Gender__c == 'Other')
            patient.GenderId  = 3;
        else
            patient.GenderId  = 3; 

        

        if(fax.LanguageId__c == null)
            patient.PrimaryLanguageId = 10; 
        else
            patient.PrimaryLanguageId = Integer.valueOf(fax.LanguageId__c); 
        
        System.debug('language ' + patient.PrimaryLanguageId);

        if(fax.Patient_Date_of_Birth__c != null){
            Datetime birtDt = fax.Patient_Date_of_Birth__c;
            patient.DateOfBirth = gmt(birtDt, 'America/New_York');
        }

        if(fax.Patient_Home_Phone__c != null && fax.Patient_Home_Phone__c != '')
            patient.HomePhone = decimal.valueOf(fax.Patient_Home_Phone__c.replace('-','')); 

        if(fax.Patient_Cell_Phone__c != null && fax.Patient_Cell_Phone__c != '')
            patient.CellPhone = decimal.valueOf(fax.Patient_Cell_Phone__c.replace('-','')); 

        if(fax.Patient_Work_Phone__c != null && fax.Patient_Work_Phone__c != '')
            patient.WorkPhone = decimal.valueOf(fax.Patient_Work_Phone__c.replace('-','')); 

        if(fax.Email__c != null && fax.Email__c != '')
            patient.EmailAddress = fax.Email__c;         

        return patient;
    }

    public Static string gmt(DateTime DT, String strTz) {
        DT = DT.addHours(12); //why? Just because...
        string local = DT.format('yyyy-MM-dd\'T\'HH:mm:ss');    
        Timezone tz = Timezone.getTimeZone(strTz);                

        integer correction = tz.getOffset(dt);
        integer absCorr = correction;
        integer sign = 1;

        if (correction < 0) {
            absCorr = -1 * correction;
            sign = -1;
        }
        time t1 = time.newInstance(0, 0, 0, absCorr );
        
        string offh = ( (t1.hour() < 10) ? '0'+ string.ValueOf( t1.hour()) : string.ValueOf( t1.hour()) );
        string offm = ( (t1.minute() < 10) ? '0'+ string.ValueOf( t1.minute()) : string.ValueOf( t1.minute()) );

        string gmt = local + ( sign == -1 ? '-'+offh+offm :'+'+offh+offm );

        return  gmt;
    }

    public static String getDiagnosisCode(String input){
        List <Diagnosis_Code__c> lst = [SELECT Code__c from Diagnosis_Code__c where Id = :input];
        if(lst.size() > 0)
            return lst[0].code__c;
        else 
            return null;
    }

    public static String getBackendId(String input){
        List <Account> lst = [SELECT Backend_ID__c from Account where Id = :input];
        if(lst.size() > 0)
            return lst[0].Backend_ID__c;
        else 
            return null;
    }

    public static String getBillingStatusId(String input){
        List <Billing_Status__c> lst = [SELECT Id__c, Name from Billing_Status__c where Id = :input];
        if(lst.size() > 0)
            //return lst[0].Id__c;
            return lst[0].Name;
        else 
            return null;
    }

    public static String getPostalCode(String input){
        List <Zip_Code__c> lst = [SELECT Name from Zip_Code__c where Id = :input];
        if(lst.size() > 0)
            return lst[0].Name;
        else 
            return null;
    }

    public static String getUserName(String input){
        List <User> lst = [SELECT Name from User where Id = :input];
        if(lst.size() > 0)
            return lst[0].Name;
        else 
            return null;
    }
     public static Boolean isValidId( Id sfId){
         String stringId;
         boolean returnBool = false;
         if(sfId == null)
            returnBool = false;
         else{
             stringId = sfId;
             if(stringId.length() == 15 || stringId.length() == 18)
                 returnBool = true;
         }  
         return returnBool;   
    } 
       
	public class Enrollment_Z {
		public Enrollment Enrollment; 
		public EnrollmentSource EnrollmentSource; 
		public String Username;

	}

    public class Enrollment {

        public String Id; 
        public List<String> DiagnosisCodes;
        public String StartTime; 
        public Integer Duration; 
        public String CurrentBundleId; 
        public String DeviceTypeId; 
        public Integer DeviceSource; 
        public String ReferringPhysicianFax; 
        public String ReferringPhysicianPhone;
        public String ReferringPhysicianFirstName;  
        public String ReferringPhysicianLastName; 
        public String ReferringPhysicianEmail; 
        public String NotificationPhysicianId; 
        public String OrderingPhysicianId; 
        public String LocationId; 
        public Patient Patient; 
        public String MedicalRecordNumber2; 
        public String MedicalRecordNumber1; 
        public Integer ServiceTypeId; 
        public Boolean Stat; 
        public String BillingStatus; 
        public List<Notes> Notes; 
        public Insurance PrimaryInsurance; 
        public Insurance SecondaryInsurance; 
        public PostProcedureMonitoringSchedule PostProcedureMonitoringSchedule; 
		public String Username; 

    	}
        public class Insurance {
            public String InsuranceId; 
            public String PayerId; 
            public String PayerName; 
            public Integer RelationshipId;
            public String SubscriberFirstName; 
            public String SubscriberLastName;              
        }

        public class PostProcedureMonitoringSchedule {
            public String ProcedureDate; 
            public List<String> FollowUpSchedule; 
        }
        
        public class EnrollmentSource {
            public String SourceEntity; 
            public String UserAgent; 
            public String ServerName; 
            public String IpAddress; 
            public String RemoteHost; 

        }
        
        public class Patient {
            public String FirstName; 
            public String LastName; 
            public String MiddleName; 
            public String AddressLine1; 
            public String AddressLine2; 
            public String City; 
            public String State; 
            public String Zip; 
            public String ShippingAddressLine1; 
            public String ShippingAddressLine2; 
            public String ShippingCity; 
            public String ShippingState; 
            public String ShippingZip; 
            public Integer GenderId; 
            public Integer PrimaryLanguageId; 
            public String DateOfBirth; 
            public Decimal HomePhone; 
            public Decimal CellPhone; 
            public Decimal WorkPhone; 
            public String EmailAddress; 
            public String AlternateContact; 
            public String AlternateContactRelation; 
            public String AlternateContactPhone; 

        }

        public class Notes {
            public String Header; 
            public String Content; 
        }
}