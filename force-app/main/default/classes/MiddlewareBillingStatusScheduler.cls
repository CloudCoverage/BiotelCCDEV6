global class MiddlewareBillingStatusScheduler implements Schedulable, Database.AllowsCallouts {

    global void execute(SchedulableContext SC) { 
  
        MiddlewareUtil.getBillingStatuses();
        


    }
}