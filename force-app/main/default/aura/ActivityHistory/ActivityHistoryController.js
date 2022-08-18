({
    init : function(c, e, h) {
        console.log('in init ' + c.get("v.recordId"));
        let recordId = c.get("v.recordId");
        if(recordId == null){
            let pr = c.get("v.pageReference");
            recordId = pr.state.c__recordId;  
            c.set("v.recordId", recordId);          
        }
        h.getNotes(c, e, h);

    },
    goToDetail : function(c, e, h) {
        var backendId = e.target.id;
        console.log('in goToDetail '+backendId);
        let activities = c.get("v.activities");
        console.log('xxx activities '+ JSON.stringify(activities));
        let act = activities.find(x => x.BackendId == backendId);
        console.log('xxx act '+ JSON.stringify(act));
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ActivityHistoryDetail",
            componentAttributes: {
                act : act
            }
        });
        evt.fire();   

    }    
})