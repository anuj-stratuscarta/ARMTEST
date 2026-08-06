/**
 * StrideFibreMaxUsage — the callee half of the seeded pair (see StrideFibreMaxRating).
 *
 * Exists so the metadata lane carries a real dependency: deploy this one alone and the caller won't
 * compile, which is exactly the failure a two-class seed should be able to provoke.
 */
public with sharing class StrideFibreMaxUsage {

    /** Round part-gigabytes UP — a partial GB is billed as a whole one on this plan. */
    public static Decimal normaliseGb(Decimal gigabytes) {
        if (gigabytes == null || gigabytes <= 0) return 0;
        return gigabytes.setScale(0, System.RoundingMode.CEILING);
    }

    /** Whether a period's usage has passed its included allowance. */
    public static Boolean isOverAllowance(Decimal usedGb, Decimal allowanceGb) {
        if (usedGb == null || allowanceGb == null) return false;
        return normaliseGb(usedGb) > allowanceGb;
    }
}