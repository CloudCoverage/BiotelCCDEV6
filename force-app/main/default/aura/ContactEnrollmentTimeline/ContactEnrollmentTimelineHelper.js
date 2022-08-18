({
    
	getEnrollments : function(component, event) {
        
        var state;
        var action = component.get("c.getEnrollments");
        
    	this.showSpinner(component);
        
        action.setParams({
            "contactOrEnrollmentId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                var enrollments = response.getReturnValue();
                component.set("v.enrollments", enrollments);
                if (enrollments.length == 0) {
                    this.hideSpinner(component);
                }
                /*else if (enrollments.length > 1) {
                    // multiple enrollments
                    this.hideSpinner(component);
                }*/
                else {
                    component.set("v.enrollmentSelectedId", enrollments[0].Id);
                    component.set("v.enrollmentSelectedName", enrollments[0].OrderNumber);
                	this.getEnrollmentTimeline(component, event);
                    var enrollmentOptions = [];
                    for (var i = 0; i < enrollments.length; i++) {
                        enrollmentOptions.push({
                            id: enrollments[i].Id,
                            orderNumber: enrollments[i].OrderNumber
                        });
                    }
                    component.set("v.enrollmentOptions", enrollmentOptions);
                }
            }
            
        });
        
        $A.enqueueAction(action);
		
	},
    
    getEnrollmentTimeline : function(component, event) {
		
        var state;
        var action = component.get("c.getEnrollmentTimeline");
        
    	this.showSpinner(component);
        
        action.setParams({
            "enrollmentId": component.get("v.enrollmentSelectedId")
        });
        
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") { 
                var timeline = response.getReturnValue();
                component.set("v.enrollmentTimeline", timeline);
                this.hideSpinner(component);
            }
        });
        
        $A.enqueueAction(action);
    
    },    
    
    showSpinner : function(component) {
        component.set("v.dataLoaded", false);
        $A.util.removeClass(
            component.find('spinner'), 
            "slds-hide"
        );
    },
    
    hideSpinner : function(component) {
        $A.util.addClass(
            component.find('spinner'), 
            "slds-hide"
        );
        component.set("v.dataLoaded", true);
    }
    
})