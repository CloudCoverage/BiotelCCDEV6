global without sharing class EnrollmentOrderLookupPlugin implements Process.Plugin {

    global Process.PluginResult invoke(Process.PluginRequest request) { 
        
        String enrollmentNumber = (String)request.inputParameters.get('enrollmentNumber');
        
        Order order = [
            SELECT Id, Name, AccountId, Account.Name, Patient_Contact_ID__c, Patient_Contact_ID__r.FirstName, Patient_Contact_ID__r.LastName, Patient_First_Name__c, Patient_Last_Name__c 
            FROM Order 
            WHERE Enrollment_Number__c = :enrollmentNumber 
            LIMIT 1
        ][0];
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('orderId', order.Id);
        result.put('accountId', order.AccountId);
        result.put('accountName', order.Account.Name);
        result.put('patientContactId', order.Patient_Contact_ID__c);
        result.put('patientFirstName', order.Patient_Contact_ID__r.FirstName);
        result.put('pastientLastName', order.Patient_Contact_ID__r.LastName);
        
        return new Process.PluginResult(result);
        
    }
    
    global Process.PluginDescribeResult describe() { 
        
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'Look Up Order By Enrollment Number';
        result.Tag = 'Order Classes';
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> { 
            new Process.PluginDescribeResult.InputParameter('enrollmentNumber', Process.PluginDescribeResult.ParameterType.STRING, true) 
        }; 
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {              
            new Process.PluginDescribeResult.OutputParameter('orderId',  Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('accountId',  Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('accountName',  Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('patientContactId',  Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('patientFirstName',  Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('pastientLastName',  Process.PluginDescribeResult.ParameterType.STRING)
        }; 
        return result; 
    
    }
        
}