Global class BatchPullTrackingNumber  implements Schedulable, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
    public String query;
    public Map<String, String> trackingNumbers;
    public Date whereDate = System.today().addDays(-90);
    public DateTime lstDate = System.now().addDays(-10);

    Global BatchPullTrackingNumber() {
        trackingNumbers = new Map<String, String>();

        query = 'SELECT Id, CreatedDate, LastModifiedDate, Enrollment_Backend_ID__c, Patient_Contact_ID__c,  ' +
                    'Tracking_Numbers__c, Patient_Contact_ID__r.Email, Enrollment_Number__c ' + 
                ' FROM Order ' +
                ' WHERE (Enrollment_Submitted_Date__c > :whereDate OR LastModifiedDate > :lstDate) ' +
                ' AND PPM__c != TRUE ' +
              //  ' AND Enrollment_Relation__c != \'Secondary\' ' +
                ' AND Patient_Contact_ID__c != NULL ' +
            //    ' AND Device_Source__c != \'Direct Sales\' ' +
            ' AND Patient_Contact_ID__r.Email != NULL' +
            //    ' AND Device_Source__c IN(\'MTP\',\'Event\') ' +
                ' AND Service_Type__c IN(\'Event\',\'Holter\',\'MCT\') ';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('whereDate ' + whereDate);
        System.debug('lstDate ' + lstDate);
        System.debug('xxx query ' + query);  
            

        return Database.getQueryLocator(query);
    }

    global  void execute(Database.BatchableContext BC, List<Order> orders){
        System.debug('size ' + orders.size());
        process(orders);
    }
    global void finish(Database.BatchableContext BC){
        System.debug('xxxxxxxxxxxxxxxxxxx tracking numbers ' + trackingNumbers);
        //System.debug('xxxxxxxxxxxxxxxxxxx tracking numbers size ' + TrackingNumbers.size());
        for(String key: trackingNumbers.keySet()){
            System.debug('Order ' + key + ' ' + trackingNumbers.get(key));
        }
    }

    public void process(List<Order> orders){
        System.debug('orders ' + orders);
        String authToken = MiddlewareUtil.getAuthToken();
        SendQueueHelper sqh = new SendQueueHelper('Shipment_Confirmation');
        
        List<Order> updateOrders = new List<Order>();
        List<Send_Queue__c> sqs = new List<Send_Queue__c>();
        Date checkDate = System.today().addDays(-2);

        for(Order order : orders){
            System.debug('order ' + order);
           
            List<MiddlewareUtil.Shipment> shipments = middlewareUtil.getShipments(order.Enrollment_Backend_ID__c, authToken);
            List<String> tns = new List<String>();
            List<String> existingTns = new List<String>();
            Map<String, Date> shipDateMap = new Map<String, Date>();
            
            if(order.Tracking_Numbers__c != null){
                existingTns = (List<String>) JSON.deserialize(order.Tracking_Numbers__c, List<String>.class);   
            }
            Boolean newTrackingNumber = false;

            for(MiddlewareUtil.Shipment s: shipments){
                if(s.TrackingNumber != null && s.Type != 'Off The Shelf' && s.Type != 'Direct Sales'){
                    System.debug('xxxxxxxxxxxxxxxxxxx tracking number ' + s.TrackingNumber);
                    String tn = sqh.setting.Test_Tracking_Number__c != null ? sqh.setting.Test_Tracking_Number__c : s.TrackingNumber;
                    trackingNumbers.put(order.Id, tn);
                    tns.add(tn);
                    shipDateMap.put(tn, Date.valueOf(s.CreatedDate));
                }
            }
            if(tns.size() > 0){
                for(String tn : tns){
                    if(!existingTns.contains(tn)){
                        newTrackingNumber = true;
                        existingTns.add(tn);
                        System.debug('xxxxxxxx Shipment Date ' + shipDateMap.get(tn));
                        System.debug('xxxxxxxx check number ' + checkDate);
                        if(shipDateMap.get(tn) > checkDate){
                            Send_Queue__c sq = sqh.createSendQueRecord(Order, tn);
                            sq.Shipment_Date__c = shipDateMap.get(tn);
                            sqs.add(sq);
                        }
                    }
                }
            }
            if(newTrackingNumber){
                order.Tracking_Numbers__c = JSON.serialize(existingTns);
                updateOrders.add(order);
            }
            //System.debug(JSON.serializePretty(shipments));

        }
        update updateOrders;
        insert sqs;
    }

	global void execute(SchedulableContext SC) 
	{		
		ID batchprocessid = Database.executeBatch(new BatchPullTrackingNumber(), 25);
	}     
   
}