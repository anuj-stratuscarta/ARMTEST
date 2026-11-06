/**
 * Unit tests for StrideDemoPricingUtil. Gives the seeded class real coverage so it
 * can deploy under RunLocalTests too, not only NoTestRun.
 */
@IsTest
private class StrideDemoPricingUtilTest {
    @IsTest
    static void appliesDiscount() {
        System.assertEquals(90.00, StrideDemoPricingUtil.applyDiscount(100, 10), '10% off 100');
        System.assertEquals(0, StrideDemoPricingUtil.applyDiscount(0, 10), 'zero amount');
        System.assertEquals(75.00, StrideDemoPricingUtil.applyDiscount(75, null), 'null percent = no discount');
    }

    @IsTest
    static void clampsPercent() {
        System.assertEquals(0.00, StrideDemoPricingUtil.applyDiscount(100, 150), 'over-100% clamps to full discount');
        System.assertEquals(100.00, StrideDemoPricingUtil.applyDiscount(100, -20), 'negative clamps to 0% discount');
    }

    @IsTest
    static void sumsLines() {
        System.assertEquals(60.00, StrideDemoPricingUtil.sumLines(new List<Decimal>{ 10, 20, 30 }), 'sum');
        System.assertEquals(30.00, StrideDemoPricingUtil.sumLines(new List<Decimal>{ 10, null, 20 }), 'nulls ignored');
        System.assertEquals(0, StrideDemoPricingUtil.sumLines(null), 'null list = 0');
    }
}