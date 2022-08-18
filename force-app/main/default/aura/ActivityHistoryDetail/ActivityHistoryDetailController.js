({
  init : function(c, e, h) {
    console.log('in init ' );
    let pr = c.get("v.pageReference");
    console.log('pr'+ JSON.stringify(pr));

    let activityId = pr.state.c__activityId;
    let enrollmentId = pr.state.c__enrollmentId;

    console.log('activityId'+ activityId);
    console.log('enrollmentId'+ enrollmentId);

    var state;
    console.log('aaa');
    var action = c.get("c.getNotes");
    console.log('bbb');
  
    action.setParams({
       "recordId": enrollmentId
    });
    console.log('ccc');
    
    action.setCallback(this, function(response) {
      state = response.getState();
      if (state === "SUCCESS") { 
        var activities = response.getReturnValue();
        //console.log('SUCCESS activityId' + activityId);
        //console.log('SUCCESS ' + JSON.stringify(activities));
        let act = activities.find(x => x.BackendId == activityId);
        c.set("v.act", act);
    }else{
      console.log('xxx ERROR!!!');
  }
});
$A.enqueueAction(action);




},  
  goToOrder : function(c, e, h) {
      //console.log('in goToOrder ' +c.get("recordId"));
      let act = c.get("v.act");
      console.log('xxx act '+ JSON.stringify(act));

      var navEvt = $A.get("e.force:navigateToSObject");
      navEvt.setParams({
        "recordId": act.enrollmentId,
        "slideDevName": "detail"
      });
      navEvt.fire();        

  }


})