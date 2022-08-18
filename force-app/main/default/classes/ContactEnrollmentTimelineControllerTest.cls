@isTest
public class ContactEnrollmentTimelineControllerTest {
    
    @testSetup
    static void setup() {
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Jon',
            LastName = 'Doe',
            AccountId = acc.Id
        );
        insert con;
        
        Order ord = new Order(
            AccountId = acc.Id,
            Patient_Contact_ID__c = con.Id,
            EffectiveDate = Date.today() - 5,
            Status = 'Submitted'
        );
        insert ord;
        
        Case cas = new Case(
            Description = 'Test Desc',
            ContactId = con.Id,
            Order__c = ord.Id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Patient Support').getRecordTypeId()
        );
        insert cas;
        cas.Status = 'Closed';
        update cas;
        
        Task tsk1 = new Task(
            WhatId = cas.Id,
            Type = 'Phone Call'
        );
        insert tsk1;
        
        Task tsk2 = new Task(
            WhatId = cas.Id,
            Type = null,
            TaskSubtype = 'Email'
        );
        insert tsk2;
        
        Task tsk3 = new Task(
            WhatId = cas.Id,
            Type = 'Task'
        );
        insert tsk3;
        
        // activity history on order
        Task tsk4 = new Task(
            WhatId = ord.Id,
            Type = 'Task'
        );
        insert tsk4;
        tsk4.Status = 'Completed';
        update tsk4;
        
        Shipment__c ship = new Shipment__c(
            Kit_Name__c = 'Test Shipment',
            Enrollment__c = ord.Id
        );
        insert ship;
        
    }
    
    @isTest
    static void testGetEnrollments() {
        
        Contact con = [
            SELECT Id, Name 
            FROM Contact
            LIMIT 1
        ];
        
        Order ord = [
            SELECT OrderNumber, AccountId, Patient_Contact_ID__c 
            FROM Order
            LIMIT 1
        ];
        
        System.debug([
            SELECT Description, ContactId, Order__c, ClosedDate FROM Case
        ]);
        
        ContactEnrollmentTimelineController.getEnrollments(con.Id);
        ContactEnrollmentTimelineController.getEnrollments(ord.Id);
        
        ContactEnrollmentTimelineController.getEnrollmentTimeline(ord.Id);
        
    }

}