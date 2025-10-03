# Bugs and Fixes

## Bug: File Metadata Missing When Zipping Single Files

### Reported By
Marcelo_Sanseau

### Reported On
October 1, 2025

### Issue Link
Reported privately (no public issue link available)

### Issue Description
When a single file was selected to zip, the file metadata (date, time, size) was not being included in the zip file. This issue was reported by a user who noticed that file data such as date and time were missing in the first run of the provided test program when a single file was selected.

### Root Cause
The issue was located in `ZipFileUtilitiesClass.clw`. The problem was in the conditional checks:

```clarion
IF FileQueue.ZipFileName = CLIP(aFILE:queue.name)
  FileQueue.ZipFileDate       = aFILE:queue.date
  FileQueue.ZipFileTime       = aFILE:queue.time
  FileQueue.uncompressed_size = aFILE:queue.size
END
```

This condition was problematic because:
- `FileQueue.ZipFileName` contains the full path to the file
- `aFILE:queue.name` contains just the filename without the path
- The comparison would fail in most cases, especially for single file selection, resulting in the metadata not being assigned

### Fix Applied
The fix removed the conditional check entirely, ensuring that file metadata is always included for both single-file and multi-file selections:

1. In the single-file selection section (around line 76):
```clarion
! Always set file metadata for single file selection
! The original condition was comparing full path with just filename
FileQueue.ZipFileDate       = aFILE:queue.date
FileQueue.ZipFileTime       = aFILE:queue.time
FileQueue.uncompressed_size = aFILE:queue.size
```

2. For consistency, the same fix was applied to the multi-file selection section (around line 58).

### Date Fixed
October 3, 2025

### Fixed By
This issue was identified and fixed based on a user report that mentioned the problem was in the `ZipFileUtilitiesClass.clw` file, specifically in the condition `IF FileQueue.ZipFileName = CLIP(aFILE:queue.name)` when the condition is not met.