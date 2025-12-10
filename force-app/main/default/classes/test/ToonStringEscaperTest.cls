/**
 * Test class for ToonStringEscaper utility.
 */
@IsTest
private class ToonStringEscaperTest {
    
    @IsTest
    private static void testEscapeNewline() {
        // Given
        String value = 'hello\nworld';

        // When
        Test.startTest();
        String result = ToonStringEscaper.escape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('hello\\nworld', result, 'Newline should be escaped');
    }
    
    @IsTest
    private static void testEscapeQuotes() {
        // Given
        String value = '"quoted"';

        // When
        Test.startTest();
        String result = ToonStringEscaper.escape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('\\"quoted\\"', result, 'Quotes should be escaped');
    }
    
    @IsTest
    private static void testEscapeTab() {
        // Given
        String value = 'tab\there';

        // When
        Test.startTest();
        String result = ToonStringEscaper.escape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('tab\\there', result, 'Tab should be escaped');
    }
    
    @IsTest
    private static void testEscapeBackslash() {
        // Given
        String value = 'path\\to\\file';

        // When
        Test.startTest();
        String result = ToonStringEscaper.escape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('path\\\\to\\\\file', result, 'Backslash should be escaped');
    }
    
    @IsTest
    private static void testEscapeCarriageReturn() {
        // Given
        String value = 'line1\rline2';

        // When
        Test.startTest();
        String result = ToonStringEscaper.escape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('line1\\rline2', result, 'Carriage return should be escaped');
    }
    
    @IsTest
    private static void testUnescapeNewline() {
        // Given
        String value = 'hello\\nworld';

        // When
        Test.startTest();
        String result = ToonStringEscaper.unescape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('hello\nworld', result, 'Escaped newline should be unescaped');
    }
    
    @IsTest
    private static void testUnescapeQuotes() {
        // Given
        String value = '\\"quoted\\"';

        // When
        Test.startTest();
        String result = ToonStringEscaper.unescape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('"quoted"', result, 'Escaped quotes should be unescaped');
    }
    
    @IsTest
    private static void testUnescapeTab() {
        // Given
        String value = 'tab\\there';

        // When
        Test.startTest();
        String result = ToonStringEscaper.unescape(value);
        Test.stopTest();

        // Then
        Assert.areEqual('tab\there', result, 'Escaped tab should be unescaped');
    }
    
    @IsTest
    private static void testEscapeNull() {
        // Given
        String value = null;

        // When
        Test.startTest();
        String result = ToonStringEscaper.escape(value);
        Test.stopTest();

        // Then
        Assert.areEqual(null, result, 'Null should return null');
    }
    
    @IsTest
    private static void testUnescapeNull() {
        // Given
        String value = null;

        // When
        Test.startTest();
        String result = ToonStringEscaper.unescape(value);
        Test.stopTest();

        // Then
        Assert.areEqual(null, result, 'Null should return null');
    }
    
    @IsTest
    private static void testValidateUnterminatedString() {
        // Given
        String value = '"unterminated';

        // When
        Test.startTest();
        Exception caughtException;
        try {
            ToonStringEscaper.validateString(value);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        // Then
        Assert.isNotNull(caughtException, 'Exception should be thrown');
        Assert.isInstanceOfType(caughtException, ToonException.class, 'Should be ToonException');
        Assert.isTrue(caughtException.getMessage().contains('Unterminated'), 'Message should mention unterminated');
    }
    
    @IsTest
    private static void testValidateInvalidQuotedString() {
        // Given
        String value = 'invalid"';

        // When
        Test.startTest();
        Exception caughtException;
        try {
            ToonStringEscaper.validateString(value);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        // Then
        Assert.isNotNull(caughtException, 'Exception should be thrown');
        Assert.isInstanceOfType(caughtException, ToonException.class, 'Should be ToonException');
    }
    
    @IsTest
    private static void testValidateProperlyQuotedString() {
        // Given
        String value = '"properly quoted"';

        // When
        Test.startTest();
        Exception caughtException;
        try {
            ToonStringEscaper.validateString(value);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        // Then
        Assert.isNull(caughtException, 'No exception should be thrown for valid string');
    }
    
    @IsTest
    private static void testValidateUnquotedString() {
        // Given
        String value = 'unquoted';

        // When
        Test.startTest();
        Exception caughtException;
        try {
            ToonStringEscaper.validateString(value);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        // Then
        Assert.isNull(caughtException, 'No exception should be thrown for unquoted string');
    }
}
