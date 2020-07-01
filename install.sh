
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ "$sourced" == "0" ];
then
    echo "Script must be soured" >&2
    exit 1
fi

if [ -z "$HOME" ]; then echo "\$HOME is not set" >&2; exit 1; fi

cd "$(dirname "${BASH_SOURCE}")";

# .bash_mine is created for having personalized PC specific setup
touch "$HOME"/.bash_mine

if [ -z "$OSUM_DOT_FILES" ];
then
    for file in "$HOME"/.{bash_profile,bashrc};
    do
        echo "Upating file: $file"
        printf "\n# Setting up personalized dot files and configuration" >> "$file"
        printf "\nexport OSUM_DOT_FILES=\""$(pwd)"\"" >> "$file"
        printf "\nsource \"\$OSUM_DOT_FILES\"/.bash_common" >> "$file"
    done
    export OSUM_DOT_FILES="$(pwd)"
    source "$OSUM_DOT_FILES/.bash_common"
fi

SYNC_FILES="$OSUM_DOT_FILES/sync/.gitconfig_common $OSUM_DOT_FILES/sync/.inputrc"
for file in $SYNC_FILES;
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

