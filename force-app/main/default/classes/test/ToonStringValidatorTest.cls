/**
 * Test class for ToonStringValidator utility.
 */
@IsTest
private class ToonStringValidatorTest {
    
    @IsTest
    private static void testSafeUnquoted_SimpleString() {
        // Given
        String value = 'hello';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Simple string should be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_WithDelimiter() {
        // Given
        String value = 'hello, world';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'String with delimiter should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_ReservedWordTrue() {
        // Given
        String value = 'true';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Reserved word "true" should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_ReservedWordFalse() {
        // Given
        String value = 'false';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Reserved word "false" should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_ReservedWordNull() {
        // Given
        String value = 'null';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Reserved word "null" should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_Number() {
        // Given
        String value = '42';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Number string should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_Decimal() {
        // Given
        String value = '3.14';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Decimal string should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_PaddedString() {
        // Given
        String value = ' padded ';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'String with padding should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_WithNewline() {
        // Given
        String value = 'hello\nworld';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'String with newline should not be safe unquoted');
    }
    
    @IsTest
    private static void testSafeUnquoted_WithQuote() {
        // Given
        String value = 'say "hello"';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isSafeUnquoted(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'String with quotes should not be safe unquoted');
    }
    
    @IsTest
    private static void testValidUnquotedKey_Valid() {
        // Given
        String key = 'name';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isValidUnquotedKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Valid key should pass');
    }
    
    @IsTest
    private static void testValidUnquotedKey_WithUnderscore() {
        // Given
        String key = 'user_id';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isValidUnquotedKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Key with underscore should be valid');
    }
    
    @IsTest
    private static void testValidUnquotedKey_StartsWithNumber() {
        // Given
        String key = '123';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isValidUnquotedKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Key starting with number should be invalid');
    }
    
    @IsTest
    private static void testValidUnquotedKey_WithHyphen() {
        // Given
        String key = 'user-name';

        // When
        Test.startTest();
        Boolean result = ToonStringValidator.isValidUnquotedKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Key with hyphen should be invalid');
    }
    
    @IsTest
    private static void testRemoveQuotes() {
        // Given
        String value = '"quoted"';

        // When
        Test.startTest();
        String result = ToonStringValidator.removeQuotes(value);
        Test.stopTest();

        // Then
        Assert.areEqual('quoted', result, 'Quotes should be removed');
    }
    
    @IsTest
    private static void testRemoveQuotes_NoQuotes() {
        // Given
        String value = 'unquoted';

        // When
        Test.startTest();
        String result = ToonStringValidator.removeQuotes(value);
        Test.stopTest();

        // Then
        Assert.areEqual('unquoted', result, 'Unquoted string should remain unchanged');
    }
    
    @IsTest
    private static void testRemoveQuotes_EmptyString() {
        // Given
        String value = '""';

        // When
        Test.startTest();
        String result = ToonStringValidator.removeQuotes(value);
        Test.stopTest();

        // Then
        Assert.areEqual('', result, 'Empty quoted string should return empty');
    }
}
