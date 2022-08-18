({
    getNotes : function(c, e, h) {
        console.log('getNotes');

        var state;
        var action = c.get("c.getNotes");
      
        action.setParams({
           "recordId": c.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                var records = response.getReturnValue();
                console.log('xxx records '+ JSON.stringify(records));
                //sort begin
                var field = 'SourceCreatedTime';
                var sortAsc = false;
                //var sortDes = true;
                records.sort(function(a,b){
                    var t1 = a[field] == b[field],
                        t2 = (!a[field] && b[field]) || (a[field] < b[field]);
                    return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
                });
                //sort end                
                
                
                
                c.set("v.activities", records);
                c.set("v.recCnt", records.length);
            }else{
                console.log('xxx ERROR!!!');
            }
        });
        $A.enqueueAction(action);
    } 
})