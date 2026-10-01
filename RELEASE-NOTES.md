# Bob 3.1.0: Colorful Neumorphic Workspace

Installer-only public distribution for Revit 2024, 2025 and 2026. No GitHub login is needed to download or run the public installation script.

## All-in-one first-time setup

Close every Revit window, open PowerShell as your normal Windows user and run:

```powershell
irm 'https://raw.githubusercontent.com/amhsekol/ai-rg-bob-installer/main/Setup-Bob.ps1' | iex
```

This installs Claude Code if missing, starts official subscription sign-in when needed, installs Bob and configures the executable path. Each user still completes browser sign-in and approves project-data sharing in Bob. No credentials are copied or saved by the setup script. Existing preferences are preserved and settings changes are backed up. This adds a setup convenience; the tested 3.1.0 add-in ZIP and its checksum are unchanged.

## Workspace changes

Adds a colorful neumorphic interface across Bob: softly raised rounded controls, inset text fields, lavender conversation cards, blue skills/view controls, mint file/data controls and amber update/review states. The same theme covers settings, chat and skill libraries, file workflows, updates and code review.

Readability remains functional: 16-pixel chat text, explicit labels, visible keyboard focus, pressed/disabled states, existing tooltips, verified text-color contrast pairs and a core high-contrast startup palette. Screenshots are from native Windows UI tests using simulated model/provider data, not live Revit.

Existing functionality remains included: Maximize/Full screen, activity feedback, direct clarification answers, attachments, local chats and skills, supported PDF/Excel exports/imports, and approved in-app updates. This is a visual release, not an expansion of previously unsupported workflows.

The updater rechecks SHA-256 and archive paths, refuses installation while Revit is running, invokes the existing backup/rollback installer, and records success or failure. It uses Windows PowerShell internally and is subject to company execution policy. Offline checks remain recoverable. The initial upgrade from 3.0.0 needs one last use of the public installer command.

Retains the animated activity card, elapsed time, queued-work Stop, local chats, instruction skills, references, reports, bounded exports and guarded text-parameter/RFA import workflows. Close Revit before installing; backups and existing Claude settings are preserved.

Unsigned build: test on model copies. Each user still needs their own Claude sign-in and project-data permission. Team libraries are local; no OCR, numeric/type parameter round trips or dedicated RVT/IFC/DWG linking.

The ZIP is the tested 3.1.0 package. It contains compiled add-ins, installers, documentation, build manifests and dependency notices; it does not include private source history or user data. Native Revit UI-thread operations can pause animation; live Revit acceptance is still required.

See README for the single-command installation and first-time Claude setup.
