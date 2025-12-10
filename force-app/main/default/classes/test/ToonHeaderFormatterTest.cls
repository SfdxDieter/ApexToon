/**
 * Test class for ToonHeaderFormatter.
 */
@IsTest
private class ToonHeaderFormatterTest {
    
    @IsTest
    private static void testSimpleArrayHeader() {
        // Given
        Integer length = 3;
        String key = 'tags';

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, null, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('tags[3]:', result, 'Should format simple array header');
    }
    
    @IsTest
    private static void testStandaloneArrayHeader() {
        // Given
        Integer length = 2;

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, null, null, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('[2]:', result, 'Should format standalone array header');
    }
    
    @IsTest
    private static void testTabDelimiterArray() {
        // Given
        Integer length = 3;
        String key = 'values';

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, null, '\t');
        Test.stopTest();

        // Then
        Assert.areEqual('values[3\t]:', result, 'Should include tab delimiter in header');
    }
    
    @IsTest
    private static void testPipeDelimiterArray() {
        // Given
        Integer length = 4;
        String key = 'options';

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, null, '|');
        Test.stopTest();

        // Then
        Assert.areEqual('options[4|]:', result, 'Should include pipe delimiter in header');
    }
    
    @IsTest
    private static void testTabularHeader() {
        // Given
        Integer length = 2;
        String key = 'items';
        List<String> fields = new List<String>{ 'id', 'name' };

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, fields, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('items[2]{id,name}:', result, 'Should format tabular header');
    }
    
    @IsTest
    private static void testTabularHeaderWithThreeFields() {
        // Given
        Integer length = 10;
        String key = 'products';
        List<String> fields = new List<String>{ 'sku', 'qty', 'price' };

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, fields, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('products[10]{sku,qty,price}:', result, 'Should format tabular header with multiple fields');
    }
    
    @IsTest
    private static void testTabularHeaderWithTabDelimiter() {
        // Given
        Integer length = 2;
        String key = 'data';
        List<String> fields = new List<String>{ 'x', 'y' };

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, fields, '\t');
        Test.stopTest();

        // Then
        Assert.areEqual('data[2\t]{x\ty}:', result, 'Should use tab delimiter in fields');
    }
    
    @IsTest
    private static void testEmptyFieldsList() {
        // Given
        Integer length = 1;
        String key = 'empty';
        List<String> fields = new List<String>();

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, fields, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('empty[1]:', result, 'Empty fields list should be ignored');
    }
    
    @IsTest
    private static void testKeyWithSpecialCharacters() {
        // Given
        Integer length = 1;
        String key = 'my-key';

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, null, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('"my-key"[1]:', result, 'Should quote key with special characters');
    }
    
    @IsTest
    private static void testFieldWithSpecialCharacters() {
        // Given
        Integer length = 1;
        String key = 'data';
        List<String> fields = new List<String>{ 'user-id', 'first-name' };

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.format(length, key, fields, ',');
        Test.stopTest();

        // Then
        Assert.areEqual('data[1]{"user-id","first-name"}:', result, 'Should quote fields with special characters');
    }
    
    @IsTest
    private static void testFormatInlineHeader() {
        // Given
        String key = 'numbers';
        Integer length = 5;
        EncodeOptions options = new EncodeOptions(2, ToonDelimiter.COMMA);

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.formatInlineHeader(key, length, options);
        Test.stopTest();

        // Then
        Assert.areEqual('numbers[5]:', result, 'Should format inline header');
    }
    
    @IsTest
    private static void testFormatTabularHeader() {
        // Given
        String key = 'users';
        Integer length = 10;
        List<String> fields = new List<String>{ 'id', 'name', 'email' };
        EncodeOptions options = new EncodeOptions(2, ToonDelimiter.COMMA);

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.formatTabularHeader(key, length, fields, options);
        Test.stopTest();

        // Then
        Assert.areEqual('users[10]{id,name,email}:', result, 'Should format tabular header');
    }
    
    @IsTest
    private static void testFormatTabularHeaderWithTabDelimiter() {
        // Given
        String key = 'data';
        Integer length = 2;
        List<String> fields = new List<String>{ 'a', 'b' };
        EncodeOptions options = new EncodeOptions(2, ToonDelimiter.TAB);

        // When
        Test.startTest();
        String result = ToonHeaderFormatter.formatTabularHeader(key, length, fields, options);
        Test.stopTest();

        // Then
        Assert.areEqual('data[2\t]{a\tb}:', result, 'Should use tab delimiter from options');
    }
}
