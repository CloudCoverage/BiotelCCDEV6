public with sharing class MiddlewareZipCode {
    @Future(callout=true)
    public static void Callout() {
        List<MiddlewareUtil.ZipCode> ZipCodes = MiddlewareUtil.getZipCodes();
        System.debug('Number of Zipcodes > ' + ZipCodes.size());
        MiddlewareZipCodeQueueable updateJob = new MiddlewareZipCodeQueueable(ZipCodes);
        ID jobID = System.enqueueJob(updateJob);
    }
}