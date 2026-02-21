# Java Snippets Reference

All snippets are provided by [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) and expanded via LuaSnip + blink.cmp.

**Usage**: Type the prefix, press `<C-y>` to expand, then `<Tab>` / `<S-Tab>` to jump between placeholders.

## Core

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `main` | Public static main method | `public static void main(String[] args) { ... }` |
| `class` | Public class | `public class FileName { ... }` |
| `ctor` | Public constructor | `public ClassName() { super(); }` |
| `new` | Create new object | `Object foo = new Object();` |
| `package` | Package statement | `package PackageName` |
| `import` | Import statement | `import PackageName` |

## Output

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `sysout` | Print to stdout | `System.out.println();` |
| `syserr` | Print to stderr | `System.err.println();` |

## Control Flow

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `if` | if statement | `if (condition) { ... }` |
| `ifelse` | if/else statement | `if (condition) { ... } else { ... }` |
| `ifnull` | if null check | `if (condition == null) { ... }` |
| `ifnotnull` | if not null check | `if (condition != null) { ... }` |
| `switch` | Switch statement | `switch (key) { case value: ... }` |

## Loops

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `fori` | Indexed for loop | `for (int i = 0; i < max; i++) { ... }` |
| `foreach` | Enhanced for loop | `for (type var : iterable) { ... }` |
| `while` | While loop | `while (condition) { ... }` |
| `dowhile` | Do-while loop | `do { ... } while (condition);` |

## Error Handling

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `try_catch` | try/catch block | `try { ... } catch (Exception e) { ... }` |
| `try_resources` | try-with-resources | `try (resource) { ... } catch (Exception e) { ... }` |

## Methods

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `public_method` | Public method | `public void name() { ... }` |
| `private_method` | Private method | `private void name() { ... }` |
| `protected_method` | Protected method | `protected void name() { ... }` |
| `public_static_method` | Public static method | `public static void name() { ... }` |
| `private_static_method` | Private static method | `private static Type name() { ... }` |

## Fields

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `public_field` | Public field | `public String name;` |
| `private_field` | Private field | `private String name;` |
| `protected_field` | Protected field | `protected String name;` |

## Javadoc

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `/**` | Full Javadoc comment | Summary, description, `@param`, `@return`, `@example` |
| `/*` | Simple Javadoc comment | Summary and description only |
| `@param` | Parameter tag | `@param name description` |
| `@return` | Return tag | `@return description` |
| `@throws` | Throws tag | `@throws IOException description` |
| `@exception` | Exception tag (synonym of @throws) | `@exception IOException description` |
| `@see` | See-also reference | `@see item` |
| `@since` | Version tag | `@since 1.0` |
| `@author` | Author tag | `@author name` |
| `@version` | Version tag | `@version 1.39, 02/28/97` |
| `@deprecated` | Deprecation tag | `@deprecated As of JDK 1.1, replaced by ...` |
| `@serial` | Serial field doc | `@serial Field description` |
| `@serialField` | Serial field component | `@serialField name type description` |
| `@serialData` | Serial data description | `@serialData Data description` |

## Testing (JUnit + Mockito)

### Setup

| Prefix | Description |
|--------|-------------|
| `imports_junit4` | Import block for JUnit 4 + Mockito + Hamcrest |
| `imports_junit5` | Import block for JUnit 5 + Mockito + Hamcrest |
| `test_before` | `@BeforeEach` setup method (JUnit 5) |
| `test_after` | `@AfterEach` teardown method (JUnit 5) |
| `test_before_junit4` | `@Before` setup method (JUnit 4) |
| `test_after_junit4` | `@After` teardown method (JUnit 4) |

### Assertions

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `test_equals` | Assert equals | `assertEquals(a, b);` |
| `test_is` | Assert that is | `assertThat(result, is("42"));` |
| `test_null` | Assert null | `assertThat(result, nullValue());` |
| `test_not_null` | Assert not null | `assertThat(result, notNullValue());` |
| `test_nullorempty` | Assert null or empty string | `assertThat(result, emptyOrNullString());` |
| `test_not_nullorempty` | Assert not null/empty string | `assertThat(result, not(emptyOrNullString()));` |
| `test_isOneOf` | Assert is one of | `assertThat("Test", isOneOf("Test", "TDD"));` |
| `test_hasSize` | Assert collection size | `assertThat(list, hasSize(2));` |
| `test_hasItem` | Assert collection has item | `assertThat(list, hasItem("Test"));` |
| `test_hasItems` | Assert collection has items | `assertThat(list, hasItems("Test", "TDD"));` |
| `test_isIn` | Assert item is in collection | `assertThat("test", isIn(list));` |
| `test_exception` | Assert throws (JUnit 5) | `Assertions.assertThrows(Exception.class, () -> { ... });` |
| `test_parameterized` | Parameterized test (JUnit 5) | `@ParameterizedTest` + `@CsvSource` |

### Mockito

| Prefix | Description | Expands to |
|--------|-------------|------------|
| `mock_class` | Create mock object | `MyService mock = mock(MyService.class);` |
| `mock_method_return` | Mock method return value | `when(mock.method(any())).thenReturn("42");` |
| `mock_method_throw` | Mock method to throw | `when(mock.method()).thenThrow(new Exception());` |
| `mock_verify_once` | Verify called once | `verify(mock).method();` |
| `mock_verify_only` | Verify only call | `verify(mock, only()).method();` |
| `mock_verify_times` | Verify called N times | `verify(mock, times(2)).method();` |
| `mock_verify_never` | Verify never called | `verify(mock, never()).method();` |
| `mock_arg_capture` | Capture argument | `ArgumentCaptor` + `verify` + `getValue()` |
