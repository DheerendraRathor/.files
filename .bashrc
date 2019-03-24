#!/bin/bash

for file in ~/.{bash_prompt,bash_custom}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;

# Brew bash completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
