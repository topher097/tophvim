ready-py:
    uv lock
    uv sync --locked

run: gadd
    nix run .

build: gadd
    nix build .

update:
    nix flake update
    devbox update
    just build

# Update the kickstart-template branch from external template repo
get-from-template-repo:
    git remote add template https://github.com/nix-community/kickstart-nix.nvim 2> /dev/null || :
    git fetch template
    git branch kickstart-template 2> /dev/null || :
    git checkout kickstart-template
    git merge template/main --allow-unrelated-histories -X theirs

# bundle:
#     nix bundle --bundler github:DavHau/nix-portable -o bundle

lockfile-pin:
    git add flake.lock
    git commit -m "pin: update flake.lock"
    git push

gadd:
    git add .
