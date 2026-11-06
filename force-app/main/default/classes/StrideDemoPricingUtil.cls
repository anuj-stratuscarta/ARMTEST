/**
 * StrideDemoPricingUtil — sample Apex seeded by Stride for deployment testing.
 *
 * A tiny, side-effect-free pricing helper: applies a percentage discount to a
 * base amount and rounds to 2 dp. Intentionally trivial — its purpose is to give
 * the Stride metadata pipeline a real ApexClass (+ test) to capture and promote.
 */
public with sharing class StrideDemoPricingUtil {
    /** Apply a percent discount (0–100) to an amount; clamps out-of-range percents. */
    public static Decimal applyDiscount(Decimal amount, Decimal percent) {
        if (amount == null || amount <= 0) {
            return 0;
        }
        Decimal pct = percent == null ? 0 : Math.min(100, Math.max(0, percent));
        Decimal net = amount * (1 - (pct / 100));
        return net.setScale(2, System.RoundingMode.HALF_UP);
    }

    /** Total a list of line amounts, treating nulls as zero. */
    public static Decimal sumLines(List<Decimal> lines) {
        Decimal total = 0;
        if (lines == null) {
            return total;
        }
        for (Decimal line : lines) {
            if (line != null) {
                total += line;
            }
        }
        return total.setScale(2, System.RoundingMode.HALF_UP);
    }
}