# Bob 3.3.0: Fewer Questions, Section Boxes, Filters and Project Info

- **Compact layout.** Tools in one row (mouse wheel scrolls it), a slim progress strip and a much larger chat area. Sharper text at every size, including 75%.
- **Understands Revit language.** Bob restates each request in Revit terms ("Understood as: ...") and then acts. It uses your selection, the active view and its level as defaults and asks at most one question, only when a wrong guess would change, delete or export the wrong thing.
- **Run Revit operations without asking.** New AI Settings option, on by default: model changes, PDF exports, family loads and enabled advanced code run without approval dialogs. Untick it to approve each action. Revit Undo still reverses model changes.
- **Auto model choice.** The Claude model dropdown lists the models your installed Claude Code accepts. **auto** (new default) uses haiku for quick questions, sonnet for ordinary edits and opus for multi-step, linked-model, phase, filter or image work. It never picks fable, which can bill usage credits.
- **Section boxes and phases in links.** Find elements in the host or a linked model by category, level, parameter or phase; create a section box around everything that matches, e.g. one phase in the MEP link.
- **View filters.** Color, halftone or hide elements by a parameter rule in the active view or its view template.
- **Project info.** Store per-project notes (where to save NWC/Navisworks and other exports, standards, contacts) and ask Bob about them. Point AI Settings at a shared folder so the whole team gets the same answers.
- **Capture Revit and Dictate.** Capture the whole Revit window, including Properties and Project Browser. Dictate opens Windows voice typing in the message box.
- **New built-in skills** for section boxes by selection, category or linked-model phase; filters; halftone existing; and "Where to save NWC".
- Close all Revit windows before installation. Unsigned build: test on model copies. Existing settings are kept; existing users keep their chosen model.
