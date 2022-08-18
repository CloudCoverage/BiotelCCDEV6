({
    init : function(c, e, h) {
        console.log('in init ' + c.get("v.recordId"));
        let recordId = c.get("v.recordId");
        if(recordId == null){
            let pr = c.get("v.pageReference");
            if(pr != null){
                recordId = pr.state.c__recordId;  
                c.set("v.recordId", recordId);   
            }
        }
        if(recordId != null){
            h.getShipments(c, e, h);
        }
    },

    goToOrder : function(c, e, h) {
        //console.log('in goToOrder ' +c.get("recordId"));
        let rec = c.get("v.sh");
        console.log('xxx rec '+ JSON.stringify(rec));
        console.log('xxx rec.enrollmentId '+rec.enrollmentId);
  
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": rec.EnrollmentId,
          "slideDevName": "detail"
        });
        navEvt.fire();        
  
    },
      
    goToDetail : function(c, e, h) {
        var backendId = e.target.id;
        console.log('in goToDetail '+backendId);
        let shipments = c.get("v.shipments");
        //console.log('xxx shipments '+ JSON.stringify(shipments));
        let rec = shipments.find(x => x.BackendId == backendId);
        console.log('xxx rec '+ JSON.stringify(rec));
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Shipment",
            componentAttributes: {
                sh : rec
            }
        });
        evt.fire();   

    }    
})