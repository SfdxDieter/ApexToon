/**
 * Test class for EncodeOptions configuration.
 */
@IsTest
private class EncodeOptionsTest {
    
    @IsTest
    private static void testDefaultOptions() {
        // Given / When
        Test.startTest();
        EncodeOptions opts = new EncodeOptions();
        Test.stopTest();

        // Then
        Assert.areEqual(2, opts.indent, 'Default indent should be 2');
        Assert.areEqual(ToonDelimiter.COMMA, opts.delimiter, 'Default delimiter should be COMMA');
        Assert.areEqual(',', opts.getDelimiterString(), 'Delimiter string should be comma');
    }
    
    @IsTest
    private static void testCustomOptions() {
        // Given / When
        Test.startTest();
        EncodeOptions opts = new EncodeOptions(4, ToonDelimiter.TAB);
        Test.stopTest();

        // Then
        Assert.areEqual(4, opts.indent, 'Custom indent should be 4');
        Assert.areEqual(ToonDelimiter.TAB, opts.delimiter, 'Custom delimiter should be TAB');
        Assert.areEqual('\t', opts.getDelimiterString(), 'Delimiter string should be tab');
    }
    
    @IsTest
    private static void testDelimiterStrings() {
        // Given / When
        Test.startTest();
        EncodeOptions commaOpts = new EncodeOptions(2, ToonDelimiter.COMMA);
        EncodeOptions tabOpts = new EncodeOptions(2, ToonDelimiter.TAB);
        EncodeOptions pipeOpts = new EncodeOptions(2, ToonDelimiter.PIPE);
        Test.stopTest();

        // Then
        Assert.areEqual(',', commaOpts.getDelimiterString(), 'COMMA delimiter should return comma');
        Assert.areEqual('\t', tabOpts.getDelimiterString(), 'TAB delimiter should return tab');
        Assert.areEqual('|', pipeOpts.getDelimiterString(), 'PIPE delimiter should return pipe');
    }
}
