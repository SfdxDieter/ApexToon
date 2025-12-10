/**
 * Test class for ToonPrimitiveEncoder.
 */
@IsTest
private class ToonPrimitiveEncoderTest {
    
    @IsTest
    private static void testEncodeNull() {
        // Given
        Object value = null;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('null', result, 'Null should encode as "null"');
    }
    
    @IsTest
    private static void testEncodeBooleanTrue() {
        // Given
        Boolean value = true;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('true', result, 'Boolean true should encode as "true"');
    }
    
    @IsTest
    private static void testEncodeBooleanFalse() {
        // Given
        Boolean value = false;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('false', result, 'Boolean false should encode as "false"');
    }
    
    @IsTest
    private static void testEncodeInteger() {
        // Given
        Integer value = 42;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('42', result, 'Integer should encode as string');
    }
    
    @IsTest
    private static void testEncodeNegativeInteger() {
        // Given
        Integer value = -123;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('-123', result, 'Negative integer should preserve sign');
    }
    
    @IsTest
    private static void testEncodeLong() {
        // Given
        Long value = 9876543210L;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('9876543210', result, 'Long should encode as string');
    }
    
    @IsTest
    private static void testEncodeDecimal() {
        // Given
        Decimal value = 3.14;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('3.14', result, 'Decimal should encode without trailing zeros');
    }
    
    @IsTest
    private static void testEncodeDecimalWithTrailingZeros() {
        // Given
        Decimal value = 1.5000;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('1.5', result, 'Should strip trailing zeros');
    }
    
    @IsTest
    private static void testEncodeDecimalWholeNumber() {
        // Given
        Decimal value = 10.0;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('10', result, 'Whole number decimal should strip .0');
    }
    
    @IsTest
    private static void testEncodeDouble() {
        // Given
        Double value = 2.718;

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('2.718', result, 'Double should encode as decimal');
    }
    
    @IsTest
    private static void testEncodeSimpleString() {
        // Given
        String value = 'hello';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('hello', result, 'Simple string should not be quoted');
    }
    
    @IsTest
    private static void testEncodeStringWithSpace() {
        // Given
        String value = 'hello world';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('hello world', result, 'String with space should not be quoted');
    }
    
    @IsTest
    private static void testEncodeStringWithDelimiter() {
        // Given
        String value = 'hello, world';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"hello, world"', result, 'String with delimiter should be quoted');
    }
    
    @IsTest
    private static void testEncodeStringWithQuotes() {
        // Given
        String value = 'say "hello"';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"say \\"hello\\""', result, 'String with quotes should be escaped and quoted');
    }
    
    @IsTest
    private static void testEncodeStringWithNewline() {
        // Given
        String value = 'line1\nline2';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"line1\\nline2"', result, 'String with newline should be escaped and quoted');
    }
    
    @IsTest
    private static void testEncodeReservedWordTrue() {
        // Given
        String value = 'true';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"true"', result, 'Reserved word should be quoted');
    }
    
    @IsTest
    private static void testEncodeReservedWordFalse() {
        // Given
        String value = 'false';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"false"', result, 'Reserved word should be quoted');
    }
    
    @IsTest
    private static void testEncodeReservedWordNull() {
        // Given
        String value = 'null';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"null"', result, 'Reserved word should be quoted');
    }
    
    @IsTest
    private static void testEncodeNumericString() {
        // Given
        String value = '123';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"123"', result, 'Numeric string should be quoted to distinguish from number');
    }
    
    @IsTest
    private static void testEncodeEmptyString() {
        // Given
        String value = '';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodePrimitive(value, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('""', result, 'Empty string should be quoted');
    }
    
    @IsTest
    private static void testEncodeKey_ValidIdentifier() {
        // Given
        String key = 'name';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodeKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual('name', result, 'Valid key should not be quoted');
    }
    
    @IsTest
    private static void testEncodeKey_WithUnderscore() {
        // Given
        String key = 'user_id';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodeKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual('user_id', result, 'Key with underscore should not be quoted');
    }
    
    @IsTest
    private static void testEncodeKey_WithHyphen() {
        // Given
        String key = 'user-name';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodeKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual('"user-name"', result, 'Key with hyphen should be quoted');
    }
    
    @IsTest
    private static void testEncodeKey_WithSpace() {
        // Given
        String key = 'first name';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodeKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual('"first name"', result, 'Key with space should be quoted');
    }
    
    @IsTest
    private static void testEncodeKey_StartsWithNumber() {
        // Given
        String key = '123key';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodeKey(key);
        Test.stopTest();

        // Then
        Assert.areEqual('"123key"', result, 'Key starting with number should be quoted');
    }
    
    @IsTest
    private static void testEncodeKey_Null() {
        // Given
        String key = null;

        // When
        Test.startTest();
        Exception caughtException;
        try {
            ToonPrimitiveEncoder.encodeKey(key);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        // Then
        Assert.isNotNull(caughtException, 'Exception should be thrown for null key');
        Assert.isInstanceOfType(caughtException, ToonEncodingException.class, 'Should be ToonEncodingException');
        Assert.isTrue(caughtException.getMessage().contains('cannot be null'), 'Should mention null in message');
    }
    
    @IsTest
    private static void testEncodeStringLiteral_WithTabDelimiter() {
        // Given
        String value = 'hello\tworld';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodeStringLiteral(value, '\t');
        Test.stopTest();

        // Then
        Assert.areEqual('"hello\\tworld"', result, 'String with tab delimiter should be escaped and quoted');
    }
    
    @IsTest
    private static void testEncodeStringLiteral_WithPipeDelimiter() {
        // Given
        String value = 'option|choice';

        // When
        Test.startTest();
        String result = ToonPrimitiveEncoder.encodeStringLiteral(value, '|');
        Test.stopTest();

        // Then
        Assert.areEqual('"option|choice"', result, 'String with pipe delimiter should be quoted');
    }
}
