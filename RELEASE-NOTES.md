# Bob 3.5.0: RG Reports and Active View Family Takeoff

- **Create RG Report:** New Files option for report instructions, editable drafts,
  optional project/preparer, example-PDF attachments and local preview/export.
  Examples guide structure by default; using their facts requires explicit opt-in.
  Selected PDF pages are reviewed as extracted text, without OCR.
- **Active View Family Takeoff → RG PDF:** New built-in skill and Files option
  with a popup for existing families in the active host-model view. Choose length
  and weight parameters or enter an explicit lb/ft factor. No AI calculation,
  Claude transmission or model-changing transaction is part of the takeoff.
- **Professional takeoff table:** Family, type, workset, quantity, length each,
  total length and pounds. Grouped by family/type/workset/displayed length with
  family subtotals and overall totals. Feet and fractional inches display to
  1/16 inch; totals sum unrounded measurements. Missing values remain unavailable
  or partial, not zero.
- **RG-branded PDFs:** Supplied RG logo top-left on every page, green headings,
  repeated table headers and page numbers. Takeoffs use exactly 11 × 18 inches
  portrait; general reports and chat exports use US Letter portrait. Drawing
  and sheet PDF export is unchanged.
- **Validated export handling:** Compact report editor, explicit preview/save,
  example-PDF overwrite protection, cancellation and complete compression
  checksums before atomic file replacement.
- Retains Bob 3.4.1 pause/review/continue recovery, Pkcs 8.0.2, NWC export,
  model locations, capture markup and existing settings.

AI report drafting uses the existing Claude subscription and cloud permission.
Optional chat/model context is off by default, and report drafting has no Revit
action tools. Manual report editing and export stay local.

Takeoff scope is Revit's host-element view collector, not pixel visibility.
Linked contents and annotations are excluded; parent assemblies and shared
nested families may overlap. Confirm parameter definitions, missing values and
totals against a trusted schedule before procurement. Saved reports describe
the captured timestamp, not later model changes. Oversized views/reports are
refused rather than silently truncated.

Supports Revit 2024, 2025 and 2026. Automated core, native WPF, installer/updater,
dependency and PDF checks are release gates, not live-model or real-Claude
acceptance. Test on a model copy; this unsigned build is not Autodesk-certified.

Save your work and close every Revit window before installation. Publishing
this release does not silently install it or change anyone's model.
