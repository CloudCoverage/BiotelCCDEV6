global class ProductForecastBatch implements Database.Batchable<SObject>, Schedulable {
    
    global Boolean updateForecast;
    global Date startDate;
    global Set<String> scopeQuarters; // leveraged to appropriately populate forecast numbers
    global Integer busDaysInForecastPastRange; // number of business days in the period of time from the pulled Daily Sales Records
    global Integer busDaysInForecastFutureRange; // number of business days in the future quarters that the forecast is being applied to
    global List<Product_Forecast__c> failedUpserts;
    global Forecast_and_Pipeline_Setting__c setting;

    // schedulable constructor
    global ProductForecastBatch () {
        Date d = Date.today();
        Date s = Date.newInstance(d.year(), d.month(), 1);
        updateForecast = false;
        // calculate the monthly totals if it's the 3rd business day of the month 
        // 1/3/19 - updated by Tina Fairing, per Liz Watts. Was previously set at 4th business day
        if(getBusDaysBetween(s, d) == 3) {
            updateForecast = true;
        }

        startDate = toStartOfQuarter(d);
        scopeQuarters = quartersList(startDate);
        failedUpserts = new List<Product_Forecast__c>();

        setting = [SELECT Name, Num_of_Previous_Months_for_Forecast_Calc__c, 
            Pipeline_Probability_Cutoff__c, Num_of_Last_Few_Months_That_Cannot_Be_0__c
            FROM Forecast_and_Pipeline_Setting__c
            WHERE Name = 'Default'
            LIMIT 1];

    }
    
    // b = whether to update the forecast or not -- currently only to be true on the first day of each quarter
    // d = date to base the updates on -- would typically send in today, but can be leveraged to back update
    global ProductForecastBatch (Boolean b, Date d) {
        updateForecast = b;
        startDate = toStartOfQuarter(d);
        scopeQuarters = quartersList(startDate);
        failedUpserts = new List<Product_Forecast__c>();

        setting = [SELECT Name, Num_of_Previous_Months_for_Forecast_Calc__c, 
            Pipeline_Probability_Cutoff__c, Num_of_Last_Few_Months_That_Cannot_Be_0__c
            FROM Forecast_and_Pipeline_Setting__c
            WHERE Name = 'Default'
            LIMIT 1];
    }

    global void execute (SchedulableContext SC) {
        Boolean isQuarterStart;
        Integer currentMonthVal = Date.today().month();
        Integer businessDaysPassed = getBusDaysBetween(Date.today().toStartOfMonth(), Date.today());
        if((currentMonthVal == 1 || currentMonthVal == 4 || currentMonthVal == 7 || currentMonthVal == 10) && businessDaysPassed == 3) {
            isQuarterStart = true;
        }
        else {
            isQuarterStart = false;
        }
        ProductForecastBatch b = new ProductForecastBatch(isQuarterStart, Date.today());
        Database.executeBatch(b);
    }
    
    // return existing Product Forecasts in the future
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT Id FROM Account';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accounts) {
        doRun(accounts);
    }

    public void doRun(List<Account> accounts) {
        System.debug('Running batch for ' + accounts.size() + ' Accounts.');
        List<Product_Forecast__c> scope = [SELECT Id, Period__c 
                          FROM Product_Forecast__c 
                          WHERE Period_End__c >= :startDate
                          AND Account__c IN :accounts];

        Map<String, Integer> pipeline = new Map<String, Integer>();
        Map<String, Integer> completedPipeline = new Map<String, Integer>();
        Map<String, Integer> forecast = new Map<String, Integer>();
        List<Opportunity> pipelineOpps = new List<Opportunity>();
        List<Opportunity> completedPipelineOpps = new List<Opportunity>();
        List<Daily_Sales_Record__c> salesRecords = new List<Daily_Sales_Record__c>();
        Map<String, Integer> lastXMonthsCounter;

        if(true){
            // update the pipeline using opportunities from this quarter and the next 3 quarters
            Date pipelineEnd = startDate.addYears(1).addDays(-1);
            busDaysInForecastFutureRange = getBusDaysBetween(startDate, pipelineEnd);

            pipelineOpps = [SELECT Id, Name, AccountId, Derived_Product__c, CloseDate, Projected_Mth_Product_Vol__c,
                                   Q1_Volume__c, Q2_Volume__c, Q3_Volume__c, Q4_Volume__c
                            FROM Opportunity 
                            WHERE Projected_Mth_Product_Vol__c != null 
                            AND Projected_Mth_Product_Vol__c != 0
                            AND Derived_Product__c != null AND Derived_Product__c != 'INR'
                            AND CloseDate >= :startDate
                            AND CloseDate <= :pipelineEnd
                            AND Probability >= :setting.Pipeline_Probability_Cutoff__c
                            AND RecordType.Name = 'Pipeline' 
                            AND AccountId IN :accounts];
            system.debug(pipelineOpps);
        }

        if(updateForecast) {            
            // set last quarter's date range and pull non-Closed/Won Opportunities
            Date completedPipelineEnd = startDate.addDays(-1);
            Date completedPipelineStart = startDate.addMonths(-3);

            completedPipelineOpps = [SELECT Id, Name, AccountId, Derived_Product__c, CloseDate,
                                            Q1_Volume__c, Q2_Volume__c, Q3_Volume__c, Q4_Volume__c
                                    FROM Opportunity
                                    WHERE Projected_Mth_Product_Vol__c != null AND Projected_Mth_Product_Vol__c != 0
                                    AND Derived_Product__c != null AND Derived_Product__c != 'INR'
                                    AND CloseDate <= :completedPipelineEnd 
                                    AND CloseDate >= :completedPipelineStart
                                    AND Probability >= :setting.Pipeline_Probability_Cutoff__c 
                                    AND RecordType.Name = 'Pipeline' 
                                    AND Type != 'Closed/Won'
                                    AND AccountId IN :accounts];
            system.debug(completedPipelineOpps);
        }

        if(updateForecast) {
            // map to hold forecast<map> key and count of how many months in the range were non-zero
            lastXMonthsCounter = new Map<String, Integer>();
            
            // set start and end date of last X months based on custom setting
            Integer monthsBack = Integer.valueOf(setting.Num_of_Previous_Months_for_Forecast_Calc__c * -1);
            Date dsrEndDate = startDate.addDays(-1);
            Date dsrStartDate = startDate.addMonths(monthsBack).toStartOfMonth();
            busDaysInForecastPastRange = getBusDaysBetween(dsrStartDate, dsrEndDate);

            salesRecords = [SELECT Id, Name, Account__c, Product__c, Quantity__c, Date__c 
                            FROM Daily_Sales_Record__c 
                            WHERE Product__c != null AND Product__c != 'INR'
                            AND Quantity__c > 0 
                            AND (Product_subtype_c__c = null OR Product_subtype_c__c = '') 
                            AND Date__c >= :dsrStartDate
                            AND Date__c <= :dsrEndDate
                            AND Account__c IN :accounts]; 
            system.debug(salesRecords);
        }

        // reset existing Product Forecasts to 0 for pipeline and forecast -- used to zero out values when a forecast/pipeline is not pulled
        List<Product_Forecast__c> existingPFs = scope;
        for(Product_Forecast__c pf : existingPFs) {
            Product_Forecast__c p = new Product_Forecast__c(Id = pf.Id);
            for(String q : scopeQuarters) {
                String pfQuarter = q.substringBefore('-');
                String pfYear = q.substringAfter('-');
                Integer quarterValueMin = (Integer.valueOf(pfQuarter.substringAfter('Q')) * 3) -2;
                if(pf.Period__c == pfYear) {
                    pf.put(pfQuarter + '_Pipeline__c', 0);
                    if(updateForecast) pf.put(pfQuarter + '_Forecast__c', 0);
                }
            }
        }
        update existingPFs;

        // ------------ START PIPELINE ------------ //
        if(true) {
            Map<String, Product_Forecast__c> pfsForUUpsert = new Map<String, Product_Forecast__c>();
            Set<Id> successfulUpserts = new Set<Id>();

            for (Opportunity o : pipelineOpps) {
                // map out 4 quarters worth of volume for the Opportunity
                for(Integer i = 0; i < 4; i++){

                    String oppQuarterYear = getQuarterYear(o.CloseDate.addMonths(i*3));
                    String quarter = oppQuarterYear.substringBefore('-');
                    String year = oppQuarterYear.substringAfter('-');
                    String key = o.AccountId + ' | ' + oppQuarterYear + ' || ' + o.Derived_Product__c;

                    if(scopeQuarters.contains(oppQuarterYear)) {
                        Integer value = (pipeline.get(key) == null ? 0 : pipeline.get(key));
                        system.debug('quarter volume test: ' + Integer.valueOf(o.get(quarter+'_Volume__c')));
                        system.debug('proj monthly value test: ' + Integer.valueOf(o.Projected_Mth_Product_Vol__c));
                        if(i == 0) { // on the first quarter of the close date, it may be partial volume
                            if(Integer.valueOf(o.get(quarter+'_Volume__c')) != null)
                                value += Integer.valueOf(o.get(quarter+'_Volume__c'));
                        }
                        else { // all subsequent quarters are 3 months of volume
                            value += Integer.valueOf(Integer.valueOf(o.Projected_Mth_Product_Vol__c) * 3);
                        }

                        system.debug('Pipleline being added for ' +  oppQuarterYear + ' ' + key + ': ' + value);
                        pipeline.put(key, value);
                    }
                    else {
                        system.debug('Pipleline not added for ' +  oppQuarterYear + ' ' + key);
                    }
                }
            }

            // add last quarter's Opportunities to upserts
            for(String key : pipeline.keyset()) {
                String accountId = key.substringBefore(' | ');
                String productName = key.substringAfter(' || ');
                List<String> quarterName = key.substringAfter(' | ').substringBefore(' || ').split('-');
                String pfQuarter = quarterName[0];
                String pfYear = quarterName[1];
                String upsertKey = accountId + ' - ' + productName + ' (' + pfYear + ')';               
                
                Integer pipelineValue = pipeline.get(key);
                
                // simply applies the value to the corresponding quarter
                Product_Forecast__c pf = pfsForUUpsert.get(upsertKey);
                if(pf == null) {
                    pf = new Product_Forecast__c();
                    pf.Upsert_Id__c = upsertKey;
                    pf.Period_End__c = Date.newInstance(Integer.valueOf(pfYear), 12, 31);
                    pf.Product__c = (productName == 'null' || productName == null) ? '' : productName;
                    pf.Account__c = accountId;
                } 
                pf.put(pfQuarter + '_Pipeline__c', pipelineValue);
                
                pfsForUUpsert.put(upsertKey, pf);
            }

            system.debug('||------- pfsForPipelineUpsert ------>' + pfsForUUpsert.values());
            List<Product_Forecast__c> upsertList = new List<Product_Forecast__c>();
            upsertList.addAll(pfsForUUpsert.values());
            Database.UpsertResult[] results = Database.upsert(upsertList, Product_Forecast__c.Fields.Upsert_Id__c, false);
            for(Integer x = 0; x < results.size(); x++) {
                if(!results[x].isSuccess())
                    failedUpserts.add(upsertList[x]);
                else
                    successfulUpserts.add(results[x].getId());
            }
        }

        // ------------ START COMPLETED PIPELINE ------------ //
        // locks in pipeline from the previous quarter to remove Closed/Won when running a quarterly batch
        if(updateForecast) {
            Map<String, Product_Forecast__c> pfsForUUpsert = new Map<String, Product_Forecast__c>();
            Set<Id> successfulUpserts = new Set<Id>();

            // map out last quarter's Opportunities that are not Closed/Won
            for (Opportunity o : completedPipelineOpps) {
                String oppQuarter = getQuarter(o.CloseDate);
                String key = o.AccountId + ' | ' + getQuarterYear(o.CloseDate) + ' || ' + o.Derived_Product__c;

                Integer value = (completedPipeline.get(key) == null) ? 0 : completedPipeline.get(key);
                if(Integer.valueOf(o.get(oppQuarter+'_Volume__c')) != null)
                    value += Integer.valueOf(o.get(oppQuarter+'_Volume__c'));

                system.debug('Completed pipleline putting in key: ' + key + ' : ' + value);
                completedPipeline.put(key, value);
            }

            // add last quarter's Opportunities to upserts
            for(String key : completedPipeline.keyset()) {
                String accountId = key.substringBefore(' | ');
                String productName = key.substringAfter(' || ');
                List<String> quarterName = key.substringAfter(' | ').substringBefore(' || ').split('-');
                String pfQuarter = quarterName[0];
                String pfYear = quarterName[1];
                String upsertKey = accountId + ' - ' + productName + ' (' + pfYear + ')';               
                
                Integer pipelineValue = completedPipeline.get(key);
                
                // simply applies the value to the corresponding quarter
                Product_Forecast__c pf = pfsForUUpsert.get(upsertKey);
                if(pf == null) {
                    pf = new Product_Forecast__c();
                    pf.Upsert_Id__c = upsertKey;
                    pf.Period_End__c = Date.newInstance(Integer.valueOf(pfYear), 12, 31);
                    pf.Product__c = (productName == 'null' || productName == null) ? '' : productName;
                    pf.Account__c = accountId;
                } 
                pf.put(pfQuarter + '_Pipeline__c', pipelineValue);
                
                pfsForUUpsert.put(upsertKey, pf);
            }

            system.debug('||------- pfsForCPipelineUpsert ------>' + pfsForUUpsert.values());
            List<Product_Forecast__c> upsertList = new List<Product_Forecast__c>();
            upsertList.addAll(pfsForUUpsert.values());
            Database.UpsertResult[] results = Database.upsert(upsertList, Product_Forecast__c.Fields.Upsert_Id__c, false);
            for(Integer x = 0; x < results.size(); x++) {
                if(!results[x].isSuccess())
                    failedUpserts.add(upsertList[x]);
                else
                    successfulUpserts.add(results[x].getId());
            }
        }

        

        // ------------ START FORECAST ------------ //
        // update forecast only if running the quarterly batch
        if(updateForecast) {
            Map<String, Product_Forecast__c> pfsForUUpsert = new Map<String, Product_Forecast__c>();
            Set<Id> successfulUpserts = new Set<Id>();

            // change monthsBack to the number of months to look back for non-zeros
            Integer monthsBack = Integer.valueOf(setting.Num_of_Last_Few_Months_That_Cannot_Be_0__c * -1);
            Date dsrValidStartDate = startDate.addMonths(monthsBack).toStartOfMonth();

            // map daily sales records to get a total from the date range per account/product combo
            for (Daily_Sales_Record__c f : salesRecords) {
                String key = f.Account__c + ' | ' + f.Product__c;

                // update how many of the last x months were not zero
                if(f.Quantity__c > 0 && f.Date__c >= dsrValidStartDate){
                    Integer xCount = (lastXMonthsCounter.get(key) == null) ? 1 : (lastXMonthsCounter.get(key) + 1);
                    lastXMonthsCounter.put(key, xCount);
                }

                Integer value = (forecast.get(key) == null) ? 0 : forecast.get(key);
                value += Integer.valueOf(f.Quantity__c);
                forecast.put(key, value);
            }

            // calculate forecast for next 4 quarters
            // forecast is based on averaging sales per day in the last period
            // and applying it to the number of business days in the next period
            for(String key : forecast.keySet()) {
                String accountId = key.substringBefore(' | ');
                String productName = key.substringAfter(' | ');
                Decimal totalSales = Decimal.valueOf(forecast.get(key));

                for(String q : scopeQuarters) {
                    String pfQuarter = q.substringBefore('-');
                    String pfYear = q.substringAfter('-');
                    String upsertKey = accountId + ' - ' + productName + ' (' + pfYear + ')';

                    // determine quarter start and end date to calculate business days in the quarter
                    Decimal pfQuarterValue = Decimal.valueOf(pfQuarter.substringAfter('Q'));
                    Date qStartDate = toStartOfQuarter(Date.newInstance(
                                                            Integer.valueOf(pfYear), // year of the quarter
                                                            Integer.valueOf(Double.valueOf(pfQuarterValue*3)), // quarter # * 3 = last month of a quarter
                                                            1)); // sent to the first day of the quarter using the method toStartOfQuarter
                    Date qEndDate = toEndOfQuarter(qStartDate);
                    Integer projectedForecast = Integer.valueOf(Math.ceil(totalSales * getBusDaysBetween(qStartDate, qEndDate) / busDaysInForecastPastRange));

                    // if the combo hit the most recent month minimum, add Product Forescast to upsert
                    Product_Forecast__c pf = pfsForUUpsert.get(upsertKey);
                    if(lastXMonthsCounter.get(key) != null && lastXMonthsCounter.get(key) > 0) { // met the minimum
                        if(pf == null) { // no exisiting Product Forecast
                            pf = new Product_Forecast__c();
                            pf.Upsert_Id__c = upsertKey;
                            pf.Period_End__c = Date.newInstance(Integer.valueOf(pfYear), 12, 31);
                            pf.Product__c = (productName == 'null' || productName == null) ? '' : productName;
                            pf.Account__c = accountId;
                        }
                        // update value and add back to upsert map
                        pf.put(pfQuarter + '_Forecast__c', projectedForecast);
                        pfsForUUpsert.put(upsertKey, pf);
                    } else if(pf != null) { // did not meet the minimum, but a pf exists
                        pf.put(pfQuarter + '_Forecast__c', 0); // ensure the Forecast value is correctly updated to 0 and add bnack to upsert map
                        pfsForUUpsert.put(upsertKey, pf);
                    }
                }  
            }

            system.debug('||------- pfsForForecastUpsert ------>' + pfsForUUpsert.values());
            List<Product_Forecast__c> upsertList = new List<Product_Forecast__c>();
            upsertList.addAll(pfsForUUpsert.values());
            Database.UpsertResult[] results = Database.upsert(upsertList, Product_Forecast__c.Fields.Upsert_Id__c, false);
            for(Integer x = 0; x < results.size(); x++) {
                if(!results[x].isSuccess())
                    failedUpserts.add(upsertList[x]);
                else
                    successfulUpserts.add(results[x].getId());
            }
        }

        // delete empty Product Forecasts
        deleteEmptyPFs(accounts);
    }
    
    global void finish( Database.BatchableContext BC) {
        system.debug('updateForecast: ' + updateForecast);
        system.debug('startDate: ' + startDate);
        system.debug('scopeQuarters: ' + scopeQuarters);
        system.debug('failedUpserts: ' + failedUpserts);
        system.debug('Batch complete!');
    }

    public void deleteEmptyPFs(List<Account> accounts) {
        List<Product_Forecast__c> pfsForDelete = [
        SELECT Id FROM Product_Forecast__c
        WHERE Account__c IN :accounts
        AND (Q1_Forecast__c = 0 or Q1_Forecast__c = null)
        AND (Q2_Forecast__c = 0 or Q2_Forecast__c = null)
        AND (Q3_Forecast__c = 0 or Q3_Forecast__c = null)
        AND (Q4_Forecast__c = 0 or Q4_Forecast__c = null)
        AND (Q1_Pipeline__c = 0 or Q1_Pipeline__c = null)
        AND (Q2_Pipeline__c = 0 or Q2_Pipeline__c = null)
        AND (Q3_Pipeline__c = 0 or Q3_Pipeline__c = null)
        AND (Q4_Pipeline__c = 0 or Q4_Pipeline__c = null)
        AND (Q1_Adjustment__c = 0 or Q1_Adjustment__c = null)
        AND (Q2_Adjustment__c = 0 or Q2_Adjustment__c = null)
        AND (Q3_Adjustment__c = 0 or Q3_Adjustment__c = null)
        AND (Q4_Adjustment__c = 0 or Q4_Adjustment__c = null)
        ];
        system.debug(pfsForDelete.size() + ' empty PFs are being deleted.');
        delete pfsForDelete;
    }

    // returns in format Q#-YYYY, i,e. Q1-2017
    public String getQuarterYear(Date d) {
        String s = 'Q' + 
            String.valueOf(Math.ceil(Decimal.valueOf(d.month()) / 3).intValue()) 
            + '-' 
            + String.valueOf(d.year());
        return s;
    }

    // returns in format Q#, i,e. Q3
    public String getQuarter(Date d) {
        String s = 'Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.month()) / 3).intValue());
        return s;
    }

    // returns a list of quarters based on the date taken in
    // list of quarters would be current quarter of date and next 3 quarters
    // formats as Q#-YYYY, i.e. Q2-2017
    public Set<String> quartersList(Date d) {
        Set<String> q = new Set<String>();
        q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.month()) / 3).intValue()) + '-' + String.valueOf(d.year()));
        q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.addMonths(3).month()) / 3).intValue()) + '-' + String.valueOf(d.addMonths(3).year()));
        q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.addMonths(6).month()) / 3).intValue()) + '-' + String.valueOf(d.addMonths(6).year()));
        q.add('Q' + String.valueOf(Math.ceil(Decimal.valueOf(d.addMonths(9).month()) / 3).intValue()) + '-' + String.valueOf(d.addMonths(9).year()));
        return q;
    }

    public Integer getBusDaysBetween(Date startdt, Date enddt) {

        Integer i = Math.mod((date.newinstance(1985, 6, 24)).daysBetween(startdt),7); // Monday
        Map<Integer, Map<Integer, Integer>> m = new Map<Integer, Map<Integer, Integer>> {
            0 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 5 , 5 => 5 , 6 => 5 },
            1 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 4 , 5 => 4 , 6 => 5 },
            2 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 3 , 4 => 3 , 5 => 4 , 6 => 5 },
            3 => new Map<Integer, Integer> { 1 => 2 , 2 => 2 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
            4 => new Map<Integer, Integer> { 1 => 1 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
            5 => new Map<Integer, Integer> { 1 => 0 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
            6 => new Map<Integer, Integer> { 1 => 1 , 2 => 2 , 3 => 3 , 4 => 4 , 5 => 5 , 6 => 5 }
        };

        Integer i2 = Math.mod((startdt.daysBetween(enddt)),7);
        Integer i3 = (m.get(i)).get(i2);
        if (i2 == null || i2 < 1 || i2 > 6) {
            if (i >= 0 && i <= 4)
                i3 = 1;
            else 
                i3 = 0;
        }

        i3 = i3 + 5 * (Math.floor( ((Decimal) startdt.daysBetween(enddt)).divide(7,4))).intValue(); 

        return Math.abs(i3);

    }

    // returns the first day of the quarter of the day passed in
    public Date toStartOfQuarter(Date d) {
        Integer quarterStartMonth = (((Math.ceil((Decimal.valueOf(d.month()) / 12) * 4))*3) - 2).intValue();
        return Date.newInstance(d.year(), quarterStartMonth, 1);
    }

    // returns the last day of the quarter of the day passed in
    public Date toEndOfQuarter(Date d) {
        Integer quarterStartMonth = (((Math.ceil((Decimal.valueOf(d.month()) / 12) * 4))*3) - 2).intValue();
        Date e = Date.newInstance(d.year(), quarterStartMonth, 1); // start with first day of current quarter
        e = e.addMonths(3); // first day of next quarter
        e = e.addDays(-1); // last day of current quarter
        return e;
    }

    // maps any relationship field to a list of records from a list that share the lookup
    /*public Map<Id, List<sObject>> mapLookupIdToObjectsList(String fieldAPIName, List<sObject> allObjects) {
        Map<Id, List<sObject>> result = new Map<Id, List<sObject>>();
        
        // send empty list of there are no records in the list
        if(allObjects == null) return result;
        
        // proceed with populating map if there are records in the list
        for(sObject o : allObjects) {
            List<sObject> objects = result.get((String)o.get(fieldAPIName));
            if(objects == null) objects = new List<sObject>{o};
            else objects.add(o);
            result.put((String)o.get(fieldAPIName), objects);
        }
        return result;
    }*/
}