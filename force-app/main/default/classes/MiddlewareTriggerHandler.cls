public with sharing class MiddlewareTriggerHandler {
    final List<Middleware_Event__e> newRecords;
    final List<Middleware_Event__e> oldRecords;
    final Map<Id, Middleware_Event__e> newMap;
    final Map<Id, Middleware_Event__e> oldMap;
    public enum objectType {Enrollment}
    public static Map<String, String> eventTypesMap = new Map<String, String>{'DeviceRetrievalNotification'=>'Device Retrieval Connected', 'NonConnectedPerpetualDeviceRetrieval'=>'Non Connect Perpetual Device Retrieval',
                                                'NonConnectedNonPerpetualDeviceRetrieval'=>'NonConnect NonPerpetual Device Retrieval'};
    static final String sendQueueStatus = 'Ready to Process';
 
    public MiddlewareTriggerHandler(List<Middleware_Event__e> newRecords, List<Middleware_Event__e> oldRecords,Map<Id, Middleware_Event__e> newMap, Map<Id, Middleware_Event__e> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public void afterInsert() {
        
        insertSendQueue(newRecords); 
    }

    public static void insertSendQueue(List<Middleware_Event__e> newRecords) {

                
        List<Order> orderList = new List<Order>();
        List<Send_Queue__c> sqList = new List<Send_Queue__c>();
        
        Map<String, String> typeMap = new Map<String, String>();

        System.debug('Records: '+ newRecords);

        for(Middleware_Event__e event : newRecords){
            System.debug('NewRecords Event Type: '+ event.Event_Type__c);
            if(eventTypesMap.keySet().contains(event.Event_Type__c) && event.Object_Type__c == objectType.Enrollment.name()){
                for (String ty : eventTypesMap.keySet()) {
                    if(event.Event_Type__c==ty){
                        typeMap.put(event.Object_GUID__c,eventTypesMap.get(ty));    
                    }
                }    
            } else{
                if (!eventTypesMap.keySet().contains(event.Event_Type__c)) {
                    typeMap.put(event.Object_GUID__c, event.Event_Type__c);  
                }
            }          
        }

        System.debug('Event type Map: '+typeMap);

        if(!typeMap.isEmpty()){
            SendQueueHelper helper = new SendQueueHelper();
            orderList = [
                SELECT Id,
                Enrollment_Backend_ID__c,
                Patient_Contact_ID__c,
                Patient_Contact_ID__r.Email,
                Enrollment_Number__c
                FROM Order
                WHERE Enrollment_Backend_ID__c =: typeMap.keySet()
                    AND Patient_Contact_ID__r.Email != null];
            System.debug('MiddlewareTriggerHandler.orderList '+orderList);

            if(!orderList.isEmpty()){
                for(Order ord : orderList){
                    String eventSQ = typeMap.get(ord.Enrollment_Backend_ID__c);
                    System.debug('eventSQ '+eventSQ);
                    Send_Queue__c newSendQueue = helper.createSendQueRecord(ord,eventSQ,ord.Patient_Contact_ID__r.Email,sendQueueStatus);  
                    System.debug('Create Queue: '+newSendQueue);   
                    sqList.add(newSendQueue);                    
                }
                System.debug('MiddlewareTriggerHandler.sqList '+sqList);

                insert sqList;
            }
            
        }    
    }
}