public with sharing class OrderAutomationHandler {
    final List<Order_Automation__e> newRecords;
    final List<Order_Automation__e> oldRecords;
    final Map<Id, Order_Automation__e> newMap;
    final Map<Id, Order_Automation__e> oldMap;

    public OrderAutomationHandler(List<Order_Automation__e> newRecords, List<Order_Automation__e> oldRecords,Map<Id, Order_Automation__e> newMap, Map<Id, Order_Automation__e> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public void afterInsert() {
        System.debug('xxx OrderAutomationHandler afterInsert' + newRecords.size());
        processAutomationRecords();
    }
  
    private void processAutomationRecords(){
        System.debug('xxx OrderAutomationHandler afterInsert process');
        Set<Id> orderIds = new Set<Id>();
        for(Order_Automation__e ordEvent : newRecords){ 
            if(ordEvent.Order_Id__c != null){
                orderIds.add(ordEvent.Order_Id__c);
            }
        }

        Map<Id, Order> orderMap = new Map<Id, Order>();
        for(Order o : [
            SELECT Enrollment_Backend_ID__c, AD_Start_Date__c, EncounterNumber__c, AccountId, Activation_AD_Enabled__c, 
                   Enrollment_Number__c, LastModifiedBy.Name, Patient_Contact_ID__c, Enrollment_Special_Instructions__c
            FROM Order
            WHERE Id in :orderIds ]){
                orderMap.put(o.Id,o);
        }

        Map<String, Id> encounterToOrderId = new Map<String, Id>();
        Map<String, Id> enrollmentToOrderId = new Map<String, Id>();
        Set<Order> ordersNeedingSpecialInstructionCase = new Set<Order>();

        for(Order_Automation__e ordEvent : newRecords){
            System.debug('xxx OrderAutomationHandler RECORD '+ ordEvent);
            switch on ordEvent.Type__c {
                when  'UpdateFaxViaEncounter' {
                    encounterToOrderId.put(orderMap.get(ordEvent.Order_Id__c).EncounterNumber__c, ordEvent.Order_Id__c);
                }
                when  'UpdateFaxViaEnrollment' {
                    enrollmentToOrderId.put(orderMap.get(ordEvent.Order_Id__c).Enrollment_Number__c, ordEvent.Order_Id__c);
                }
                when  'createSpecialInstructionCase' {
                    ordersNeedingSpecialInstructionCase.add(orderMap.get(ordEvent.Order_Id__c));
                }                                 
                                                
            }
        }
        System.debug('xxx OrderAutomationHandler encounterToOrderId '+ encounterToOrderId);
        System.debug('xxx OrderAutomationHandler enrollmentToOrderId '+ enrollmentToOrderId);
        System.debug('xxx OrderAutomationHandler ordersNeedingSpecialInstructionCase '+ ordersNeedingSpecialInstructionCase);

        if(encounterToOrderId.size() > 0){
            processEncounterFaxUpdates(encounterToOrderId);
        }
        if(enrollmentToOrderId.size() > 0){
            processEnrollmentFaxUpdates(enrollmentToOrderId);
        }
        if(ordersNeedingSpecialInstructionCase.size() > 0){
            createSpecialInstructionCases(ordersNeedingSpecialInstructionCase);
        }        
    }

    private static void processEncounterFaxUpdates(Map<String, Id>encounterToOrderId){
        List<Fax_Enrollment__c> faxes = [
            SELECT Id, Encounter_Number__c 
            FROM Fax_Enrollment__c 
            WHERE Encounter_Number__c IN :encounterToOrderId.keySet()];

        for(Fax_Enrollment__c fax : faxes){
            fax.Order__c = encounterToOrderId.get(fax.Encounter_Number__c);
        }
        UPDATE faxes;
        System.debug('xxx OrderAutomationHandler processEncounterFaxUpdates faxes '+ faxes);
    }

    private static void processEnrollmentFaxUpdates(Map<String, Id>enrollmentToOrderId){
        List<Fax_Enrollment__c> faxes = [
            SELECT Id, Enrollment_Number__c 
            FROM Fax_Enrollment__c 
            WHERE Enrollment_Number__c IN :enrollmentToOrderId.keySet()];

        for(Fax_Enrollment__c fax : faxes){
            fax.Order__c = enrollmentToOrderId.get(fax.Enrollment_Number__c);
        }
        UPDATE faxes;
        System.debug('xxx OrderAutomationHandler processEnrollmentFaxUpdates faxes '+ faxes);
    }

    private static void createSpecialInstructionCases(Set<Order> orders){
        List<Case> cases = new List<Case>();
        CaseBuilder caseBuilder = new CaseBuilder();
        for(Order order : orders){
            cases.add(caseBuilder.createSpecialInstructionCase(order));
        }
        INSERT cases;
        System.debug('xxx OrderAutomationHandler createSpecialInstructionCases cases '+ cases);
    }    

}