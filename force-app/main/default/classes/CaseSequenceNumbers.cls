public with sharing class CaseSequenceNumbers {
    
    private static final Id customerComplaint = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Complaint').getRecordTypeId();
    private static final Id nonComplaint    = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non-Complaint').getRecordTypeId();

    public static void execute(List<Case> cases, Map<Id, Case> oldMap) {

        Decimal maxIntPrp = getMaxInt(nonComplaint);
        Decimal maxIntComplaint = getMaxInt(customerComplaint); 
        System.debug('xxx in customerComplaint ' + customerComplaint );
        System.debug('xxx in nonComplaint ' + nonComplaint );
        System.debug('xxx in maxIntPrp ' + maxIntPrp );
        System.debug('xxx in maxIntComplaint ' + maxIntComplaint );

        for(Case c : cases){
            System.debug('xxx in caseFor ' + c.recordTypeId);
            if(c.recordTypeId == nonComplaint){
                System.debug('xxx nonComplaint ' + maxIntPrp);
                c.PRP_Number__c = maxIntPrp;
                maxIntPrp++;

            }else if(c.recordTypeId == customerComplaint){
                c.Customer_Complaint_Number__c = maxIntComplaint;
                System.debug('xxx customerComplaint ' + maxIntComplaint);
                maxIntComplaint++;
            }


        }




    }
    private static Decimal getMaxInt(Id recType){
        System.debug('getMaxInt ');
        Decimal maxInt = 0;
        List<Case> newChildCases = new List<Case>();
        List<Case> Cases = new List<Case>();

        if(recType == customerComplaint){
            Cases = [SELECT Customer_Complaint_Number__c 
                                            FROM Case
                                            WHERE Customer_Complaint_Number__c != NULL
                                            AND recordTypeId = :recType
                                        ORDER BY Customer_Complaint_Number__c DESC
                                            LIMIT 1];
            if(Cases.size() > 0){
                maxInt = Cases[0].Customer_Complaint_Number__c;
                maxInt++;
            }else{
                maxInt = 1;
            }
            
        } else if(recType == nonComplaint){
            Cases = [SELECT PRP_Number__c 
                                            FROM Case
                                            WHERE PRP_Number__c != NULL
                                            AND recordTypeId = :recType
                                        ORDER BY PRP_Number__c DESC
                                            LIMIT 1];
            if(Cases.size() > 0){
                maxInt = Cases[0].PRP_Number__c;
                maxInt++;
            }else{
                maxInt = 1;
            }
                
        }
        
        


        System.debug('maxInt ' +maxInt); 
        return maxInt;

    }       
}