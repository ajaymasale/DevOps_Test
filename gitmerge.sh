#!/bin/bash
# Script to merge Git branches
# Authors: Ajay Masale

# Pre-requisites
# 1 - Git should be installed.
# 2 - ssh public key should be saved in Git server.

# All variables are sourced interactively or direct inputs
# $1 - Source branch to be merged from
# $2 - Destination branch tobe merged to
# $3 - repo url

# functions
merge() {
  git checkout $2
  git merge --no-ff $1
  git push origin $2
  echo "Merged $1 to $2 successfully!"
  echo ""
  echo "..........................."
  # Ask if user requires to merge this to Master
  read -p "Do you want to merge with Master? [y/n] " -n 1 -r
  echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      # Merge to Master
      git checkout master
      git merge --no-ff $2
      git push origin master
      echo "Merging is complete!"
      echo ""
      echo "....................."
    fi
  echo "Job Done, Exiting!"
}

check_branch() {
    if [ "git branch --list $1" ]; then
       echo "Merging $1 with $2 ..."
       merge $1 $2
    else
      echo "Branch ($1) doesn't exist. Exiting now..."
      exit 1
    fi
}

#-Execution

# Locate the help argument before continuing
for arg in "$@"

do
    if [ $arg = "-h" ] || [ $arg = "--help" ]; then
        echo "# ---> User Interactive"
        echo "Usage: ./git_merge.sh"
        echo "OR"
        echo "# ---> Direct Input"
        echo "Usage: ./git_merge.sh <Source Branch> <Destination Branch> <Repo URL>"
        exit 0
    fi
done

# now process the input
if [ "$#" -eq 0 ]; then
  read -p "Enter the Git repo URL: " repourl
  read -p "Name of the source brance " branch
  read -p "Name of the destination branch " destbranch
  rm -rf workdir
  mkdir workdir
  cd workdir
  git clone $repourl && cd $(basename $_ .git)
  check_branch $branch $destbranch
else
  rm -rf workdir
  mkdir workdir
  cd workdir
  git clone $repourl && cd $(basename $_ .git)
  check_branch $branch $destbranch
  git checkout master
  for branch in "$@"
  do
      check_branch $branch $destbranch
  done
fi

exit 0
