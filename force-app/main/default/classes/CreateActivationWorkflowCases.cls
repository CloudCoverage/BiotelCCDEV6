public with sharing class CreateActivationWorkflowCases {
    @InvocableMethod(label='Create Activation Workflow Case')
    public static void execute(List<Id> ids){

        List<Order> orders = [
            SELECT Id, AccountId, Patient_Contact_ID__c, Enrollment_Submitted_Date__c, Enrollment_Relation__c, Device_Source__c, Secondary_AWFC_CreateDate__c, 
                Activation_Workflow_Status__c, In_Practice_Call_Queue_checkbox__c, Activation_Workflow_Case__c, Activation_AD_Enabled__c, Prescription_Start_Date__c 
            FROM Order 
            WHERE Id IN :ids
        ];
        if(orders.size() > 0){
            process(orders);
        }
    }

    public static void process(List<Order> orders){
        Id activationWorkflowRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
    
        List<Group> queues = [
            SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN ('Activation_Workflow')
        ];
        String queueId;
        if(queues.size() > 0)
            queueId = queues[0].Id;
    
    
        List <Case_Reason_Lookup__c> crls = [
            SELECT Id FROM 
            Case_Reason_Lookup__c 
            WHERE Name = 'Activation Workflow' AND Active__c = true AND Case_Record_Type__c = 'Activation Workflow Case'];
            
        String reasonId = crls.size() > 0 ? crls[0].Id : 'a0Q6S00000Np6EyUAJ';

        Map<Id, Id> contactToOrder = new Map<id, Id>();
        for(Order o : Orders){
            contactToOrder.put(o.Patient_Contact_ID__c, o.Id);
        }

        List<Order> primaryOrders = [
            SELECT Id, Patient_Special_Instructions__c, Enrollment_Relation__c, Patient_Contact_ID__c, Activation_AD_Enabled__c, Secondary_AWFC_CreateDate__c 
              From Order 
             WHERE Patient_Contact_ID__c IN :contactToOrder.keySet()
               AND Enrollment_Relation__c = 'Primary'];

        System.debug('xxx primaryOrders ' + primaryOrders);

        Map<Id, Order> primaryOrdersMap = new Map<Id, Order>();
        for(Order o : primaryOrders){
            primaryOrdersMap.put(o.Patient_Contact_ID__c, o);
        }


        
        List<Case> cases = new List<Case>();
        Map<Id, Order> OrdersMap = new Map<Id,Order>();

        for(Order o : orders){
            if(o.Activation_Workflow_Case__c == null){
                OrdersMap.put(o.Id, o);
                Boolean FourInOneDeviation = o.Enrollment_Relation__c == 'Secondary' && o.Device_Source__c == 'OTS';
                System.debug('xxx FourInOneDeviation ' + FourInOneDeviation);
                Case c = new Case();
                c.recordTypeId = activationWorkflowRT;
                c.ownerId = queueId;
                c.Case_Reason_Lookup__c = reasonId;
                c.Subject = 'Activation Workflow Case';
                c.Order__c = o.Id;
                C.Origin = 'Workflow';
                c.AccountId = o.AccountId;
                c.ContactId = o.Patient_Contact_ID__c;
                C.Case_Record_Type_Picklist__c = 'Activation Workflow Case';
                c.Initial_Estimated_Delivery_Date__c = o.Enrollment_Submitted_Date__c;
                c.Status = o.Activation_Workflow_Status__c;
                if(FourInOneDeviation){
                    c.Activation_AD_Enabled__c = primaryOrdersMap.get(o.Patient_Contact_ID__c).Activation_AD_Enabled__c;
                }
                else if(o.In_Practice_Call_Queue_checkbox__c == false){
                    c.Activation_AD_Enabled__c = true;
                }else{
                    c.Activation_AD_Enabled__c = false;
                }
                c.Prescription_Start_Date__c = o.Prescription_Start_Date__c;
                c.Secondary_AWFC_CreateDate__c = o.Secondary_AWFC_CreateDate__c;
                c.Enrollment_Relation__c = o.Enrollment_Relation__c;
                cases.add(c);
                System.debug('xxx c.Activation_AD_Enabled__c ' + c.Activation_AD_Enabled__c);
            }

        }
        INSERT cases;
        System.debug('xxx cases ' + cases);
        Map<Id, Id> orderToCase = new Map<Id,Id>();
        for(Case c : cases) orderToCase.put(c.Order__c, c.Id);
        updateOrders(orderToCase, JSON.serialize(OrdersMap));
  

    }
    @future(callout = true)
    public static void updateOrders(Map<Id, Id> orderToCase, String ordersMapString){
        System.debug('xxx updateOrders');
        Map<Id, Order> ordersMap = (Map<Id,Order>) JSON.deserialize(ordersMapString, Map<Id,Order>.class);
        Map<Id, Id> contactToOrder = new Map<id, Id>();
        for(Id key : ordersMap.keySet()){
            Order o = ordersMap.get(key);
            contactToOrder.put(o.Patient_Contact_ID__c, key);
        }
        //List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN: contactToOrder.keySet()];
        List<Order> primaryOrders = [
            SELECT Id, Patient_Special_Instructions__c, Enrollment_Relation__c, Patient_Contact_ID__c, Activation_AD_Enabled__c 
              From Order 
             WHERE Patient_Contact_ID__c IN :contactToOrder.keySet()
               AND Enrollment_Relation__c = 'Primary'];

        System.debug('xxx primaryOrders ' + primaryOrders);

        Map<Id, Order> primaryOrdersMap = new Map<Id, Order>();
        for(Order o : primaryOrders){
            primaryOrdersMap.put(o.Patient_Contact_ID__c, o);
        }
        System.debug('xxx primaryOrdersMap ' + primaryOrdersMap);


        List<Order> os = new List<Order>();
        for(Id key: orderToCase.keySet()){
            if(orderToCase.get(key) != null){
                Order od = new Order();
                od.Activation_Workflow_Case__c = orderToCase.get(key);
                od.Id = key;

                Order order = ordersMap.get(od.Id);
                System.debug('xxx order.Patient_Contact_ID__c ' + order.Patient_Contact_ID__c);
                System.debug('xxx primaryOrdersMap.get(order.Patient_Contact_ID__c) ' + primaryOrdersMap.get(order.Patient_Contact_ID__c));

                if(primaryOrdersMap.get(order.Patient_Contact_ID__c) != null && primaryOrdersMap.get(order.Patient_Contact_ID__c).Patient_Special_Instructions__c != null){
                    od.Patient_Special_Instructions__c = primaryOrdersMap.get(order.Patient_Contact_ID__c).Patient_Special_Instructions__c;
                }
                os.add(od);
            }
        }
        update os;
    }
    
}