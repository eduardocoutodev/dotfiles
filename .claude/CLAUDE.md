# Code Navigation

Always prefer LSP tools over text search when available:

- Use `goToDefinition` instead of Grep to find where a symbol is defined
- Use `findReferences` instead of Glob to find all usages of a function/class
- Use `hover` to inspect types and signatures before editing
- Use `getDiagnostics` after editing a file to catch errors immediately
- Fall back to Grep/Glob only for things LSP can't help with (e.g. searching comments, TODOs, or plain text)

When refactoring, always run `findReferences` first to understand the full blast radius before making changes.
