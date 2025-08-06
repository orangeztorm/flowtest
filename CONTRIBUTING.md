# Contributing to FlowTest

Thank you for your interest in contributing to FlowTest! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- Flutter SDK (3.32.0 or higher)
- Dart SDK (3.8.0 or higher)
- Git

### Development Setup

1. **Fork and clone** the repository
   ```bash
   git clone https://github.com/your-username/flowtest.git
   cd flowtest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run tests** to ensure everything works
   ```bash
   flutter test
   ```

## Project Structure

```
flowtest/
├── packages/
│   ├── flowtest_sdk/          # Core Flutter SDK
│   ├── flowtest_cli/          # Command-line interface
│   └── flowtest_vscode/       # VS Code extension
├── examples/
│   └── weather_app/           # Example application
├── docs/                      # Documentation
└── services/
    └── llm_service/           # AI-powered test generation
```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Follow the existing code style and patterns
- Add tests for new functionality
- Update documentation as needed

### 3. Run Tests

```bash
# Run all tests
flutter test

# Run specific package tests
cd packages/flowtest_sdk
flutter test

# Run integration tests
flutter test integration_test/
```

### 4. Code Quality Checks

```bash
# Static analysis
flutter analyze

# Format code
dart format .

# Run lints
flutter analyze --no-fatal-infos
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "feat: add new feature description"
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

## Code Style Guidelines

### Dart/Flutter

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Build/tooling changes

Examples:
```
feat(sdk): add support for custom widget selectors
fix(recorder): resolve tap detection on nested widgets
docs(readme): update installation instructions
```

## Testing Guidelines

### Unit Tests

- Write tests for all new functionality
- Aim for high test coverage
- Use descriptive test names
- Test both success and failure cases

### Integration Tests

- Test complete user workflows
- Verify cross-platform compatibility
- Test error handling and edge cases

### Example Test Structure

```dart
group('FeatureName', () {
  testWidgets('should handle normal case', (tester) async {
    // Arrange
    await tester.pumpWidget(MyWidget());
    
    // Act
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.text('Success'), findsOneWidget);
  });

  testWidgets('should handle error case', (tester) async {
    // Test error scenarios
  });
});
```

## Documentation

### Code Documentation

- Document all public APIs
- Include usage examples
- Explain complex algorithms

### User Documentation

- Update README files for significant changes
- Add examples for new features
- Keep documentation in sync with code

## Pull Request Process

### Before Submitting

1. **Ensure tests pass** locally
2. **Update documentation** if needed
3. **Check code style** with `flutter analyze`
4. **Test on multiple platforms** if applicable

### PR Description

Include:
- Description of changes
- Motivation for changes
- Testing performed
- Screenshots (if UI changes)
- Breaking changes (if any)

### Review Process

- All PRs require at least one review
- Address review comments promptly
- Maintainers may request changes
- PRs are merged after approval

## Issue Reporting

### Bug Reports

Include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Flutter version, etc.)
- Screenshots or logs if applicable

### Feature Requests

Include:
- Description of the feature
- Use cases and benefits
- Implementation suggestions (if any)
- Priority level

## Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Help others learn and grow
- Provide constructive feedback
- Follow project conventions

### Communication

- Use GitHub issues for bug reports and feature requests
- Use GitHub discussions for questions and ideas
- Be patient and helpful with newcomers

## Release Process

### Versioning

We follow [semantic versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- Breaking changes bump major version
- New features bump minor version
- Bug fixes bump patch version

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Release notes written
- [ ] Packages published

## Getting Help

- **Documentation**: Check the [docs/](docs/) directory
- **Issues**: Search existing [GitHub issues](https://github.com/your-org/flowtest/issues)
- **Discussions**: Use [GitHub discussions](https://github.com/your-org/flowtest/discussions)

## License

By contributing to FlowTest, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to FlowTest! 🎉 