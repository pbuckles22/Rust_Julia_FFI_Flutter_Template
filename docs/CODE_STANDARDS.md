# Code Standards and Best Practices

This document outlines the coding standards, best practices, and conventions used in the wrdlHelper Flutter-Rust FFI project. These standards ensure consistency, maintainability, and collaboration across the Flutter-Rust codebase.

## Table of Contents

1. [General Principles](#general-principles)
2. [Rust Standards](#rust-standards)
3. [Flutter/Dart Standards](#flutterdart-standards)
4. [FFI Integration Standards](#ffi-integration-standards)
5. [Linting Standards](#linting-standards)
6. [Testing Standards](#testing-standards)
7. [Documentation Standards](#documentation-standards)
8. [Version Control Standards](#version-control-standards)

## General Principles

### Code Quality
- **Readability**: Code should be self-documenting and easy to understand
- **Maintainability**: Code should be easy to modify and extend
- **Performance**: Optimize for performance while maintaining readability
- **Security**: Follow security best practices for all languages
- **Consistency**: Maintain consistent style across all languages

### Documentation
- **Comprehensive Comments**: Every public function must have detailed documentation
- **API Documentation**: All public APIs must be documented
- **Architecture Documentation**: Document system architecture and design decisions
- **Usage Examples**: Provide practical examples for all major features

### Testing
- **Comprehensive Coverage**: Aim for 90%+ test coverage
- **Unit Tests**: Test individual functions and methods
- **Integration Tests**: Test component interactions
- **Performance Tests**: Benchmark critical operations
- **Error Handling Tests**: Test error conditions and edge cases

## Rust Standards

### Code Style
```rust
/**
 * Function documentation following Rust conventions
 * 
 * This function demonstrates proper Rust documentation style with:
 * - Brief description
 * - Detailed explanation
 * - Parameter documentation
 * - Return value documentation
 * - Example usage
 * - Performance characteristics
 * 
 * # Arguments
 * - `param1`: Description of parameter 1
 * - `param2`: Description of parameter 2
 * 
 * # Returns
 * Description of return value
 * 
 * # Example
 * ```rust
 * let result = example_function("hello", 42);
 * assert_eq!(result, "expected_output");
 * ```
 * 
 * # Performance
 * - Time complexity: O(n)
 * - Space complexity: O(1)
 */
pub fn example_function(param1: String, param2: i32) -> String {
    // Implementation with clear variable names
    let processed_data = param1.to_uppercase();
    format!("{}_{}", processed_data, param2)
}
```

### Naming Conventions
- **Functions**: `snake_case`
- **Variables**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Types**: `PascalCase`
- **Modules**: `snake_case`

### Error Handling
```rust
// Use Result types for fallible operations
pub fn fallible_operation(input: &str) -> Result<String, String> {
    if input.is_empty() {
        return Err("Input cannot be empty".to_string());
    }
    
    Ok(input.to_uppercase())
}

// Use Option for nullable values
pub fn optional_operation(input: &str) -> Option<String> {
    if input.is_empty() {
        None
    } else {
        Some(input.to_uppercase())
    }
}
```

### FFI Integration
```rust
// Mark FFI functions with proper attributes
#[flutter_rust_bridge::frb(sync)]
pub fn ffi_function(input: String) -> String {
    // Implementation
    input.to_uppercase()
}

// Use proper memory management
#[flutter_rust_bridge::frb(sync)]
pub fn ffi_with_memory_management(data: Vec<u8>) -> Vec<u8> {
    // Process data without memory leaks
    data.into_iter().map(|b| b.wrapping_add(1)).collect()
}
```

## Flutter/Dart Standards

### Code Style
```dart
/**
 * Class documentation following Dart conventions
 * 
 * This class demonstrates proper Dart documentation style with:
 * - Brief description
 * - Detailed explanation
 * - Usage examples
 * - Performance characteristics
 * 
 * # Example
 * ```dart
 * final service = MyService();
 * final result = await service.performOperation();
 * ```
 */
class MyService {
  /// Private field with clear naming
  final String _baseUrl;
  
  /// Constructor with proper documentation
  /// 
  /// [baseUrl] The base URL for API calls
  MyService({required String baseUrl}) : _baseUrl = baseUrl;
  
  /// Public method with comprehensive documentation
  /// 
  /// Performs a specific operation with the given parameters.
  /// 
  /// [param1] Description of parameter 1
  /// [param2] Description of parameter 2
  /// 
  /// Returns a [Future] that completes with the operation result.
  /// 
  /// Throws [Exception] if the operation fails.
  Future<String> performOperation({
    required String param1,
    int param2 = 0,
  }) async {
    try {
      // Implementation with clear error handling
      final result = await _internalOperation(param1, param2);
      return result;
    } catch (e) {
      throw Exception('Operation failed: $e');
    }
  }
  
  /// Private method with clear implementation
  Future<String> _internalOperation(String param1, int param2) async {
    // Implementation details
    return 'result';
  }
}
```

### Naming Conventions
- **Classes**: `PascalCase`
- **Functions/Methods**: `camelCase`
- **Variables**: `camelCase`
- **Constants**: `camelCase` (prefer `const` over `final` for compile-time constants)
- **Files**: `snake_case.dart`

### State Management
```dart
// Use proper state management patterns
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
  
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String _data = '';
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const CircularProgressIndicator()
          : Text(_data),
    );
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await MyService().performOperation();
      setState(() {
        _data = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }
}
```

### FFI Integration
```dart
// Use proper FFI function calls
import 'package:my_working_ffi_app/src/rust/frb_generated.dart';

class FFIService {
  /// Call Rust function with proper error handling
  Future<String> callRustFunction(String input) async {
    try {
      final result = greet(name: input);
      return result;
    } catch (e) {
      throw Exception('FFI call failed: $e');
    }
  }
  
  /// Call Rust function with async operations
  Future<int> callAsyncRustFunction(int a, int b) async {
    try {
      final result = addNumbers(a: a, b: b);
      return result;
    } catch (e) {
      throw Exception('Async FFI call failed: $e');
    }
  }
}
```

## Linting Standards

### **CRITICAL: Generated Files Must Be Excluded from Linting**

#### **Files That Should NEVER Be Manually Edited:**
- `lib/src/rust/frb_generated.dart` - Auto-generated FFI bindings
- `lib/src/rust/frb_generated.io.dart` - Auto-generated FFI bindings for IO
- `lib/src/rust/frb_generated.web.dart` - Auto-generated FFI bindings for Web
- `lib/src/rust/api/wrdl_helper.dart` - Auto-generated API bindings
- Any file with `@generated` comment at the top
- Any file in `lib/src/rust/` directory (except manually written files)

#### **Why Generated Files Are Excluded:**
- **Auto-regenerated**: These files are overwritten every time FFI bindings are regenerated
- **Manual edits lost**: Any manual changes will be lost on next regeneration
- **Linter issues ignored**: Generated files may have linter issues that cannot be fixed manually
- **Build process**: These files are created by `flutter_rust_bridge` during build

#### **Linting Strategy for Generated Files:**
```bash
# ALWAYS exclude generated files from linting fixes
flutter analyze --no-fatal-infos 2>/dev/null | grep "public_member_api_docs" | grep -v "lib/src/rust/frb_generated" | grep -v "lib/src/rust/api/wrdl_helper"

# Count only manual files
flutter analyze --no-fatal-infos 2>/dev/null | grep "public_member_api_docs" | grep -v "lib/src/rust/" | wc -l
```

### **Linting Workflow:**

#### **Step 1: Identify File Types**
```bash
# Check if file is generated
head -5 lib/src/rust/frb_generated.dart
# Look for: "// This file is automatically generated"

# Check file location
# Generated files are in: lib/src/rust/
# Manual files are in: lib/services/, lib/widgets/, lib/models/, etc.
```

#### **Step 2: Focus on Manual Files Only**
- **Services**: `lib/services/` - Always safe to edit
- **Widgets**: `lib/widgets/` - Always safe to edit  
- **Models**: `lib/models/` - Always safe to edit
- **Controllers**: `lib/controllers/` - Always safe to edit
- **Exceptions**: `lib/exceptions/` - Always safe to edit
- **State Management**: `lib/state_management/` - Always safe to edit
- **Utils**: `lib/utils/` - Always safe to edit

#### **Step 3: Linting Commands**
```bash
# Lint only manual files (exclude generated)
flutter analyze --no-fatal-infos 2>/dev/null | grep "linter_rule" | grep -v "lib/src/rust/"

# Count issues in manual files only
flutter analyze --no-fatal-infos 2>/dev/null | grep "linter_rule" | grep -v "lib/src/rust/" | wc -l

# Get file breakdown (manual files only)
flutter analyze --no-fatal-infos 2>/dev/null | grep "linter_rule" | grep -v "lib/src/rust/" | cut -d: -f1 | sort | uniq -c | sort -nr
```

### **Common Linter Rules and Fixes:**

#### **public_member_api_docs**
- **Rule**: All public members must have documentation
- **Fix**: Add `/// Documentation comment` above public fields, methods, constructors
- **Example**:
```dart
class MyClass {
  /// The main data field
  final String data;
  
  /// Creates a new instance
  const MyClass({required this.data});
  
  /// Performs an operation
  void doSomething() {}
}
```

#### **prefer_expression_function_bodies**
- **Rule**: Use expression function bodies for simple functions
- **Fix**: Convert `{ return value; }` to `=> value;`
- **Example**:
```dart
// Before
String getName() {
  return name;
}

// After  
String getName() => name;
```

#### **type_annotate_public_apis**
- **Rule**: Public APIs must have explicit type annotations
- **Fix**: Add return type annotations to public methods
- **Example**:
```dart
// Before
getValue() => value;

// After
String getValue() => value;
```

#### **avoid_catches_without_on_clauses**
- **Rule**: Catch clauses should specify exception types
- **Fix**: Add `on ExceptionType` to catch clauses
- **Example**:
```dart
// Before
try {
  riskyOperation();
} catch (e) {
  handleError(e);
}

// After
try {
  riskyOperation();
} on SpecificException catch (e) {
  handleError(e);
} on Exception catch (e) {
  handleGenericError(e);
}
```

### **Linting Best Practices:**

#### **Systematic Approach**
1. **Identify linter rule**: `flutter analyze | grep "rule_name"`
2. **Count total issues**: `wc -l` to get total count
3. **Focus on manual files**: Exclude generated files
4. **Fix by file**: Work on one file at a time
5. **Verify progress**: Re-run linter after each file
6. **Commit frequently**: Commit after each significant batch

#### **File Priority Order**
1. **Services** (highest priority - core functionality)
2. **Models** (data structures)
3. **Controllers** (business logic)
4. **Widgets** (UI components)
5. **Exceptions** (error handling)
6. **Utils** (utility functions)

#### **Linting Tools Integration**
```bash
# VS Code settings for automatic linting
{
  "dart.lineLength": 80,
  "dart.enableSdkFormatter": true,
  "dart.runPubGetOnPubspecChanges": true,
  "dart.analysisExcludedFolders": [
    "lib/src/rust/"
  ]
}
```

### **Linting Documentation Requirements:**

#### **Every Linting Session Must Document:**
1. **Total issues found**: Before starting
2. **Files excluded**: Generated files that were skipped
3. **Issues fixed**: Number of issues resolved
4. **Files modified**: List of files that were changed
5. **Remaining issues**: Count of unfixed issues
6. **Next steps**: What to tackle next

#### **Example Linting Session Documentation:**
```markdown
## Linting Session: public_member_api_docs

### Initial State:
- Total issues: 405
- Generated files (excluded): 267 issues
- Manual files (target): 138 issues

### Files Fixed:
- lib/services/game_service.dart: 17 issues fixed
- lib/widgets/game_grid.dart: 6 issues fixed
- lib/models/statistical_analysis.dart: 4 issues fixed

### Progress:
- Issues fixed: 27
- Remaining: 111
- Completion: 19.6%

### Next Steps:
- Continue with lib/controllers/ files
- Focus on lib/exceptions/ files
- Target: Complete all manual files
```

### **Linting Automation:**

#### **Pre-commit Hooks**
```bash
#!/bin/bash
# .git/hooks/pre-commit
echo "Running linter on manual files only..."
flutter analyze --no-fatal-infos 2>/dev/null | grep -v "lib/src/rust/" | grep "error"
if [ $? -eq 0 ]; then
  echo "Linting errors found in manual files. Please fix before committing."
  exit 1
fi
echo "Linting passed for manual files."
```

#### **CI/CD Integration**
```yaml
# .github/workflows/lint.yml
- name: Lint Manual Files Only
  run: |
    flutter analyze --no-fatal-infos 2>/dev/null | grep -v "lib/src/rust/" | grep "error"
    if [ $? -eq 0 ]; then
      echo "Linting errors found"
      exit 1
    fi
```

### **Linting Troubleshooting:**

#### **Common Issues:**
1. **Generated file confusion**: Always check file location and content
2. **Lost changes**: Never edit generated files
3. **Linter count mismatch**: Use proper exclusion filters
4. **Build failures**: Regenerate FFI bindings if needed

#### **Verification Commands:**
```bash
# Verify file is not generated
head -5 lib/src/rust/frb_generated.dart | grep -q "generated" && echo "GENERATED - SKIP" || echo "MANUAL - FIX"

# Check file location
echo $file | grep -q "lib/src/rust/" && echo "GENERATED LOCATION - SKIP" || echo "MANUAL LOCATION - FIX"
```

## Julia Standards

### Code Style
```julia
"""
    Function documentation following Julia conventions

This function demonstrates proper Julia documentation style with:
- Brief description
- Detailed explanation
- Parameter documentation
- Return value documentation
- Example usage
- Performance characteristics

# Arguments
- `param1::String`: Description of parameter 1
- `param2::Int`: Description of parameter 2

# Returns
- `String`: Description of return value

# Example
```julia
result = example_function("hello", 42)
@assert result == "expected_output"
```

# Performance
- Time complexity: O(n)
- Space complexity: O(1)
"""
function example_function(param1::String, param2::Int)::String
    # Implementation with clear variable names
    processed_data = uppercase(param1)
    return "$processed_data_$param2"
end
```

### Naming Conventions
- **Functions**: `snake_case`
- **Variables**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Types**: `PascalCase`
- **Modules**: `PascalCase`

### Error Handling
```julia
# Use proper error handling
function fallible_operation(input::String)::Union{String, Nothing}
    if isempty(input)
        return nothing
    end
    
    return uppercase(input)
end

# Use exceptions for serious errors
function critical_operation(input::String)::String
    if isempty(input)
        throw(ArgumentError("Input cannot be empty"))
    end
    
    return uppercase(input)
end
```

### FFI Integration
```julia
# Use proper C-compatible function signatures
function julia_ffi_function(input::Cstring)::Cstring
    input_str = unsafe_string(input)
    result = uppercase(input_str)
    return Base.unsafe_convert(Cstring, result)
end

# Use proper memory management
function julia_ffi_with_memory(data::Vector{UInt8})::Vector{UInt8}
    # Process data without memory leaks
    return [b + 1 for b in data]
end
```

## FFI Integration Standards

### Cross-Language Communication
```rust
// Rust side - proper FFI function
#[flutter_rust_bridge::frb(sync)]
pub fn rust_to_dart_function(input: String) -> String {
    // Process input
    input.to_uppercase()
}
```

```dart
// Dart side - proper FFI call
import 'package:my_working_ffi_app/src/rust/frb_generated.dart';

String callRustFunction(String input) {
  return rustToDartFunction(input: input);
}
```

```julia
# Julia side - proper FFI function
function julia_ffi_function(input::Cstring)::Cstring
    input_str = unsafe_string(input)
    result = uppercase(input_str)
    return Base.unsafe_convert(Cstring, result)
end
```

### Data Type Mapping
| Rust | Dart | Julia | Notes |
|------|------|-------|-------|
| `String` | `String` | `Cstring` | UTF-8 strings |
| `i32` | `int` | `Int32` | 32-bit integers |
| `f64` | `double` | `Float64` | 64-bit floats |
| `Vec<T>` | `List<T>` | `Vector{T}` | Dynamic arrays |
| `bool` | `bool` | `Bool` | Boolean values |

### Memory Management
- **Rust**: Automatic memory management with ownership
- **Dart**: Garbage collected, automatic memory management
- **Julia**: Garbage collected, automatic memory management
- **FFI**: Use proper memory management for cross-language calls

## Testing Standards

### Test Structure
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_function_name() {
        // Arrange
        let input = "test_input";
        let expected = "expected_output";
        
        // Act
        let result = function_under_test(input);
        
        // Assert
        assert_eq!(result, expected);
    }
    
    #[test]
    fn test_error_conditions() {
        // Test error conditions
        assert!(function_under_test("").is_err());
    }
}
```

### Test Categories
1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test component interactions
3. **Performance Tests**: Benchmark critical operations
4. **Error Handling Tests**: Test error conditions
5. **Memory Tests**: Test for memory leaks

### Test Coverage
- Aim for 90%+ test coverage
- Test all public APIs
- Test error conditions
- Test edge cases
- Test performance characteristics

## Documentation Standards

### Code Comments
```rust
// Single line comment for simple explanations

/**
 * Multi-line comment for complex explanations
 * that span multiple lines
 */

/// Documentation comment for public APIs
/// 
/// This function does something important.
/// 
/// # Arguments
/// - `param`: Description of parameter
/// 
/// # Returns
/// Description of return value
/// 
/// # Example
/// ```rust
/// let result = example_function("hello");
/// ```
pub fn example_function(param: &str) -> String {
    // Implementation
}
```

### API Documentation
- Document all public functions
- Include parameter descriptions
- Include return value descriptions
- Include usage examples
- Include performance characteristics
- Include error conditions

### Architecture Documentation
- Document system architecture
- Document design decisions
- Document integration points
- Document performance considerations
- Document security considerations

## Version Control Standards

### Commit Messages
```
type(scope): brief description

Detailed description of changes made.

- Bullet point for specific changes
- Another bullet point for other changes

Closes #123
```

### Branch Naming
- `feature/feature-name`: New features
- `bugfix/bug-description`: Bug fixes
- `hotfix/critical-fix`: Critical fixes
- `refactor/refactor-description`: Code refactoring
- `test/test-description`: Test improvements

### Pull Request Standards
- Clear title and description
- Link to related issues
- Include test results
- Include performance benchmarks
- Code review required
- All tests must pass

## Performance Standards

### Benchmarking
- Benchmark critical operations
- Monitor performance regressions
- Set performance thresholds
- Document performance characteristics

### Optimization
- Profile before optimizing
- Optimize bottlenecks first
- Maintain code readability
- Document optimization decisions

## Security Standards

### Input Validation
- Validate all inputs
- Sanitize user data
- Use proper error handling
- Avoid buffer overflows

### Memory Safety
- Use safe memory management
- Avoid memory leaks
- Use proper error handling
- Test memory usage

## Conclusion

These standards ensure consistency, maintainability, and collaboration across the multi-language codebase. All team members should follow these standards and contribute to their improvement.

For questions or suggestions about these standards, please create an issue or discuss in team meetings.
