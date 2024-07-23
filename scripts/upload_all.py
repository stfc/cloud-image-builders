#!/usr/bin/env python3
"""
Script to upload all CAPI images in k8s-image-builder to OpenStack
"""

import argparse
import dataclasses
import logging
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List

import git
import openstack


@dataclasses.dataclass
class Args:
    """
    Holds user arguments for the script
    """

    dry_run: bool
    public: bool
    os_cloud: str


# Find the root of the git repository
def glob_output_files() -> List[Path]:
    """
    Globs the output files from the CAPI image builder
    :return: A list of files to upload
    """
    repo = git.Repo(".", search_parent_directories=True)
    root_dir = Path(repo.working_tree_dir)

    # Append the full path to the CAPI output directory
    capi_output_dir = root_dir / "k8s-image-builder" / "images" / "capi" / "output"
    output_files = capi_output_dir.glob("**/*kube*")

    return [i for i in output_files if i.is_file()]


def parse_args(args) -> Args:
    """
    Parse the user arguments
    :param args: sys.argv[1:] arguments
    :return: Parsed arguments as a dataclass
    """
    parser = argparse.ArgumentParser(description="Upload CAPI images to OpenStack")
    parser.add_argument(
        "--dry-run", action="store_true", help="Do not actually upload the images"
    )
    parser.add_argument("--public", action="store_true", help="Make the images public")
    parser.add_argument(
        "os_cloud", default="default", help="The OpenStack cloud to use"
    )
    parsed = parser.parse_args(args)
    return Args(**vars(parsed))


def get_upload_name(file: Path) -> str:
    """
    Generates the standard name for the uploaded image
    :param file: The Path of a file to upload
    :return: The name containing the date and original name
    """
    return f"capi-{file.name}-{datetime.today().strftime('%Y-%m-%d')}"


def upload_images_to_openstack(files: List[Path], args: Args):
    """
    Uploads the given files to OpenStack using the given arguments
    :param files: A list of files to upload
    :param args: The user args to drive the behaviour
    """
    for file in files:
        upload_args = {
            "name": get_upload_name(file),
            "filename": file.as_posix(),
            "disk_format": "qcow2",
            "container_format": "bare",
            "wait": True,
            "visibility": "public" if args.public else "private",
            # Metadata fields - setting through kwargs invokes automatic type conversion
            "hw_scsi_model": "virtio-scsi",
            "hw_disk_bus": "scsi",
            "hw_vif_multiqueue_enable": "true",
        }
        logging.debug("Upload args: %s", upload_args)
        if args.dry_run:
            logging.warning("Dry run, skipping upload")
        else:
            logging.info("Uploading %s...", file)
            upload_single_image(args.os_cloud, upload_args)
            logging.info("Uploaded %s", file)


def upload_single_image(os_cloud: str, upload_args: Dict):
    """
    Uploads a single image to OpenStack
    :param os_cloud: The OpenStack cloud to use
    :param upload_args: The parsed OpenStack SDK Image args
    """
    conn = openstack.connect(cloud=os_cloud)
    conn.create_image(**upload_args)


def main(args: Args):
    """
    Runs the main steps of the script to upload all images
    :param args: Pre-parsed args from the user
    """
    to_upload = glob_output_files()
    upload_images_to_openstack(to_upload, args)


if __name__ == "__main__":
    main(parse_args(sys.argv[1:]))
