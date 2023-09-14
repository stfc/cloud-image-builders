This file is currently manually maintained. It is used to target the
versions of Kubernetes that we support.

We plan on automating this in the future too as part of a matrix build strategy.

## Adding a new version
- Navigate to https://kubernetes.io/releases/
- Find the version you want to add or update
- Update the semver in the relevant JSON file. There should be a 1:1 mapping of
JSON files to major versions of Kubernetes. E.g. a file for 1.24, 1.25, etc.


## Developer Notes
Since we cannot add comments to JSON files I've documented some points here:

- We share the compliance role in the os_builders directory. This allows us to
update compliance for all of our images at once.
