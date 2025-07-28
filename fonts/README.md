# Fonts Configuration

This directory manages font installation for the terminal-based development environment.

## Font Included

- **MesloLGS NF** - Nerd Font specifically recommended by Powerlevel10k for optimal icon display

## Installation

The font is installed automatically when you run the main install script:

```bash
# Install all modules including fonts
./install.sh

# Install only fonts module
./install.sh fonts
```

## Terminal Configuration

After installation, configure your terminal to use the MesloLGS NF font:

### iTerm2
1. Open iTerm2 Preferences (`Cmd + ,`)
2. Go to Profiles → Text
3. Change Font to "MesloLGS NF"
4. Set size to 12-14pt (recommended)

### macOS Terminal
1. Open Terminal Preferences (`Cmd + ,`)
2. Select your profile (or create a new one)
3. Go to Text tab
4. Change Font to "MesloLGS NF"
5. Set size to 12-14pt

### VS Code Integrated Terminal
Add to your VS Code settings.json:
```json
{
    "terminal.integrated.fontFamily": "MesloLGS NF",
    "terminal.integrated.fontSize": 13
}
```

### Alacritty
Add to your alacritty.yml:
```yaml
font:
  normal:
    family: MesloLGS NF
  size: 13.0
```

## Why This Font?

- **Nerd Font**: Includes additional glyphs for icons, symbols, and powerline segments
- **Powerlevel10k Optimized**: Specifically designed to work perfectly with Powerlevel10k
- **Programming Focus**: Optimized for code readability
- **Consistent Experience**: Same font across all development tools

## Troubleshooting

If icons don't display correctly in your terminal:

1. Verify the font is installed: `brew list --cask font-meslo-lg-nerd-font`
2. Restart your terminal application completely
3. Check that your terminal is using "MesloLGS NF" (not "Meslo" or similar)
4. Ensure font size is not too small (12pt minimum recommended)

## Uninstallation

To remove the installed fonts:

1. **Uninstall via Homebrew**:
   ```bash
   brew uninstall --cask font-meslo-lg-nerd-font
   ```

2. **Reset terminal font settings**:
   - **iTerm2**: Go to Preferences → Profiles → Text → Change font back to default
   - **macOS Terminal**: Go to Preferences → Text → Change font back to default
   - **VS Code**: Remove or change the `terminal.integrated.fontFamily` setting
   - **Alacritty**: Remove or change the font family in alacritty.yml

3. **Verify removal**:
   ```bash
   # Check if font is still installed
   brew list --cask | grep font-meslo
   ```

**Note**: After uninstalling, terminal icons and symbols may not display correctly if you're using Powerlevel10k or other tools that rely on Nerd Fonts.
