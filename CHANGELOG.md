# Changelog

All notable changes to the ZipTools project will be documented in this file.

## [1.2.0] - Unreleased

### ⚠️ Breaking Changes ⚠️
- Renamed `CZipClass` → `ZipToolsClass` for better naming consistency with library
- Renamed `ZipQ` → `ZipQueueType` for better type clarity
- Renamed `ZipOptions` → `ZipOptionsType` for consistency
- Renamed `UnzipOptions` → `UnzipOptionsType` for consistency
- Renamed `UnzipFileInfo` → `UnzipFileInfoType` for consistency
- Renamed `FileUtilitiesClass` → `ZipFileUtilitiesClass` for better naming consistency

## [1.1.0] - 2025-09-24

### Added
- Dynamic loading of zlib and zlibwapi DLLs at runtime
- Clarion template (ZipTools.tpl) for easy integration
- InstallZipTools.bat script for copying files to Clarion directories
- Developer resource details to zlibwapi.dll

### Changed
- Updated documentation to reflect new features
- Improved DLL loading mechanism for better compatibility

### Fixed
- Potential DLL conflicts with other libraries

## [1.0.0] - 2025-09-23

### Added
- Initial release of CZipClass
- Multi-threaded ZIP file creation and extraction
- Adaptive compression strategies
- Password protection support
- Progress reporting
- Comprehensive error handling
- Memory management optimizations