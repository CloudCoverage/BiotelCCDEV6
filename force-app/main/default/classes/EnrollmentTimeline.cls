global class EnrollmentTimeline implements Comparable {
    
    //@AuraEnabled public Id linkId { get; set; }
    @AuraEnabled public String linkId { get; set; }
    @AuraEnabled public String lineType { get; set; }
    @AuraEnabled public String style { get; set; }
    @AuraEnabled public String icon { get; set; }
    @AuraEnabled public String subject { get; set; }
    @AuraEnabled public String action { get; set; }
    @AuraEnabled public Id relatedToId { get; set; }
    @AuraEnabled public String relatedToName { get; set; }
    @AuraEnabled public Id createdById { get; set; }
    @AuraEnabled public String createdByName { get; set; }
    @AuraEnabled public Datetime createdDate { get; set; }
    @AuraEnabled public String caseDescription { get; set; }
    @AuraEnabled public String caseActionTaken { get; set; }
    @AuraEnabled public String caseReason { get; set; }
    @AuraEnabled public String orderNumber { get; set; }
    @AuraEnabled public String orderStatus { get; set; }
    @AuraEnabled public String taskNotes { get; set; }
    @AuraEnabled public String taskSourceSystem { get; set; }
    @AuraEnabled public String emailFromAddress { get; set; }
    @AuraEnabled public String emailToAddress { get; set; }
    @AuraEnabled public String emailTextBody { get; set; }
    @AuraEnabled public String callName { get; set; }
    @AuraEnabled public String callDescription { get; set; }
    @AuraEnabled public String shipmentStatus { get; set; }
    @AuraEnabled public String shipmentType { get; set; }
    
    public EnrollmentTimeline() {}
    
    global Integer compareTo(Object compareTo) {
        
        EnrollmentTimeline etl = (EnrollmentTimeline)compareTo;
        if (createdDate == etl.createdDate) 
            return 0;
        if (createdDate < etl.createdDate) 
            return 1;
        return -1; 
        
    }

}