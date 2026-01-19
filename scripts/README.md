# Helper scripts for building multiple images

- build-all.sh  - Build all CAPI images based on the JSON files in the `versions` directory

## Preparation
1. Create a venv with the dependencies
   ```shell
   sudo apt-get install python3-venv
   python3 -m venv venv
   source venv/bin/activate
   pip install -r os_builders/requirements.txt
   ```
2. Build your images with `build-all.sh` or manually following the readme in the `cluster-api` directory
   ```shell
   # Specify dev or prod OpenStack
   ./scripts/build-all.sh <env>
   ```
3. This will build all new images and upload them to OpenStack in the form `capi-ubuntu-2204-kube-<k8s_semver>`
