#!/usr/bin/env bash

branch=$(git symbolic-ref --short -q HEAD)

if [[ $branch =~ ^[0-9.]+$ ]]
then
  echo The Dockerfile, for branch \'$branch\', will be push to the repository.
  git status
  #git add Dockerfile -f
  #git commit -m '[ci skip]'
  #git push
else
  echo The branch name \'$branch\' does not match regexp \'\^[0-9.]+\$\' =\> Dockerfile is not push to the repository.
fi
