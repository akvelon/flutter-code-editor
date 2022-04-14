#!/usr/bin/env sh
# package.json "deploy": "yarn build; push-dir --dir=dist --branch=gh-pages --cleanup"

# abort on errors
set -e

# build
flutter build web --release --no-sound-null-safety

# navigate into the build output directory
cd build/web

# Commit repo
git init
git add -A
git commit -m 'deploy'
git push -f git@github.com:BertrandBev/code_field.git master:gh-pages

# Nav back
cd -