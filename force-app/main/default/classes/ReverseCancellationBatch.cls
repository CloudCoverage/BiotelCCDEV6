/*
TSK-00070228Find all open Act WF Cases with:
Order.Activation Workflow Status <> Activation Complete, Stopped 
ANDInitial Case Creation Date = TODAY() 
ORSubsequent Case Creation Date = TODAY()
ORAct AD Stopped = TRUE

1) Set Subsequent Case Creation Date = TODAY()+1 (as fall back default follow-up)
2) Call "Create Case Flow" TSK-00065698
3) <1 HR DELAY> Delete any still open outgoing manual interactions cases TSK-00070232
*/
Global class ReverseCancellationBatch  implements Schedulable, Database.Batchable<SObject>, Database.Stateful  {
        public String query;
        public Id activationWorkflowRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
        public Id patientInteractionRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        public Date today = System.today();
        //public Date testDate = Date.newInstance(2021, 06, 03);

        Global ReverseCancellationBatch() {
            Id activationWorkflowRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
            Id patientInteractionRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
            Date today = System.today();
           // Date testDate = Date.newInstance(2021, 06, 03);
            /*
            List<Case> deleteCases = new List<Case>();
            List<Case> cases = [
                SELECT Id, CreatedById,  LastModifiedById
                  FROM Case 
                 WHERE RecordTypeId = :patientInteractionRT 
                   AND Parent.recordTypeId = :activationWorkflowRT
                   AND Status = 'New'
                   AND Case_Reason_Lookup__r.Interaction_Type__c = 'Outgoing'
                   ];
                   
            for(Case c : cases){
                if(c.CreatedById == c.LastModifiedById)
                    deleteCases.add(c);
            }
    
            System.debug(deleteCases);
            System.debug('deleteCases > ' + deleteCases.size());
            DELETE deleteCases;
            */
            
            query = 
              'SELECT Id, Status, Order__c, Activation_AD_Enabled__c, Order__r.AD_Start_Date__c, Order__r.Enrollment_Backend_ID__c ' + 
                'FROM CASE ' +
               'WHERE recordTypeId = :activationWorkflowRT ' +
                ' AND Case_Reason_Lookup__c != null' +
                ' AND Case_Reason_Lookup__r.Active__c = true' +
              //' AND Order__r.Activation_Workflow_Status__c NOT IN (\'Activation Complete\', \'Stopped\') ' per Renell Automation Specs  2021-01-27
                ' AND Status NOT IN (\'Activation Complete\', \'Pending Cancellation\',\'Cancelled\') ' +
                ' AND (Initial_Case_Creation_Date__c = :today OR Subsequent_Case_Creation_Date__c = :today)'
               ;
            if(Test.isRunningTest()) {
                query += ' limit 1';
            }
                    
        }
    
        global Database.QueryLocator start(Database.BatchableContext BC){
    
            System.debug('xxx query ' + query);      
    
            return Database.getQueryLocator(query);
        }
    
        global  void execute(Database.BatchableContext BC, List<Case> cases){
            System.debug('size ' + cases.size());
            process(cases);
    
        }

    /*
    1) Set Subsequent Case Creation Date = TODAY()+1 (as fall back default follow-up)
    2) Call "Create Case Flow" TSK-00065698
    
    */
    public static void process(List<Case> cases){
        
        System.debug('yyy cases ' + cases);
        List<Case> newCases = new List<Case>();
        Date todayPlusOne = System.today().addDays(1);
        List<Id> caseIds = new List<Id>();
        Map<Id, Order> OldMap = new Map<Id, Order>();
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        for(Case cs : cases){
            System.debug('yyy cs ' + cs);
            //cs.Subsequent_Case_Creation_Date__c = todayPlusOne; - remove per Renell 2021/01/08
            // taking this out becuase validation rule was written after status was set
            //cs.Cancellation_Reason__c = 'Batch Update'; // added this line because of validation error - 5000R000007E5wwQAC; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Cancellation Reason is required to set Status to &quot;Pending Cancellation
            case c = new Case();
            c.Id = cs.Id;
            //newCases.add(c);
            caseIds.add(c.Id);

            Order order = new Order(
                Id = cs.Order__c, 
                Enrollment_Backend_ID__c = cs.Order__r.Enrollment_Backend_ID__c,
                AD_Start_Date__c = cs.Order__r.AD_Start_Date__c
            );
            OldMap.put(cs.Order__c, order);

        }
        System.debug('yyy createPatientInteractionCase ' + caseIds);
        ClosePatientCases.execute(caseIds); 
        ActivationWorkflowHelper.createPatientInteractionCase(caseIds);

        List<Order> orderToUpdate = new List<Order>(); 
        List<Order> orders = [SELECT Id, Enrollment_Backend_ID__c, AD_Start_Date__c 
            FROM Order 
            WHERE Id IN: OldMap.keySet()];

        for(Order order : orders){
            Order old = OldMap.get(order.Id);
            System.debug('xxxa order ' + order);
            System.debug('xxxa old ' + old);
            if(order.AD_Start_Date__c != old.AD_Start_Date__c){
                System.debug('xxxa making the call ');
                orderToUpdate.add(order);
            }
        }
        
        ReverseCancellationQueueable updateJob = new ReverseCancellationQueueable(orderToUpdate);
        ID jobID = System.enqueueJob(updateJob);

        //update Cases; - remove per Renell 2021/01/08
        
    }
            
        global void finish(Database.BatchableContext BC){
    
        }
        
        global void execute(SchedulableContext SC) 
        {		
            ID batchprocessid = Database.executeBatch(new ReverseCancellationBatch(), 5);
        } 
   

    }