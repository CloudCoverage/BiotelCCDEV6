({
    /*
    getShipment : function(c, e, h) {
        console.log('getShipment');

        var state;
        var action = c.get("c.fetchShipment");
      
        action.setParams({
           "recordId": c.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state == "SUCCESS") { 
                var record = response.getReturnValue();
                console.log('xxx Shipment '+ JSON.stringify(record));
                c.set("v.sh", record);
                if(record != null && record.ShipmentItems != null){
                    let shipmentItems = record.ShipmentItems;
                    c.set("v.shItemList", shipmentItems);
                }
            }else{
                console.log('xxx ERROR!!!');
            }
        });
        $A.enqueueAction(action); 
    },
    */
})