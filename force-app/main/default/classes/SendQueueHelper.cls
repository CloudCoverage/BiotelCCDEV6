public with sharing class SendQueueHelper {
/* REMEMBER  TO LOGIN AS INTEGRATION USER
System.Schedule('BatchSendMessages Batch Job @ 0 past the hour',  '0 0 * * * ?', new BatchSendMessages());
System.Schedule('BatchSendMessages Batch Job @ 15 past the hour',  '0 15 * * * ?', new BatchSendMessages());
System.Schedule('BatchSendMessages Batch Job @ 30 past the hour',  '0 30 * * * ?', new BatchSendMessages());
System.Schedule('BatchSendMessages Batch Job @ 45 past the hour',  '0 45 * * * ?', new BatchSendMessages());  
System.Schedule('BatchPullTrackingNumber Batch Job @ 1030pm past the hour',  '0 30 22 * * ?', new BatchPullTrackingNumber());
System.Schedule('BatchPullTrackingNumber Batch Job @ 1030pm past the hour',  '0 30 22 * * ?', new BatchPullTrackingNumber());
System.Schedule('BatchUPSTracker Batch Job @ 9am past the hour',  '0 0 9 * * ?', new BatchUPSTracker());
System.Schedule('BatchUPSTracker Batch Job @ 1pm past the hour',  '0 0 13 * * ?', new BatchUPSTracker());
System.Schedule('BatchUPSTracker Batch Job @ 9pm past the hour',  '0 0 21 * * ?', new BatchUPSTracker());
*/


    public Send_Queue_Settings__mdt setting;
    public EmailTemplate emailTemplate;
    public String event;
    public String fromAddress;  

    public List<Send_Queue_Settings__mdt> settings;
    public List<EmailTemplate> emailTemplates;

    Map<String, Send_Queue_Settings__mdt> settingsMap;
    Map<String, EmailTemplate> emailTemplatesMap;
    
    public SendQueueHelper(String event){
        setting = [
            SELECT Label, Tepmplate_Id__c, From_Email__c, Template_Name__c, Test_To_Email__c, Test_Tracking_Number__c 
              FROM Send_Queue_Settings__mdt
             WHERE Label = :event
              ];

            System.debug('xxx setting ' + this.setting);

            emailTemplate = [
                SELECT Id,Subject,Description, DeveloperName, Name 
                  FROM EmailTemplate 
                WHERE Name = :this.setting.Template_Name__c];

            System.debug('xxx EmailTemplate ' + this.EmailTemplate);

            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'PE-NoReply@gobio.com'];
            if ( owea.size() > 0 ) {
                fromAddress = owea.get(0).Id;
            }            
    }

    public SendQueueHelper(){
        settingsMap = new Map<String, Send_Queue_Settings__mdt>();
        emailTemplatesMap = new  Map<String, EmailTemplate>();

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'PE-NoReply@gobio.com'];
        if ( owea.size() > 0 ) {
            fromAddress = owea.get(0).Id;
        }   

        settings = [
            SELECT Label, Tepmplate_Id__c, From_Email__c, Template_Name__c, Test_To_Email__c, Test_Tracking_Number__c 
              FROM Send_Queue_Settings__mdt
              ];
              System.debug('xxx settings ' + settings);

              for(Send_Queue_Settings__mdt s : settings){
                settingsMap.put(s.Label, s);
              }


        emailTemplates = [
            SELECT Id,Subject,Description,DeveloperName, Name
              FROM  EmailTemplate 
            ];

            for(EmailTemplate t : emailTemplates){
                emailTemplatesMap.put(t.Name, t);
              }            

            System.debug('xxx emailTemplatesMap ' + this.emailTemplatesMap);
    }    
    public void processEvents(List<Send_Queue__c> recs){
        System.debug('xxx processEvents ');
        List<Task> tasks = new List<Task>();

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();  
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        Map<Id, Send_Queue__c> sqsMap = new Map<Id, Send_Queue__c>();
        for(Send_Queue__c sq : recs){
            sqsMap.put(sq.Id, sq);
        }

        for(Send_Queue__c sq : sqsMap.values()){
            setting = settingsMap.get(sq.Event__c);
            System.debug('xxx setting ' + setting.Template_Name__c);
            emailTemplate = emailTemplatesMap.get(setting.Template_Name__c);
            System.debug('xxx emailTemplate ' + emailTemplate);
            sq.Template_Name__c = emailTemplate.Name;
            System.debug('xxx sq ' + sq);
            messages.add(createEmail(sq));

        }
        System.debug('xxx messages ' + messages);

        try {
            results = Messaging.sendEmail(messages,false);
            System.debug('xxx results ' + results);
            for(Integer i = 0; i < results.size(); i++){
                System.debug('xxx result '+ results[i]);
                if (results[i].success) {
                    System.debug('The email was sent successful');
                    tasks.add(createTask('Email Sent: ', sqsMap.get(messages[i].getWhatId()), true, 'Email send successful'));
                    sqsMap.get(messages[i].getWhatId()).Send_Successful__c = true;
                    sqsMap.get(messages[i].getWhatId()).Error_Message__c = 'Email send successful';
                    sqsMap.get(messages[i].getWhatId()).Sent_Timestamp__c = System.now();  
                    sqsMap.get(messages[i].getWhatId()).Status__c = 'Processed';                  
                } else {
                    sqsMap.get(messages[i].getWhatId()).Status__c = 'Failed';
                    sqsMap.get(messages[i].getWhatId()).Send_Successful__c = false;
                    sqsMap.get(messages[i].getWhatId()).Error_Message__c = 'Email send failed: ' + results[i].errors[0].message;
                    tasks.add(createTask('Email Send Failed: ', sqsMap.get(messages[i].getWhatId()), false, results[i].errors[0].message));
                } 
            }
            /*
            for(Send_Queue__c sq : sqsMap.values()){
                if(sq.Send_Successful__c != false){
                    sq.Error_Message__c = 'Email send successful';
                    sq.Status__c = 'Processed';
                    sq.Send_Successful__c = true;
                    sq.Sent_Timestamp__c = System.now();                    
                }
            }*/
           
        } catch (Exception e) {
            for(Send_Queue__c sq : recs){
                sq.Status__c = 'Failed';
                sq.Send_Successful__c = false;
                sq.Error_Message__c = e.getMessage();
            }
        }
        update sqsMap.values();
        insert tasks;

        
    }


    public Messaging.SingleEmailMessage createEmail (Send_Queue__c sq){   
        System.debug('xxx sq ' + sq);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();   
        message.setOrgWideEmailAddressId(fromAddress);
        message.setTargetObjectId(sq.Patient__c); 
		message.setWhatId(sq.Id);
        message.optOutPolicy = 'FILTER'; 
        message.setSaveAsActivity(false);   
        message.setTemplateID(emailTemplate.Id); 
        return message;  
    }
    
    public static Task createTask(String subject, Send_Queue__c sq, Boolean success, String message){
        System.debug('yyy createTask ' + message);

        String description;
        if(success){
            switch on sq.Event__c {
                when 'Delivery_Confirmation'
                    {description = 'Package was delivered on ' + formatDate(sq.Shipment_Delivery_Date__c)  + ' at ' + sq.Shipment_Delivery_Time__c;}
                when 'Shipment_Confirmation'
                {
                    description = 'Package was shipped on ' + formatDate(sq.Shipment_Date__c);
                    if(sq.Estimated_Delivery_Date__c != null){
                        description = description + '. Estimated Delivery Date is ' + formatDate(sq.Estimated_Delivery_Date__c);
                     }
                }
                when 'New_Enrollment_Welcome_MTP'
                {description = 'Welcome MTP email successfully sent to Patient ';}                                
                when 'New_Enrollment_Welcome_OTS'
                {description = 'Welcome OTS email Successfully sent to Patient ';}                                
            } 
        } else{
            switch on sq.Event__c {
                when 'Delivery_Confirmation'
                    {description = 'Error sending Delivery Confirmation email: ' + message;}
                when 'Shipment_Confirmation'
                    {description = 'Error sending Shipment Confirmation email: ' + message;}
                when 'New_Enrollment_Welcome_MTP'
                    {description = 'Error sending Welcome email: ' + message;}   
                when 'New_Enrollment_Welcome_OTS'
                    {description = 'Error sending Welcome email: ' + message;}                                       
            }            

        }
       
        return new Task(
            WhatId = sq.Enrollment__c,
            Status = 'Completed',
            Description = description,
            Description__c = description,
            Subject = subject + sq.Event__c.replace('_', ' ').replace('OTS', '').replace('MTP', ''),
            WhoId = sq.Patient__c
        );
    }
    public static String formatDate(Date d) {
        return d.month() + '/' + d.day()  + '/' + d.year() ;
    }     

    public Send_Queue__c createSendQueRecord(Order o, String tn){
        Send_Queue__c sq = new Send_Queue__c(
            Enrollment__c = o.Id,
            //To__c = this.setting.Test_To_Email__c != null ? this.setting.Test_To_Email__c : o.Patient_Contact_ID__r.Email,
            Type__c = 'Email',
            Event__c = 'Shipment_Confirmation',
            Status__c = 'Pending',
            Patient__c = o.Patient_Contact_ID__c,
            Tracking_Number__c = tn,
            From__c = setting.From_Email__c,
            Template_Name__c = setting.Template_Name__c,
            Enrollment_Number__c = o.Enrollment_Number__c
        );

        return sq;
    }

    
    public Send_Queue__c createSendQueRecord(Send_Queue__c s, String tn, String event, String type){
        System.debug('xxxy settingsMap ' + settingsMap);
        System.debug('xxxy event ' + event);

        setting = settingsMap.get(event);

        Send_Queue__c sq = new Send_Queue__c(
            Enrollment__c = s.Enrollment__c,
            //To__c = s.To__c,
            Type__c = type,
            Event__c = event,
            Status__c = 'Pending',
            Patient__c = s.Patient__c,
            Tracking_Number__c = tn,
            From__c = setting.From_Email__c,
            Template_Name__c = setting.Template_Name__c,
            Enrollment_Number__c = s.Enrollment_Number__c != null ? s.Enrollment_Number__c : null 
        );

        return sq;
    }

    public Send_Queue__c createSendQueRecord(Order o, String event, String toEmail, String status){

        setting = settingsMap.get(event);
        System.debug('yyy setting' + setting);
        Send_Queue__c sq = new Send_Queue__c(
            Enrollment__c = o.Id,
            //To__c = this.setting.Test_To_Email__c != null ? this.setting.Test_To_Email__c : toEmail,
            Type__c = 'Email',
            Event__c = event,
            Status__c = status,
            Patient__c = o.Patient_Contact_ID__c,
            From__c = setting.From_Email__c,
            Template_Name__c = setting.Template_Name__c,
            Enrollment_Number__c = o.Enrollment_Number__c

        );
        System.debug('yyy sq' + sq);

        return sq;
    }        


}