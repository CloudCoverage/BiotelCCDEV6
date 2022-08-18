({
    init : function(c, e, h) {
        console.log('in init ' + c.get("v.recordId"));
        let recordId = c.get("v.recordId");
        let sh = c.get("v.sh");
        c.set("v.shItemList", sh.ShipmentItems);
       /*
        if(sh == null && recordId != null){
          h.getShipment(c, e, h);
        }*/
       	    
    }, goToOrder: function(c, e, h) {
        console.log('in goToOrder ');
        var navEvt = $A.get("e.force:navigateToSObject");
        let orderId = c.get("v.sh.EnrollmentId");
        console.log('in goToOrder ' + orderId);
        navEvt.setParams({
          "recordId": orderId,
          "slideDevName": "detail"
        });
        navEvt.fire();    } 
})