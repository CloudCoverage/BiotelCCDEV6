public with sharing class CaseTriggerHandler {
    final List<Case> cases;
    final Map<Id, Case> oldMap;
 
    private static final Id activationWorkflowRT    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Activation_Workflow_Case').getRecordTypeId();
    
    public static Boolean beforeInsertDateNotBeenCalled = true;
    public static Boolean beforeUpdateDateNotBeenCalled = true;
    public List<Case_Automation__e> caseEvents = new List<Case_Automation__e>();


    public CaseTriggerHandler(List<Case> cases, Map<Id, Case> oldMap) {
        this.cases = cases;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        System.debug('xxx beforeInsert ' + cases);
        CaseSequenceNumbers.execute(cases, oldMap); 
        beforeInsertDate(cases, oldMap);
    }

    public void beforeUpdate() {
        System.debug('xxx beforeUpdate');
        caseEvents = new List<Case_Automation__e>();

        beforeUpdateDate(cases, oldMap);
    }

    public static void beforeInsertDate(List<Case> cases, Map<Id, Case> oldMap) {
        System.debug('xxx beforeInsertDate xxxxxxxxxxxxxxxxxxxxx');

        Map<String, Date_Calculation_Setting__c> settingsMap = new Map<String, Date_Calculation_Setting__c>();
        List<Date> holidays = new List<Date>();

        settingsMap = getSettings('Insert');
        holidays = getHolidays();
        List<Date_Calculation_Setting__c> settings = settingsMap.values();

        for(Case c : cases){

            if(c.RecordTypeId == activationWorkflowRT){
                System.debug('xxxy=======================');
                System.debug('xxxy settingsMap ' + settingsMap);

                for (Date_Calculation_Setting__c s : settings){
                    System.debug('xxxy s ' + s);
                    System.debug('xxxy c ' + c);

                    if(s.Device_Source__c == c.Device_Source__c && ((s.Use_Enrollment_Relation__c && s.Enrollment_Relation__c == c.Enrollment_Relation__c) || (!s.Use_Enrollment_Relation__c))){
                        if(s.If_Field__c != null)
                            System.debug('xxxy in device source c.get(s.If_Field__c) ' + c.get(s.If_Field__c));
                        System.debug('xxxy in device source s.If_Value__c ' + s.If_Value__c);

                        if(s.If_Field__c == null || c.get(s.If_Field__c) == s.If_Value__c){
                            System.debug('xxxy in if');

                            Boolean condition =  s.Start_Date_API_Name__c == 'TODAY()' || c.get(s.Start_Date_API_Name__c) != null;

                            System.debug('xxxy condition ' + condition);

                            if(condition){
                                Date startDt = s.Start_Date_API_Name__c == 'TODAY()' ? System.today() : (Date) c.get(s.Start_Date_API_Name__c);
                                String key = s.Enrollment_Relation__c != null ? s.API_Name__c+c.Device_Source__c+c.Enrollment_Relation__c : s.API_Name__c+c.Device_Source__c;
                                Date newDate = ActivationWorkflowHelper.adjustDateForHolidayAndWeekends(startDt , holidays, settingsMap, key);
                                c.put(s.API_Name__c, newDate); 
                            }                                
                        }
                    }

                }
            }
        }
    }

    public static void beforeUpdateDate(List<Case> cases, Map<Id, Case> oldMap) {
        System.debug('xxx subsequentCaseCreateDate');
            
        Map<String, Date_Calculation_Setting__c> settingsMap = new Map<String, Date_Calculation_Setting__c>();
        List<Date> holidays = new List<Date>();

        settingsMap = getSettings('Update');
        holidays = getHolidays();
        List<Date_Calculation_Setting__c> settings = settingsMap.values();

        for(Case c : cases){

            if(c.RecordTypeId == activationWorkflowRT){
                Case old = oldMap.get(c.Id);

                System.debug('xxxy=======================');
                System.debug('xxxy settingsMap ' + settingsMap);

                for (Date_Calculation_Setting__c s : settings){
                    System.debug('xxxy s ' + s);

                    if(s.Device_Source__c == c.Device_Source__c){
                        if(s.If_Field__c != null)
                            System.debug('xxxy in device source c.get(s.If_Field__c) ' + c.get(s.If_Field__c));
                        System.debug('xxxy in device source s.If_Value__c ' + s.If_Value__c);

                        if(s.If_Field__c == null || c.get(s.If_Field__c) == s.If_Value__c){
                            System.debug('xxxy in if');

                            Boolean condition = s.Start_Date_API_Name__c != 'TODAY()' && c.get(s.Start_Date_API_Name__c) != old.get(s.Start_Date_API_Name__c);
                            //condition |= s.Start_Date_API_Name__c == 'TODAY()';
                            condition |= s.If_Field__c != null && c.get(s.If_Field__c) != old.get(s.If_Field__c);
                            condition &= s.Start_Date_API_Name__c == 'TODAY()' || c.get(s.Start_Date_API_Name__c) != null;

                            System.debug('xxxy condition ' + condition);

                            if(condition){
                                Date startDt = s.Start_Date_API_Name__c == 'TODAY()' ? System.today() : (Date) c.get(s.Start_Date_API_Name__c);
                                String key = s.Enrollment_Relation__c != null ? s.API_Name__c+c.Device_Source__c+c.Enrollment_Relation__c : s.API_Name__c+c.Device_Source__c;
                                Date newDate = ActivationWorkflowHelper.adjustDateForHolidayAndWeekends(startDt , holidays, settingsMap, key);
                                c.put(s.API_Name__c, newDate); 
                            }                                
                        }
                    }
                }
            }
        }        

    } 
    
    public static List<Date> getHolidays(){
        Date begindt = Date.newInstance(System.today().year(), 1, 1);
        Date enddt = Date.newInstance(System.today().year(), 12, 31);
        
        List<Date> holidayDates = new List<Date>();
        Map<Date, Holiday> holidays = HolidayUtil.getHolidaysForDates(begindt, enddt);

        for(Date dt : holidays.keySet()){

            holidayDates.add(Date.valueOf(dt));
        }
        return holidayDates;
    }

    public static Map<String, Date_Calculation_Setting__c> getSettings(String operation){

        List<Date_Calculation_Setting__c>  settings = [
          SELECT Id, Name, Record_Key__c, API_Name__c, Device_Source__c, Number_of_Days__c, Count_Weekend__c, Count_Holiday__c, Land_on_Weekend__c, Land_on_Holiday__c, Start_Date_API_Name__c, If_Field__c, If_Value__c, Enrollment_Relation__c, Operation__c, Use_Enrollment_Relation__c   
            FROM Date_Calculation_Setting__c
           WHERE Operation__c = : operation
           ORDER BY Sequence__c
        ];

        Map<String, Date_Calculation_Setting__c> settingsMap = new Map<String, Date_Calculation_Setting__c>();

        for(Date_Calculation_Setting__c ad : settings){
            settingsMap.put(ad.Record_Key__c, ad);
        }
        
        return settingsMap;
    
    }

}