public with sharing class StrideDemoBundle {
    // STRIDE demo — promoted through the ARM Release pipeline alongside the
    // Residential Internet bundle config-data (data/arm/*.json).
    public static String bundleCode() {
        return 'PRD_RES_INTERNET';
    }
    public static Integer speedOptionCount() {
        return [SELECT COUNT() FROM AttributePicklistValue
                WHERE Picklist.Code = 'INTERNET_SPEED_OPTIONS'];
    }
}