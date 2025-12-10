/**
 * Test class for ToonSObjectEncoder and ApexToon SObject methods.
 */
@IsTest
private class ToonSObjectEncoderTest {
    
    @TestSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Industry = 'Technology',
                AnnualRevenue = 1000000 * (i + 1),
                NumberOfEmployees = 100 * (i + 1)
            ));
        }
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        Integer contactIndex = 0;
        for (Account acc : accounts) {
            contacts.add(new Contact(
                FirstName = 'John',
                LastName = 'Doe ' + acc.Name,
                Email = 'john' + String.valueOf(contactIndex) + '@test.com',
                AccountId = acc.Id,
                Title = 'Manager'
            ));
            contactIndex++;
        }
        insert contacts;
    }
    
    @IsTest
    private static void testEncodeSObjectsWithSObjectFields() {
        // Given
        List<Account> accounts = [SELECT Name, Industry, AnnualRevenue FROM Account];
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Schema.Account.Name,
            Schema.Account.Industry,
            Schema.Account.AnnualRevenue
        };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(accounts, fields);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('[5]{'), 'Should have tabular header');
        Assert.isTrue(toon.contains('Name'), 'Should contain Name field');
        Assert.isTrue(toon.contains('Industry'), 'Should contain Industry field');
        Assert.isTrue(toon.contains('AnnualRevenue'), 'Should contain AnnualRevenue field');
        Assert.isTrue(toon.contains('Test Account 0'), 'Should contain account name');
        Assert.isTrue(toon.contains('Technology'), 'Should contain industry value');
    }
    
    @IsTest
    private static void testEncodeSObjectsWithFieldNames() {
        // Given
        List<Account> accounts = [SELECT Name, Industry FROM Account LIMIT 3];
        List<String> fieldNames = new List<String>{ 'Name', 'Industry' };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(accounts, fieldNames);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('[3]{'), 'Should have array header with count');
        Assert.isTrue(toon.contains('Name'), 'Should contain Name');
        Assert.isTrue(toon.contains('Industry'), 'Should contain Industry');
    }
    
    @IsTest
    private static void testEncodeSObjectsWithRelationshipFields() {
        // Given
        List<Contact> contacts = [
            SELECT FirstName, LastName, Email, Account.Name, Account.Industry
            FROM Contact
            LIMIT 3
        ];
        List<String> fieldNames = new List<String>{
            'FirstName',
            'LastName',
            'Email',
            'Account.Name',
            'Account.Industry'
        };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(contacts, fieldNames);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('FirstName'), 'Should contain FirstName');
        Assert.isTrue(toon.contains('Account.Name'), 'Should contain relationship field');
        Assert.isTrue(toon.contains('Account.Industry'), 'Should contain relationship field');
        Assert.isTrue(toon.contains('John'), 'Should contain contact first name');
        Assert.isTrue(toon.contains('Test Account'), 'Should contain related account name');
    }
    
    @IsTest
    private static void testEncodeSingleSObjectWithFields() {
        // Given
        Account account = [SELECT Name, Industry, AnnualRevenue FROM Account LIMIT 1];
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Schema.Account.Name,
            Schema.Account.Industry
        };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObject(account, fields);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('[1]{'), 'Should encode as single-item array');
        Assert.isTrue(toon.contains('Name'), 'Should contain Name field');
        Assert.isTrue(toon.contains('Industry'), 'Should contain Industry field');
    }
    
    @IsTest
    private static void testEncodeSingleSObjectWithFieldNames() {
        // Given
        Contact contact = [SELECT FirstName, LastName, Email FROM Contact LIMIT 1];
        List<String> fieldNames = new List<String>{ 'FirstName', 'LastName', 'Email' };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObject(contact, fieldNames);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('FirstName'), 'Should contain FirstName');
        Assert.isTrue(toon.contains('LastName'), 'Should contain LastName');
        Assert.isTrue(toon.contains('Email'), 'Should contain Email');
    }
    
    @IsTest
    private static void testEncodeSObjectsWithCustomOptions() {
        // Given
        List<Account> accounts = [SELECT Name, Industry FROM Account LIMIT 2];
        List<String> fieldNames = new List<String>{ 'Name', 'Industry' };
        EncodeOptions options = new EncodeOptions(4, ToonDelimiter.PIPE);

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(accounts, fieldNames, options);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('|'), 'Should use pipe delimiter');
        Assert.isTrue(toon.contains('[2|]'), 'Should show delimiter in header');
    }
    
    @IsTest
    private static void testSObjectToMap() {
        // Given
        Account account = [SELECT Name, Industry, AnnualRevenue FROM Account LIMIT 1];
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Schema.Account.Name,
            Schema.Account.Industry
        };

        // When
        Test.startTest();
        Map<String, Object> result = ToonSObjectEncoder.sObjectToMap(account, fields);
        Test.stopTest();

        // Then
        Assert.areEqual(2, result.size(), 'Should have 2 fields');
        Assert.isTrue(result.containsKey('Name'), 'Should contain Name');
        Assert.isTrue(result.containsKey('Industry'), 'Should contain Industry');
        Assert.areEqual(account.Name, result.get('Name'), 'Name should match');
    }
    
    @IsTest
    private static void testSObjectToMapByFieldNames() {
        // Given
        Contact contact = [
            SELECT FirstName, LastName, Account.Name
            FROM Contact
            LIMIT 1
        ];
        List<String> fieldNames = new List<String>{
            'FirstName',
            'LastName',
            'Account.Name'
        };

        // When
        Test.startTest();
        Map<String, Object> result = ToonSObjectEncoder.sObjectToMapByFieldNames(contact, fieldNames);
        Test.stopTest();

        // Then
        Assert.areEqual(3, result.size(), 'Should have 3 fields');
        Assert.isTrue(result.containsKey('FirstName'), 'Should contain FirstName');
        Assert.isTrue(result.containsKey('Account.Name'), 'Should contain relationship field');
    }
    
    @IsTest
    private static void testGetAccessibleFields() {
        // Given / When
        Test.startTest();
        List<Schema.SObjectField> fields = ToonSObjectEncoder.getAccessibleFields(Account.SObjectType);
        Test.stopTest();

        // Then
        Assert.isTrue(fields.size() > 0, 'Should return accessible fields');
        
        for (Schema.SObjectField field : fields) {
            Assert.isTrue(field.getDescribe().isAccessible(), 'All fields should be accessible');
        }
    }
    
    @IsTest
    private static void testNullFieldsSkipped() {
        // Given
        Account acc = new Account(Name = 'Test', Industry = null);
        insert acc;
        
        List<Account> accounts = [SELECT Name, Industry FROM Account WHERE Id = :acc.Id];
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Schema.Account.Name,
            Schema.Account.Industry
        };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(accounts, fields);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('Name'), 'Should contain Name field');
    }
    
    @IsTest
    private static void testEmptyRecordsList() {
        // Given
        List<Account> emptyList = new List<Account>();
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Schema.Account.Name
        };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(emptyList, fields);
        Test.stopTest();

        // Then
        Assert.areEqual('[0]:', toon, 'Should return empty array header');
    }
    
    @IsTest
    private static void testMixedSObjectTypesThrowsException() {
        // Given
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test');
        insert con;
        
        List<SObject> mixed = new List<SObject>{ acc, con };
        List<String> fieldNames = new List<String>{ 'Name' };

        // When
        Test.startTest();
        Exception caughtException;
        try {
            ApexToon.encodeSObjects(mixed, fieldNames);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        // Then
        Assert.isNotNull(caughtException, 'Should throw exception');
        Assert.isTrue(caughtException.getMessage().contains('Mixed SObject types'), 'Should mention mixed types');
    }
    
    @IsTest
    private static void testNullRelationshipField() {
        // Given
        Contact orphan = new Contact(FirstName = 'Orphan', LastName = 'Contact');
        insert orphan;
        
        List<Contact> contacts = [SELECT FirstName, LastName, Account.Name FROM Contact WHERE Id = :orphan.Id];
        List<String> fieldNames = new List<String>{
            'FirstName',
            'LastName',
            'Account.Name'
        };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(contacts, fieldNames);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('FirstName'), 'Should contain FirstName');
        Assert.isTrue(toon.contains('LastName'), 'Should contain LastName');
    }
    
    @IsTest
    private static void testDateTimeFieldNormalization() {
        // Given
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        List<Opportunity> opps = [SELECT Name, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        List<String> fieldNames = new List<String>{ 'Name', 'CloseDate' };

        // When
        Test.startTest();
        String toon = ApexToon.encodeSObjects(opps, fieldNames);
        Test.stopTest();

        // Then
        Assert.isTrue(toon.contains('Name'), 'Should contain Name');
        Assert.isTrue(toon.contains('CloseDate'), 'Should contain CloseDate');
    }
}
