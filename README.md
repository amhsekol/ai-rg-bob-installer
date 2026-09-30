# AI RG: Bob for Revit

Public installer distribution for Bob 3.0, supporting Revit 2024, 2025 and 2026 on Windows. This repository contains installation scripts, compiled installer packages, checksums, documentation and installer tests, not the private add-in development repository or its history.

## Install with one command

Save your work and **close every Revit window**. Open PowerShell as your usual Windows user and paste this line, then press Enter:

```powershell
irm 'https://raw.githubusercontent.com/amhsekol/ai-rg-bob-installer/main/Install-Bob.ps1' | iex
```

No GitHub account, GitHub CLI or GitHub sign-in is required. The script downloads the tested package, verifies SHA-256, extracts temporarily, installs matching per-year add-ins with backups and removes temporary files. No manual ZIP handling is needed.

This command executes the installation script published in this repository. Review `Install-Bob.ps1` if you prefer to inspect it first. Company policies may require IT approval; do not bypass organizational restrictions.

The installer targets all three supported years by default. It does not install Revit itself, close Revit forcibly, install a Windows service or silently run future updates.

After installation, open a model copy and choose **AI RG → Chat with Bob**. Confirm the header says **Chat 3.0** (package version 3.0.0). Existing users keep their Claude settings and sign-in.

## First-time Claude setup

Installing Bob does not include a Claude account or subscription. Each user needs their own eligible Claude account or organization-assigned access and must authorize sending project data.

If official Claude Code is not installed, run:

```powershell
winget install --id Anthropic.ClaudeCode --exact
```

Open a new PowerShell window, then:

```powershell
claude auth login
(Get-Command claude).Source
```

Use your own account in the official sign-in flow. In Bob's **AI Settings**, set the full executable path returned by the second command, review cloud-data permission and check the subscription connection. Never share credentials, tokens or device authorization codes.

## Included workflows and limits

- **Workspace:** Visible Maximize opens a maximized window in one click. Full screen removes window chrome; F11 toggles it and Esc exits full screen without cancelling work. Return to dock preserves the same chat, draft and request. Read-only result tables, tooltips and direct Continue for clarification choices remain available.
- **Visible activity:** Prominent working card, moving activity bar, staggered pulse dots, actual stage labels, elapsed time and queued-work Stop. Approval waiting, completion and errors are distinct states. No invented percentages or pretend activity while idle.
- **Chats:** New/previous conversations, search, rename, pin, archive and safe resume. Disk history is opt-in in Chats.
- **Skills:** Built-in and personal instruction recipes, editable inputs, versions and reviewed imports. Project/Team collections are local, not cloud-synchronized.
- **References:** Text, selected PDF text pages, selected XLSX worksheets and PNG/JPG previews; view capture. No scanned-PDF OCR.
- **Exports:** Chat PDF/Markdown/XLSX, bounded host-view inventories, parameter templates and drawing PDFs.
- **Imports:** Same-open-session writable text instance parameters and separately approved RFA loading. Numeric/type parameters and dedicated RVT/IFC/DWG imports are not supported.

This is an **unsigned build**, not production certification. Real Revit behavior and the user's Claude connection need testing on model copies. Model changes require approval. Advanced generated code, if explicitly enabled, is full-trust and not sandboxed.

Activity animation respects Windows reduced-motion settings. Native Revit operations that occupy its UI thread can temporarily pause the display; an animation is not a guarantee that Revit is responsive. Elapsed time includes provider and approval waiting, not an estimate of time remaining.

## Privacy and distribution

Anyone can download this installer. Compiled .NET assemblies can be inspected or decompiled; distributing binaries is not a guarantee that implementation details remain secret.

The installer does not include employee accounts, model files, saved chats or Claude credentials. Bob sends approved messages, references and requested model information through the user's own Claude Code connection. Review company/project policy before enabling cloud-data permission.

Local opted-in history and skills live under `%LOCALAPPDATA%\RGConstruction\RevitAI\workspace`. History is not encrypted by Bob. Provider retention is independent of local history.

## Verification and rollback

The package includes `START-HERE.md`, `UI-VERIFICATION.md`, per-year build manifests and dependency notices. Keep the backup path printed during installation; follow the included rollback instructions if required.

The current ZIP SHA-256 is:

```text
266a6aaadf1e39e4a0819d45c1e681adc163eb8da8227f3caf55ce07f0d31133
```

The public installer workflow tests Windows PowerShell 5.1 and PowerShell 7, checks the package hash and rejects unsafe archive paths before publishing a release. Automated checks do not replace live testing inside Revit.
