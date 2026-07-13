public with sharing class StrideMergeDemo {
    // Stride merge-conflict demo — a pricing engine. Region comments anchor the line differ so
    // non-overlapping edits on different methods auto-merge and only the overlap needs a decision.

    public static final Decimal BASE_RATE = 100.00;
    public static final Integer MAX_LINE_ITEMS = 500;

    // ---- validation (identical on every branch) ----
    public static Boolean isValidQuantity(Integer qty) {
        if (qty == null) return false;
        if (qty <= 0) return false;
        return qty <= MAX_LINE_ITEMS;
    }

    public static Boolean isValidCustomer(String customerId) {
        return customerId != null && customerId.length() == 18;
    }

    // ---- discount (CONFLICT: edited by both Dev and SIT) ----
    public static Decimal calculateDiscount(Integer qty, String tier) {
        Decimal rate = 0.00;
        if (qty >= 100) rate = 0.10;
        else if (qty >= 50) rate = 0.05;
        return rate;
    }

    // ---- tax (SIT edits the rate; auto-merges) ----
    public static Decimal computeTax(Decimal amount) {
        return amount * 0.05;
    }

    // ---- totals (identical on every branch) ----
    public static Decimal computeSubtotal(Integer qty, Decimal unitPrice) {
        return qty * unitPrice;
    }

    public static Decimal computeGrandTotal(Integer qty, Decimal unitPrice, String tier) {
        Decimal subtotal = computeSubtotal(qty, unitPrice);
        Decimal discount = calculateDiscount(qty, tier);
        Decimal taxed = computeTax(subtotal);
        return subtotal - (subtotal * discount) + taxed;
    }

    // ---- formatting (identical on every branch) ----
    public static String formatCurrency(Decimal amount) {
        if (amount == null) return '$0.00';
        return '$' + amount.setScale(2).toString();
    }

    public static String describeOrder(Integer qty, String tier) {
        return 'Order: ' + qty + ' unit(s), tier=' + tier;
    }
}
