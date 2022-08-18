global class MiddlewareZipCodeScheduler implements Schedulable, Database.AllowsCallouts {
    /*
    MiddlewareZipCodeScheduler mzs = new MiddlewareZipCodeScheduler();
    mzs.execute(null);
    */
    global void execute(SchedulableContext SC) { 
        MiddlewareZipCode.Callout();
        //Id batchProcessId = Database.executeBatch(new MiddlewareZipCode());        
    }
}