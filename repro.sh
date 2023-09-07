#!/usr/bin/env bash

set -euo pipefail

shouldFail=false
if [ -z "${GOOGLE_USE_DEFAULT_CREDENTIALS:-}" ]; then
  echo "Warning: GOOGLE_USE_DEFAULT_CREDENTIALS is not set, recommend setting this to true."
  exit 1
fi
if [ -z "${GOOGLE_PROJECT:-}" ]; then
  echo "Error: GOOGLE_PROJECT is not set"
  shouldFail := true
fi

if [ -z "${GOOGLE_REGION:-}" ]; then
  echo "Error: GOOGLE_REGION is not set"
  shouldFail := true
fi
if [ -z "${GOOGLE_ZONE:-}" ]; then
  echo "Error: GOOGLE_ZONE is not set"
  shouldFail := true
fi

if $shouldFail; then
  echo "One or more errors occurred, exiting"
  exit 1
fi

# Prompt the user if we should remove any .gitignored files, i.e.: statefiles, .terraform directories:
echo "Would you like to remove any .gitignored files? (y/n)"
read -r removeFiles
if [ "$removeFiles" = "y" ]; then
  echo "Removing .gitignored files"
  find . -type d -name ".terraform" -prune -exec rm -rf {} \;
  find . -type f -name "*.tfstate*" -prune -exec rm -rf {} \;
fi

cwd=$(pwd)
exit() {
  echo "⚠️ Cleaning up in 5 seconds. If this script ran as expected, you should see an error above."
  sleep 5
  if [ -f "${cwd}/update/terraform.tfstate" ]; then
    cd "${cwd}/update"
    terraform destroy
  elif [ -f "${cwd}/create/terraform.tfstate" ]; then
    cd "${cwd}/create"
    terraform destroy
  fi
}
trap "exit" INT TERM ERR

pushd create
terraform init
terraform apply
popd

pushd update
terraform init
terraform apply
popd

pushd update
cp ../create/terraform.tfstate .
terraform init
echo "⚠️ We expect this apply to fail with Error 412: Condition does not match., staleData"
terraform apply -refresh=false
popd
