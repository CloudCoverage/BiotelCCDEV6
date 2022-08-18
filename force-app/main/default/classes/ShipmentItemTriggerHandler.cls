public class ShipmentItemTriggerHandler extends TriggerHandler {
    
    private Map<Id, Shipment_Item__c> newShipmentItemMap;
    private Map<Id, Shipment_Item__c> oldShipmentItemMap;
    
    public ShipmentItemTriggerHandler() {
        this.newShipmentItemMap = (Map<Id, Shipment_Item__c>) Trigger.newMap;
        this.oldShipmentItemMap = (Map<Id, Shipment_Item__c>) Trigger.oldMap;        
    }
    
    public override void afterInsert(){
        updateOrders(newShipmentItemMap.keySet());      
    }
    
    public override void afterUpdate(){
        Set<Id> shipmentItemIdsToUpdate = new Set<Id>();
        for(Id i : newShipmentItemMap.keySet()){
            Shipment_Item__c newShipmentItem = newShipmentItemMap.get(i);
            Shipment_Item__c oldShipmentItem = oldShipmentItemMap.get(i);
            
            if(newShipmentItem.Name != oldShipmentItem.Name || 
               newShipmentItem.Asset_Serial_Number__c != oldShipmentItem.Asset_Serial_Number__c || 
               newShipmentItem.Description__c != oldShipmentItem.Description__c){                   
                   shipmentItemIdsToUpdate.add(i);
               }
        }
        
        if(shipmentItemIdsToUpdate.size() > 0)
            updateOrders(shipmentItemIdsToUpdate);        
    }
    
    private void updateOrders(Set<Id> shipmentItemIds){
        List<Shipment_Item__c> updatedShipmentItems = [SELECT Id, Shipment__r.Name, Shipment__c, 
                                                       Shipment__r.Enrollment__c, Description__c, Name, 
                                                       Asset_Serial_Number__c
                                                       FROM Shipment_Item__c WHERE Id in :shipmentItemIds];
        
        Map<Id, Order> orderMap = new Map<Id,Order>();
        
        //step 1 -- if shipment item has serial number, update order
        //also put together a list of shipments so we can query back all associated items
        
        List<Id> shipments = new List<Id>();
        for(Shipment_Item__c si:updatedShipmentItems){
            if(si.Asset_Serial_Number__c != null && si.Asset_Serial_Number__c != ''){
                String deviceList = si.Description__c + ' (PN:' + si.Name + ' SN:' + si.Asset_Serial_Number__c + ')';
                if(si.Shipment__r.Enrollment__c != null)
                    orderMap.put(si.Shipment__r.Enrollment__c, new Order(Id = si.Shipment__r.Enrollment__c, Device_List__c = deviceList ));
            }
            
            shipments.add(si.Shipment__c);
        }
        
        //step 2 query shipments with all shipment items
        
        List<Shipment__c> shipmentList = [SELECT Id, Name, Enrollment__c, (SELECT Description__c, Name FROM Shipment_Items__r)
                                          FROM Shipment__c WHERE Id in :shipments];
        
        
        //loop over and append
        
        for(Shipment__c s:shipmentList){
            String shipmentItems = 'Order-' + s.Name + '\n';
            
            for(Shipment_Item__c si:s.Shipment_Items__r){
                shipmentItems += si.Description__c + ' (' + si.Name + ')\n';
            }
            
            shipmentItems = shipmentItems.removeEnd('\n');
            
            //see if order is already in our map
            if(s.Enrollment__c != null){
                Order o = orderMap.get(s.Enrollment__c);
                
                if(o != null){
                    o.Order_Details__c = shipmentItems;
                    orderMap.put(s.Enrollment__c, o);
                } else {
                    o = new Order(Id = s.Enrollment__c, Order_Details__c = shipmentItems);
                    orderMap.put(s.Enrollment__c,o);
                }
            }
        }
        
        List<Order> ordersToUpdate = orderMap.values();
        system.debug(ordersToUpdate);
        if(ordersToUpdate.size() > 0)
            try{//marty westbrook bandaid 02/17/19
                update ordersToUpdate;
            }
        catch(Exception e) {
            System.debug('XXX upsert failed ordersToUpdate Message > '+  e.getMessage());
            System.debug('XXX upsert failed ordersToUpdate List > '+  ordersToUpdate);
        }
        
    }
    
    
    
}