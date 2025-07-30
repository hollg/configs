# Go Toolchain Configuration

This directory manages installation and configuration for the Go programming language toolchain.

## What's Included

- **Go (golang)** installed via Homebrew
- Version management and updates handled by Homebrew
- Ready for development with Go modules and common workflows

## Installation

Go is installed automatically when you run the main install script:

```bash
# Install all modules including Go
your/path/to/configs/install.sh

# Install only Go module
your/path/to/configs/install.sh go
```

## Usage

After installation, Go will be available in your PATH:

```bash
go version   # Check installed Go version
go run main.go   # Run Go programs
go mod init <module>   # Initialize Go modules
```

## Updating

Update Go via Homebrew:

```bash
brew upgrade go
```

## Uninstallation

To remove Go from your system:

```bash
brew uninstall go
```

## Troubleshooting

If Go is not available after installation:

1. Verify installation: `brew list go`
2. Restart your terminal
3. Ensure Homebrew's bin directory is in your PATH

## More Information

- [Go Documentation](https://golang.org/doc/)
- [Go Modules](https://blog.golang.org/using-go-modules)

