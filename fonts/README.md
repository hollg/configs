# Fonts Configuration

This directory manages font installation for the terminal-based development environment.

## Font Included

- **MesloLGS NF** - Nerd Font specifically recommended by Powerlevel10k for optimal icon display
- **JetBrains Mono** - Nerd Font designed for legibility

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

### Ghostty
Add to your Ghostty config:
```yaml
font-family: JetBrains Mono
```

