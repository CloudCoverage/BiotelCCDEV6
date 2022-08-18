global class MiddlewareDiagnosisScheduler implements Schedulable, Database.AllowsCallouts {
    /*
    MiddlewareDiagnosisScheduler sched = new MiddlewareDiagnosisScheduler();
    sched.execute(null);
    */
    global void execute(SchedulableContext SC) { 
  
        MiddlewareUtil.getDiagnosisCodes();
    }
}