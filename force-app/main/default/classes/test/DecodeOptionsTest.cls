/**
 * Test class for DecodeOptions configuration.
 */
@IsTest
private class DecodeOptionsTest {
    
    @IsTest
    private static void testDefaultOptions() {
        // Given / When
        Test.startTest();
        DecodeOptions opts = new DecodeOptions();
        Test.stopTest();

        // Then
        Assert.areEqual(PathExpansion.NONE, opts.pathExpansion, 'Default pathExpansion should be NONE');
        Assert.areEqual(false, opts.strictMode, 'Default strictMode should be false');
    }
    
    @IsTest
    private static void testCustomOptions() {
        // Given / When
        Test.startTest();
        DecodeOptions opts = new DecodeOptions(PathExpansion.SAFE, true);
        Test.stopTest();

        // Then
        Assert.areEqual(PathExpansion.SAFE, opts.pathExpansion, 'Custom pathExpansion should be SAFE');
        Assert.areEqual(true, opts.strictMode, 'Custom strictMode should be true');
    }
}
