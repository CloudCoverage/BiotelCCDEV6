global class MiddlewarePayersScheduler implements Schedulable, Database.AllowsCallouts {

    global void execute(SchedulableContext SC) { 
  
        MiddlewareUtil.getPayer();
    }
}