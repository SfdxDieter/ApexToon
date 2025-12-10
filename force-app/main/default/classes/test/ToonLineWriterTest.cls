/**
 * Test class for ToonLineWriter.
 */
@IsTest
private class ToonLineWriterTest {
    
    @IsTest
    private static void testEmptyWriter() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(2);

        // When
        Test.startTest();
        String result = writer.toString();
        Test.stopTest();

        // Then
        Assert.areEqual('', result, 'Empty writer should produce empty string');
        Assert.areEqual(true, writer.isEmpty(), 'Writer should be empty');
        Assert.areEqual(0, writer.size(), 'Size should be zero');
    }
    
    @IsTest
    private static void testSingleLine() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(2);

        // When
        Test.startTest();
        writer.push(0, 'name: Ada');
        String result = writer.toString();
        Test.stopTest();

        // Then
        Assert.areEqual('name: Ada', result, 'Should output single line');
        Assert.areEqual(false, writer.isEmpty(), 'Writer should not be empty');
        Assert.areEqual(1, writer.size(), 'Size should be one');
    }
    
    @IsTest
    private static void testMultipleLines() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(2);

        // When
        Test.startTest();
        writer.push(0, 'id: 123');
        writer.push(0, 'name: Ada');
        writer.push(0, 'active: true');
        String result = writer.toString();
        Test.stopTest();

        // Then
        Assert.areEqual('id: 123\nname: Ada\nactive: true', result, 'Should output multiple lines');
        Assert.areEqual(3, writer.size(), 'Size should be three');
    }
    
    @IsTest
    private static void testIndentation() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(2);

        // When
        Test.startTest();
        writer.push(0, 'user:');
        writer.push(1, 'id: 123');
        writer.push(1, 'name: Ada');
        String result = writer.toString();
        Test.stopTest();

        // Then
        String expected = 'user:\n  id: 123\n  name: Ada';
        Assert.areEqual(expected, result, 'Should indent nested lines');
    }
    
    @IsTest
    private static void testDeepNesting() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(2);

        // When
        Test.startTest();
        writer.push(0, 'level0:');
        writer.push(1, 'level1:');
        writer.push(2, 'level2:');
        writer.push(3, 'value: deep');
        String result = writer.toString();
        Test.stopTest();

        // Then
        String expected = 'level0:\n  level1:\n    level2:\n      value: deep';
        Assert.areEqual(expected, result, 'Should handle deep nesting');
    }
    
    @IsTest
    private static void testCustomIndentSize() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(4);

        // When
        Test.startTest();
        writer.push(0, 'user:');
        writer.push(1, 'name: Ada');
        String result = writer.toString();
        Test.stopTest();

        // Then
        String expected = 'user:\n    name: Ada';
        Assert.areEqual(expected, result, 'Should use custom indent size');
    }
    
    @IsTest
    private static void testZeroIndent() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(0);

        // When
        Test.startTest();
        writer.push(0, 'line1');
        writer.push(1, 'line2');
        writer.push(2, 'line3');
        String result = writer.toString();
        Test.stopTest();

        // Then
        String expected = 'line1\nline2\nline3';
        Assert.areEqual(expected, result, 'Zero indent should produce no indentation');
    }
    
    @IsTest
    private static void testMixedDepths() {
        // Given
        ToonLineWriter writer = new ToonLineWriter(2);

        // When
        Test.startTest();
        writer.push(0, 'root:');
        writer.push(1, 'child1: value1');
        writer.push(2, 'grandchild: value2');
        writer.push(1, 'child2: value3');
        writer.push(0, 'sibling: value4');
        String result = writer.toString();
        Test.stopTest();

        // Then
        String expected = 'root:\n  child1: value1\n    grandchild: value2\n  child2: value3\nsibling: value4';
        Assert.areEqual(expected, result, 'Should handle mixed depths correctly');
    }
}
