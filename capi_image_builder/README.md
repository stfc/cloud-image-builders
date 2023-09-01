- git submodule update --init --recursive

Manual testing
--------------

This is useful for testing new roles, customisations, etc. without having to run
the main pipeline script

```bash
cd upstream_image_builder/images/capi
PACKER_VAR_FILES="../../../customisation/stfc.json ../../../customisation/versions/vx_y.json" make build-qemu-ubuntu-2004
```