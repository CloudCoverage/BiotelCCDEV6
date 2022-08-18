trigger ShipmentItemTrigger on Shipment_Item__c (after insert,after update) {
	system.debug('ShipmentItemTrigger');
    new ShipmentItemTriggerHandler().run();
}