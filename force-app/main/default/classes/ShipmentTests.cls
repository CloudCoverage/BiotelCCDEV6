@isTest
public class ShipmentTests {

	@isTest
	static void test_method_1(){
        Account a = new Account();
        a.Name = 'Test Account';
        a.Type = 'Practice';
        a.Sub_Type__c = 'Family Practice';
        insert a;
        
        Order o = new Order();
        o.AccountId = a.Id;
        o.EffectiveDate = Date.today();
        o.Status = 'Submitted';
        insert o;
        
        Shipment__c shipment = new Shipment__c();
        shipment.Enrollment__c = o.Id;

        insert shipment;
        
        shipment.Status__c = 'Completed';
        
        update shipment;
        
        Shipment_Item__c shipmentItem = new Shipment_Item__c();
        shipmentItem.Shipment__c = shipment.Id;
        insert shipmentItem;
        
        shipmentItem.Asset_Serial_Number__c = 'ABC';
        update shipmentItem;
    }
}