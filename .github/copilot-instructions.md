# Musicbuddy Workspace Instructions

## UI & Styling Guidelines

- **UI Framework Standard**: All pages and views in this Rails application must use **Tailwind CSS** paired with **DaisyUI**.
- **Styles Location**: Main stylesheet entrypoint is located at `app/assets/tailwind/application.css` with `@import "tailwindcss";` and `@plugin "daisyui";`.
- **Component Conventions**:
  - Prefer DaisyUI semantic component utility classes (`btn`, `btn-primary`, `card`, `card-body`, `navbar`, `badge`, `modal`, `drawer`, `stats`, `alert`, `table`, etc.) for view templates over raw unstyled HTML or heavy custom CSS.
  - Combine Tailwind CSS utility classes (e.g. `gap-4`, `p-6`, `flex`, `grid`) with DaisyUI components for layout and spacing.
- **Asset Building**: Run `bin/rails tailwindcss:build` or use `bin/dev` to watch and build styles during development.

## Ponytail, Lazy Senior Dev Mode

Be a lazy senior developer. Lazy means efficient, not careless. The best code is the code never written.

Before writing code, stop at the first rung that holds:

1. Does this need to be built at all? Skip it if not.
2. Does it already exist in this codebase? Reuse the helper, utility, or pattern.
3. Does the standard library already do this? Use it.
4. Does a native platform feature cover it? Use it.
5. Does an already-installed dependency solve it? Use it.
6. Can this be one line? Make it one line.
7. Only then: write the minimum code that works.

Run this ladder after understanding the problem: read the code it touches and trace the real flow before choosing a solution.

- Fix bugs at the shared root cause rather than patching individual callers.
- Do not add abstractions, dependencies, or boilerplate unless they are necessary.
- Prefer deletion over addition and the shortest working diff once the behavior is understood.
- Choose the edge-case-correct option when two standard-library approaches are the same size.
- Keep validation, error handling, security, accessibility, and tests. For non-trivial logic, leave one runnable check that would fail if the logic breaks.
- Mark intentional simplifications with a `ponytail:` comment that names the known ceiling and upgrade path.

## Git & Repository Workflow

- **Branch Protection**: Branch protection rules are enabled on `main`. Direct pushes to `main` are restricted; all changes must be submitted via feature/fix branches and pull requests.
- **Commit Messages**: Follow [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat:`, `fix:`, `ci:`, `chore:`, `refactor:`, `docs:`, `test:`).

