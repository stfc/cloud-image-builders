# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added:

### Changed:
- Switched from Pakiti 2 to Pakiti 3. Virtual machines will now report to Pakiti correctly.

### Fixed:

### Removed:

## [0.2.1] - 2026-08-13

### Changed:
- Ubuntu 22.04 now uses the HWE 6.8 Kernel to mitigate CVE-2026-43499. [#175](https://github.com/stfc/cloud-image-builders/pull/175)

## [0.2.0] - 2026-07-15

### Added:
- Added new builders for Rocky 8 and 9 AQ images. [#148](https://github.com/stfc/cloud-image-builders/pull/148)

### Changed:
- Updated Ansible version for building. [#144](https://github.com/stfc/cloud-image-builders/pull/144)
- Created separate requirements file for RL8 image builds. [#153](https://github.com/stfc/cloud-image-builders/pull/153)

### Fixed:
- Ubuntu 22 stuck at reboot when building image. [#153](https://github.com/stfc/cloud-image-builders/pull/153)

## [0.1.0] - 2026-05-05

### Added:

- Added this CHANGELOG file to track changes to the images.
- Image metadata value "image_builder_version" to track the version of the image builders used when making the image [#135](https://github.com/stfc/cloud-image-builders/pull/135)

### Changed:
- Changed image build flavor to l6.c2 to enable images to be used on VMs with less than 50GB disk [#130](https://github.com/stfc/cloud-image-builders/issues/130)
- Changed update_cloud_users.sh to use the new username service. This script is more reslient to failures. [#138](https://github.com/stfc/cloud-image-builders/pull/138)

### Fixed:
- Fix user creation on VMs with 10.10 or 192.168 IP address [#126](https://github.com/stfc/cloud-image-builders/issues/126)
- Fix cleaning up users after image creation [#125](https://github.com/stfc/cloud-image-builders/issues/125)
