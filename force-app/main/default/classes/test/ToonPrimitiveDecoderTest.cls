/**
 * Test class for ToonPrimitiveDecoder.
 */
@IsTest
private class ToonPrimitiveDecoderTest {
    
    @IsTest
    private static void testParseNull() {
        // Given
        String value = 'null';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(null, result, 'Should parse null');
    }
    
    @IsTest
    private static void testParseBooleanTrue() {
        // Given
        String value = 'true';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Should parse true');
    }
    
    @IsTest
    private static void testParseBooleanFalse() {
        // Given
        String value = 'false';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Should parse false');
    }
    
    @IsTest
    private static void testParseInteger() {
        // Given
        String value = '42';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(42L, result, 'Should parse integer');
    }
    
    @IsTest
    private static void testParseNegativeInteger() {
        // Given
        String value = '-123';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(-123L, result, 'Should parse negative integer');
    }
    
    @IsTest
    private static void testParseDecimal() {
        // Given
        String value = '3.14';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(3.14, result, 'Should parse decimal');
    }
    
    @IsTest
    private static void testParseZero() {
        // Given
        String value = '0';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(0, result, 'Should parse zero');
    }
    
    @IsTest
    private static void testParseQuotedString() {
        // Given
        String value = '"hello world"';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual('hello world', result, 'Should parse quoted string');
    }
    
    @IsTest
    private static void testParseQuotedStringWithEscapes() {
        // Given
        String value = '"line1\\nline2"';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual('line1\nline2', result, 'Should unescape newline');
    }
    
    @IsTest
    private static void testParseUnquotedString() {
        // Given
        String value = 'hello';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual('hello', result, 'Should return unquoted string as-is');
    }
    
    @IsTest
    private static void testParseEmptyString() {
        // Given
        String value = '';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual('', result, 'Should return empty string');
    }
    
    @IsTest
    private static void testParseEmptyQuotedString() {
        // Given
        String value = '""';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual('', result, 'Should parse empty quoted string');
    }
    
    @IsTest
    private static void testParseDelimitedValues_Comma() {
        // Given
        String input = 'admin,ops,dev';

        // When
        Test.startTest();
        List<Object> result = ToonPrimitiveDecoder.parseDelimitedValues(input, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(3, result.size(), 'Should have 3 values');
        Assert.areEqual('admin', result[0], 'First value should be admin');
        Assert.areEqual('ops', result[1], 'Second value should be ops');
        Assert.areEqual('dev', result[2], 'Third value should be dev');
    }
    
    @IsTest
    private static void testParseDelimitedValues_Tab() {
        // Given
        String input = '1\t2\t3';

        // When
        Test.startTest();
        List<Object> result = ToonPrimitiveDecoder.parseDelimitedValues(input, '\t');
        Test.stopTest();

        // Then
        Assert.areEqual(3, result.size(), 'Should have 3 values');
        Assert.areEqual(1L, result[0], 'Should parse numbers');
    }
    
    @IsTest
    private static void testParseDelimitedValues_Pipe() {
        // Given
        String input = 'a|b|c';

        // When
        Test.startTest();
        List<Object> result = ToonPrimitiveDecoder.parseDelimitedValues(input, '|');
        Test.stopTest();

        // Then
        Assert.areEqual(3, result.size(), 'Should have 3 values');
        Assert.areEqual('a', result[0], 'Should parse with pipe delimiter');
    }
    
    @IsTest
    private static void testParseDelimitedValues_WithQuotes() {
        // Given
        String input = '"hello, world",test,"another"';

        // When
        Test.startTest();
        List<Object> result = ToonPrimitiveDecoder.parseDelimitedValues(input, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(3, result.size(), 'Should have 3 values');
        Assert.areEqual('hello, world', result[0], 'Should preserve comma in quotes');
        Assert.areEqual('test', result[1], 'Should parse unquoted value');
        Assert.areEqual('another', result[2], 'Should parse quoted value');
    }
    
    @IsTest
    private static void testParseDelimitedValues_MixedTypes() {
        // Given
        String input = '1,true,"text",null';

        // When
        Test.startTest();
        List<Object> result = ToonPrimitiveDecoder.parseDelimitedValues(input, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(4, result.size(), 'Should have 4 values');
        Assert.areEqual(1L, result[0], 'Should parse number');
        Assert.areEqual(true, result[1], 'Should parse boolean');
        Assert.areEqual('text', result[2], 'Should parse string');
        Assert.areEqual(null, result[3], 'Should parse null');
    }
    
    @IsTest
    private static void testParseDelimitedValues_Empty() {
        // Given
        String input = '';

        // When
        Test.startTest();
        List<Object> result = ToonPrimitiveDecoder.parseDelimitedValues(input, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(0, result.size(), 'Empty input should return empty list');
    }
    
    @IsTest
    private static void testParseDelimitedValues_TrailingComma() {
        // Given
        String input = 'a,b,';

        // When
        Test.startTest();
        List<Object> result = ToonPrimitiveDecoder.parseDelimitedValues(input, ',');
        Test.stopTest();

        // Then
        Assert.areEqual(3, result.size(), 'Should handle trailing comma');
        Assert.areEqual('', result[2], 'Last value should be empty string');
    }
    
    @IsTest
    private static void testParseOctalNumber() {
        // Given
        String value = '0123';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual('0123', result, 'Octal-looking number should be treated as string');
    }
    
    @IsTest
    private static void testParseScientificNotation() {
        // Given
        String value = '1.5e10';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.isTrue(result instanceof Decimal, 'Should parse scientific notation as Decimal');
    }
    
    @IsTest
    private static void testParseLargeNumber() {
        // Given
        String value = '9876543210';

        // When
        Test.startTest();
        Object result = ToonPrimitiveDecoder.parse(value);
        Test.stopTest();

        // Then
        Assert.areEqual(9876543210L, result, 'Should parse large number as Long');
    }
}
