public with sharing class FaxEnrollmentTriggerHandler {
    final List<Fax_Enrollment__c> faxes;
    final Map<Id, Fax_Enrollment__c> oldMap;
    

    public FaxEnrollmentTriggerHandler(List<Fax_Enrollment__c> faxes, Map<Id, Fax_Enrollment__c> oldMap) {
        
        System.debug('xxx FaxEnrollmentTriggerHandler ');
        this.faxes = faxes;
        this.oldMap = oldMap;
    }

    public void beforeUpdate(){

        System.debug('xxxaaa FaxEnrollmentTriggerHandler beforUpdate');
        associateOrderToFax();

    }    
    
    private void associateOrderToFax() {
        List<Order> orders = new List<Order>();
        for(Fax_Enrollment__c fax : faxes){
            Fax_Enrollment__c old = oldMap.get(fax.Id);
            if(fax.Order__c != null && old.Order__c == null){
                Order order = new Order();
                order.Id = fax.Order__c;
            }
        }
        if(orders.size() > 0)
            update orders;
    }
}