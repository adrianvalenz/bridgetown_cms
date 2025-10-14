# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- ...

## [0.2.0] - 2025-10-13

### Added
- EasyMDE markdown editor integration for rich content editing
- Live preview and side-by-side editing modes
- Markdown toolbar with formatting shortcuts
- Image upload functionality via custom toolbar button
- Automatic image file naming with timestamps
- Images stored in `src/images/uploads` directory
- Automatic markdown insertion for uploaded images
- Editor autosave feature (saves to localStorage)
- Version number display in admin footer

### Fixed
- Editor content now properly syncs with HTMX form submissions
- Form reset button now correctly clears editor content
- Cancel button properly clears editor when returning to new article form
- Autosaved content no longer persists when loading empty forms

### Changed
- Replaced plain textarea with EasyMDE markdown editor
- Improved admin UI with better visual feedback during image uploads

## [0.1.0] - YYYY-MM-DD

- First version
- Basic CRUD operations for blog posts
- HTMX-powered admin interface
- Article listing and management
