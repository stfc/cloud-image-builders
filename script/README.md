Helper scripts for building multiple images

- build-all.sh  - Build all CAPI images based on the JSON files in the `versions` directory
- upload_all.py - Upload all CAPI images to OpenStack based on the os-cloud provided

Upload All
==========

This automatically globs all the output files in the k8s-image-builder directory and uploads them to OpenStack with the
name format including today's date.

Preparation
-----------

- Create a venv
- Install the requirements from `requirements.txt`
- Build your images with `build-all.sh` or manually following the readme in the `cluster-api` directory

Usage
-----

`upload_all.py` requires the name of the OS cloud to upload to. It also has the following optional arguments:
- `--dry-run` - Do not upload the images, just print the commands
- `--public` - If specified the images will be public, otherwise they will be private to the project

