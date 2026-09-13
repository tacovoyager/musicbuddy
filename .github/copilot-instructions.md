# Musicbuddy Workspace Instructions

## UI & Styling Guidelines

- **UI Framework Standard**: All pages and views in this Rails application must use **Tailwind CSS** paired with **DaisyUI**.
- **Styles Location**: Main stylesheet entrypoint is located at `app/assets/tailwind/application.css` with `@import "tailwindcss";` and `@plugin "daisyui";`.
- **Component Conventions**:
  - Prefer DaisyUI semantic component utility classes (`btn`, `btn-primary`, `card`, `card-body`, `navbar`, `badge`, `modal`, `drawer`, `stats`, `alert`, `table`, etc.) for view templates over raw unstyled HTML or heavy custom CSS.
  - Combine Tailwind CSS utility classes (e.g. `gap-4`, `p-6`, `flex`, `grid`) with DaisyUI components for layout and spacing.
- **Asset Building**: Run `bin/rails tailwindcss:build` or use `bin/dev` to watch and build styles during development.
