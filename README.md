# Rails Test Application Template Guide

## Overview
This Rails application template is designed to streamline the setup of new Rails projects and enhance existing ones, focusing on testing, code quality, and development efficiency.

## Features
- **RSpec**: Integrates RSpec for testing.
- **FactoryBot**: Provides a straightforward syntax for fixtures replacement.
- **SimpleCov**: Adds code coverage analysis.
- **RuboCop**: Enforces Ruby coding standards and best practices.
- **Guard**: Automates various tasks based on file modifications.
- **VCR**: Records HTTP interactions for test suite reliability.
- **TimeCop**: Allows "time travel" and "time freezing" capabilities in tests.
- **Shoulda Matchers**: Offers simple one-liner tests for common Rails functionality.

## How to Use in an existing project
Currently it only support for existing (newly created) Rails project.
1. Run this command inside the project root:
   ```
   rails app:template LOCATION=https://raw.githubusercontent.com/KLG-tech/rails-test-template/main/app_template.rb
   ```
2. Follow the subsequent steps as detailed in the [Customization](#customization) and [Post-Setup](#post-setup) sections.


## Customization
- **Modifying `.rspec`**: Adjust RSpec flags and formats to suit your preferences.
- **Customize VCR Configuration**: Modify the `spec/support/vcr.rb` file as needed.

## Post-Setup
- **Generating Factories**: After setup, you can generate factories for existing models.
- **Remove Test Directory**: Optionally, remove the default `/test` directory if switching to RSpec.

- This template is flexible for modification to meet specific project requirements.

---

This addition should provide guidance on integrating the template's features into an existing Rails project. Be sure to carefully check compatibility with your project's existing setup and Rails version.
