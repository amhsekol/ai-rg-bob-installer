# Bob 3.2.0: Private Skill Review Submissions

Public installer distribution for Windows Revit 2024, 2025 and 2026.
Anyone can install Bob without GitHub sign-in or manual ZIP extraction.

## One installation command

Save your models, close every Revit window, open PowerShell as your usual Windows
user and run:

```powershell
irm 'https://raw.githubusercontent.com/amhsekol/ai-rg-bob-installer/main/Setup-Bob.ps1' | iex
```

Setup installs official Claude Code if missing, starts its official browser
sign-in when needed, installs Bob and configures the executable path.
Each user needs their own eligible Claude access and must approve project-data
sharing in Bob. New installations do not automatically enable cloud sharing,
advanced generated code or local chat saving. Company policies still apply.

The command uses main's promoted version. A versioned package can be staged on
this release before main and the in-app latest feed are switched.

## New skill submission workflow

- Select a skill in **Skills → Submit for approval**.
- Check GitHub access and inspect the exact name, instructions, version and input names.
- Confirm the privacy review and submit directly to the private RG Construction queue.
- Follow visible progress, cancel waiting, check the saved receipt or open the queue.
- Repeated clicks reuse a receipt; uncertain outcomes do not automatically retry.

Only the chosen skill and review metadata are submitted. Chats, attachments,
project labels, model snapshots and local Reviewed flags are not automatically
uploaded. Instructions themselves can contain confidential data: review them first.

## Private access and unfinished features

**The installer is public; RG Construction skills are private.**
The skills repository remains owner-only. The optional submission feature requires
separate official GitHub CLI sign-in and authorized access; it does not borrow
Claude SSO, invite teammates or grant permissions.

Reviewer-controlled publishing, approved-library synchronization and teammate
access onboarding are not included. A submitted or closed issue is never approval.
Every Revit model change still needs its separate approval.

## Existing workspace retained

Colorful neumorphic controls, Maximize/Full screen, visible activity and Stop,
direct clickable clarification answers, attachments, saved local chats/skills,
supported PDF/Excel exports and guarded text-parameter/RFA imports remain included.
Project/Team libraries are still local labels. No OCR, numeric/type-parameter
round trips or dedicated RVT/IFC/DWG imports are added.

## Tests and recovery

The add-in has Windows builds for all three Revit years, automated safety and
submission tests, and native WPF tests on .NET Framework 4.8 and .NET 8.
Submission tests use synthetic GitHub responses; live sign-in, real issue posting,
and live Revit acceptance are not certified by these tests.

The public bootstrap is tested on Windows PowerShell 5.1 and PowerShell 7.
Downloads and per-year payloads are hash checked. The installer refuses to run
while Revit is open and retains per-version backups. Existing settings, chats,
skills and Claude sign-in are preserved. Keep the printed backup path.

Bob 3.1.0 remains available as the prior release. This is an unsigned build:
test on model copies before production use. A release is not proof that it has
been installed on any workstation.
