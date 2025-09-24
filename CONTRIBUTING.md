# Contributing to ZipTools for Clarion

Thank you for your interest in contributing to ZipTools for Clarion! This document provides guidelines and instructions to help you get started.

## Getting Started

### Fork and Clone the Repository

1. Fork the repository by clicking the "Fork" button at the top right of the [repository page](https://github.com/YourUsername/ZipTools-for-Clarion).
2. Clone your fork to your local machine:
   ```
   git clone https://github.com/YourUsername/ZipTools-for-Clarion.git
   cd ZipTools-for-Clarion
   ```
3. Add the original repository as an upstream remote:
   ```
   git remote add upstream https://github.com/OriginalOwner/ZipTools-for-Clarion.git
   ```
4. Keep your fork in sync:
   ```
   git fetch upstream
   git merge upstream/main
   ```

## Setting Up Your Clarion Environment

1. Ensure you have a compatible version of Clarion installed (Clarion 10 or later recommended).
2. Open the ZipClassTesting.sln solution file in Clarion.
3. Run the InstallZipTools.bat script to set up the necessary dependencies.
4. Build the solution to verify everything is working correctly.

## Coding Standards

### Naming Conventions

- Use PascalCase for class names, method names, and properties (e.g., `ZipReaderClass`, `ExtractFile`).
- Use camelCase for local variables and parameters (e.g., `fileName`, `zipEntry`).
- Prefix class member variables with "m_" (e.g., `m_ErrorCode`).
- Use descriptive names that clearly indicate the purpose of the entity.

### Code Style

- Indent using 2 spaces.
- Include comments for complex logic or non-obvious functionality.
- Keep methods focused on a single responsibility.
- Document public methods and classes with clear descriptions.
- Follow the existing code structure when adding new features.

## Testing Your Changes

1. Run the ZipClassTesting project to verify your changes work as expected.
2. Add appropriate test cases for new functionality.
3. Ensure all existing tests pass before submitting your changes.
4. Test your changes on different Clarion versions if possible.

## Submitting Changes

### Creating Issues

1. Check if an issue already exists for the bug or feature you're addressing.
2. If not, create a new issue using the appropriate template:
   - Bug report: Use the bug report template for reporting issues.
   - Feature request: Use the feature request template for suggesting enhancements.
3. Be as detailed as possible in your issue description.

### Creating Pull Requests

1. Create a new branch for your changes:
   ```
   git checkout -b feature/your-feature-name
   ```
   or
   ```
   git checkout -b fix/your-bug-fix
   ```
2. Make your changes and commit them with clear, descriptive commit messages.
3. Push your branch to your fork:
   ```
   git push origin feature/your-feature-name
   ```
4. Create a pull request from your branch to the main repository.
5. Fill out the pull request template with all required information.
6. Link your pull request to any related issues.

## Reference Links

- [GitHub Issues](https://github.com/OriginalOwner/ZipTools-for-Clarion/issues)
- [ClarionHub Thread](https://clarionhub.com/t/ziptools-for-clarion)
- [Clarion Documentation](https://docs.softvelocity.com/)
- [ZLib Documentation](https://www.zlib.net/manual.html)

## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We aim to foster an inclusive and welcoming community.

Thank you for contributing to ZipTools for Clarion!