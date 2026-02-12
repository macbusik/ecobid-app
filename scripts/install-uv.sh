#!/bin/bash

echo "Installing uv package manager..."
curl -LsSf https://astral.sh/uv/install.sh | sh

echo ""
echo "Installing Python 3.10..."
~/.local/bin/uv python install 3.10

echo ""
echo "✓ Installation complete!"
echo ""
echo "Add to your PATH (add to ~/.bashrc or ~/.zshrc):"
echo 'export PATH="$HOME/.local/bin:$PATH"'
echo ""
echo "Then reload your shell:"
echo "source ~/.bashrc  # or source ~/.zshrc"
echo ""
echo "Verify installation:"
echo "uvx --version"
