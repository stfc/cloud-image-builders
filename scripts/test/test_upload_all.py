"""
Associated tests for the upload_all.py script
"""

from datetime import datetime
from pathlib import Path
from typing import Dict
from unittest import mock
from unittest.mock import Mock, call

import pytest

from upload_all import (
    glob_output_files,
    Args,
    parse_args,
    upload_images_to_openstack,
    upload_single_image,
    main,
    get_upload_name,
)


def test_glob_output_files(tmp_path):
    """
    Test that the glob_output_files function returns the expected files
    and does not include directories
    :param tmp_path: A temp path setup by pytest
    """
    expected_output_path = tmp_path / "k8s-image-builder" / "images" / "capi" / "output"
    expected_output_path.mkdir(parents=True)

    expected = ["ubuntu-kube-1.23.4", "ubuntu-kube-1.40.0"]
    for out_name in expected:
        # Make parent dir as this is a named dir with a single file
        (expected_output_path / out_name).mkdir(parents=True)
        (expected_output_path / out_name / out_name).touch()
        # And a fake file in each
        (expected_output_path / out_name / "should_not_appear").touch()

    with mock.patch("git.Repo") as mocked_repo:
        mocked_repo.return_value.working_tree_dir = str(tmp_path)
        returned = list(glob_output_files())  # Avoid exhausting the generator

    expected = sorted(str(expected_output_path / file / file) for file in expected)
    assert sorted(str(file) for file in returned) == expected
    assert len(returned) == len(expected)


def test_arg_parse_all_true():
    """
    Tests that the parse_args function returns the expected Args object
    if the user sets all optional arguments
    """
    user_input = ["--dry-run", "--public", "default"]
    expected = Args(dry_run=True, public=True, os_cloud="default")
    assert parse_args(user_input) == expected


def test_arg_parse_no_optional_args():
    """
    Tests that the parse_args function returns the expected Args object
    if the user does not set any optional arguments
    """
    user_input = ["bar"]
    expected = Args(dry_run=False, public=False, os_cloud="bar")
    assert parse_args(user_input) == expected


def test_arg_parse_no_args():
    """
    Tests that the parse_args function exits with a SystemExit
    if the user does not set the OS cloud argument
    """
    user_input = []
    with pytest.raises(SystemExit):
        parse_args(user_input)


def test_upload_images_to_openstack_dry_run():
    """
    Tests that the upload_images_to_openstack function does not call
    anything uploading to OpenStack if the dry_run flag is set
    """
    expected_files = [Path("file1"), Path("file2")]
    args = Args(dry_run=True, public=True, os_cloud="default")

    with mock.patch("upload_all.upload_single_image") as mocked_upload_single_image:
        upload_images_to_openstack(expected_files, args)

    mocked_upload_single_image.assert_not_called()


def _expected_args_helper(file: Path, visibility: str) -> Dict:
    """
    Helper function to generate the expected arguments for upload_single_image
    :param file: The Path of a file to upload
    :param visibility: A string of either "public" or "private"
    :return: A dictionary of expected arguments for an assert call list
    """
    # pylint: disable=duplicate-code
    return {
        "name": get_upload_name(file),
        "filename": file.as_posix(),
        "disk_format": "qcow2",
        "container_format": "bare",
        "wait": True,
        "visibility": visibility,
    }


def test_upload_images_to_openstack_real_run():
    """
    Tests that the upload_images_to_openstack function calls
    upload_single_image with the expected arguments
    """
    expected_files = [Path("file1"), Path("file2")]

    args = Args(dry_run=False, public=True, os_cloud="default")
    with mock.patch("upload_all.upload_single_image") as mocked_upload_single_image:
        upload_images_to_openstack(expected_files, args)

    expected = [
        call(args.os_cloud, _expected_args_helper(file, "public"))
        for file in expected_files
    ]
    mocked_upload_single_image.assert_has_calls(expected, any_order=True)


def test_upload_images_with_private_annotation():
    """
    Tests that the upload_images_to_openstack function calls
    upload_single_image with the expected arguments if the public flag is not set
    """
    args = Args(dry_run=False, public=False, os_cloud="foo")
    with mock.patch("upload_all.upload_single_image") as mocked_upload_single_image:
        upload_images_to_openstack([Path("file1")], args)

    assert mocked_upload_single_image.call_count == 1
    expected = [call(args.os_cloud, _expected_args_helper(Path("file1"), "private"))]
    assert mocked_upload_single_image.call_args_list == expected


def test_upload_single_image():
    """
    Tests the connection and image upload forwards the args as-is
    """
    fake_args = {"foo": "bar", "baz": "qux"}
    with mock.patch("openstack.connect") as mocked_openstack_connect:
        mocked_openstack_connect.return_value.create_image = Mock()
        upload_single_image("fake_cloud", fake_args)

    mocked_openstack_connect.assert_called_once_with(cloud="fake_cloud")
    mocked_openstack_connect.return_value.create_image.assert_called_once_with(
        **fake_args
    )


def test_get_upload_name():
    """
    Tests that the name generator returns the expected name
    with the format capi-{file.name}-{today's date}
    """
    input_name = "ubuntu-kube-1.23.4"
    expected = f"capi-{input_name}-{datetime.today().strftime('%Y-%m-%d')}"
    print(f"Expected: {expected}")
    assert get_upload_name(Path(input_name)) == expected


@mock.patch("upload_all.glob_output_files")
@mock.patch("upload_all.upload_images_to_openstack")
def test_main_steps(mock_upload, mock_glob):
    """
    Tests the main flow ordering of the script
    """
    args = Args(dry_run=True, public=True, os_cloud="default")
    main(args)

    mock_glob.assert_called_once()
    mock_upload.assert_called_once_with(mock_glob.return_value, args)
