({
    init : function(c, e, h) {
        console.log('in init ');
        let shItemList = c.get("v.shItemList");
        console.log('in init ' + JSON.stringify(shItemList));
        c.set("v.recCnt", shItemList.length);
    },
    goToDetail : function(c, e, h) {
        var backendId = e.target.id;
        console.log('in goToDetail '+backendId);
        let shItemList = c.get("v.shItemList");
        //console.log('xxx shipments '+ JSON.stringify(shipments));
        let sh = c.get("v.sh");
        let rec = shItemList.find(x => x.BackendId == backendId);
        console.log('xxx rec '+ JSON.stringify(rec));
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ShipmentItemDetail",
            componentAttributes: {
                sh : sh,
                shItem : rec
            }
        });
        evt.fire();   

    },
    goToList : function(c, e, h) {
        var backendId = e.target.id;
        console.log('in goToDetail '+backendId);
        let shItemList = c.get("v.shItemList");
        //console.log('xxx shipments '+ JSON.stringify(shipments));
        let sh = c.get("v.sh");
        let rec = shItemList.find(x => x.BackendId == backendId);
        console.log('xxx rec '+ JSON.stringify(rec));
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ShipmentItemList",
            componentAttributes: {
                sh : sh,
                shItemList : shItemList,
                showBody: true
            }
        });
        evt.fire();   

    }          
})