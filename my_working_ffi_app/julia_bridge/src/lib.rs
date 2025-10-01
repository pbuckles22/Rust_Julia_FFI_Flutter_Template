/**
 * Julia-Rust Bridge - Dedicated C FFI Library
 * 
 * This crate provides a clean, dedicated C FFI interface for Julia to call Rust functions.
 * It's separate from the flutter_rust_bridge to avoid conflicts and ensure proper symbol export.
 * 
 * # Architecture
 * - Pure C FFI with #[no_mangle] functions
 * - No flutter_rust_bridge dependencies
 * - Clean symbol export for Julia's dlsym
 * - Proper memory management
 * 
 * # Usage
 * Julia loads this library and calls the exported C functions directly.
 */

use std::collections::HashMap;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_double, c_void};
use std::ptr;

// ============================================================================
// C FFI Functions for Julia Integration
// ============================================================================

/**
 * C FFI: Initialize Julia-Rust bridge
 * 
 * This function is called by Julia to initialize the bridge.
 * 
 * # Arguments
 * - `_context`: Unused context pointer
 * 
 * # Returns
 * - 0 on success, non-zero on failure
 */
#[no_mangle]
pub extern "C" fn init_bridge(_context: *mut c_void) -> c_int {
    // For now, just return success
    // In a full implementation, we'd set up shared memory, etc.
    0
}

/**
 * C FFI: Cleanup Julia-Rust bridge
 * 
 * This function is called by Julia to cleanup the bridge.
 * 
 * # Arguments
 * - `_context`: Unused context pointer
 * 
 * # Returns
 * - 0 on success, non-zero on failure
 */
#[no_mangle]
pub extern "C" fn cleanup_bridge(_context: *mut c_void) -> c_int {
    // For now, just return success
    // In a full implementation, we'd cleanup shared memory, etc.
    0
}

/**
 * C FFI: Rust greet function
 * 
 * This function is called by Julia to use Rust's greet functionality.
 * 
 * # Arguments
 * - `name`: C string containing the name to greet
 * 
 * # Returns
 * - C string containing the greeting (must be freed by caller)
 * 
 * # Safety
 * The input string must be valid UTF-8 and null-terminated.
 * The returned string must be freed by the caller.
 */
#[no_mangle]
pub extern "C" fn rust_greet(name: *const c_char) -> *mut c_char {
    if name.is_null() {
        return ptr::null_mut();
    }
    
    unsafe {
        let name_str = match CStr::from_ptr(name).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        };
        
        let greeting = format!("Hello from Rust, {}!", name_str);
        let c_greeting = match CString::new(greeting) {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        };
        
        c_greeting.into_raw()
    }
}

/**
 * C FFI: Rust add_numbers function
 * 
 * This function is called by Julia to use Rust's safe integer addition.
 * 
 * # Arguments
 * - `a`: First integer
 * - `b`: Second integer
 * 
 * # Returns
 * - Sum as c_int, or -1 if overflow occurred
 * 
 * # Safety
 * Handles integer overflow safely.
 */
#[no_mangle]
pub extern "C" fn rust_add_numbers(a: c_int, b: c_int) -> c_int {
    match a.checked_add(b) {
        Some(result) => result,
        None => -1, // Return -1 for overflow
    }
}

/**
 * C FFI: Rust multiply_floats function
 * 
 * This function is called by Julia to use Rust's floating-point multiplication.
 * 
 * # Arguments
 * - `a`: First float
 * - `b`: Second float
 * 
 * # Returns
 * - Product as c_double
 */
#[no_mangle]
pub extern "C" fn rust_multiply_floats(a: c_double, b: c_double) -> c_double {
    a * b
}

/**
 * C FFI: Rust get_string_lengths function
 * 
 * This function is called by Julia to use Rust's string length analysis.
 * 
 * # Arguments
 * - `strings`: Array of C strings
 * - `count`: Number of strings in the array
 * 
 * # Returns
 * - Array of string lengths (must be freed by caller)
 * 
 * # Safety
 * The input strings must be valid UTF-8 and null-terminated.
 * The returned array must be freed by the caller.
 */
#[no_mangle]
pub extern "C" fn rust_get_string_lengths(strings: *const *const c_char, count: c_int) -> *mut c_int {
    if strings.is_null() || count <= 0 {
        return ptr::null_mut();
    }
    
    unsafe {
        let mut lengths = Vec::with_capacity(count as usize);
        
        for i in 0..count {
            let string_ptr = *strings.offset(i as isize);
            if string_ptr.is_null() {
                return ptr::null_mut();
            }
            
            let string_str = match CStr::from_ptr(string_ptr).to_str() {
                Ok(s) => s,
                Err(_) => return ptr::null_mut(),
            };
            
            lengths.push(string_str.len() as c_int);
        }
        
        let result = lengths.into_boxed_slice();
        Box::into_raw(result) as *mut c_int
    }
}

/**
 * C FFI: Rust create_string_map function
 * 
 * This function is called by Julia to use Rust's HashMap functionality.
 * 
 * # Arguments
 * - `keys`: Array of C strings for keys
 * - `values`: Array of C strings for values
 * - `count`: Number of key-value pairs
 * 
 * # Returns
 * - Pointer to HashMap (must be freed by caller)
 * 
 * # Safety
 * The input strings must be valid UTF-8 and null-terminated.
 * The returned HashMap must be freed by the caller.
 */
#[no_mangle]
pub extern "C" fn rust_create_string_map(keys: *const *const c_char, values: *const *const c_char, count: c_int) -> *mut c_void {
    if keys.is_null() || values.is_null() || count <= 0 {
        return ptr::null_mut();
    }
    
    unsafe {
        let mut map = HashMap::new();
        
        for i in 0..count {
            let key_ptr = *keys.offset(i as isize);
            let value_ptr = *values.offset(i as isize);
            
            if key_ptr.is_null() || value_ptr.is_null() {
                return ptr::null_mut();
            }
            
            let key_str = match CStr::from_ptr(key_ptr).to_str() {
                Ok(s) => s.to_string(),
                Err(_) => return ptr::null_mut(),
            };
            
            let value_str = match CStr::from_ptr(value_ptr).to_str() {
                Ok(s) => s.to_string(),
                Err(_) => return ptr::null_mut(),
            };
            
            map.insert(key_str, value_str);
        }
        
        let boxed_map = Box::new(map);
        Box::into_raw(boxed_map) as *mut c_void
    }
}

/**
 * C FFI: Rust factorial function
 * 
 * This function is called by Julia to use Rust's factorial computation.
 * 
 * # Arguments
 * - `n`: Number to compute factorial for
 * 
 * # Returns
 * - Factorial result
 */
#[no_mangle]
pub extern "C" fn rust_factorial(n: c_int) -> c_int {
    if n <= 1 {
        1
    } else {
        n * rust_factorial(n - 1)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    #[test]
    fn test_init_bridge() {
        assert_eq!(init_bridge(ptr::null_mut()), 0);
    }

    #[test]
    fn test_cleanup_bridge() {
        assert_eq!(cleanup_bridge(ptr::null_mut()), 0);
    }

    #[test]
    fn test_rust_greet() {
        let name = CString::new("Alice").unwrap();
        let result_ptr = rust_greet(name.as_ptr());
        assert!(!result_ptr.is_null());
        
        unsafe {
            let result = CStr::from_ptr(result_ptr).to_str().unwrap();
            assert_eq!(result, "Hello from Rust, Alice!");
            // Free the string
            let _ = CString::from_raw(result_ptr);
        }
    }

    #[test]
    fn test_rust_add_numbers() {
        assert_eq!(rust_add_numbers(5, 3), 8);
        assert_eq!(rust_add_numbers(i32::MAX, 1), -1); // Overflow
    }

    #[test]
    fn test_rust_multiply_floats() {
        assert_eq!(rust_multiply_floats(2.5, 4.0), 10.0);
    }

    #[test]
    fn test_rust_factorial() {
        assert_eq!(rust_factorial(5), 120);
        assert_eq!(rust_factorial(0), 1);
    }
}