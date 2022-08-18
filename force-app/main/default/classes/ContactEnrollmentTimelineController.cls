public class ContactEnrollmentTimelineController {
    
    @AuraEnabled
    public static List<Order> getEnrollments(String contactOrEnrollmentId) {
        
        Id theId = contactOrEnrollmentId;
        System.debug(theId.getSobjectType());
        
        List<Order> enrollments = new List<Order>();
        if (String.valueOf(theId.getSobjectType()) == 'Order') {
            enrollments = [
                SELECT Id, OrderNumber, AccountId, Patient_Contact_ID__c, CreatedDate 
                FROM Order 
                WHERE Id = :theId
            ];
        }
        else if (String.valueOf(theId.getSobjectType()) == 'Contact') {
            enrollments = [
                SELECT Id, OrderNumber, AccountId, Patient_Contact_ID__c, CreatedDate 
                FROM Order 
                WHERE Patient_Contact_ID__c = :theId
            ];
        }
        else if (String.valueOf(theId.getSobjectType()) == 'Case') {
            enrollments = [
                SELECT Id, OrderNumber, AccountId, Patient_Contact_ID__c, CreatedDate 
                FROM Order 
                WHERE Activation_Workflow_Case__c = :theId
            ];
        }        
        return enrollments;
        
    }
  
    @AuraEnabled
    public static List<EnrollmentTimeline> getEnrollmentTimeline(String enrollmentId) {
        
        List<EnrollmentTimeline> timeline = new List<EnrollmentTimeline>();
        EnrollmentTimeline etl = new EnrollmentTimeline();
        
        Order enrollment = [
            SELECT Id, Name, Patient_Contact_ID__c, Patient_Contact_ID__r.Name, CreatedById, CreatedBy.Name, CreatedDate, Enrollment_Number__c, Status, Visit_Date__c, Enrollment_Created_User__c, Enrollment_Backend_ID__c 
            FROM Order 
            WHERE Id = :enrollmentId
        ];
        etl = new EnrollmentTimeline();
        etl.linkId = enrollment.Id;
        etl.lineType = 'orders';
        etl.style = 'orders';
        etl.icon = 'standard:orders';
        etl.subject = enrollment.Name;
        etl.action = 'created an enrollment for';
        etl.relatedToId = enrollment.Patient_Contact_ID__c;
        etl.relatedToName = enrollment.Patient_Contact_ID__r.Name;
        etl.createdById = enrollment.Id;
        etl.createdByName = enrollment.Enrollment_Created_User__c;
        etl.createdDate = enrollment.Visit_Date__c;
        etl.orderNumber = enrollment.Enrollment_Number__c;
        etl.orderStatus = enrollment.Status;
        timeline.add(etl);
        
        List<Id> caseIdList = new List<Id>();
        List<Case> cases = [
            SELECT Id, Subject, Description, ContactId, Contact.Name, CreatedById, CreatedBy.Name, CreatedDate, Case_Reason_Lookup__c, Case_Reason_Lookup__r.Name, ClosedDate, Closed_By__c, Closed_By__r.Name, Actions_Taken__c
            FROM Case
            WHERE Order__c = :enrollmentId
        ];
        System.debug('xxx cases ' + cases);
        for (Case c : cases) {
            caseIdList.add(c.Id);
            etl = new EnrollmentTimeline();
            etl.linkId = c.Id;
            etl.lineType = 'case';
            etl.style = 'case';
            etl.icon = 'standard:case';
            etl.subject = c.Subject;
            etl.action = 'created a case for';
            etl.relatedToId = c.Case_Reason_Lookup__c;
            etl.relatedToName = c.Case_Reason_Lookup__r.Name;
            etl.createdById = c.CreatedById;
            etl.createdByName = c.CreatedBy.Name;
            etl.createdDate = c.CreatedDate;
            etl.caseDescription = c.Description;
            etl.caseActionTaken = c.Actions_Taken__c;
            etl.caseReason = c.Case_Reason_Lookup__r.Name;
            timeline.add(etl);
            if (c.ClosedDate != null) {
                etl = new EnrollmentTimeline();
                etl.linkId = c.Id + '1';
                etl.lineType = 'case';
                etl.style = 'case';
                etl.icon = 'standard:case';
                etl.subject = c.Subject;
                etl.action = 'closed a case for';
                etl.relatedToId = c.Case_Reason_Lookup__c;
                etl.relatedToName = c.Case_Reason_Lookup__r.Name;
                etl.createdById = c.Closed_By__c;
                etl.createdByName = c.Closed_By__r.Name;
                etl.createdDate = c.ClosedDate;
                etl.caseDescription = c.Description;
                etl.caseActionTaken = c.Actions_Taken__c;
            	etl.caseReason = c.Case_Reason_Lookup__r.Name;
                timeline.add(etl);
            }
        }
        
        List<MiddlewareUtil.Note> notes = new List<MiddlewareUtil.Note>();
        if(Test.isRunningTest()){
            String s = '[{"BackendId":"10550830","Subject":"NEXTGEN Activity","Description":"Online Enrollment","ActivityDate":"2019-07-17T11:31:09.213","WhatId":"f06106bd-80ef-4e8c-aa0f-ba21912b222b","SourceSystem":"NEXTGEN","SourceCreatedBy":"NEXTGENIntegration","SourceCreatedTime":"2019-07-17T11:31:09.213"}]';
            notes = (List<MiddlewareUtil.Note>) JSON.deserialize(s, List<MiddlewareUtil.Note>.class);   
          }else{        
            notes = MiddlewareUtil.getNotes(enrollment.Enrollment_Backend_ID__c);
        }

        for(MiddlewareUtil.Note note : notes){
            System.debug('note.description > ' +note.description);
            etl = new EnrollmentTimeline();
            etl.linkId = note.BackendId;
            etl.lineType = 'task';
            etl.style = 'task';
            etl.icon = 'standard:task';
            etl.action = 'created an external activity for';
            etl.taskNotes = note.Description;
            etl.taskSourceSystem = note.SourceSystem;
            etl.subject = note.Subject;
            etl.relatedToName = note.BackendId;
            etl.createdByName = note.SourceCreatedBy;
            etl.createdDate = note.SourceCreatedTime;  
            timeline.add(etl);          
        }
        
        List<Task> tasks = [
            SELECT Id, Subject, Source_System__c, Description, Description__c, Type, TaskSubtype, WhatId, WhoId, CreatedById, CreatedBy.Name, CreatedDate  
            FROM Task 
            WHERE WhatId IN :caseIdList
               OR WhatId = :enrollment.Id
        ];
        List<Id> whoIdList = new List<Id>();
        List<Id> activityIdList = new List<Id>();
        for (Task t : tasks) {
            activityIdList.add(t.Id);
            if (t.WhoId != null) {
                whoIdList.add(t.WhoId);
            }
        }
        Map<ID, Contact> contacts = new Map<ID, Contact>([
            SELECT Id, Name 
            FROM Contact 
            WHERE Id IN :whoIdList
        ]);
        Map<ID, EmailMessage> emails = new Map<Id, EmailMessage>();
        for (EmailMessage em : [SELECT Id, FromAddress, ToAddress, TextBody, RelatedToId, ParentId, ActivityId FROM EmailMessage WHERE ActivityId IN :activityIdList]) {
            emails.put(em.ActivityId, em);
        }
        for (Task t : tasks) {
            etl = new EnrollmentTimeline();
            etl.linkId = t.Id;
            if (t.Type == 'Phone Call') {
                etl.lineType = 'call';
                etl.style = 'log-a-call';
                etl.icon = 'standard:log_a_call';
                etl.action = 'logged a call for';
                if (contacts.containsKey(t.WhoId)) {
                    etl.callName = contacts.get(t.WhoId).Name;
                } 
                etl.callDescription = t.Description;
            }
            else if (t.Type == null && t.TaskSubtype == 'Email') {
                etl.lineType = 'email';
                etl.style = 'email';
                etl.icon = 'standard:email';
                etl.action = 'sent an email for';
                if (emails.containsKey(t.Id)) {
                    etl.linkId = emails.get(t.Id).Id;
                    etl.emailFromAddress = emails.get(t.Id).FromAddress;
                    etl.emailToAddress = emails.get(t.Id).ToAddress;
                    etl.emailTextBody = emails.get(t.Id).TextBody;
                } 
            }
            else {
                etl.lineType = 'task';
                etl.style = 'task';
                etl.icon = 'standard:task';
                etl.action = 'created a task for';
                etl.taskNotes = t.Description;
                etl.taskSourceSystem = t.Source_System__c;
            }
            etl.subject = t.Subject;
            etl.relatedToId = t.WhatId;
            etl.relatedToName = t.WhatId;
            etl.createdById = t.CreatedById;
            etl.createdByName = t.CreatedBy.Name;
            etl.createdDate = t.CreatedDate;
            timeline.add(etl);
        }

        List<MiddlewareUtil.Shipment> shipments = new List<MiddlewareUtil.Shipment>();
        if(Test.isRunningTest()){
            String s = '[{"Id":null,"OwnerId":null,"BackendId":"ec3afe3b-9814-4ef5-a32d-ed08e782d2a1","IsDeleted":false,"Name":"2300928","LastViewedDate":null,"LastReferencedDate":null,"Enrollment":"f06106bd-80ef-4e8c-aa0f-ba21912b222b","BundleNumber":"2300928","CenterName":"Chester","DeliverByDate":"2019-07-19T00:00:00","FulfilledDateTime":"2019-07-18T00:00:00","KitName":"C6 Flex Electrode","Status":"Completed","Type":"Ship To Patient","CreatedUser":"CARDIONETandrea.purnell","CreatedDate":"2019-07-17T08:52:42.367","ShipmentItems":[{"Id":null,"IsDeleted":false,"Name":"100-0046-02","LastViewedDate":null,"LastReferencedDate":null,"Shipment":"ec3afe3b-9814-4ef5-a32d-ed08e782d2a1","AssetSerialNumber":"MT21001033","Description":"Monitor (C6) J3","Quantity":1.0,"BackendId":"2cccfa08-20aa-46c2-a260-f80effa8553a","ExtensionData":null}],"ExtensionData":null}]';
            shipments = (List<MiddlewareUtil.Shipment>) JSON.deserialize(s, List<MiddlewareUtil.Shipment>.class);   
          }else{        
            shipments = MiddlewareUtil.getShipments(enrollment.Enrollment_Backend_ID__c);
          }
        
        for(MiddlewareUtil.Shipment s :shipments){
            etl = new EnrollmentTimeline();
            etl.linkId = s.Name;
            etl.lineType = 'case';
            etl.style = 'case';
            etl.icon = 'custom:custom98';
            etl.subject = s.KitName;
            etl.action = 'created a shipment with an estimated deliver by date of';
            if(s.DeliverByDate != null)
            	etl.relatedToName = String.valueOf(s.DeliverByDate).substring(0,10);
            etl.createdByName = s.CreatedUser;
            etl.createdDate = s.CreatedDate; //.addHours(4)
            etl.shipmentStatus = s.Status;
            etl.shipmentType = s.Type;
            timeline.add(etl);       
        }
        
        timeline.sort();
        return timeline;
		
        
    }
    
}