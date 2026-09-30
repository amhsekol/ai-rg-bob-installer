# Bob 3.0.1: Updates Inside Bob

Installer-only public distribution for Revit 2024, 2025 and 2026. No GitHub login is needed to download or run the public installation script.

Adds Check for updates, a newer-release notice and daily automatic checks while Bob/Revit is running, with an opt-out. Install after Revit closes reviews the release, downloads and verifies it, then launches an updater that waits for all Revit windows to close. No manual commands are needed for subsequent updates. It never closes Revit forcibly and never installs without approval.

The updater rechecks SHA-256 and archive paths, refuses installation while Revit is running, invokes the existing backup/rollback installer, and records success or failure. It uses Windows PowerShell internally and is subject to company execution policy. Offline checks remain recoverable. The initial upgrade from 3.0.0 needs one last use of the public installer command.

Retains the animated activity card, elapsed time, queued-work Stop, local chats, instruction skills, references, reports, bounded exports and guarded text-parameter/RFA import workflows. Close Revit before installing; backups and existing Claude settings are preserved.

Unsigned build: test on model copies. Each user still needs their own Claude sign-in and project-data permission. Team libraries are local; no OCR, numeric/type parameter round trips or dedicated RVT/IFC/DWG linking.

The ZIP is the tested 3.0.1 package. It contains compiled add-ins, installers, documentation, build manifests and dependency notices; it does not include private source history or user data. Native Revit UI-thread operations can pause animation; live Revit acceptance is still required.

See README for the single-command installation and first-time Claude setup.
