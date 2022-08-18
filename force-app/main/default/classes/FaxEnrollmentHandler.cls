public with sharing class FaxEnrollmentHandler {
    final List<Fax_Enrollment__c> faxs;
    final Map<Id, Fax_Enrollment__c> oldMap;
    

    public FaxEnrollmentHandler(List<Fax_Enrollment__c> faxs, Map<Id, Fax_Enrollment__c> oldMap) {
        
        System.debug('xxx FaxEnrollmentHandler ');
        this.faxs = faxs;
        this.oldMap = oldMap;
    }

    public void beforeUpdate(){

        System.debug('xxxaaa FaxEnrollmentHandler beforUpdate');
        updateOrder();

    }    
    
    public void updateOrder() {
        List<Order> orders = new List<Order>();
        for(Fax_Enrollment__c fax : faxs){
            Fax_Enrollment__c old = oldMap.get(fax.Id);
            if(fax.Order__c != null && old.Order__c == null){
                orders.add(new Order(
                    Id = fax.Order__c,
                    Results_Phone__c = fax.Results_Phone__c,
                    Results_Fax__c = fax.Results_Fax_Number__c,
                    Training_Type__c = fax.Training_Type__c
                ));
            }
        }
        if(orders.size() > 0)
            update orders;


    }
      

}