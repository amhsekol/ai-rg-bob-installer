# Bob 3.4.1: Review and Continue Paused Tasks

- Bob now pauses after eight AI rounds instead of clearing its action history and showing a generic error. Nothing resumes automatically.
- Review completed actions opens a read-only local record. Result cards show reported status above the original JSON.
- Continue remaining work runs up to eight more rounds in the same live model, retaining prior results, original image context and successful-action duplicate protection. Your composer draft is preserved.
- Use New chat for a different task. Model switches, settings changes and reopening a saved chat invalidate continuation. Reopened chats include bounded historical results, never executable actions or restored approvals.
- Cancellation and runtime errors stop work without automatic retries. Context-size limits require a new chat and target re-inspection.
- Includes System.Security.Cryptography.Pkcs 8.0.2, patched for [CVE-2026-84008](https://github.com/advisories/GHSA-846f-f764-76mx) and [CVE-2026-70162](https://github.com/dotnet/announcements/issues/454).
- Retains Bob 3.4.0 model locations, NWC export setup, capture markup and existing settings.

Recorded success is not independent verification. Duplicate blocking does not detect every semantically equivalent rewrite of generated code. Existing cloud consent, advanced-code opt-in and action-approval preferences remain unchanged.

Supports Revit 2024, 2025 and 2026. Automated core, native WPF, installer/updater and dependency checks passed for the source candidate; this does not establish live-Revit or real-Claude acceptance.

Save your work and close every Revit window before installation. Unsigned build: test on model copies. No silent installation or automatic model changes are performed by publishing this release.
