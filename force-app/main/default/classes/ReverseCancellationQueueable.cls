public class ReverseCancellationQueueable implements Queueable {

    private List<Order> orders;
    
    public ReverseCancellationQueueable (List<Order> orders){
        this.orders = orders;
    }
    
    public void execute(QueueableContext context) { 
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        System.debug('xxxa orders '+ orders);
        for(Order order : orders){
            futureCall(order.Enrollment_Backend_ID__c, order.AD_Start_Date__c, userName);
        }
    }

    @Future(callout=true)
    public static void futureCall(String backendId, Date startDate, String userName){
        MiddlewareUtil.FollowupDate(backendId, startDate, userName);
    }

}