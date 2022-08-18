@isTest(seeAllData=false)
public class HolidayUtilTest {
    static testmethod void test1(){
        Date bDate = Date.newInstance(2021, 01, 01);
        Date eDate = Date.newInstance(2021, 01, 5);

        Date hbegin = Date.newInstance(2021, 01, 01);
        Date hend = Date.newInstance(2021, 12, 31);
        Date christmas = Date.newInstance(2021, 12, 31);
        Date thanksgiving = Date.newInstance(2021, 12, 31);

        /*
NAME	ISALLDAY	ACTIVITYDATE	ISRECURRENCE	RECURRENCESTARTDATE	RECURRENCEENDDATEONLY	RECURRENCETYPE	RECURRENCEDAYOFWEEKMASK	RECURRENCEDAYOFMONTH	RECURRENCEINSTANCE	RECURRENCEMONTHOFYEAR
New Years	TRUE	2021-01-01	TRUE	2021-01-01	2030-01-01	RecursYearly	null	1	null	January
Christmas	TRUE	2021-12-25	TRUE	2021-12-25	2030-12-25	RecursYearly	null	25	null	December
Thanksgiving	TRUE	2021-11-29	TRUE	2021-11-29	null	RecursEveryWeekday	62	null	null	null

*/
        Holiday h1 = new Holiday(
            NAME= 'New Year',
            ISALLDAY = true,
            ACTIVITYDATE = christmas,
            ISRECURRENCE = true,	
            RECURRENCESTARTDATE = hbegin,
            RECURRENCEENDDATEONLY = hend,	
            RECURRENCETYPE = 'RecursYearly',	
            RECURRENCEDAYOFMONTH = 1,
            RECURRENCEMONTHOFYEAR = 'January'
        );  
        
        Holiday h2 = new Holiday(
            NAME= 'New Year',
            ISALLDAY = true,
            ACTIVITYDATE = thanksgiving,
            ISRECURRENCE = true,	
            RECURRENCESTARTDATE = hbegin,
            RECURRENCEENDDATEONLY = hend,	
            RECURRENCETYPE = 'RecursYearly',	
            RECURRENCEDAYOFMONTH = 27,
            RECURRENCEMONTHOFYEAR = 'November'
        );         

        List<Holiday> h = new List<Holiday>();
        h.add(h1);
        h.add(h2);
        insert h;
        System.debug(JSON.serializePretty(h));
        
        HolidayUtil.getYears(bDate, eDate);
        HolidayUtil.getHolidaysForDates(bDate, eDate);
        HolidayUtil.seperateBitMask(64);
        HolidayUtil.getBitMaskMap();
        HolidayUtil.getYearlyHoliday(h[1], bDate, eDate);
        HolidayUtil.getYearlyNthHoliday(h[1], bDate, eDate);
        HolidayUtil.getMonthlyHoliday(h[1], bDate, eDate);
        HolidayUtil.getMonthlyNthHoliday(h[1], bDate, eDate);
        //HolidayUtil.getWeeklyHoliday(h[1], bDate, eDate);
        //HolidayUtil.getDailyHoliday(h[1], bDate, eDate);
        HolidayUtil.getLastXOfMonth(1, 1, 2021);
        
    }
}