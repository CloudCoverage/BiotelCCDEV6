/* 	Author: Shalimar Caceres, Synaptic Advisory Partners
	Created: March 2017
	Version 1.1 : Updated to exclude year filter, add Pipeline and Forecast as split columns under each quarter
	Version 1.2 : Updated to put Product_Forecast__c in wrapper. Display only current and next 3 quarters only. 
				  Pipeline, Forecast, Andjustment, and Adjusted Forecast under each quarter. 
	Version 1.3 : Updated to perform CRUD checks within the code for security review. 
	Version 1.4 : Updated to check field level editability. If unable to edit, no save operation will be 
				  attempted. The page uses the canSave variable to render the Adjustment as input or output. 
				  On the page, the save button is not rendered without necessary rights. 
	Version 2.1 : Removed dynamic object references that were not required. Refactored to batch on Accounts.  
	Version 2.2 : Add filter option for "All Parent Accounts". Add method to allow AEs to refresh their own Pipeline. 
*/

public with sharing class ForecastWorksheetController {
	public Map<Id, Product_Forecast__c> idToRecordMap;
	public String selectedParentAccount {get; set;}
	public String selectedParentAccountName {get; set;}
	public String selectedAccount {get; set;}
	public Set<String> selectedProductList {get; set;}
	public List<String> addProduct {get; set;}
	public List<String> removeProduct {get; set;}
	public Set<String> selectedAEList {get; set;}
	public List<String> addAE {get; set;}
	public List<String> removeAE {get; set;}
	public Date today {get; set;}
	public List<String> quarters {get; set;}
	public List<dataRow> tableRows {get; set;}
	public Boolean filteredListEmpty {get; set;}
	public Boolean filtersEmpty {get; set;}
	public Boolean noAccess {get; set;}
	public Boolean canSave {get; set;}
	public String reportURL {get; set;}
	public String reportName {get; set;}
	public Map<Integer, List<SelectOption>> allAccountOptions {get; set;}
	public Map<Integer, List<SelectOption>> allParentAccountOptions {get; set;}
	public Integer maxListSize;
	public List<String> searchCriteria;

	public ForecastWorksheetController() {
		maxListSize = 1000;
		idToRecordMap = new Map<Id, Product_Forecast__c>();
		selectedParentAccount = '';
		selectedParentAccountName = '';
		selectedAccount = '';
		selectedProductList = new Set<String>();
		addProduct = new List<String>();
		removeProduct = new List<String>();
		selectedAEList = new Set<String>();
		addAE = new List<String>();
		removeAE = new List<String>();
		today = Date.today(); // run report based on current day
		quarters = quartersList(today);
		setParentAccountOptions();
		setAccountOptions();
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		filteredListEmpty = false;
		filtersEmpty = false;
		searchCriteria = new List<String>();
		checkReadAccess();
		canSave = checkSaveAccess();

		Forecast_and_Pipeline_Setting__c setting = [
			SELECT Worksheet_Report_Name__c, Worksheet_Report_URL__c
            FROM Forecast_and_Pipeline_Setting__c
            WHERE Name = 'Default'
            LIMIT 1];
        if(setting != null) {
        	reportURL = setting.Worksheet_Report_URL__c;
        	reportName = setting.Worksheet_Report_Name__c;
        }
	}

	// builds an entire row for the Account & Product unique combo
	// each row builds the cells as needed and ties them to the Product_Forecast__c Id
	// construct with (List<Product_Forecast__c> records for this row only, Date today, List<String> quarters)
	public class dataRow {
		public String accountExecutive {get; set;}
		public String accountExecutiveFull {get; set;}
		public String accountName {get; set;}
		public String accountId {get; set;}
		public String product {get; set;}
		public List<dataCell> cells {get;set;}
		public Integer forecastTotal {get; set;}
		public Integer pipelineTotal {get; set;}
		public Integer adjustmentTotal {get; set;}
		public Integer adjustedForecastTotal {get; set;}

		public dataRow(List<Product_Forecast__c> rowPFs, List<String> quarters) {
			system.debug('----- Data Row Create ------ rowPFs:' + rowPFs + ' | quarters: ' + quarters);
			// all PFs would have the same unique Account & Product combo
			accountExecutive = rowPFs[0].Account_Executive_Initials__c;
			accountExecutiveFull = rowPFs[0].Account__r.Owner.Name;
			accountName = rowPFs[0].Account__r.Name;
			if(rowPFs[0].Account__r.At_Risk_Start_Date__c != null) accountName = '*' + accountName;
			accountId = rowPFs[0].Account__c;
			product = rowPFs[0].Product__c;

			// populate cells, one for each identified quarter
			cells = new List<dataCell>();
			Map<String, Product_Forecast__c> yearToPF = new Map<String, Product_Forecast__c>();
			for(Product_Forecast__c pf : rowPFs) {
				yearToPF.put(pf.Period__c, pf);
				
			}
			for(String q : quarters) {
				String quarter = q.substringBefore(' '); // just the quarter portion
				String year = q.substringAfter(' '); // just the year portion
				cells.add(new dataCell(yearToPF.get(year), quarter, year, accountId, product));
			}

			updateTotals();
		}

		public void updateTotals() {
			// start totals at zero
			forecastTotal = 0;
			pipelineTotal = 0;
			adjustmentTotal = 0;

			for(dataCell c : cells) {
				forecastTotal += c.forecast;
				pipelineTotal += c.pipeline;
				adjustmentTotal += c.adjustment;
			}

			adjustedForecastTotal = pipelineTotal + forecastTotal + adjustmentTotal;
		}
	}

	// builds a single cell for a dataRow
	// construct with (Product_Forecast__c a single record, String quarter value -- Q1, Q2, Q3, or Q4)
	// must set visualforce page param as objId for each cell for the actionsupport to add it to the modified PFs list
	public class dataCell {
		public Id objId {get; set;}
		public Id accountId {get; set;}
		public String product {get; set;}
		public String quarter {get; set;}
		public String year {get; set;}
		public Integer forecast {get; set;}
		public Integer pipeline {get; set;}
		public Integer adjustment {get; set;}
		public Integer adjustedForecast {get; set;}
		public boolean isEditable {get; set;}

		// create when a pf records exists
		public dataCell(Product_Forecast__c pf, String q, String y, String aId, String p) {
			system.debug('----- Data Cell Create ------ q:' + q + ' | ' + pf);
			quarter = q;
			year = y;
			accountId = aId;
			product = p;

			if(pf == null) {
				forecast = 0;
				pipeline = 0;
				adjustment = 0;
				isEditable = false;
			}
			else {
				objId = pf.Id;
				isEditable = true;

				// set to corresponding quarter's field values
				if(q == 'Q1') {
					forecast = (Integer.valueOf(pf.Q1_Forecast__c) != null) ? Integer.valueOf(pf.Q1_Forecast__c) : 0;
					pipeline = (Integer.valueOf(pf.Q1_Pipeline__c) != null) ? Integer.valueOf(pf.Q1_Pipeline__c) : 0;
					adjustment = (Integer.valueOf(pf.Q1_Adjustment__c) != null) ? Integer.valueOf(pf.Q1_Adjustment__c) : 0;
				} else if(q == 'Q2') {
					forecast = (Integer.valueOf(pf.Q2_Forecast__c) != null) ? Integer.valueOf(pf.Q2_Forecast__c) : 0;
					pipeline = (Integer.valueOf(pf.Q2_Pipeline__c) != null) ? Integer.valueOf(pf.Q2_Pipeline__c) : 0;
					adjustment = (Integer.valueOf(pf.Q2_Adjustment__c) != null) ? Integer.valueOf(pf.Q2_Adjustment__c) : 0;
				} else if(q == 'Q3') {
					forecast = (Integer.valueOf(pf.Q3_Forecast__c) != null) ? Integer.valueOf(pf.Q3_Forecast__c) : 0;
					pipeline = (Integer.valueOf(pf.Q3_Pipeline__c) != null) ? Integer.valueOf(pf.Q3_Pipeline__c) : 0;
					adjustment = (Integer.valueOf(pf.Q3_Adjustment__c) != null) ? Integer.valueOf(pf.Q3_Adjustment__c) : 0;
				} else {
					forecast = (Integer.valueOf(pf.Q4_Forecast__c) != null) ? Integer.valueOf(pf.Q4_Forecast__c) : 0;
					pipeline = (Integer.valueOf(pf.Q4_Pipeline__c) != null) ? Integer.valueOf(pf.Q4_Pipeline__c) : 0;
					adjustment = (Integer.valueOf(pf.Q4_Adjustment__c) != null) ? Integer.valueOf(pf.Q4_Adjustment__c) : 0;
				}
			}
			
			adjustedForecast = forecast + adjustment + pipeline;
		}
	}

	// returns a list of quarters based on the date taken in
	// list of quarters would be current quarter of date and next 3 quarters
	// formats as Q# YYYY, i.e. Q2 2017
	public List<String> quartersList(Date d) {
		List<String> q = new List<String>();
		q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.month()) / 3).intValue()) + ' ' + String.valueOf(d.year()));
		q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.addMonths(3).month()) / 3).intValue()) + ' ' + String.valueOf(d.addMonths(3).year()));
		q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.addMonths(6).month()) / 3).intValue()) + ' ' + String.valueOf(d.addMonths(6).year()));
		q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.addMonths(9).month()) / 3).intValue()) + ' ' + String.valueOf(d.addMonths(9).year()));
		return q;
	}

	// all records where the period end is greater than today
	// batch will ensure that the future records are limited accordingly
	public void setRecords() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		String whereClause = getSearchClause();
		if(whereClause != null) {
			String query = 'SELECT Id, Account__c, Product__c, Period_End__c, Period__c, Account_Executive_Initials__c, Account__r.At_Risk_Start_Date__c, '
						 + 'Account__r.Name, Account__r.OwnerId, Account__r.Owner.Name, Account__r.ParentId, Account__r.Parent.Name, Upsert_Id__c, '
						 + 'Q1_Forecast__c, Q2_Forecast__c, Q3_Forecast__c, Q4_Forecast__c, Total_Forecast__c, '
						 + 'Q1_Pipeline__c, Q2_Pipeline__c, Q3_Pipeline__c, Q4_Pipeline__c, Total_Pipeline__c, '
						 + 'Q1_Adjustment__c, Q2_Adjustment__c, Q3_Adjustment__c, Q4_Adjustment__c, Total_Adjustment__c '
						 + 'FROM Product_Forecast__c '
						 + whereClause + ' '
						 + 'ORDER BY Period__c, Account_Executive_Initials__c, Account__r.Name, Product__c ASC';
			List<Product_Forecast__c> filteredPFs = Database.query(query);
			idToRecordMap = new Map<Id, Product_Forecast__c>(filteredPFs);
		}
		else {
			idToRecordMap = new Map<Id, Product_Forecast__c>();
		}
		setAccountOptions();
	}

	// narrows records based on the given parent account
	public List<Product_Forecast__c> filteredRecords() {
		System.debug('Limits status before filtering: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		setRecords();
		if(idToRecordMap.values().size() > 0 || filtersEmpty) filteredListEmpty = false;
		else filteredListEmpty = true;
		System.debug('Limits status after filtering: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		return idToRecordMap.values();
	}

	// put together the WHERE clause for the records we will query
	public String getSearchClause() {
		System.debug('Filter selectedParentAccount? ' + selectedParentAccount);
		System.debug('Filter selectedAccount? ' + selectedAccount);
		System.debug('Filter selectedAEList? ' + selectedAEList);
		System.debug('Filter selectedProductList? ' + selectedProductList);
		List<String> searchCriteria = new List<String>();
		if(!String.isBlank(selectedParentAccount) && selectedParentAccount != 'ALL' && selectedParentAccount != '-') 
			searchCriteria.add('Account__r.ParentId = :selectedParentAccount');
		if(selectedParentAccount == '-') 
			searchCriteria.add('Account__r.ParentId = null');
		if(!String.isBlank(selectedAccount) && selectedAccount != '-') 
			searchCriteria.add('Account__c = :selectedAccount');
		if(!selectedProductList.isEmpty()) 
			searchCriteria.add('Product__c IN :selectedProductList');
		if(!selectedAEList.isEmpty()) 
			searchCriteria.add('Account__r.Owner.Name IN :selectedAEList');
		if(searchCriteria.size() < 1) {
			filtersEmpty = true;
			return null;
		}


		filtersEmpty = false;
		String searchClause = 'WHERE Period_End__c >= :today AND ' + String.join(searchCriteria, ' AND ');
		System.debug('Filter search criteria: ' + searchClause);
		return searchClause;
	}

	// returns list of rows for VF page
	public void updateTableRows() { 
		system.debug('Updating table rows...');
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		List<dataRow> allRows = new List<dataRow>();
		Map<String, List<Product_Forecast__c>> rowsAndPFs = new Map<String, List<Product_Forecast__c>>();
		selectedParentAccountName = '';

		for(Product_Forecast__c f : filteredRecords()) {
			if (selectedParentAccountName == '' && f.Account__r.Parent.Name != null) selectedParentAccountName = f.Account__r.Parent.Name;
			List<Product_Forecast__c> pfs = (rowsAndPFs.get(f.Account__r.Name + '---' + f.Product__c) == null) ? new List<Product_Forecast__c>() : rowsAndPFs.get(f.Account__r.Name + '---' + f.Product__c);
			pfs.add(f);
			rowsAndPFs.put(f.Account__r.Name + '---' + f.Product__c, pfs);
		}

		system.debug('rowsAndPFs prio to create----' + rowsAndPFs);
		for(String s : rowsAndPFs.keyset()) {
			allRows.add(new dataRow(rowsAndPFs.get(s), quarters));
		}

		tableRows = allRows;
		setParentAccountOptions();
		setAccountOptions();
	}

	public void setAccountOptions() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		Map<String, String> accountOptions = new Map<String, String>();
		if(String.isBlank(selectedParentAccount) || selectedParentAccount == 'ALL') {
			/*// aggregate Account Ids
			AggregateResult[] agr = [SELECT Account__c a, Count(Id)
										        FROM Product_Forecast__c 
										        WHERE Period_End__c >= :today
										        GROUP BY Account__c];
			// add to list for query
			List<Id> acctIds = new List<Id>();
			for (AggregateResult ar : agr)  {
			    acctIds.add(String.valueOf(ar.get('a')));
			}

			// add to account options
			for(Account a : [SELECT Id, Name FROM Account WHERE Id IN: acctIds]) {
				accountOptions.put(a.Name, a.Id);
			}*/
			accountOptions.put('Select a Parent Account First', '');
		}
		else {
			for(Product_Forecast__c pf : idToRecordMap.values()) {
				if((selectedParentAccount == '-'  && pf.Account__r.ParentId == null) || 
					(selectedParentAccount != '-' && (selectedParentAccount == '' || selectedParentAccount == null || pf.Account__r.ParentId == selectedParentAccount)))
					accountOptions.put(pf.Account__r.Name, pf.Account__c);
			}
		}

		List<String> sortedList = new List<String>();
		for(String s : accountOptions.keySet()) {
			sortedList.add(s);
		}
		sortedList.sort();

		Map<Integer, List<SelectOption>> allOptions = new Map<Integer, List<SelectOption>>();
		Integer optionsSoFar = 1;
		List<SelectOption> options = new List<SelectOption>();
		if(!accountOptions.containsKey('Select a Parent Account First')) 
			options.add(new SelectOption('', 'Location'));
		// add Accounts in groups of 1000
		for(String s : sortedList) {
			if(s != null) {
				options.add(new SelectOption(accountOptions.get(s), s));
				optionsSoFar++;
				if(optionsSoFar == maxListSize) {
					allOptions.put(allOptions.size(), options);
					options = new List<SelectOption>();
					optionsSoFar = 0;
				}
			}
		}
		// add remainder of Accounts
		if(optionsSoFar > 0) {
			allOptions.put(allOptions.size(), options);
		}

		// make the list 20 long, if it's not already --  MAX is 20,000 Accounts
		while(allOptions.size() < 20) allOptions.put(allOptions.size(), new List<SelectOption>());

		allAccountOptions = allOptions;
		
	}

	public void setParentAccountOptions() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		Map<String, String> pAccountOptions = new Map<String, String>();
		// aggregate Account Ids
		AggregateResult[] agr = [SELECT Account__r.ParentId pId, Count(Id) 
						         FROM Product_Forecast__c 
						         WHERE Period_End__c >= :today AND Account__r.ParentId != null
						         GROUP BY Account__r.ParentId];
		// add to list for query
		List<Id> acctIds = new List<Id>();
		for (AggregateResult ar : agr)  {
		    acctIds.add(String.valueOf(ar.get('pId')));
		}

		// add to account options
		for(Account a : [SELECT Id, Name FROM Account WHERE Id IN :acctIds]) {
			pAccountOptions.put(a.Name, a.Id);
		}

		List<String> sortedList = new List<String>();
		for(String s : pAccountOptions.keySet()) {
			sortedList.add(s);
		}
		sortedList.sort();

		Map<Integer, List<SelectOption>> allOptions = new Map<Integer, List<SelectOption>>();
		Integer optionsSoFar = 2;
		List<SelectOption> options = new List<SelectOption>();
		// add Accounts in groups of 1000
		options.add(new SelectOption('ALL', '- All Parent Accounts -'));
		options.add(new SelectOption('-', '- No Parent -'));
		for(String s : sortedList) {
			if(s != null) {
				options.add(new SelectOption(pAccountOptions.get(s), s));
				optionsSoFar++;
				if(optionsSoFar == maxListSize) {
					allOptions.put(allOptions.size(), options);
					options = new List<SelectOption>();
					optionsSoFar = 0;
				}
			}
		}
		// add remainder of Accounts
		if(optionsSoFar > 0) {
			allOptions.put(allOptions.size(), options);
		}

		// make the list 10 long, if it's not already --  MAX is 10,000 Accounts
		while(allOptions.size() < 10) allOptions.put(allOptions.size(), new List<SelectOption>());

		allParentAccountOptions = allOptions;
	}

	public List<SelectOption> getAvailableProducts() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		Set<String> productOptions = new Set<String>();
		if(String.isBlank(selectedParentAccount) || selectedParentAccount == 'ALL') {
			// aggregate Product Names
			AggregateResult[] agr = [SELECT Product__c p, Count(Id)
							         FROM Product_Forecast__c 
							         WHERE Period_End__c >= :today
							         GROUP BY Product__c];
			// add to list for query
			for (AggregateResult ar : agr)  {
				productOptions.add(String.valueOf(ar.get('p')));
			}
		}
		else {
			for(Product_Forecast__c pf : idToRecordMap.values()) {
				if(!selectedProductList.contains(pf.Product__c)){
					if((selectedParentAccount == '-'  && pf.Account__r.ParentId == null) || 
						(selectedParentAccount != '-' && (selectedParentAccount == '' || selectedParentAccount == null || pf.Account__r.ParentId == selectedParentAccount)))
							productOptions.add(pf.Product__c);
				}
			}
		}

		List<SelectOption> options = new List<SelectOption>();
		for(String s : productOptions) {
			if(s != null && !selectedProductList.contains(s))
				options.add(new SelectOption(s, s));
		}

		options.sort();
		return options;
	}

	public List<SelectOption> getSelectedProducts() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		List<SelectOption> options = new List<SelectOption>();
		for(String s : selectedProductList) {
			if(s != null)
				options.add(new SelectOption(s, s));
		}

		options.sort();
		return options;
	}

	public void addSelectedProduct() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		system.debug('Add product: ' + addProduct);
		selectedProductList.addAll(addProduct);
		system.debug('Selected product list: ' + selectedProductList);
	}

	public void removeSelectedProduct() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		system.debug('Remove product: ' + removeProduct);
		selectedProductList.removeAll(removeProduct);
		system.debug('Selected product list: ' + selectedProductList);
	}

	public List<SelectOption> getAvailableAEs() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		Set<String> aeOptions = new Set<String>();
		if(String.isBlank(selectedParentAccount) || selectedParentAccount == 'ALL') {
			// aggregate AE Ids
			AggregateResult[] agr = [SELECT Account__r.OwnerId ae, Count(Id)
							         FROM Product_Forecast__c 
							         WHERE Period_End__c >= :today
							         GROUP BY Account__r.OwnerId ];
			// add to list for query
			List<Id> aeIds = new List<Id>();
			for (AggregateResult ar : agr)  {
				aeIds.add(String.valueOf(ar.get('ae')));
			}
			for(User u : [SELECT Id, Name FROM User WHERE Id IN :aeIds]) {
				if(!selectedAEList.contains(u.Id)){
					aeOptions.add(u.Name);
				}
			}
		}
		else {
			for(Product_Forecast__c pf : idToRecordMap.values()) {
				if(!selectedAEList.contains(pf.Account__r.OwnerId)){
					if((selectedParentAccount == '-'  && pf.Account__r.ParentId == null) || 
						(selectedParentAccount != '-' && (selectedParentAccount == '' || selectedParentAccount == null || pf.Account__r.ParentId == selectedParentAccount)))
							aeOptions.add(pf.Account__r.Owner.Name);
				}
			}
		}

		List<SelectOption> options = new List<SelectOption>();
		for(String s : aeOptions) {
			if(s != null && !selectedAEList.contains(s))
				options.add(new SelectOption(s, s));
		}

		options.sort();
		return options;
	}

	public List<SelectOption> getSelectedAEs() {
		System.debug('Limits status: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
		List<SelectOption> options = new List<SelectOption>();
		for(String s : selectedAEList) {
			if(s != null)
				options.add(new SelectOption(s, s));
		}

		options.sort();
		return options;
	}

	public void addSelectedAE() {
		system.debug('Add AE: ' + addAE);
		selectedAEList.addAll(addAE);
		system.debug('Selected AE list: ' + selectedAEList);
	}

	public void removeSelectedAE() {
		system.debug('Remove AE: ' + removeAE);
		selectedAEList.removeAll(removeAE);
		system.debug('Selected AE list: ' + selectedAEList);
	}

	public PageReference updateRecords() {
		updateTableRows();
		return null;
	}

	// reset the variables for the filters, except Parent Account, which should stay as is
	public PageReference clearFilters() {
		selectedAccount = '';
		selectedProductList.clear();
		selectedAEList.clear();
		updateTableRows();
		return null;
	}

	// loop through filtered records and add the touched ones to a list for update
	public PageReference save() {
		if(canSave) {

			Map<Id, Product_Forecast__c> forecastsForUpdate = new Map<Id, Product_Forecast__c>(); 
			for(dataRow d : tableRows) {
				for(dataCell c : d.cells) {

					Product_Forecast__c p = idToRecordMap.get(c.objId);

					// if the Product Forecast record exists, update it, otherwise create and upsert a new one
					if(p != null && p.get(c.quarter + '_Adjustment__c') != c.adjustment){
						Product_Forecast__c pf = new Product_Forecast__c(
							Id = p.Id,
							Upsert_Id__c = p.Upsert_Id__c
						);
						pf.put(c.quarter + '_Adjustment__c', c.adjustment);
						//idToRecordMap.put(p.Id, p); // put back in map to save updated record for the next time it's pulled
						forecastsForUpdate.put(pf.Id, pf);
					}
					else if(p == null && c.adjustment != 0 && c.adjustment != null) {
	                	String upsertKey = c.accountId + ' - ' + c.product + ' (' + c.year + ')';
						p = new Product_Forecast__c();
						p.Account__c = c.accountId;
						p.Product__c = c.product;
						p.put(c.quarter + '_Adjustment__c', c.adjustment);
						p.Period_End__c = Date.newInstance(Integer.valueOf(c.year), 12, 31);
						p.Upsert_Id__c = upsertKey;
						upsert p Upsert_Id__c;
					}
				}
				
			}

			//List<Product_Forecast__c> updateList = new List<Product_Forecast__c>();
			system.debug('----------forecastsForUpdate------ ' + forecastsForUpdate);
			update forecastsForUpdate.values();
			setRecords();
			updateTableRows();
		}

		return null;
	}

	// user must have rights to view all referenced fields in the object to simply view the page
	public void checkReadAccess() {
		if(	Schema.sObjectType.Product_Forecast__c.isAccessible() &&
            Schema.sObjectType.Product_Forecast__c.fields.Upsert_Id__c.isAccessible() && 
            Schema.sObjectType.Product_Forecast__c.fields.Period_End__c.isAccessible() && 
            Schema.sObjectType.Product_Forecast__c.fields.Product__c.isAccessible() && 
            Schema.sObjectType.Product_Forecast__c.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Product_Forecast__c.fields.Period__c.isAccessible() && 
            Schema.sObjectType.Product_Forecast__c.fields.Account_Executive_Initials__c.isAccessible() && 
			Schema.sObjectType.Product_Forecast__c.fields.Q1_Adjustment__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q2_Adjustment__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q3_Adjustment__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q4_Adjustment__c.isAccessible() && 
			Schema.sObjectType.Product_Forecast__c.fields.Q1_Forecast__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q2_Forecast__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q3_Forecast__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q4_Forecast__c.isAccessible() && 
			Schema.sObjectType.Product_Forecast__c.fields.Q1_Pipeline__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q2_Pipeline__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q3_Pipeline__c.isAccessible() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q4_Pipeline__c.isAccessible()
		 	) {
			noAccess = false;
		}
		else {
			noAccess = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You do not have the minimum user rights needed to use this page. Please contact your administrator for assistance.'));
		}
	}

	// user must have rights to create and update the PF
	public boolean checkSaveAccess() {
		if(	Schema.sObjectType.Product_Forecast__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.isUpdateable() &&
            Schema.sObjectType.Product_Forecast__c.fields.Upsert_Id__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.fields.Upsert_Id__c.isUpdateable() &&
            Schema.sObjectType.Product_Forecast__c.fields.Period_End__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.fields.Period_End__c.isUpdateable() &&
            Schema.sObjectType.Product_Forecast__c.fields.Product__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.fields.Product__c.isUpdateable() &&
            Schema.sObjectType.Product_Forecast__c.fields.Account__c.isCreateable() && 
			Schema.sObjectType.Product_Forecast__c.fields.Q1_Adjustment__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.fields.Q1_Adjustment__c.isUpdateable() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q2_Adjustment__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.fields.Q2_Adjustment__c.isUpdateable() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q3_Adjustment__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.fields.Q3_Adjustment__c.isUpdateable() && 
		 	Schema.sObjectType.Product_Forecast__c.fields.Q4_Adjustment__c.isCreateable() && Schema.sObjectType.Product_Forecast__c.fields.Q4_Adjustment__c.isUpdateable() 
		 	) {
			return true;
		}
		else {
			return false;
		}
	}

	/*public void scheduleBatch() {
		try{
			List<CronTrigger> job = [SELECT CronJobDetail.Name, TimesTriggered, NextFireTime, PreviousFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Product Forecast Batch'];
			if(job.isEmpty()) {
				ProductForecastBatch pfb = new ProductForecastBatch();
				String sch = '0 0 1 ? * *'; // 1am every day
				String jobID = system.schedule('Product Forecast Batch', sch, pfb);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The batch is now scheduled!'));
			} else {
				String message = job[0].CronjobDetail.Name + ' is currently scheduled. The next run will be: ' + job[0].NextFireTime.format() + '.';
				if(job[0].PreviousFireTime != null) message += 'The last run was: ' + job[0].PreviousFireTime.format() + '. The batch has run a total of ' + job[0].TimesTriggered + ' times.';
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
			}

			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'An unknown error has ocurred: ' + e));
			}
	}*/

	public void runAEBatch() {
		try{
			// leverage batch to run for this AE's Accounts to update records
			ProductForecastBatch b = new ProductForecastBatch(true, Date.today());
			b.doRun([SELECT Id FROM Account WHERE OwnerId = :UserInfo.getUserId()]);

			// refresh data on the page and refilter
			setRecords();
			updateTableRows();
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'An unknown error has ocurred: ' + e));
		}
	}

}