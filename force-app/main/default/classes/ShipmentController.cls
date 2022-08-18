public with sharing class ShipmentController {

	@AuraEnabled
    public static List<MiddlewareUtil.Shipment> fetchShipments(String recordId){

        Order en = [Select Id, OrderNumber, Enrollment_Number__c, Enrollment_Backend_ID__c From Order Where Id = :recordId];

        List<MiddlewareUtil.Shipment> shipments = middlewareUtil.getShipments(en.Enrollment_Backend_ID__c);
        for(MiddlewareUtil.Shipment shipment :shipments){
            shipment.EnrollmentNumber = en.OrderNumber;
            shipment.EnrollmentId = en.Id; 

        }    
        return shipments; 

    }

    /*
	@AuraEnabled
    public static MiddlewareUtil.Shipment fetchShipment(String recordId){

        MiddlewareUtil.Shipment shipment = middlewareUtil.getShipment('6dfc67e3-4b02-4b28-a3d3-9e010ed611dd', 'f06106bd-80ef-4e8c-aa0f-ba21912b222b');

        List<Order> order = [Select Id, OrderNumber, Enrollment_Number__c From Order Where Enrollment_Backend_ID__c = :shipment.Enrollment];
        if(order != null){
            shipment.EnrollmentNumber = order[0].OrderNumber;
            shipment.EnrollmentId = order[0].Id;  
        }
        //if(shipment.DeliverByDate != null) 
        //    shipment.FulfilledDateTimeString = gmt(shipment.DeliverByDate, 'America/New_York');


        return shipment;

    }
    public Static string gmt(DateTime DT, String strTz) {
        DT = DT.addHours(12); //why? Just because...
        string local = DT.format('yyyy-MM-dd\'T\'HH:mm:ss');    
        Timezone tz = Timezone.getTimeZone(strTz);                

        integer correction = tz.getOffset(dt);
        integer absCorr = correction;
        integer sign = 1;

        if (correction < 0) {
            absCorr = -1 * correction;
            sign = -1;
        }
        time t1 = time.newInstance(0, 0, 0, absCorr );
        
        string offh = ( (t1.hour() < 10) ? '0'+ string.ValueOf( t1.hour()) : string.ValueOf( t1.hour()) );
        string offm = ( (t1.minute() < 10) ? '0'+ string.ValueOf( t1.minute()) : string.ValueOf( t1.minute()) );

        string gmt = local + ( sign == -1 ? '-'+offh+offm :'+'+offh+offm );

        return  gmt;
    } */   
}