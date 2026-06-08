---
name: fetch-source
description: >
  Use opensrc to access the source code of any library — open source or internal — whenever you
  need to understand how it works. Trigger this whenever you are researching, debugging, exploring,
  or implementing anything that involves a dependency you need to inspect. Source code is the source
  of truth. Always prefer it over guessing, reading docs, or reverse-engineering artifacts (e.g.
  JARs, minified bundles). Use official docs only for pure signature lookups (method name, argument
  types) where the docs are unambiguous. In all other cases — behavior questions, edge cases,
  internal libs, version-specific details — fetch the source.
---

# fetch-source

Use `opensrc` to get a local path to any package's source code, then navigate it directly with
`Read`, `grep`, and `find`.

## CLI

```bash
# Public packages (npm default)
opensrc path zod
opensrc path lodash

# Explicit registry
opensrc path pypi:requests
opensrc path crates:serde

# GitHub repo (public or private — GITHUB_TOKEN is already configured)
opensrc path github:<owner>/<repo>
```

The command fetches on first use and returns the cached path on subsequent calls. Pipe the path
into any file navigation tool:

```bash
cat $(opensrc path zod)/src/index.ts
grep -r "safeParse" $(opensrc path zod)/src/
```

## Internal libraries

For internal libraries not on a public registry, infer the GitHub coordinates from context
(package name, import paths, company org) and use the `github:` prefix. The `GITHUB_TOKEN`
environment variable is already set and grants access to private repos.

```bash
opensrc path github:blip/blip-auth
```

If you cannot infer the org/repo with confidence, ask the user:
> "I need the source for `blip-auth`. Do you know the GitHub repo path (e.g. `blip/blip-auth`),
> or can you point me to a local checkout?"

## When opensrc fails

If the fetch fails (404, auth error, unknown package), do not silently fall back to docs. Ask
the user:
> "`opensrc path github:blip/blip-auth` failed. Can you give me the repo URL or a local path
> to the source?"
