# Releases

This doccument contains information relevant to users. This includes behavioral changes and bug fixes to OS images.

## 0.2.0 - 15th July 2026

No changes that affect users.

## 0.1.0 - 5th May 2026

### Overview:

This is the initial release of the versioned image builders. This versioning will keep track of what state the tooling was in when an image was built.

Fixes problems with user accounts on virtual machines and building on certain flavors.

### Details:

#### Added:

- Image metadata field "image_builder_version".
    - Use this to check which version of these releases your virtual machine is running.

#### Fixed:

- OpenStack user accounts will now create on virtual machines with 10.10 or 192.168 IP addresses.
- Removed user account faa44923 from the image.
- Now able to build virtual machines with these images on the l6.c2 flavor.
