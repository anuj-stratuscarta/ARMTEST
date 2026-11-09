/**
 * Stride user guide demo: works out a loyalty discount from an Account's Guide_Tier__c.
 */
public with sharing class StrideGuideDiscount {
    public static Decimal percentFor(String tier) {
        switch on tier {
            when 'Gold'   { return 15; }
            when 'Silver' { return 10; }
            when 'Bronze' { return 5; }
            when else     { return 0; }
        }
    }
}
