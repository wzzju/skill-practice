# Skill Practice

A collection of AI agent skills, configurations, and reference materials. This repository aggregates various skill sources and provides custom skills for enhancing AI coding assistance.

## Repository Structure

### Submodules
This repository includes several external skill collections as submodules:
- **[makepad-skills](https://github.com/ZhangHanDong/makepad-skills)**: Skills for building apps with Makepad.
- **[obsidian-skills](https://github.com/kepano/obsidian-skills)**: Agent skills for Obsidian.
- **[planning-with-files](https://github.com/OthmanAdi/planning-with-files)**: Manus-style persistent markdown planning.
- **[rust-skills](https://github.com/actionbook/rust-skills)**: Rust Developer AI Assistance System.
- **[superpowers](https://github.com/obra/superpowers)**: Additional capabilities.
- **[anthropics/skills](https://github.com/anthropics/skills)**: Official Anthropic skills.

### Local Skills
Custom skills developed in this repository:
- **rust10x**: A comprehensive Rust programming skill set including best practices for cargo, CLI, error handling, macros, and testing.
- **suggest-git-commit**: A skill to generate semantic git commit messages based on changes.

## Usage

### Setup
A setup script is provided to install these skills into your local environment (e.g., `~/.trae/skills`).

```bash
./setup_skills.sh
```

This script will:
1. Clean up the existing skills directory (`~/.trae/skills`).
2. Copy skills from the submodules and local directories to the target location.
3. Handle conditional installations (e.g., for Rust or Makepad specific environments if configured).

## License
Refer to the individual submodules and files for their specific licensing information.
