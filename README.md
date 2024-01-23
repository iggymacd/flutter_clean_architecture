# clean_architecture_template

<p align="center">
<img src="https://raw.githubusercontent.com/EagleDev-io/flutter_clean_architecture/master/flutter_architecture.png">
</p>

## Usage 
TODO: 
 - How to rename this template ? 

## Setup and Tooling

**Get flutter and dart**

```
git clone https://github.com/flutter/flutter.git
```

1. Add `export PATH="$PATH:`pwd`/flutter/bin"` to ~/.bash_profile or ~/.bashrc
2. Verify `which flutter`
3. Install Xcode and Android Studio. Run `flutter doctor` for installation diagnostics.

This project currently run on version : `Flutter 1.12.13+hotfix.8 • channel stable` and `Dart 2.7.0`


## Development

Setup githooks by doing the following (modified script for powershell on windows). 
```
Write-Host "\e[33;1m%s\e[0m\n" 'Running unit tests'
flutter test
```
ran this command
```
 git config core.hooksPath .githooks
```

This will ensure that for instance tests are run before pushing etc...

This project uses code generation for generating entities and some bloc state and events.  So whenever
making changes to those files be sure to run:

```
dart run build_runner watch (updated since flutter run build_runner is deprecated)
```

**VSCode Configuration**

Start with the [intial guide](https://flutter.dev/docs/development/tools/vs-code)

Setup a keyboard shortcut for running unit tests, by assigning a keybinding to command dart.runAllTestsWithoutDebugging.

We recommend some extension for development in particular: 

    - Flutter Widget snippets (Alexis Villegas Torres)
    - bloc (Felix Angelov)
    - Dart Built Value Snippets (YongZhen Low)


## Dependencies

For precise versions of each dependencies head over to [pubspec.yml](pubspec.yaml)

- [Equatable]() (Since Dart ony supports reference equality out of the box.)
- [Freezed]() Enable value type semantics, value equality, json serialization, sealed classes.
- [Bloc]() Reactive state management.
- [Dartz](https://pub.dev/packages/dartz) Some functional programmintg utilities and types (purify your Dart)).
- [GetIt](https://pub.dev/packages/get_it) Dependency Injection

**Testing**

- [mockito](https://pub.dev/packages/mockito)
- [bloc_test](https://pub.dev/packages/bloc_test) (Indirectly includes mockito)

## Coding/Naming Conventions

Coding conventions are mostly handled by dartfmt but file names by convention are named with snake_case.

Customization of linting errors is done through analysis_options.yaml file.
The [lint package](https://pub.dev/packages/lint#-readme-tab-) is used as a starting point set of defaults.

