public with sharing class OrderTriggerHandler {
    final List<Order> orders;
    final Map<Id, Order> oldMap;
    
    public static Boolean middlewareFollowupDateNotBeenCalled = true;
    public static Boolean middlewareAutoDialerBeenCalled = true;
    public static Boolean sendQueueNotBeenCalled = true;
    public static Map<String, Boolean> FollowupDateCalled = new Map<String, Boolean>();
    public static Map<String, Boolean> AutoDialerCalled = new Map<String, Boolean>();
    public List<Order_Automation__e> orderEvents = new List<Order_Automation__e>();
    private static final Middleware__mdt settings = MiddlewareUtil.getSettings();


    public OrderTriggerHandler(List<Order> orders, Map<Id, Order> oldMap)
    {
        
        System.debug('xxx OrderTriggerHandler ');
        this.orders = orders;
        this.oldMap = oldMap;
    }
    public void beforeUpdate(){

        System.debug('xxx OrderTriggerHandler beforUpdate');
        orderEvents = new List<Order_Automation__e>();
        updateFax(orders, oldMap);
        createSpecialInstructionCase(orders, oldMap);
        System.debug('xxx orderEvents' +orderEvents.size());

        if(orderEvents.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(orderEvents);  
            System.debug('xxx results' +results);
        }

    }     
    
    public void afterInsert() 
    {
        System.debug('xxx OrderTriggerHandler afterInsert');
        createActivationWorkflowCase(orders); 
        sendQueue(orders); 
        orderEvents = new List<Order_Automation__e>();
        updateFax(orders, null);
        createSpecialInstructionCase(orders, null);

        if(orderEvents.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(orderEvents);  
            System.debug('xxx results' +results);
        }

    }
    
    
    public void afterUpdate() 
    {
        System.debug('xxx OrderTriggerHandler afterUpdate');
        middlewareFollowupDate(orders, oldMap); 
        middlewareAutoDialer(orders, oldMap); 
    }

    public void beforeInsert() 
    {
        System.debug('xxx OrderTriggerHandler beforeInsert');
    }

    private void updateFax(List<Order> orders, Map<Id, Order> oldMap) {
        System.debug('xxx OrderTriggerHandler updateFax');
        for(Order order : orders){
            if(settings.Enrollment_Submission__c == 'Encounter API' && order.EncounterNumber__c != null && (oldMap == null || order.EncounterNumber__c != oldMap.get(order.Id).EncounterNumber__c)){
                orderEvents.add(createOrderEvent(order.Id, 'UpdateFaxViaEncounter'));
            } else if(settings.Enrollment_Submission__c == 'Enrollment number API' && order.Enrollment_Number__c != null && (oldMap == null || order.Enrollment_Number__c != oldMap.get(order.Id).Enrollment_Number__c)){
                orderEvents.add(createOrderEvent(order.Id, 'UpdateFaxViaEnrollment'));
            }
        }
    }    
    private void createSpecialInstructionCase(List<Order> orders, Map<Id, Order> oldMap) {
        System.debug('xxx OrderTriggerHandler createSpecialInstructionCase');
        for(Order order : orders){
            if(order.Enrollment_Special_Instructions__c != null && (oldMap == null || order.Enrollment_Special_Instructions__c != oldMap.get(order.Id).Enrollment_Special_Instructions__c)){
                orderEvents.add(createOrderEvent(order.Id, 'createSpecialInstructionCase'));
            }
        }
    }  
    public static void sendQueue(List<Order> orders) {
        System.debug('xxx OrderTriggerHandler sendQueue');
        List<String> validService = new List<String>{'Event','Holter','MCT'};

        if(sendQueueNotBeenCalled){
            SendQueueHelper sqHelper = new SendQueueHelper();

            List<Send_Queue__c> sqs = new List<Send_Queue__c>();
            sendQueueNotBeenCalled = false;
            for(Order order : orders){
                if(!order.PPM__c && order.Patient_Email__c != null && order.Device_Source__c == 'MTP' && order.Enrollment_Relation__c != 'Secondary' && validService.contains(order.Service_Type__c)){
                    sqs.add(sqHelper.createSendQueRecord(order, 'New_Enrollment_Welcome_MTP', order.Patient_Email__c, 'Ready to Process'));
                } else if(!order.PPM__c && order.Patient_Email__c != null && order.Device_Source__c == 'OTS' && order.Enrollment_Relation__c != 'Secondary'  && validService.contains(order.Service_Type__c)){
                    sqs.add(sqHelper.createSendQueRecord(order, 'New_Enrollment_Welcome_OTS', order.Patient_Email__c, 'Ready to Process'));
                } 
            }
            insert sqs;
        }
    }

    public static void createActivationWorkflowCase(List<Order> orders) {
        System.debug('xxx OrderTriggerHandler createActivationWorkflowCase');
        List<Order> awfOrders = new List<Order>();
        for(Order order : orders){
            if((order.Activation_Workflow_Status__c == 'Awaiting Activation' || order.Activation_Workflow_Status__c == 'Awaiting Baseline') && (order.Device_Source__c == 'OTS' || order.Device_Source__c == 'MTP')){
                System.debug('xxx OrderTriggerHandler createActivationWorkflowCase in if');
                awfOrders.add(order);
                /*
                Flow.Interview flow = new Flow.Interview.Create_Activation_Workflow_Case(new map<String,Object> {'recordId' => order.Id});
                if(!Test.isRunningTest()) {
                    flow.start();
                }*/
                
                System.debug('xxx OrderTriggerHandler createActivationWorkflowCase order.Enrollment_Backend_ID__c ' + order.Enrollment_Backend_ID__c);
                System.debug('xxx OrderTriggerHandler createActivationWorkflowCase order.AD_Start_Date__c ' + order.AD_Start_Date__c);
               
                if(!System.isBatch()){
                    if(order.AD_Start_Date__c != null)  
                        middlewareFollowupDateCall(order.Enrollment_Backend_ID__c, order.AD_Start_Date__c);
                    if(order.Activation_AD_Enabled__c)     
                        middlewareAutoDialerCall(order.Enrollment_Backend_ID__c, order.Activation_AD_Enabled__c);            
                }
                   
            }
        }
        if(awfOrders.size() > 0){
            CreateActivationWorkflowCases.process(awfOrders);            
        }
    }
    
    
    public static void middlewareFollowupDate(List<Order> orders, Map<Id, Order> oldMap) {
        System.debug('xxx OrderTriggerHandler middlewareFollowupDate');
        //if(middlewareFollowupDateNotBeenCalled) {
        //    middlewareFollowupDateNotBeenCalled = false;
            for(Order order : orders){
                Order old = oldMap.get(order.Id);
                System.debug('xxx OrderTriggerHandler old ' + old);
                System.debug('xxx OrderTriggerHandler order.AD_Start_Date__c ' + order.AD_Start_Date__c);
                if(old != null && order.AD_Start_Date__c != old.AD_Start_Date__c){
                    System.debug('xxx OrderTriggerHandler middlewareFollowupDate in if');
                    if(!System.isBatch())
                        middlewareFollowupDateCall(order.Enrollment_Backend_ID__c, order.AD_Start_Date__c);
                }
    
            }            
        //}        

    }

    public static void middlewareAutoDialer(List<Order> orders, Map<Id, Order> oldMap) {
        System.debug('xxx OrderTriggerHandler middlewareAutoDialer');
        //if(middlewareAutoDialerBeenCalled) {
            //middlewareAutoDialerBeenCalled = false;
            for(Order order : orders){
                Order old = oldMap.get(order.Id);
                System.debug('xxx OrderTriggerHandler old ' + old);
                System.debug('xxx OrderTriggerHandler order.Activation_AD_Enabled__c ' + order.Activation_AD_Enabled__c);
                if(old != null  && order.Activation_AD_Enabled__c != old.Activation_AD_Enabled__c){
                    System.debug('xxx OrderTriggerHandler middlewareFollowupDate in if');
                    if(!System.isBatch())
                        middlewareAutoDialerCall(order.Enrollment_Backend_ID__c, order.Activation_AD_Enabled__c);
                }

            }
        //}
    }    

    public static void middlewareFollowupDateCall(String backendId, Date startDate){
        System.debug('xxx OrderTriggerHandler middlewareFollowupDateCall');
        System.debug('xxx OrderTriggerHandler middlewareFollowupDateCall FollowupDateCalled.get(backendId) ' + FollowupDateCalled.get(backendId));
        if(FollowupDateCalled.get(backendId) == null){
            String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            System.debug('xxx OrderTriggerHandler middlewareFollowupDateCall userName ' + userName);
            middlewareFollowupDateCallFuture(backendId, startDate, userName);
            FollowupDateCalled.put(backendId, true);
        }
    }
    @Future(callout=true)
    public static void middlewareFollowupDateCallFuture(String backendId, Date startDate, String userName){
        MiddlewareUtil.FollowupDate(backendId, startDate, userName);
    }

    public static void middlewareAutoDialerCall(String backendId, Boolean adStop){
        System.debug('xxx OrderTriggerHandler middlewareAutoDialerCall');
        if(AutoDialerCalled.get(backendId) == null){
            String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            System.debug('xxx OrderTriggerHandler middlewareAutoDialerCall userName ' + userName);
            middlewareAutoDialerCallFuture(backendId, adStop, userName);
            AutoDialerCalled.put(backendId, true);
        }
    }
    @Future(callout=true)
    public static void middlewareAutoDialerCallFuture(String backendId, Boolean adStop, String userName){
        MiddlewareUtil.AutoDialerEnabled(backendId, adStop, userName);
    }
    
    private static Order_Automation__e createOrderEvent(Id id, String type){
        return new Order_Automation__e(Order_Id__c = id, Type__c = type, User_Name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName());

    }    

}