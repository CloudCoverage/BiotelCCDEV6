public class ShipmentTriggerHandler extends TriggerHandler {
    
    private Map<Id, Shipment__c> newShipmentMap;
    private Map<Id, Shipment__c> oldShipmentMap;
    
    
    public ShipmentTriggerHandler() {
        this.newShipmentMap = (Map<Id, Shipment__c>) Trigger.newMap;
        this.oldShipmentMap = (Map<Id, Shipment__c>) Trigger.oldMap;        
    }
    
    public override void afterInsert(){
        updateOrders(newShipmentMap.keySet());      
    }
    
    public override void afterUpdate(){
        Set<Id> shipmentIdsToUpdate = new Set<Id>();
        for(Id i : newShipmentMap.keySet()){
            Shipment__c newShipment = newShipmentMap.get(i);
            Shipment__c oldShipment = oldShipmentMap.get(i);
            
            if(newShipment.Name != oldShipment.Name || 
               newShipment.Status__c != oldShipment.Status__c || 
               newShipment.Deliver_by_Date__c != oldShipment.Deliver_by_Date__c){                   
                   shipmentIdsToUpdate.add(i);
               }
        }
        
		if(shipmentIdsToUpdate.size() > 0)
            updateOrders(shipmentIdsToUpdate);
    }
    
    private void updateOrders (Set<Id> shipmentIds){
        
        List<Shipment__c> shipments = [SELECT Name, Status__c, Deliver_By_Date__c, 
                                       		  Kit_Name__c, Enrollment__c 
                                       FROM Shipment__c 
                                       WHERE Id in :shipmentIds];
        
        List<Order> updatedOrders = new List<Order>();
        
        for(Shipment__c s:shipments){
            String orderList = 'Order-' + s.Name + ' Status-' + s.Status__c + ' Deliver By: ';
            if(s.Deliver_by_Date__c != null){
                orderList += s.Deliver_By_Date__c.month() + '/' + s.Deliver_by_Date__c.day() + '/' + s.Deliver_by_Date__c.year();
            }
            String kitName = s.Kit_Name__c;
            if(s.Enrollment__c != null) //marty westbrook bandaid 02/17/19
            	updatedOrders.add(new Order(Id = s.Enrollment__c, Order_List__c = orderList, Kit_Name__c = kitName));
        }
        
        if(updatedOrders.size() > 0){
            try{//marty westbrook bandaid 02/17/19
                update updatedOrders;
            }
            catch(Exception e) {
                System.debug('XXX upsert failed updatedOrders > '+  e.getMessage());
            }
        }            
    }
}