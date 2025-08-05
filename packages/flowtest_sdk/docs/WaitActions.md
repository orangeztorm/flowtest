# FlowTest SDK - Wait Action Best Practices

## 🎯 Dynamic vs Static Waits: The Complete Guide

The FlowTest SDK implements **industry best practices** for test automation waits, preventing flaky tests and infinite hangs.

### ✅ **Recommended: Dynamic/Conditional Waits**

**Wait for a condition to be met (with timeout safety):**

```json
{
  "action": "wait",
  "expects": [{ "target": "text:Welcome!", "condition": "exists" }],
  "value": "10000" // Optional: Custom timeout (10 seconds)
}
```

**How it works:**

- ✅ **Fast**: Continues immediately when condition is met
- ✅ **Reliable**: Waits as long as needed (up to timeout)
- ✅ **Safe**: Never hangs forever (timeout prevents infinite wait)

### ⚠️ **Use Sparingly: Static Waits**

**Fixed duration wait (only when absolutely necessary):**

```json
{
  "action": "wait",
  "value": "1000" // Wait exactly 1 second
}
```

**When to use:**

- Animation delays where timing is critical
- Debugging (temporary waits to observe behavior)
- Hardware-specific delays (camera initialization, etc.)

## 🛡️ **Safety Features Built Into FlowTest SDK**

### **1. Automatic Timeout Protection**

```dart
// Every conditional wait has a timeout to prevent infinite hangs
await _waitUntil(
  step.expects!,
  timeoutMs: int.tryParse(step.value ?? '5000') ?? 5000,
  //                      \_____/    \___/
  //                        |         |
  //                   Custom     Default
  //                  timeout    (5 seconds)
);
```

### **2. Smart Default Handling**

- **Custom timeout**: `"value": "15000"` → waits up to 15 seconds
- **No timeout specified**: Automatically uses 5-second default
- **Invalid timeout**: Falls back to 5-second default

### **3. Production-Ready Error Messages**

```dart
// When a conditional wait times out:
throw TestFailure('wait-until timed out after 10000 ms');
```

## 📊 **Real-World Examples**

### **Example 1: Login Flow with Network Delay**

```json
[
  { "action": "tap", "target": "@email_field" },
  { "action": "input", "target": "@email_field", "value": "user@example.com" },
  { "action": "tap", "target": "@password_field" },
  { "action": "input", "target": "@password_field", "value": "password123" },
  { "action": "tap", "target": "@login_button" },
  {
    "action": "wait",
    "expects": [{ "target": "text:Welcome!", "condition": "exists" }],
    "value": "15000" // Allow up to 15s for server response
  }
]
```

### **Example 2: Loading States**

```json
[
  { "action": "tap", "target": "@refresh_button" },
  {
    "action": "wait",
    "expects": [{ "target": "text:Loading...", "condition": "exists" }],
    "value": "2000" // Loading indicator should appear quickly
  },
  {
    "action": "wait",
    "expects": [{ "target": "text:Loading...", "condition": "notExists" }],
    "value": "30000" // Data loading might take longer
  }
]
```

### **Example 3: Animation Completion**

```json
[
  { "action": "tap", "target": "@menu_button" },
  {
    "action": "wait",
    "expects": [{ "target": "@side_menu", "condition": "exists" }],
    "value": "3000" // Wait for slide-in animation
  }
]
```

## 🚀 **Performance Benefits**

| Scenario         | Static Wait       | Dynamic Wait         | Time Saved      |
| ---------------- | ----------------- | -------------------- | --------------- |
| **Fast Network** | 5 seconds         | 0.5 seconds          | **90% faster**  |
| **Slow Network** | 5 seconds (fails) | 8 seconds (succeeds) | **No failures** |
| **Average Case** | 5 seconds         | 2 seconds            | **60% faster**  |

## 🔧 **Configuration Options**

### **Default Timeout (Globally)**

```dart
// In FlowRunner class
static const int _defaultWaitTimeoutMs = 5000;  // 5 seconds
```

### **Per-Step Custom Timeouts**

```json
// Short timeout for fast operations
{"action": "wait", "expects": [...], "value": "2000"}

// Long timeout for slow operations
{"action": "wait", "expects": [...], "value": "30000"}

// Use default timeout (5 seconds)
{"action": "wait", "expects": [...]}
```

## ✅ **Best Practices Summary**

1. **Always prefer conditional waits** over static waits
2. **Set appropriate timeouts** for different operations:
   - UI animations: 2-5 seconds
   - Network requests: 10-30 seconds
   - File operations: 5-15 seconds
3. **Use descriptive expectations** that clearly indicate what you're waiting for
4. **Test with different network conditions** to validate timeout values
5. **Monitor CI/CD logs** to identify tests that frequently timeout

---

**The FlowTest SDK wait system is designed for production reliability and developer productivity. It prevents the two most common test automation failures: flaky tests and infinite hangs.**
