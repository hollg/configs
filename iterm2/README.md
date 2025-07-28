# iTerm2 Configuration

This module installs and manages iTerm2 terminal emulator with Catppuccin themes and version-controlled preferences.

## What's Included

- iTerm2 terminal emulator installed via Homebrew cask
- Catppuccin color themes (Mocha, Latte, Frappe, Macchiato)
- Version-controlled iTerm2 preferences (via Stow)
- Export/import workflow for configuration management

## Installation

Run the install script to set up iTerm2 and themes:

```bash
cd iterm2
./install.sh
```

Or install as part of the full configs project:

```bash
# From the root of the configs project
./install.sh iterm2
```

## Configuration Workflow

### Initial Setup
1. **Install iTerm2**: `./install.sh`
2. **Use this configuration**: `settings` > `General` > `Settings` > check `Load preferences from a custom folder or URL` and select `~/configs/iterm2`
3. **Auto-save changes**: Under `Save changes` select `Automatically`
4. **Push changes to git**: Remember that changes should be pushed to git to keep everything synced

### Making Changes
1. **Modify settings** in iTerm2 application
2. **Auto-saved**: Changes are instantly reflected in this repo
3. **Commit to git** when you want to save a snapshot

### New Machine Setup
1. **Clone this repo**
2. **Install iTerm2**: `./install.sh iterm2`
3. **Apply config**: `stow iterm2`
4. **Done!** All your settings are applied instantly

## Scripts

- `install.sh` - Install iTerm2 and download themes
- `setup.sh` - Show configuration workflow and status

## Themes

The module includes all Catppuccin iTerm2 themes:

- **Catppuccin Mocha** (Dark) - Recommended for dark environments
- **Catppuccin Latte** (Light) - For light environments  
- **Catppuccin Frappe** (Dark) - Warmer dark variant
- **Catppuccin Macchiato** (Dark) - Medium contrast dark variant

### Manual Theme Import

After installation, import themes manually in iTerm2:

1. Open iTerm2 Preferences (`⌘ + ,`)
2. Go to **Profiles** → **Colors** → **Color Presets** → **Import**
3. Navigate to your configs directory: `<configs-path>/iterm2/colors/`
4. Select your preferred `.itermcolors` file (e.g., `catppuccin-mocha.itermcolors`)
5. Click **Open** to import the theme
6. Select the newly imported theme from the **Color Presets** dropdown

**Note**: The `.itermcolors` files are color scheme files that must be imported through iTerm2's preferences interface. They cannot be automatically applied via the command line.

## Features

- **Homebrew Installation**: Installs iTerm2 via Homebrew cask for easy management
- **Catppuccin Themes**: Beautiful, soothing pastel themes for better coding experience
- **Conflict Detection**: Detects existing manual installations and provides cleanup instructions
- **Verification**: Verifies successful installation
- **Package Management**: Easy updates via `brew upgrade --cask iterm2`

## Configuration with Stow

The module includes a `Library/` directory structure that mirrors your home directory for use with GNU Stow.

### Using Stow for configuration management

```bash
# From the root of configs project
stow iterm2
```

This will create symlinks for any configuration files you place in:
- `iterm2/Library/Preferences/` → `~/Library/Preferences/`
- `iterm2/Library/Application Support/iTerm2/` → `~/Library/Application Support/iTerm2/`

### Adding your own configurations

1. **Export current settings**:
   ```bash
   # Export your current iTerm2 preferences
   cp ~/Library/Preferences/com.googlecode.iterm2.plist iterm2/Library/Preferences/
   ```

2. **Apply with Stow**:
   ```bash
   stow iterm2
   ```

3. **Version control**: Your iTerm2 settings are now tracked in git!

## Manual Cleanup

If you have a manually installed iTerm2 that conflicts with the Homebrew installation, remove it with:

```bash
rm -rf "/Applications/iTerm.app"
rm -rf ~/Library/Preferences/com.googlecode.iterm2.plist
rm -rf ~/Library/Application\ Support/iTerm2/
```

## Recommended Settings

After installation and theme setup, configure these iTerm2 settings for the best experience:

### Essential Setup
1. **Profiles** → **Text** → **Font**: Use a Nerd Font (like MesloLGS NF from the fonts module)
2. **Profiles** → **Colors**: Import and select your preferred Catppuccin theme
3. **Appearance** → **General** → **Theme**: 
   - **Dark** for Mocha/Frappe/Macchiato themes
   - **Light** for Latte theme
   - This makes the title bar match your color scheme!

### Optional Improvements
4. **Profiles** → **Terminal** → **Scrollback**: Increase to 10,000+ lines
5. **Profiles** → **Keys** → **Key Mappings**: Load Preset → Natural Text Editing
6. **Appearance** → **General** → **Status bar location**: Bottom (cleaner look)

### Pro Tip: Title Bar Colors
The key to making iTerm2 look great with Catppuccin is setting the **Appearance Theme** to match your color scheme. This eliminates the ugly default macOS title bar and makes everything cohesive.

## Updating

Update iTerm2 via Homebrew:

```bash
brew upgrade --cask iterm2
```

To update themes, re-run the install script:

```bash
./iterm2/install.sh
```

## Uninstalling

Remove iTerm2 via Homebrew:

```bash
brew uninstall --cask iterm2
```

## Troubleshooting

### Themes not showing up
- Ensure you've imported them via iTerm2 Preferences
- Check that files exist in `iterm2/colors/` directory
- Restart iTerm2 after importing

### Font rendering issues
- Install a Nerd Font (the fonts module includes MesloLGS NF)
- Set the font in Preferences → Profiles → Text
