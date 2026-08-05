/**
 * StrideFibreMaxRating — seeded test Apex for multi-lane deployment testing.
 *
 * Deliberately depends on StrideFibreMaxUsage: a metadata lane with two INDEPENDENT classes proves
 * almost nothing, whereas a caller/callee pair fails loudly if the deploy orders them wrongly or
 * carries only one of the two.
 */
public with sharing class StrideFibreMaxRating {

    public static final String UPLINK_ATTRIBUTE = 'TST_FMAX_ATT_UPLINK';

    /** Monthly charge for a Fibre Max line: base plus a per-mesh-node uplift. */
    public static Decimal monthlyCharge(Decimal basePrice, Integer meshNodes) {
        if (basePrice == null) return 0;
        Integer nodes = meshNodes == null ? 0 : Math.max(0, meshNodes);
        return basePrice + (nodes * meshNodeUplift());
    }

    /** Per-node uplift. Kept separate so the pricing test can pin it without a DML setup. */
    public static Decimal meshNodeUplift() {
        return 12.50;
    }

    /** Rated usage for a billing period, delegating the unit conversion to StrideFibreMaxUsage. */
    public static Decimal ratedUsage(Decimal gigabytes, Decimal ratePerGb) {
        if (gigabytes == null || ratePerGb == null) return 0;
        return StrideFibreMaxUsage.normaliseGb(gigabytes) * ratePerGb;
    }
}