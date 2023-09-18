#!/bin/sh
which nixfmt &> /dev/null && \
	echo "Running nixfmt..." && \
	nixfmt /etc/nixos/configuration.nix || \
	echo "Nixfmt not found, not running..."
