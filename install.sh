#!/usr/bin/env bash

#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude "install.sh" \
    -avh --no-perms . ~;

source ~/.bash_profile;
