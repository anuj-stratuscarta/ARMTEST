@IsTest
private class StrideGuideDiscountTest {
    @IsTest
    static void tiersMapToDiscounts() {
        System.assertEquals(15, StrideGuideDiscount.percentFor('Gold'));
        System.assertEquals(10, StrideGuideDiscount.percentFor('Silver'));
        System.assertEquals(5,  StrideGuideDiscount.percentFor('Bronze'));
        System.assertEquals(0,  StrideGuideDiscount.percentFor(null));
    }
}
