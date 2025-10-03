# Changelog

All notable changes to the ZipTools project will be documented in this file.

## [1.4.0] - 2025-10-03

### Added
- New bugs.md file for tracking bug reports and fixes
- Added CZ_NULL constant to replace literal zeros for better code clarity
- Added CZ_TRACEON equate in ZipEquates.inc to centralize debug control

### Changed
- Enhanced DLL loading mechanism for better compatibility with third-party tools
- Improved InstallZipTools.bat with interactive prompts before overwriting existing zlib DLLs
- Removed dependency on static library files (zlib1.lib and zlibwapi.lib) in favor of dynamic loading
- Standardized debug handling via CZ_TRACEON instead of hardcoded czDebugOn flags
- Improved code organization in ZipFileUtilitiesClass with better variable grouping

### Fixed
- Fixed bug with file metadata not being included when zipping single files
- Fixed bug in ZipStringUtilsClass.GetFileExtension function
- Enhanced path handling logic in ZipFileUtilitiesClass.CreateDirectoriesFromPath
- Improved error handling in installation script

## [1.3.0] - 2025-09-24

### Changed
- Added ,VIRTUAL to key methods across the codebase to improve extensibility:
  - ZipToolsClass: SelectFilesToZip, SelectFolderToZip, ExtractZipFile, CreateZipFile
  - ZipErrorClass: SetError, GetErrorMessage
  - ZipFileUtilitiesClass: CreateDirectoriesFromPath, SelectFiles, SelectZipFolder, SelectFolder, SelectFile
  - ZipReaderClass: ExtractZipFile, GetZipContents
  - ZipWriterClass: CompressFileToBuffer, ReadFileToBuffer, WritePrecompressedToZip
  - ZipWorkerClass: InitThreadData, BuildQueue
  
  ### Added
  - GitHub contribution templates:
    - Bug report issue template
    - Feature request issue template
    - Pull request template
  - Comprehensive CONTRIBUTING.md guide with:
    - Repository setup instructions
    - Clarion environment setup
    - Coding standards and conventions
    - Testing procedures
    - Contribution workflow
  
  ### Improved
- Enhanced inheritance support by marking key extension points as virtual
- Better support for derived classes to customize behavior without rewriting entire classes

## [1.2.0] - 2025-09-24

### ⚠️ Breaking Changes ⚠️
- Renamed `CZipClass` → `ZipToolsClass` for better naming consistency with library
- Renamed `ZipQ` → `ZipQueueType` for better type clarity
- Renamed `ZipOptions` → `ZipOptionsType` for consistency
- Renamed `UnzipOptions` → `UnzipOptionsType` for consistency
- Renamed `UnzipFileInfo` → `UnzipFileInfoType` for consistency
- Renamed `FileUtilitiesClass` → `ZipFileUtilitiesClass` for better naming consistency

### Added
- Enhanced InstallZipTools.bat script to automatically remove obsolete files from previous versions

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