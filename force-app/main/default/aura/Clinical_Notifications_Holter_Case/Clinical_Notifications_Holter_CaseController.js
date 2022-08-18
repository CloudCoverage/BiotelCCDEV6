({
    doInit : function( component, event, helper ) {
        var flow = component.find('flow');
        flow.startFlow('New_Case_Clinical_Notifications_Holter_Guest_Profile');//,[{flowLayout:'oneColumn'}]
    },

    handleFlowStatusChange : function( component, event, helper ) {

      if ( event.getParam( 'status' ) === 'FINISHED' ) {
		var urlEvent = $A.get("e.force:navigateToURL");
                  urlEvent.setParams({
                     //"recordId": outputVar.value,
                     //"url": "https:deppartial-myeco.cs94.force.com/s/login/",
                      "url": "/",

                     "isredirect": true
                  });
                  urlEvent.fire();
           /* var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
               outputVar = outputVariables[i];
               console.log(outputVar);
               if(outputVar.name === "varAppId") {

                  
               }
            }
            */
        }

    }
})