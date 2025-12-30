# Future Improvements

Dokumen ini mencatat fitur-fitur dan perbaikan yang direncanakan untuk pengembangan selanjutnya.

---

## ✅ Completed in v2.1 (2025-12-27)

### Print Statements Cleanup
**Status:** ✅ Selesai  
Debug print statements telah dihapus dari:
- `monitor_screen.dart`
- `history_screen.dart`
- `notification_provider.dart`

### Manual Mode Notification Persistence
**Status:** ✅ Selesai  
Manual mode notifications sekarang disimpan ke backend database.

### Delete Kit UI
**Status:** ✅ Selesai  
Long-press di kit selector untuk menghapus kit dari list user.

---

## 📋 Planned Improvements

### 1. Per-User Kit Nickname

**Priority:** Medium  
**Effort:** 1-2 jam

**Current:** Kit name bersifat global (first user yang add menentukan nama).

**Enhancement:**
```sql
ALTER TABLE user_kits ADD COLUMN nickname TEXT;
```

Setiap user bisa punya display name berbeda untuk kit yang sama.

---

### 2. Kit Removal Detection for Publisher

**Priority:** Low  
**Effort:** 30 menit

**Current:** Publisher terus publish ke kit yang sudah dihapus sampai restart.

**Enhancement:** Detect kit removal dari database dan stop publishing.

---

### 3. MQTT Instant Kit Notification

**Priority:** Low  
**Effort:** 1 jam

**Current:** Publisher poll setiap 3 detik untuk kit baru.

**Enhancement:** Backend publish ke topic `system/kit-added`, publisher subscribe untuk instant detection.

---

### 4. Exception Handling - No Silent Failures

**Priority:** Medium  
**Effort:** 2-3 jam

**Masalah:**
Error pada API calls di-catch dan return value kosong tanpa feedback ke user.

**Solusi:**
- Buat custom `ApiException` class
- Throw exception ke provider layer
- Tampilkan SnackBar ke user

---

### 5. Deprecated `withOpacity()` 

**Priority:** Low  
**Effort:** 15 menit

Multiple files menggunakan deprecated `color.withOpacity(0.5)`.

**Solusi:**
```diff
- color.withOpacity(0.5)
+ color.withValues(alpha: 0.5)
```

---

## 📝 Notes

- Test file warnings (dangling_library_doc_comments) bisa diabaikan
- Local variable naming (_kitId) bisa diperbaiki saat refactoring
