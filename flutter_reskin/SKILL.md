---
name: flutter_reskin
description: An autonomous system prompt to thoroughly reskin, refactor, and redesign a template Flutter app for a new topic, blending strict architectural preservation with a bespoke, physics-based 2025 UI.
---

# Intent
The user maintains a template Flutter application built with Riverpod (StateNotifier), local Hive database, and specific CRUD patterns. 
When the user invokes this skill and provides a **Topic** for a new app, your job is to systematically transform the entire codebase to match the new topic. You must preserve the core architecture while completely overhauling the UI into a bespoke, domain-specific, 2025 modern aesthetic. Do NOT just copy the existing UI. It should look like an original, premium application built from scratch for this industry.

# Execution Steps

## Phase 1: Duplication, Setup & Identity (CRITICAL)
1. **Clean Workspace:** Delete the `.git` folder to detach history. Delete `build/` and `.dart_tool/` to ensure a fresh start.
2. **Rename Project Identity:** 
   - Update `pubspec.yaml` with the new project name (snake_case) and description.
   - Update `android/app/build.gradle` (change `applicationId`, `namespace`, and `label`).
   - If iOS is supported, update `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj`.
3. **Global Import Replacement:** Perform a global find-and-replace across the entire `lib/` directory to swap `package:<old_project_name>/` with `package:<new_project_name>/`.

## Phase 2: Domain Adaptation & Logic Refactoring
*Constraint: You MUST preserve Riverpod for global state. Do not change to GetX, Bloc, or vanilla setState. Keep the `InputProvider -> ProjectProvider -> UI` pattern.*

1. **Update Data Model:** Refactor the primary Hive model in `lib/models/` (Rename `SurveyingInstrumentModel` to the new topic). Retain infrastructure fields like `id` and `photoPath`, but replace generic domain fields with subject-specific ones (e.g., material, era, conditions). Update `toJson` and `fromJson`.
2. **Update Enums:** Target `lib/enum/`. Swap out old enums for new, highly relevant categorization types (e.g. EngineType, BuckleMaterial).
3. **Database Layer:** Rename the Hive box and update the TypeAdapters accordingly.
4. **Providers Refactor:** 
   - Update `InputProvider` to perfectly capture the new fields.
   - Ensure `ProjectProvider` accurately manages the new Model. 

## Phase 3: Visual & Thematic Overhaul (The Aesthetic)
*Constraint: Ensure you read `@ui_rules.txt` if available. You MUST preserve the logic in `lib/main.dart` regarding `userProv.firstTimeUser` to show the InitialScreen.*

1. **Theme Tokens (`theme.dart` & `const.dart`):** Completely rewrite the color palette to match the new topic. Implement modern typography (Google Fonts like Inter, Outfit). Use extreme corner radiuses (pill-shapes), soft glassmorphic panels, and high-fidelity shadows. No generic designs.
2. **Home Screen:** Redesign how items are listed (e.g., use dynamic GridViews, fluid sliver app bars, collapsible search). Incorporate bespoke "Empty State" vectors/illustrations.
3. **Add/Edit Screens:** Break up the input forms into multiple PageViews or Steppers. Do not dump all text fields on one massive scrolling page. Make it user-friendly with custom sliders/chips.
4. **Info Screen:** Showcase the item brilliantly. Use a large hero image, floating spec cards, and stylish tags.
5. **Showcase Screen (The Masterpiece):** 
   - **MANDATORY:** Replace the rigid grid/list with an interactive, kinetic 2D data visualization.
   - Implement a custom physics engine (using a `Ticker` and `Canvas`) that fits the theme (e.g., fluid dynamics for maritime, rigid-body dropping blocks for construction, elastic springs for machinery). It must be touch-responsive, 60fps, and visually stunning.
6. **Stats Screen:** Build highly specific, brand new metric visualizations based on the new enum data (horizontal progress rings, heatmaps, overlapping spider charts).

## Phase 4: Verification & Testing
1. Run `flutter pub get` and `dart fix --apply`.
2. Verify `InitialScreen` logic fires correctly on first boot.
3. Verify all CRUD operations (Create, Read, Update, Delete) function perfectly from the UI.
4. Ensure Riverpod state propagates changes instantly across all newly designed UI widgets.
