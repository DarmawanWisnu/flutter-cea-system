# Future Improvements

Dokumen ini mencatat fitur-fitur dan perbaikan yang direncanakan untuk pengembangan selanjutnya.

---

## 1. Exception Handling - No Silent Failures

**Status:** Belum diimplementasi  
**Priority:** Medium  
**Effort:** 2-3 jam

**Masalah:**
Error pada API calls di-catch dan return value kosong tanpa feedback ke user.

```dart
} catch (e, s) {
  debugPrint('getLatestTelemetry error: $e\n$s');
  return null;  // User tidak tahu ada error
}
```

**Solusi:**
- Buat custom `ApiException` class
- Throw exception ke provider layer
- Tampilkan SnackBar ke user

---

## 2. Code Quality Issues (Flutter Analyze)

**Status:** Belum diperbaiki  
**Priority:** Low  
**Effort:** 15-30 menit

### 2.1 Print Statements in Production

| File | Line | Issue |
|------|------|-------|
| `lib/features/monitor/monitor_screen.dart` | 120, 147, 191, 195 | `print()` harus diganti `debugPrint()` |
| `lib/utils/firebase_error_handler.dart` | 20 | `print()` harus diganti `debugPrint()` |

**Solusi:**
```diff
- print('Debug message');
+ debugPrint('Debug message');
```

### 2.2 Deprecated `withOpacity()`

| File | Line |
|------|------|
| `lib/features/home/home_screen.dart` | 398 |
| `lib/features/monitor/monitor_screen.dart` | 340, 373 |
| `lib/features/auth/forgot_password_screen.dart` | 121 |

**Solusi:**
```diff
- color.withOpacity(0.5)
+ color.withValues(alpha: 0.5)
```

### 2.3 Local Variable Naming

| File | Line | Issue |
|------|------|-------|
| `lib/features/monitor/monitor_screen.dart` | 202 | `_kitId` → `kitId` |
| `lib/features/monitor/monitor_screen.dart` | 410 | Unnecessary underscores |

**Solusi:**
Hilangkan underscore prefix untuk local variables.

---

## 3. Test File Warnings

**Status:** Bisa diabaikan  
**Priority:** Low  

| Category | Files | Issue |
|----------|-------|-------|
| `dangling_library_doc_comments` | 15+ test files | Doc comment tanpa target |
| Type arguments | `mock_providers.dart` | Non-type as type argument |

**Note:** Ini hanya info-level warnings dan tidak mempengaruhi functionality.
