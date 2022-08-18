({
    getShipments : function(c, e, h) {
        console.log('Shipments');

        var state;
        var action = c.get("c.fetchShipments");
        this.showSpinner(c); 
      
        action.setParams({
           "recordId": c.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                var records = response.getReturnValue();
                console.log('xxx SHIPMENT LIST records '+ JSON.stringify(records));
                //sort begin
                var field = 'Name';
                var sortAsc = true;
                //var sortDes = true;
                records.sort(function(a,b){
                    var t1 = a[field] == b[field],
                        t2 = (!a[field] && b[field]) || (a[field] < b[field]);
                    return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
                });
                //sort end                
                console.log('xxx SHIPMENT LIST records '+ JSON.stringify(records));
                c.set("v.shipments", records);
                c.set("v.recCnt", records.length);
            }else{
                console.log('xxx ERROR!!!');
            }
            this.hideSpinner(c);
        });
        $A.enqueueAction(action);
    },

    showSpinner : function(c) {
        console.log('in h.showSpinner');
        c.set("v.dataLoaded", false);
        $A.util.removeClass(
            c.find('spinner'), 
            "slds-hide"
        );
    },
    
    hideSpinner : function(c) {
        console.log('in h.hideSpinner');
        $A.util.addClass(
            c.find('spinner'), 
            "slds-hide"
        );
        c.set("v.dataLoaded", true);
    }

})