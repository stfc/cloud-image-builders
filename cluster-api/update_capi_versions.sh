#!/bin/bash

set -euo pipefail

printf "%-20s %-20s %-25s\n" "kubernetes_series" "kubernetes_semver" "kubernetes_deb_version"
printf "%-20s %-20s %-25s\n" "-------------------" "-------------------" "------------------------"

for v in $(find versions -iname "v*.json" -printf "%f\n" | sed -e "s/.json//g" -e "s/_/./g"); do
 deb_version=$(
    curl -fsSL "https://pkgs.k8s.io/core:/stable:/$v/deb/Packages" |
    awk '
      /^Package: kubeadm$/ {found=1}
      found && /^Version:/ {print $2; found=0}
    ' |
    sort -V |
    tail -1
  )

 semver=$(echo "$deb_version" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

 printf "%-20s %-20s %-25s\n" "$v" "v$semver" "$deb_version"
done