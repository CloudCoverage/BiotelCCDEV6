public without sharing class ActivationWorkflowHelper {

    public static Date adjustDateForHolidayAndWeekends(Date input, List<Date> holidayDates, Map<String, Date_Calculation_Setting__c> settingsMap, String mapKey) {

        System.debug('xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxx adjustDateForHolidayAndWeekends mapKey ' + mapKey);
        System.debug('xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxx settingsMap.get(mapKey) ' + settingsMap.get(mapKey));
        System.debug('xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxx startDt ' + input);
        //c.AD_Start_Date__c = ActivationWorkflowHelper.adjustDateForHolidayAndWeekends(c.Initial_Estimated_Delivery_Date__c , holidays, settingsMap, 'AD_Start_Date__c'+c.Device_Source__c);


        Decimal numOfDaysDec = settingsMap.get(mapKey) != null ? settingsMap.get(mapKey).Number_of_Days__c : 0;  
        Integer numOfDays = Integer.valueOf(numOfDaysDec);
        Boolean countWeekend = settingsMap.get(mapKey) != null ? settingsMap.get(mapKey).Count_Weekend__c : false;  
        Boolean countHoliday = settingsMap.get(mapKey) != null ? settingsMap.get(mapKey).Count_Holiday__c : false;  
        Boolean landOnWeekend = settingsMap.get(mapKey) != null ? settingsMap.get(mapKey).Land_on_Weekend__c  : false;  
        Boolean landOnHoliday = settingsMap.get(mapKey) != null ? settingsMap.get(mapKey).Land_on_Holiday__c  : false;  
        Date work;
        /* create list of holiday dates */
        //for(Holiday h : holidays){
        //    holidayDates.add(h.ActivityDate); 
        //}
        System.debug('input ' + input);
        System.debug('holidayDates ' + holidayDates);
        System.debug('settingsMap ' + settingsMap);
        System.debug('mapKey ' + mapKey);

        System.debug('numOfDays ' + numOfDays);
        System.debug('numOfDaysDec ' + numOfDaysDec);
        System.debug('countWeekend ' + countWeekend);

        //if(numOfDays == null || numOfDays == 0)
        if(numOfDays == null)
            return input;

        /*if input date is a holiday or weekend subtract 1 from the number of days in the future*/
        if(holidayDates.contains(input) && !countHoliday){
            numOfDays--;
        } else if((getWeekdayNumberFromDate(input) == 5 || getWeekdayNumberFromDate(input) == 6) &&  !countWeekend){
            numOfDays--;
        }
      //if(numOfDays > 0){
        if(numOfDays >= 0){
            for(Integer i = 0; i < numOfDays+1; i++){ 
                System.debug('count = ' + i + 'numOfDays = ' + numOfDays);
                if(holidayDates.contains(input.addDays(i))  && !countHoliday){
                    System.debug(input.addDays(i) + 'Is a Holiday');
                    numOfDays++;
                }else if((getWeekdayNumberFromDate(input.addDays(i)) == 5 || getWeekdayNumberFromDate(input.addDays(i)) == 6)   && !countWeekend){
                    System.debug(input.addDays(i) + 'Is a weekend');
                    numOfDays++;
                } else {
                    work = input.addDays(i);
                    System.debug(input.addDays(i) + 'Is NOT a weekend or Holiday');
                }
            }
        } else {
            work = input;   
        }

        System.debug('final date ' + work);
        if(holidayDates.contains(work)  && !landOnHoliday){
            work = adjustDateForHoliday(work, holidayDates);
        } else if((getWeekdayNumberFromDate(work) == 5 || getWeekdayNumberFromDate(work) == 6)   && !landOnWeekend){
            work = adjustDateForWeekend(work);
        }
        
        return work;
    }

    public static Integer getWeekdayNumberFromDate(Date fromDate) {
        return Integer.valueOf(((Datetime) fromDate).format('u'));
    }    

    public static Date adjustDateForWeekend(Date input) {

        if((getWeekdayNumberFromDate(input) == 5 || getWeekdayNumberFromDate(input) == 6)) input = input.addDays(1);
        if((getWeekdayNumberFromDate(input) == 5 || getWeekdayNumberFromDate(input) == 6)) input = input.addDays(1);
        
        return input;
    }

    public static Date adjustDateForHoliday(Date input, List<Date> holidayDates) {

        if(holidayDates.contains(input)) input = input.addDays(1);
        if(holidayDates.contains(input)) input = input.addDays(1);
        if(holidayDates.contains(input)) input = input.addDays(1);

        System.debug('holidayDates ' + holidayDates);  
        
        return input;
    }    

    @InvocableMethod(label='Create Patient Case From Order')
    public static Void createReverseCancellationPIC(List<Id> ids){
        System.debug('xxx yyy createReverseCancellationPIC ids ' + ids);
        Id patientInteractionRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        Date today = System.today();
        List <Case_Reason_Lookup__c> crls = [SELECT Id FROM Case_Reason_Lookup__c WHERE External_Id__c = 'a0Q0R000003bqUgUAI'];
        String reasonId = crls.size() > 0 ? crls[0].Id : 'a0Q0R000003bqUgUAI';
    
        
        //List<Case> actWfCases = [
        List<Case> actWfCases = [
            SELECT Id, Order__c, Order__r.AccountId, Order__r.Patient_Id__c, AD_Start_Date__c, Subsequent_Case_Creation_Date__c, 
            Initial_Case_Creation_Date__c, Activation_AD_Enabled__c, order__r.Patient_Contact_ID__c, OB_Manual_Baseline_Follow_Up_Created__c, 
            (SELECT Id FROM Cases WHERE IsClosed = false AND Case_Reason_Lookup__c = :reasonId AND RecordTypeId = :patientInteractionRT) 
              FROM Case
             WHERE Id IN :Ids];
             System.debug('xxx yyy createReverseCancellationPIC actWfCases ' + actWfCases);

        //String queueId;
        //String devName = System.isBatch() ? 'Activation_BaseLine' : 'Activation_Reverse_Cancellation';

        List<Group> queue = [
            SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN ('Activation_Reverse_Cancellation')//'Activation_BaseLine'  should be Activation_Reverse_Cancellation IF COMING FROM PB 
        ];
        String activationReverse =  queue[0].Id;

        List<Id> caseReasonIds = new List<Id>();
        /* 
        a0Q0R000003bqUgUAI - Complete Reverse Cancellation
        */
        List <Case_Reason_Lookup__c> caseReasonList = [
              SELECT  Id, Name, Case_Record_Type__c, Case_Type__c, Category__c, Active__c, External_Id__c 
                FROM  Case_Reason_Lookup__c 
               WHERE  External_Id__c = 'a0Q0R000003bqUgUAI'        
                 AND  Active__c = TRUE
        ];

        System.debug('xxx yyy createReverseCancellationPIC caseReasonList ' + caseReasonList);

        List <Case> patientInteractionCases = new List<Case>();
        List<Order> updateOrders = new List<Order>();
        
        for(Case c : actWfCases){
            if(c.Cases.isEmpty()){
                Case pc = new Case();
                pc.RecordTypeId = patientInteractionRT;
                pc.Order__c = c.Order__c;
                pc.Activation_AD_Enabled__c = c.Activation_AD_Enabled__c;
                if(c.AD_Start_Date__c > System.today())
                    pc.AD_Start_Date__c = c.AD_Start_Date__c;
                else
                    pc.AD_Start_Date__c = System.today().addDays(1);
    
                System.debug('xxx Activation_Reverse_Cancellation ' + activationReverse);
    
                pc.OwnerId = activationReverse;
                System.debug('pc.OwnerId ' + pc.OwnerId);
                pc.Status = 'New';
                pc.ParentId = c.Id;
                pc.Origin = 'Workflow';
                if(c.Order__c != null && c.Order__r.AccountId != null)
                    pc.AccountId = c.Order__r.AccountId;
                if(c.Order__c != null && c.Order__r.Patient_Contact_ID__c != null)
                    pc.ContactId = c.Order__r.Patient_Contact_ID__c;
                pc.Case_Reason_Lookup__c = caseReasonList[0].Id;
                pc.Subject = caseReasonList[0].Name;                    
                if(c.Order__c != null){
                    Order o = new Order(Id = c.Order__c, RC_Status__c = 'Case Created');
                    updateOrders.add(o);
                }
                
                System.debug('xxx yyy createReverseCancellationPIC pc ' + pc);
                patientInteractionCases.add(pc);                
            }
        }
        update actWfCases;
        update updateOrders;

        INSERT patientInteractionCases;
        System.debug('xxx yyy createReverseCancellationPIC patientInteractionCases ' + patientInteractionCases);
    } 

    public static Void createPIC(List<Id> ids){
        System.debug('xxx yyy createPIC ids ' + ids);
        Id patientInteractionRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        Date today = System.today();
    
        List<Group> queue = [
            SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'Activation_BaseLine' //'Activation_BaseLine'  should be Activation_Reverse_Cancellation IF COMING FROM PB 
        ];
        String activationBaseline = queue[0].Id;

        List<Case> actWfCases = [
            SELECT Id, Order__c, Order__r.AccountId, Order__r.Patient_Id__c, AD_Start_Date__c, Subsequent_Case_Creation_Date__c, 
            Initial_Case_Creation_Date__c, Activation_AD_Enabled__c, order__r.Patient_Contact_ID__c, OB_Manual_Baseline_Follow_Up_Created__c 
              FROM Case
             WHERE Id IN :Ids];
             System.debug('xxx yyy createPIC actWfCases ' + actWfCases);
        


        List<Id> caseReasonIds = new List<Id>();
        //Need to find the correct case reason lookup - card 5.Automation: Create Initial Patient interaction case
        List <Case_Reason_Lookup__c> caseReasonList = [
              SELECT  Id, Name, Case_Record_Type__c, Case_Type__c, Category__c, Active__c, External_Id__c 
                FROM  Case_Reason_Lookup__c 
               WHERE  External_Id__c IN ('a0Q0R000003cbkUUAQ', 'a0Q0R000003cbkWUAQ')        
                 AND  Active__c = TRUE
        ];
        /* 
        a0Q0R000003cbkUUAQ- Outbound Device Not Activated/Baselined
        a0Q0R000003cbkWUAQ - Outbound Device Not Activated/Baselined - Subsequent
        a0Q0R000003bqUgUAI - Complete Reverse Cancellation
        */
        Map<String,String> caseReasonMap = new Map<String,String>();
        for(Case_Reason_Lookup__c c : caseReasonList){
            caseReasonMap.put(c.External_Id__c, c.Id);
        }

        Map<String,String> caseReasonNameMap = new Map<String,String>();
        for(Case_Reason_Lookup__c c : caseReasonList){
            caseReasonNameMap.put(c.External_Id__c, c.Name);
        }        

        List <Case> patientInteractionCases = new List<Case>();
        
        for(Case c : actWfCases){
            Case pc = new Case();
            pc.RecordTypeId = patientInteractionRT;
            pc.Order__c = c.Order__c;
            pc.Activation_AD_Enabled__c = c.Activation_AD_Enabled__c;
            if(c.AD_Start_Date__c > System.today())
                pc.AD_Start_Date__c = c.AD_Start_Date__c;
            else
                pc.AD_Start_Date__c = System.today().addDays(1);

            System.debug('xxx Activation_Baseline ' + activationBaseline);


            pc.OwnerId = activationBaseline;
            System.debug('pc.OwnerId ' + pc.OwnerId);
            pc.Status = 'New';
            pc.ParentId = c.Id;
            pc.Origin = 'Workflow';
            if(c.Order__c != null && c.Order__r.AccountId != null)
                pc.AccountId = c.Order__r.AccountId;
            if(c.Order__c != null && c.Order__r.Patient_Contact_ID__c != null)
                pc.ContactId = c.Order__r.Patient_Contact_ID__c;
            if(caseReasonList.size() > 1){

                if(c.Initial_Case_Creation_Date__c == System.today()){
                    pc.Case_Reason_Lookup__c = caseReasonMap.get('a0Q0R000003cbkUUAQ');
                    pc.Subject = caseReasonNameMap.get('a0Q0R000003cbkUUAQ');
                    c.OB_Manual_Baseline_Follow_Up_Created__c = incrmentCount(c.OB_Manual_Baseline_Follow_Up_Created__c);
                }else{
                    pc.Case_Reason_Lookup__c = caseReasonMap.get('a0Q0R000003cbkWUAQ');
                    pc.Subject = caseReasonNameMap.get('a0Q0R000003cbkWUAQ');
                    c.OB_Manual_Baseline_Follow_Up_Created__c = incrmentCount(c.OB_Manual_Baseline_Follow_Up_Created__c);
                }

            }
            System.debug('xxx yyy createPIC pc ' + pc);
            patientInteractionCases.add(pc);                
        }
        update actWfCases;

        INSERT patientInteractionCases;
        System.debug('xxx yyy createPIC patientInteractionCases ' + patientInteractionCases);
    }

    public static Void createReverseCancellationPICFromOrder(String orderId){
        System.debug('xxx yyy createPICFromOrder orderId ' + orderId);
        Id patientInteractionRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Support').getRecordTypeId();
        Date today = System.today();
        Order order = [
            SELECT Id, Activation_AD_Enabled__c, AD_Start_Date__c, AccountId, Patient_Contact_ID__c 
              FROM Order 
             WHERE Id = :orderId];
        //String queueId;
        //String devName = System.isBatch() ? 'Activation_BaseLine' : 'Activation_Reverse_Cancellation';

        List<Group> queue = [
            SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'Activation_Reverse_Cancellation' 
        ];
        String activationReverse =  queue[0].Id;



        List<Id> caseReasonIds = new List<Id>();
        //Need to find the correct case reason lookup - card 5.Automation: Create Initial Patient interaction case
        List <Case_Reason_Lookup__c> caseReasonList = [
              SELECT  Id, Name, Case_Record_Type__c, Case_Type__c, Category__c, Active__c, External_Id__c 
                FROM  Case_Reason_Lookup__c 
               WHERE  External_Id__c = 'a0Q0R000003bqUgUAI'    
                 AND  Active__c = TRUE
        ];
        /* 

        a0Q0R000003bqUgUAI - Complete Reverse Cancellation
        */

        List <Case> patientInteractionCases = new List<Case>();
        
        Case pc = new Case();
        pc.RecordTypeId = patientInteractionRT;
        pc.Order__c =orderId;
        pc.Activation_AD_Enabled__c = order.Activation_AD_Enabled__c;
        if(order.AD_Start_Date__c > System.today())
            pc.AD_Start_Date__c = order.AD_Start_Date__c;
        else
            pc.AD_Start_Date__c = System.today().addDays(1);

        pc.OwnerId = activationReverse;
        System.debug('pc.OwnerId ' + pc.OwnerId);
        pc.Status = 'New';
        pc.Origin = 'Workflow';
        if(order.AccountId != null)
            pc.AccountId = order.AccountId;
        if(order.Patient_Contact_ID__c != null)
            pc.ContactId = order.Patient_Contact_ID__c;
        if(caseReasonList.size() > 0){
            System.debug('if 1');
            pc.Case_Reason_Lookup__c = caseReasonList[0].Id;
            pc.Subject = caseReasonList[0].Name;                    
        }
        INSERT pc;
        order.RC_Status__c = 'Case Created';
        update order;
        System.debug('xxx yyy createPICFromOrder pc ' + pc);
    }

    private static Decimal incrmentCount(Decimal counter){
        if(counter == null){
            return 1;
        } else{
            return counter + 1;
        }
    }


   
     
}