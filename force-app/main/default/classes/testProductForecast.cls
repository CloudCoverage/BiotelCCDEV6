@isTest
public class testProductForecast {
	private static final Date runDate = Date.newInstance(2017, 6, 22);

	@TestSetup
	public static void TestSetup() {
		Forecast_and_Pipeline_Setting__c setting = new Forecast_and_Pipeline_Setting__c(
			Name = 'Default',
			Num_of_Previous_Months_for_Forecast_Calc__c = 6,
			Pipeline_Probability_Cutoff__c = 0.70,
			Num_of_Last_Few_Months_That_Cannot_Be_0__c = 3
		);
		insert setting;

		// Parent Accounts
		Account fp1 = new Account(Name = 'Test 1');
		insert fp1;
		Account fp2 = new Account(Name = 'Test 2');
		insert fp2;

		// Child Accounts
		List<Account> accounts = new List<Account>();
		Account fa1 = new Account(
			Name = 'Test 3',
			ParentId = fp1.Id
		); accounts.add(fa1);
		Account fa2 = new Account(
			Name = 'Test 4',
			ParentId = fp1.Id
		); accounts.add(fa2);
		Account fa3 = new Account(
			Name = 'Test 5',
			ParentId = fp2.Id
		); accounts.add(fa3);
		Account fa4 = new Account(
			Name = 'Test 6',
			ParentId = fp2.Id
		); accounts.add(fa4);
		insert accounts;

		List<String> products = new List<String>{
			'Event', 
			'mCot',
			'Holter'
		};

		// empty PF
		Product_Forecast__c pf = new Product_Forecast__c(
			Account__c = fa1.Id,
			Period_End__c = runDate
		); insert pf;

		List<Enrolled_Service__c> services = new List<Enrolled_Service__c>();
		Enrolled_Service__c s1 = new Enrolled_Service__c(
			Account__c = fa1.Id,
			Product__c = 'Event'
		); services.add(s1);
		Enrolled_Service__c s2 = new Enrolled_Service__c(
			Account__c = fa2.Id,
			Product__c = 'mCot'
		); services.add(s2);
		Enrolled_Service__c s3 = new Enrolled_Service__c(
			Account__c = fa3.Id,
			Product__c = 'Event'
		); services.add(s3);
		Enrolled_Service__c s4 = new Enrolled_Service__c(
			Account__c = fa4.Id,
			Product__c = 'Holter'
		); services.add(s4);
		insert services;
		
		List<Daily_Sales_Record__c> salesRecords = new List<Daily_Sales_Record__c>();
		Integer i = 0;
		Integer ai = 0;
		for(Account a : accounts) {
			for(Integer x = 0; x < 12; x++)	{
				Integer monthsToAdd = x * -1;
				Daily_Sales_Record__c dsr = new Daily_Sales_Record__c(
					Account__c = a.Id,
					Product__c = products[Math.mod(i,3)],
					Quantity__c = (x + 3) * 2,
					Date__c = runDate.addMonths(monthsToAdd),
					Service__c = services[ai].Id
				);
				salesRecords.add(dsr);
				i++;
			}
			ai++;
		}
		insert salesRecords;

		Id pipelineRID = [SELECT Id 
						  FROM RecordType 
						  WHERE DeveloperName = 'Pipeline'
						  AND SobjectType = 'Opportunity'
						  LIMIT 1].Id;
		Opportunity po1 = new Opportunity(
			RecordTypeId = pipelineRID,
			Name = 'Opp 1',
			StageName = 'Approach/Prospecting',
			AccountId = fa3.Id,
			Product__c = 'Event',
			Product_Group__c = 'Event',
			Event_Potential_Volume__c = 100,
			Estimated_Monthly_Volume__c = 100,
			CloseDate = runDate.addMonths(1)
		); insert po1;

		Opportunity po2 = new Opportunity(
			RecordTypeId = pipelineRID,
			Name = 'Opp 1',
			StageName = 'Won/Prescribing Targeted Service',
			AccountId = fa3.Id,
			Product__c = 'Holter',
			Product_Group__c = 'Holter',
			Holter_Potential_Volume__c = 211,
			Estimated_Monthly_Volume__c = 211,
			CloseDate = runDate.addMonths(-3)
		); insert po2;

		Opportunity po3 = new Opportunity(
			RecordTypeId = pipelineRID,
			Name = 'Opp 1',
			StageName = 'Validate/BAA Contracting',
			AccountId = fa4.Id,
			Product__c = 'Event',
			Product_Group__c = 'Event',
			Event_Potential_Volume__c = 320,
			Estimated_Monthly_Volume__c = 320,
			CloseDate = runDate.addMonths(2)
		); insert po3;

		Opportunity po4 = new Opportunity(
			RecordTypeId = pipelineRID,
			Name = 'Opp 1',
			StageName = 'Lost/Inactive',
			AccountId = fa4.Id,
			Product__c = 'Holter',
			Product_Group__c = 'Holter',
			Holter_Potential_Volume__c = 600,
			Estimated_Monthly_Volume__c = 600,
			CloseDate = runDate
		); insert po4;

		Opportunity po5 = new Opportunity(
			RecordTypeId = pipelineRID,
			Name = 'Opp 1',
			StageName = 'Negotiate/In-service',
			AccountId = fa3.Id,
			Product__c = 'Holter',
			Product_Group__c = 'Holter',
			Holter_Potential_Volume__c = 77,
			Estimated_Monthly_Volume__c = 77,
			CloseDate = runDate.addMonths(-3)
		); insert po5;

		Opportunity po6 = new Opportunity(
			RecordTypeId = pipelineRID,
			Name = 'Opp 1',
			StageName = 'Won/Prescribing Targeted Service',
			AccountId = fa4.Id,
			Product__c = 'Event',
			Event_Potential_Volume__c = 574,
			Estimated_Monthly_Volume__c = 574,
			CloseDate = runDate
		); insert po6;

	}

	public static testmethod void testBatch() {

		// test batch
		Test.startTest();
		ProductForecastBatch b = new ProductForecastBatch(true, runDate);
		system.assert(b.startDate == Date.newInstance(2017, 4, 1), 'Startdate is not first day of current quarter: ' + b.startDate);
		Database.executeBatch(b);
		Test.stopTest();

		// test scheduling
		String jobId = System.schedule('Test Forecast Batch', '0 0 0 * * ? ', new ProductForecastBatch()); // test scheduling

	}

	public static testmethod void testController() {

		// create records for testing the page
		Test.startTest();
		ProductForecastBatch b = new ProductForecastBatch(true, runDate);
		Database.executeBatch(b);
		Test.stopTest();

		// test worksheet page
		PageReference wkst = Page.ForecastWorksheet;
		Test.setCurrentPage(wkst);
		ForecastWorksheetController fw = new ForecastWorksheetController();
		fw.runAEBatch();
		fw.today = runDate;
		fw.maxListSize = 1;
		fw.setRecords();

		// test parent account filtering
		fw.setParentAccountOptions();
		fw.selectedParentAccount = '-';
		fw.updateRecords();
		fw.getAvailableAEs();
		fw.setAccountOptions();
		fw.getAvailableProducts();

		System.assert(fw.tableRows.size() == 0, 
			'selectedParentAccount: ' + fw.selectedParentAccount + 
			'\n\nFiltered Records: ' + fw.tableRows + 
			'\n\nRecords: ' + fw.idToRecordMap.values());

		Product_Forecast__c getTestParent = [SELECT Account__r.ParentId FROM Product_Forecast__c WHERE Account__r.ParentId != null LIMIT 1];

		// test all parent account filtering with no filters
		fw.clearFilters();
		fw.selectedParentAccount = 'ALL';
		fw.updateRecords();
		fw.getAvailableAEs();
		fw.getAvailableProducts();

		System.assert(fw.tableRows.size() == 0, 
			'selectedParentAccount: ' + fw.selectedParentAccount + 
			'\n\nFiltered Records: ' + fw.tableRows + 
			'\n\nRecords: ' + fw.idToRecordMap.values());

		// test parent account filtering
		fw.selectedParentAccount = getTestParent.Account__r.ParentId;
		fw.updateRecords();
		fw.setAccountOptions();
		fw.getAvailableAEs();
		fw.getAvailableProducts();

		System.assert(fw.tableRows.size() > 0, 
			'selectedParentAccount: ' + fw.selectedParentAccount + 
			'\n\nFiltered Records: ' + fw.tableRows + 
			'\n\nRecords: ' + fw.idToRecordMap.values());

		// test save
		fw.clearFilters();
		fw.tableRows[0].cells[0].adjustment = 4;
		fw.save();

		// test AE selection and updating
		fw.getAvailableAEs();
		fw.addAE = new List<String>{''};
		fw.addSelectedAE();
		fw.getSelectedAEs();
		fw.removeAE = new List<String>{''};
		fw.removeSelectedAE();
		fw.updateRecords();

		// test Product selection and updating
		fw.clearFilters();
		fw.getAvailableProducts();
		fw.addProduct = new List<String>{'Event', null};
		fw.addSelectedProduct();
		fw.updateRecords();
		fw.getSelectedProducts();
		fw.getAvailableProducts();
		fw.removeProduct = new List<String>{'Event', null};
		fw.removeSelectedProduct();
		fw.updateRecords();

		// test account filtering
		Account fa1 = [SELECT Id FROM Account WHERE Name = 'Test 3'];
		fw.clearFilters();
		fw.setAccountOptions();
		fw.selectedAccount = fa1.Id;
		fw.updateRecords();

		// make filtered list empty
		fw.addProduct = new List<String>{'Bad'};
		fw.addSelectedProduct();
		fw.updateRecords();

		


	}

}