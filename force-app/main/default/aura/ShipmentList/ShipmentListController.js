({
    init : function(c, e, h) {
        console.log('SHIPMENT LIST in init ' + c.get("v.recordId"));
        let recordId = c.get("v.recordId");
        if(recordId == null){
            let pr = c.get("v.pageReference");
            if(pr != null){
                recordId = pr.state.c__recordId;  
                c.set("v.recordId", recordId);   
            }
        }
        h.getShipments(c, e, h);

        

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


        
    },   
    goToTracking : function (component, event, helper){

        var trackingNumber = event.currentTarget;
        var trackingString = trackingNumber.dataset.value;
        console.log('trackingString ',trackingString);
        var urlEvent = $A.get("e.force:navigateToURL")
        
        urlEvent.setParams({
            url: 'https://www.ups.com/track?loc=null&tracknum=' + trackingString + '&requester=WT/trackdetails'
        })
        urlEvent.fire()

    }
        
        
})