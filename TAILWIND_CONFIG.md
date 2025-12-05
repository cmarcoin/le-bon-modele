# Tailwind CSS Configuration

## Summary

This Rails 8 app uses **Tailwind CSS v4** (via `tailwindcss-rails` gem v4.4.0).

## Configuration Method

### ✅ **`@theme` directive in CSS** (ACTIVE)
- **Location**: `app/assets/tailwind/application.css`
- **Status**: ✅ **This is the method being used**
- **How it works**: Tailwind v4 uses CSS-based configuration via the `@theme` directive

```css
@import "tailwindcss";

@theme {
  --color-herve-blue: #1A3B8F;
  --color-herve-green: #80FF00;
  --color-herve-light-blue: #E0F0FF;
  --color-herve-red: #FF0000;
}
```

### ❌ **`tailwind.config.js`** (NOT USED)
- **Location**: `config/tailwind.config.js`
- **Status**: ❌ **This file is NOT being used by Tailwind v4**
- **Why**: Tailwind CSS v4 moved away from JavaScript config files to CSS-based configuration
- **Note**: You can delete this file if you want, or keep it for reference (it won't affect anything)

## CSS Linter Warning

### Issue
You may see: `Unknown at rule @theme css(unknownAtRules)`

### Solution
This is just a linter warning - the `@theme` directive works perfectly! The linter doesn't recognize Tailwind-specific directives.

**Fixed**: Added `.vscode/settings.json` to ignore this warning:
```json
{
  "css.lint.unknownAtRules": "ignore",
  "scss.lint.unknownAtRules": "ignore"
}
```

## Testing Results

✅ **Confirmed**: Colors defined in `@theme` are being compiled correctly
- `--color-herve-blue: #1a3b8f` ✅
- `--color-herve-green: #80ff00` ✅
- `--color-herve-light-blue: #e0f0ff` ✅

❌ **Confirmed**: Changes to `tailwind.config.js` do NOT affect the output
- Changed `herve-blue` to `#FF0000` in config.js
- Compiled CSS still showed `#1a3b8f` (from `@theme`)

## Conclusion

- **Use `@theme` in CSS** for all Tailwind configuration
- **Ignore `tailwind.config.js`** - it's not used in Tailwind v4
- **The linter warning is harmless** - already fixed in VS Code settings

## References

- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs/v4-beta)
- [tailwindcss-rails gem](https://github.com/rails/tailwindcss-rails)

