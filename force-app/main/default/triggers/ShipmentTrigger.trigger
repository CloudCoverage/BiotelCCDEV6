trigger ShipmentTrigger on Shipment__c (after insert, after update) {
	system.debug('ShipmentTrigger');
    new ShipmentTriggerHandler().run();
}