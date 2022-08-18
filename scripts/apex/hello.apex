//MiddlewareUtil.getPayer();
//System.debug([SELECT Payer_Id__c, Name FROM Payer_Info__c WHERE Name = 'Miscellaneous Payer' limit 1]?.Payer_Id__c);
//System.debug(Schema.SObjectType.Fax_Enrollment__c.getRecordTypeInfosByDeveloperName().get('INR_Enrollments').getRecordTypeId());
        String kHexChars = '0123456789abcdef';
        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        System.debug('xxxxxxxxxxxxxxxxxxxxxxxxxx' + returnValue);


    public static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }         
    