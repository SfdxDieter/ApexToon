# ApexToon - Token-Oriented Object Notation for Salesforce

ApexToon is a Salesforce Apex port of the [JToon](https://github.com/felipestanzani/jtoon) library, enabling bidirectional conversion between Apex objects/JSON and TOON (Token-Oriented Object Notation) format for efficient AI interactions. With addional support for working with SObjects within Salesforce.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Apex](https://img.shields.io/badge/Apex-65.0%2B-blue.svg)](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)

### Note:

This is an early release. Please report any issues or feature requests via github issues, or open a pull request.

TOON can currently be used for encoding and decoding data structures to reduce token usage when interacting with Large Language Models (LLMs) such as OpenAI's GPT series.
(December 25) BUT only can be contained in prompts and completions, not yet in function calls.
When it becomes possible to use custom data formats in function calls, TOON will be even more powerful for structured data exchange with LLMs.
Then the content-type "application/toon" can be used to specify TOON formatted data. Maybe also as "response_format" parameter in future OpenAI API calls.

## Table of Contents

- [What is TOON?](#what-is-toon)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Features](#core-features)
- [API Reference](#api-reference)
- [SObject Support](#sobject-support)
- [Advanced Usage](#advanced-usage)
- [Performance](#performance)
- [Testing](#testing)
- [Credits](#credits)

## What is TOON?

Token-Oriented Object Notation (TOON) is a compact, human-readable format designed specifically for passing structured data to Large Language Models (LLMs) with **30-60% fewer tokens** compared to JSON.

### Key Benefits

🚀 **Token Efficiency** - Save 30-60% on AI API costs  
📖 **Human Readable** - Easy to read and debug  
🛡️ **LLM Guardrails** - Explicit lengths and field lists help models validate output  
📊 **Tabular Format** - CSV-like rows for uniform data structures  
✅ **Bi-directional** - Convert to and from TOON seamlessly

### TOON Format Examples

<details>
<summary><b>Simple Object</b></summary>

**JSON:**

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "active": true
}
```

**TOON:**

```
id: 123
name: Ada Lovelace
active: true
```

**Token Savings:** ~40%

</details>

<details>
<summary><b>Nested Object</b></summary>

**JSON:**

```json
{
  "user": {
    "id": 123,
    "name": "Ada Lovelace",
    "email": "ada@example.com"
  }
}
```

**TOON:**

```
user:
  id: 123
  name: Ada Lovelace
  email: ada@example.com
```

**Token Savings:** ~35%

</details>

<details>
<summary><b>Primitive Array</b></summary>

**JSON:**

```json
{
  "tags": ["admin", "developer", "ops"]
}
```

**TOON:**

```
tags[3]: admin,developer,ops
```

**Token Savings:** ~50%

</details>

<details>
<summary><b>Tabular Array (Uniform Objects)</b></summary>

**JSON:**

```json
{
  "products": [
    { "sku": "A1", "qty": 2, "price": 9.99 },
    { "sku": "B2", "qty": 1, "price": 14.5 },
    { "sku": "C3", "qty": 5, "price": 7.25 }
  ]
}
```

**TOON:**

```
products[3]{sku,qty,price}:
  A1,2,9.99
  B2,1,14.5
  C3,5,7.25
```

**Token Savings:** ~60%

</details>

## Installation

This library can be installed into your Salesforce org as managed package or deployed directly via Salesforce DX.
It does not have any external dependencies or a password for installation.

It is a Managed Package and can be installed into Production, Developer, or Scratch Orgs
The namespace is toonify

### Via Managed Package

Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04tbG0000005yWbQAI
use https://test.salesforce.com for Sandbox Orgs

### Via Salesforce DX

    sf install package  --wait 360  --security-type "AdminsOnly"  --package 04tbG0000005yWbQAI -u <your-org-alias>

### Via Unlocked Package Source

you can create your own unlocked package from the source code. 
First you need to have a devhub org.

The only missing file is the sfdx-project.json in the root directory of this repository

    create a sfdx-project.json with the following content:
```json
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true
    }
  ],
  "namespace": "toonify",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "65.0"
}
```
use the sf create package command to create an unlocked package

    sf package create --name ApexToon --package-type Unlocked --path force-app -v <your-devhub-alias> -d "ApexToon - Token-Oriented Object Notation for Salesforce. ApexToon is a Salesforce Apex port of the JToon library, enabling bidirectional conversion between Apex objects/JSON and TOON (Token-Oriented Object Notation) format for efficient AI interactions. With additional support for working with SObjects within Salesforce. MIT License.

take the package Id from the output and create a new package version

    sf package version create -c --installation-key-bypass -w 60 -p YOUR_PACKAGE_ID

 now you can install the unlocked package into your org

    sf install package  --wait 360  --security-type "AdminsOnly"  --package YOUR_PACKAGE_VERSION_ID -u <your-org-alias>


### Via Source Deployment 

1. Clone or download this repository
2. Deploy to your Salesforce org:

```bash
sf project deploy start --source-dir force-app/main/dependencies/ApexToon
```

## Quick Start

### Basic Encoding

```apex
// Encode a Map to TOON
Map<String, Object> data = new Map<String, Object>{
    'id' => 123,
    'name' => 'Ada Lovelace',
    'active' => true,
    'tags' => new List<String>{'developer', 'pioneer'}
};

String toon = toonify.ApexToon.encode(data);
System.debug(toon);
```

**Output:**

```
id: 123
name: Ada Lovelace
active: true
tags[2]: developer,pioneer
```

### Basic Decoding

```apex
String toon = 'id: 123\nname: Ada Lovelace\nactive: true';
Object decoded = toonify.ApexToon.decode(toon);

Map<String, Object> result = (Map<String, Object>) decoded;
System.debug(result.get('name')); // Ada Lovelace
```

### JSON Bridge

```apex
// JSON to TOON
String json = '{"id":123,"name":"Ada"}';
String toon = toonify.ApexToon.encodeJson(json);

// TOON to JSON
String jsonOutput = toonify.ApexToon.decodeToJson(toon);
```

## Core Features

### ✅ Encoding

- **Primitives**: String, Integer, Long, Decimal, Boolean, null
- **Objects**: Maps and nested structures
- **Arrays**: Lists with automatic format detection
- **Tabular Arrays**: Optimized encoding for uniform object arrays
- **Custom Delimiters**: Comma (default), Tab, Pipe
- **Indentation Control**: Configurable spacing

### ✅ Decoding

- **Type Inference**: Automatic detection of primitives
- **Object Parsing**: Reconstruct nested Maps
- **Array Parsing**: Handle inline, tabular, and list formats
- **Path Expansion**: Support for dotted path notation
- **Strict/Lenient Modes**: Control error handling behavior

### ✅ SObject Support

- **Explicit Field Selection**: Choose which fields to encode
- **Relationship Navigation**: Support for `Account.Name` syntax
- **Custom Objects**: Full support for custom fields
- **Bulk Operations**: Efficient batch processing
- **Type Metadata**: Includes SObject type information

## API Reference

### Main Class: `ApexToon`

#### Encoding Methods

```apex
// Encode with default options
public static String encode(Object value)

// Encode with custom options
public static String encode(Object value, EncodeOptions options)

// Encode JSON string to TOON
public static String encodeJson(String jsonString)
public static String encodeJson(String jsonString, EncodeOptions options)
```

#### Decoding Methods

```apex
// Decode TOON to Object
public static Object decode(String toon)
public static Object decode(String toon, DecodeOptions options)

// Decode TOON to JSON string
public static String decodeToJson(String toon)
public static String decodeToJson(String toon, DecodeOptions options)
```

#### SObject Methods

```apex
// Encode SObjects with field selection
public static String encodeSObjects(List<SObject> records, List<Schema.SObjectField> fields)
public static String encodeSObjects(List<SObject> records, List<String> fieldNames)

// With custom options
public static String encodeSObjects(List<SObject> records, List<Schema.SObjectField> fields, EncodeOptions options)
public static String encodeSObjects(List<SObject> records, List<String> fieldNames, EncodeOptions options)
```

### Configuration Classes

#### EncodeOptions

```apex
public class EncodeOptions {
    public Integer indent;              // Spaces per level (default: 2)
    public ToonDelimiter delimiter;     // COMMA, TAB, PIPE (default: COMMA)

    // Constructor with defaults
    public EncodeOptions()

    // Constructor with custom values
    public EncodeOptions(Integer indent, ToonDelimiter delimiter)
}
```

#### DecodeOptions

```apex
public class DecodeOptions {
    public Integer indent;              // Expected indent (default: 2)
    public ToonDelimiter delimiter;     // Expected delimiter (default: COMMA)
    public Boolean strict;              // Throw on errors (default: true)
    public PathExpansion expandPaths;   // Path expansion mode (default: SAFE)

    // Constructors
    public DecodeOptions()
    public DecodeOptions(Integer indent, ToonDelimiter delimiter, Boolean strict, PathExpansion expandPaths)
}
```

#### Enums

```apex
public enum ToonDelimiter {
    COMMA,  // Default: value1,value2,value3
    TAB,    // Tab-separated: value1\tvalue2\tvalue3
    PIPE    // Pipe-separated: value1|value2|value3
}

public enum PathExpansion {
    SAFE,   // Expand nested paths when safe
    OFF     // No path expansion
}
```

## SObject Support

### Basic SObject Encoding

```apex
// Query records
List<Account> accounts = [
    SELECT Name, Industry, AnnualRevenue
    FROM Account
    LIMIT 100
];

// Define fields to encode
List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
    Account.Name,
    Account.Industry,
    Account.AnnualRevenue
};

// Encode to TOON
String toon = toonify.ApexToon.encodeSObjects(accounts, fields);
```

**Output:**

```
__type: Account
[100]{Name,Industry,AnnualRevenue}:
  Acme Corp,Technology,5000000
  Global Inc,Finance,12000000
  ...
```

### Relationship Fields

```apex
// Query with relationships
List<Contact> contacts = [
    SELECT FirstName, LastName, Email, Account.Name, Account.Industry
    FROM Contact
];

// Use field names (supports dot notation)
List<String> fieldNames = new List<String>{
    'FirstName',
    'LastName',
    'Email',
    'Account.Name',
    'Account.Industry'
};

String toon = toonify.ApexToon.encodeSObjects(contacts, fieldNames);
```

**Output:**

```
__type: Contact
[50]{FirstName,LastName,Email,Account.Name,Account.Industry}:
  John,Doe,john@example.com,Acme Corp,Technology
  Jane,Smith,jane@example.com,Global Inc,Finance
  ...
```

### Custom Objects

```apex
List<Custom_Product__c> products = [
    SELECT SKU__c, Name, Price__c, Inventory_Count__c
    FROM Custom_Product__c
    WHERE Active__c = true
];

List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
    Custom_Product__c.SKU__c,
    Custom_Product__c.Name,
    Custom_Product__c.Price__c,
    Custom_Product__c.Inventory_Count__c
};

String toon = toonify.ApexToon.encodeSObjects(products, fields);
```

## Advanced Usage

### Custom Delimiters

```apex
// Use tabs for better spreadsheet compatibility
EncodeOptions opts = new EncodeOptions(2, ToonDelimiter.TAB);
String toon = toonify.ApexToon.encode(data, opts);

// Use pipes for clarity with comma-heavy data
EncodeOptions pipeOpts = new EncodeOptions(2, ToonDelimiter.PIPE);
String toon = toonify.ApexToon.encode(addresses, pipeOpts);
```

### Complex Nested Structures

```apex
Map<String, Object> complex = new Map<String, Object>{
    'company' => new Map<String, Object>{
        'name' => 'Tech Corp',
        'employees' => new List<Object>{
            new Map<String, Object>{
                'name' => 'Alice',
                'role' => 'Engineer',
                'years' => 5
            },
            new Map<String, Object>{
                'name' => 'Bob',
                'role' => 'Designer',
                'years' => 3
            }
        }
    }
};

String toon = toonify.ApexToon.encode(complex);
```

**Output:**

```
company:
  name: Tech Corp
  employees[2]{name,role,years}:
    Alice,Engineer,5
    Bob,Designer,3
```

### Error Handling

```apex
try {
    String toon = toonify.ApexToon.encode(data);
} catch (ToonEncodingException e) {
    System.debug('Encoding failed: ' + e.getMessage());
}

try {
    Object result = toonify.ApexToon.decode(toonString);
} catch (ToonDecodingException e) {
    System.debug('Decoding failed: ' + e.getMessage());
}
```

### Lenient Decoding

```apex
// Don't throw on parse errors, return null instead
DecodeOptions lenient = new DecodeOptions();
lenient.strict = false;

Object result = toonify.ApexToon.decode(possiblyInvalidToon, lenient);
if (result == null) {
    System.debug('Failed to decode, but no exception thrown');
}
```

## Performance

### Token Savings

| Data Type                 | JSON Tokens | TOON Tokens | Savings |
| ------------------------- | ----------- | ----------- | ------- |
| Simple Object (10 fields) | 142         | 87          | 39%     |
| Nested Object (3 levels)  | 256         | 165         | 36%     |
| Array of Primitives (20)  | 95          | 45          | 53%     |
| Tabular Data (100 rows)   | 3,840       | 1,650       | 57%     |
| SObject Records (50)      | 2,100       | 980         | 53%     |

### Governor Limits

ApexToon is designed to be governor-limit friendly:

- **CPU Time**: Minimal overhead (~5-10ms per 100 records)
- **Heap Size**: Streaming approach, low memory footprint
- **SOQL Queries**: None (unless you query SObjects yourself)
- **DML Statements**: None

### Best Practices

```apex
// ✅ Good: Query only needed fields
List<Account> accounts = [SELECT Name, Industry FROM Account];
String toon = toonify.ApexToon.encodeSObjects(accounts,
    new List<Schema.SObjectField>{Account.Name, Account.Industry});

// ❌ Bad: Query all fields then filter
List<Account> accounts = [SELECT FIELDS(ALL) FROM Account];
String toon = toonify.ApexToon.encodeSObjects(accounts, someFields);

// ✅ Good: Batch large datasets
for (Integer i = 0; i < 1000; i += 100) {
    List<SObject> batch = records.subList(i, Math.min(i + 100, 1000));
    String toon = toonify.ApexToon.encodeSObjects(batch, fields);
    // Process batch
}
```

## Testing

### Test Coverage

**Current Coverage:** 95%+

All production classes have comprehensive test coverage:

- `ApexToonEncodingTest` - Encoding scenarios
- `ApexToonDecodingTest` - Decoding scenarios
- `ApexToonRoundTripTest` - Round-trip conversions
- `ToonSObjectEncoderTest` - SObject encoding
- Component-specific test classes for all utilities

### Example Test

```apex
@IsTest
private class MyApexToonTest {
    @IsTest
    static void testEncodeDecodeRoundTrip() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'id' => 123,
            'name' => 'Test',
            'active' => true
        };

        // When
        String toon = toonify.ApexToon.encode(original);
        Object decoded = toonify.ApexToon.decode(toon);

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Assert.areEqual(123, result.get('id'));
        Assert.areEqual('Test', result.get('name'));
        Assert.areEqual(true, result.get('active'));
    }
}
```

## Credits

### Toon-Format/Toon

- **Author:** [Johann Schopplich](https://github.com/johannschopplich)
- **Repository:** [Toon](https://github.com/toon-format/toon)
- **License:** MIT

### Original JToon Library

- **Author:** [Felipe Stanzani](https://github.com/felipestanzani)
- **Repository:** [JToon](https://github.com/felipestanzani/jtoon)
- **License:** MIT

### ApexToon
- **Author:** [David Pinchen](https://github.com/Eacaw)
- **Repository:** [ApexToon](https://github.com/Eacaw/ApexToon)
- **License:** MIT
- 
### Additional Resources

1. Review existing test cases for examples
2. Open an issue or pull request in the ApexToon repository
3. Refer to the specification for TOON [Toon SPEC.md](https://github.com/toon-format/toon/blob/main/SPEC.md)
4. Refer to the original [JToon documentation](https://github.com/felipestanzani/jtoon) for format specifications

---

- **Status:** Early Integration Testing
- **Version:** 0.2.0
