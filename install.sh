
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ "$sourced" = "0" ];
then
    echo "Script must be soured" >&2
    exit 1
fi

if [ -z "$HOME" ]; then echo "\$HOME is not set" >&2; exit 1; fi

# Detect the shell this script was sourced in and pick the matching dot files.
# bash and zsh have parallel sets of scripts (.bash_* / .zsh_*) and rc files.
if [ -n "$ZSH_VERSION" ];
then
    SHELL_NAME="zsh"
    SCRIPT_SOURCE="${(%):-%x}"
    MINE_FILE="$HOME/.zsh_mine"
    COMMON_FILE=".zsh_common"
    RC_FILES=("$HOME/.zshrc")
elif [ -n "$BASH_VERSION" ];
then
    SHELL_NAME="bash"
    SCRIPT_SOURCE="${BASH_SOURCE}"
    MINE_FILE="$HOME/.bash_mine"
    COMMON_FILE=".bash_common"
    RC_FILES=("$HOME/.bash_profile" "$HOME/.bashrc")
else
    echo "Unsupported shell. Source this from bash or zsh." >&2
    exit 1
fi

cd "$(dirname "$SCRIPT_SOURCE")";

# .{bash,zsh}_mine is created for having personalized PC specific setup
touch "$MINE_FILE"

# Append the bootstrap lines to a shell rc file.
osum_bootstrap_rc() {
    file="$1"
    echo "Upating file: $file"
    printf "\n# Setting up personalized dot files and configuration" >> "$file"
    printf "\nexport OSUM_DOT_FILES=\""$(pwd)"\"" >> "$file"
    printf "\nsource \"\$OSUM_DOT_FILES\"/$COMMON_FILE" >> "$file"
}

if [ -z "$OSUM_DOT_FILES" ];
then
    for file in "${RC_FILES[@]}";
    do
        osum_bootstrap_rc "$file"
    done
    export OSUM_DOT_FILES="$(pwd)"
    source "$OSUM_DOT_FILES/$COMMON_FILE"
fi
unset -f osum_bootstrap_rc

for file in "$OSUM_DOT_FILES/sync/.gitconfig_common" "$OSUM_DOT_FILES/sync/.inputrc";
do
    outfile="$HOME/$(basename $file)"
    if [[ -f $outfile ]];
    then
        if [[ "$(readlink $outfile)" != "$file" ]];
        then
            >&2 echo "$outfile already exists and not a symlink to $file. Please fix it manually"
        fi
        continue
    fi

    ln -s "$file" "$outfile"
done

# Include .gitconfig_common in .gitconfig
git config --global include.path "$HOME/.gitconfig_common"
