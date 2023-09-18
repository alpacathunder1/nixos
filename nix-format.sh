#!/bin/sh
CONFIG="/etc/nixos/configuration.nix"

nixfmtCheck (){
	which nixfmt > /dev/null 2>&1
}

nixfmtRun (){
	echo "Running nixfmt..."
	nixfmt "$CONFIG"
}

nixfmtFail (){
	echo "Nixfmt not found, not running..."
}

if nixfmtCheck
then
	nixfmtRun
else
	nixfmtFail
fi
