({
    
	initialize : function(component, event, helper) {
        
        helper.getEnrollments(component, event);
		
	},
    
    handleEnrollmentChange : function(component, event, helper) {
        
        var opt = component.get("v.enrollmentOptions")[component.get("v.enrollmentOptionsValue")];
        component.set("v.enrollmentSelectedId", opt.id);
        component.set("v.enrollmentSelectedName", opt.orderNumber);
        helper.getEnrollmentTimeline(component, event);
        
    },
    
    toggleDetails : function(component, event, helper) {
        
        var target = event.currentTarget;
        var itemId = event.currentTarget.id.split('-')[0];
        var elem = document.getElementById(itemId + '-PARENT');
        $A.util.toggleClass(elem, 'slds-is-open');
        let itemIds = component.get("v.itemIds")
        itemIds.push(itemId)
        component.set("v.itemIds", itemIds);

        console.log('itemIds ' + itemIds)

        
    },
    toggleAll : function(component, event, helper) {
        console.log('toggleAll')
        component.set("v.expandAll", !component.get("v.expandAll"));
        let expandAll = component.get("v.expandAll")

        var itemIds = component.get("v.itemIds");

        if(itemIds.length > 0){
            var itemIds = component.get("v.itemIds");
            if(itemIds.length > 0){
                
                itemIds.forEach(function(itemId) {
                    var elem = document.getElementById(itemId + '-PARENT')
                    $A.util.toggleClass(elem, 'slds-is-open')
                })
                itemIds = [];
                component.set("v.itemIds",itemIds)  
            }
        }

        let item = document.querySelectorAll('[id$="-PARENT"]');
        for (var i = 0; i < item.length; i++) {
            var elem = document.getElementById(item[i].id)
            $A.util.toggleClass(elem, 'slds-is-open')
        }

    },
    
})