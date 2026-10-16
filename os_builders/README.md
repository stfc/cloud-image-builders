# os_builders

## Contents:

- [How to build images](#how-to-build-images)
- [How to update the playbooks](#how-to-update-the-playbooks)
- [How to release a new version](#how-to-release-a-new-verison)
- [How to release a hotfix](#how-to-release-a-hotfix)
- [Branch reviews](#branch-reviews)

## How to build images

### Setting up the build environment

#### Prerequisites:
- Rocky or Ubuntu VM
- Access to the **packer** project, on dev and prod
- Application credential for **packer** project, admin is not required

#### Steps on VM:

1. Install Python pip and venv modules
   ```shell
   # Ubuntu
   sudo apt install python3-pip python3-venv -y
   # Rocky
   sudo dnf install python3-pip python3-venv -y
   ```

2. Create a virtual environment
   ```shell
   python3 -m venv image_builders
   source image_builders/bin/activate
   ```

3. Clone the repository
   ```shell
   git clone https://github.com/stfc/cloud-image-builders.git

   cd cloud-image-builders/os_builders
   ```

4. Install Python packages
   ```shell
   # Unless you are building Rocky 8 images, use the standard requirements.txt
   pip install -r requirements.txt
   # For Rocky 8 images
   pip install -r requirements-rl8.txt
   ```
  
5. Install Packer and dependencies
   ```shell
   ansible-playbook prep_builder.yml
   ```

6. Create clouds.yaml with application credential
   ```shell
   mkdir -p ~/.config/openstack
   touch ~/.config/openstack/clouds.yaml

   # Using vim or nano, paste your application credential into the clouds.yaml
   ```

### Building the image

The following steps assume you have set up your VM correctly as in the previous steps.

#### Steps on VM:

1. Ensure environment is prepared
   ```shell
   source ~/image_builders/bin/activate
   cd ~/cloud-image-builders/os_builders
   export OS_CLOUD=openstack
   ```
2. Choose from the following steps whether you want to build one or multiple images. Also, "env=dev" should match the environment your application credentials were made in.
4. Intiate Packer image build for multiple images
   ```shell
   # Replace image-name with the actual image name. "openstack." is required
   packer build --var env=dev -only openstack.<image-name>,openstack.<image-name>... build.pkr.hcl
   # e.g.
   packer build --var env=dev -only openstack.ubuntu-jammy-24.04-nogui,openstack.rocky-9-nogui build.pkr.hcl
   ```
5. Initiate Packer image build for a single image
   ```shell
   # Replace image-name with the actual image name. "openstack." is required
   packer build --var env=dev -only openstack.<image-name> build.pkr.hcl
   # e.g.
   packer build --var env=dev -only openstack.ubuntu-jammy-22.04-nogui build.pkr.hcl
   ```
6. Once the build completes successfully you will get a UUID of the new image

### Testing the image is working

We need to do some basic verification on the image before releasing it to users.

#### Steps on VM:

1. Ensure environment is prepared
   ```shell
   source ~/image_builders/bin/activate
   cd ~/cloud-image-builders/os_builders
   export OS_CLOUD=openstack
   ```

2. Build a new VM using the new image. This can be done in Horizon or command line from the VM
   ```shell
   openstack server create --wait \
   --flavor l3.nano \
   --network Internal \
   --key-name <openstack-ssh-key-name> \
   --image <new-image-id> \
   <server-name>
   ```

3. SSH to VM with your fed ID, if you are not using an SSH agent you will need to exit this VM first
   ```shell
   ssh <fed-id>@172.16.X.Y
   ```

4. If you get logged in then testing is complete. If not then it needs to be looked into.

5. Delete VM in Horizon or command line from the VM
   ```shell
   openstack server delete <server-name>
   ```

### Releasing an image

The new image needs to be made public and renamed, the old image needs to be deactivated and renamed. This **requires** an admin account.

#### Steps on VM:

1. Ensure environment is prepared
   ```shell
   source ~/image_builders/bin/activate
   cd ~/cloud-image-builders/os_builders
   export OS_CLOUD=openstack
   ```

2. Run the rename_images.sh script to make it public
   ```shell
   ./rename_images.sh <current-image-name> <new-image-id>
   # e.g.
   ./rename_images.sh ubuntu-jammy-22.04-nogui 0b8884fa-111c-4d8f-aa4c-98bed3f521c8
   ```

## How to update the playbooks

The image configuration is based on the Ansible playbooks run by Packer. If we want to make changes, e.g. update a pinned package version, then you need to update or add new roles / tasks. When making any changes you will need to verify they work across all the OS images in the build file.

#### Steps on VM:

1. Ensure environment is prepared
   ```shell
   source ~/image_builders/bin/activate
   cd ~/cloud-image-builders/os_builders
   export OS_CLOUD=openstack
   ```
2. Bring development branch up to date with remote
   ```shell
   git switch develop
   git pull
   ```
2. Create a branch name using the correct prefix:
   - **feature/<feature>**
   - **docs/<docs>**
   - **bugfix/<fixes>**
   - **release/<release>**
2. Switch to new branch
   ```shell
   # For example:
   git switch -c feature/update-wazuh
   ```
2. Create a VM using the current image for the OS 
  ```shell
  openstack server create --wait \
  --network Internal
  --flavor l3.nano \
  --image <os-image> \
  --key-name <your-openstack-key> \
  <server-name>
  ```

3. Edit `inventory.yml` and add your host's IP
  ```shell
  # Contents of: inventory.yml
  ---
  all:
    hosts:
      test-vm:
        ansible_host: "172.16.255.255"  # Your host's IP
        ansible_user: "ubuntu"  # or rocky
  ```

4. Run the baseline against the VM
  ```shell
  ansible-playbook -i inventory configure_os_images.yml
  ```

5. If it is an AQ image, run the quattor playbook
  ```shell
  ansible-playbook -i inventory quattor.yml
  ```
6. Repeat steps 5-6 making changes to the playbooks

7. Commit any changes you have made and update the [CHANGELOG](./CHANGELOG.md)

8. Make a pull request to either **develop** adding labels and linking, if any, the GitHub issue

9. See [Branch Reviews](#branch-reviews)

## How to release a new image builders version

By default we do not put any unreleased changes into the main branch. This allows images to be built without switching branches, preventing mistakes. To release the next version we need to merge the next version branch into main.

This only requires Git and you do not need the environment set up to build images.

#### Steps:

1. Clone and change into the repository directory
   ```shell
   git clone git@github.com:stfc/cloud-image-builders.git
   cd cloud-image-builders/os_builders
   ```
2. Create a release branch to freeze changes. Then other work can continue to be merged into develop
   ```shell
   git switch develop
   git pull
   git switch -c release/<version>
   ```
3. In [CHANEGLOG.md](./CHANGELOG.md):
   - Update the unreleased section to the next version and date it.
   - Add the pull request URL to any changes that are missing one.
   - Add a new unreleased section at the top
5. In [RELEASES.md](./RELEASES.md):
   - Add the release version with the date
   - Summarise changes **that affect** users.
   - If no changes affect users then state that.
6. Update the version in:
   - [version.txt](./version.txt).
   - [build.pkr.hcl](./build.pkr.hcl): The variable **image_builder_version**
8. Commit and push the changes as the following:
   ```markdown
   RELEASE: Version 0.X.Y

   See RELEASES.md and CHANGELOG.md for details.
   ```
9. In GitHub, create a pull request from the release branch to main.
   ```markdown
   For example:
   main <- release/0.5.1
   ```
10. See [Branch Reviews](#branch-reviews)
11. Once the release branch has been merged into main, it needs to be merged back into develop
12. See [Branch Reviews](#branch-reviews)

## How to release a hotfix

Sometimes bugs are not noticed until after release. If they are important and need to be fixed we need to be able to get a fix merged into main without merging unprepared development features. Follow the below steps to create a new release with the hotfix.

#### Steps:

1. Start from main and make sure it is up-to-date.
   ```shell
   git switch main
   git pull
   ```
2. Create a new branch from here. This avoids having to merge in features from **develop**.
   ```shell
   # It is important you use the prefix "hotfix/"
   git switch -c hotfix/<bug>
   ```
3. Write the fix and commit it to the branch.
   ```shell
   # ... bug fixing in the playbooks
   git add <files>
   git commit
   # Commit message: 
   # HOTFIX - os_builders: Some hotfix
   # 
   # This issue must be addressed in a hotfix and we cannot wait
   # for the next release.
   ```
4. Test the fix thoroughly against all images. You don't want to have to hotfix a hotfix.
   ```shell
   packer build ...
   ```
5. Create the release commit within this branch also. Follow steps 4 to 7 from the [release guide](#how-to-release-a-new-image-builders-version).
6. Create a pull request to the **main** branch.
10. See [Branch Reviews](#branch-reviews)
7. Once it has been merged follow [How to build images](#how-to-build-images).
11. After we are back to stable. The branch has been merged into main, it needs to be merged back into develop
12. See [Branch Reviews](#branch-reviews)


## Branch Reviews

Merging feature branches into **develop** is where the majority of code will be reviewed. Any new features should be working before they are merged. This is important as release branches are made off of develop. That means any broken code in develop will make it to a release.

**The following describes criteria for the quality and number of reviews for the most common branching scenarios:**

### develop <-- feature/*
#### Consider:
This is usually new code such as tests, bug fixes, new features...

#### Criteria:
- At least 2 reviewers
- Must confirm code is working
- Must confirm testing has been done via an image build

### main <-- release/*
#### Consider:
1. All code has been through the develop branch and reviewed thoroughly.
2. Here we make sure that the release documentation is clear and the version update is sane.
3. Although the commits with the new code will be included in the changes, it is not neccesary to review them.

#### Criteria:
- At least 1 reviewer
- Must confirm the version update follows [SemVer](https://semver.org/)
- Must confirm [RELEASES.md](./RELEASES.md) and [CHANGELOG.md](./CHANGELOG.md) have been updated.

### develop <-- release/*
#### Consider:
1. The code has already been merged to main.
2. The only new changes should be docummentation and versions
3. There may be merge conflicts as develop has moved ahead

#### Criteria:
- At least 1 reviewer
- Must confirm the [CHANGELOG.md](./CHANGELOG.md) has had conflicts resolved correctly.

### main <-- hotfix/*
#### Consider:
Can the fix be applied as a bugfix in the next release?
- Yes. Change the merge target to **develop**
- No. Review thoroughly

#### Criteria:
- At least 2 reviewers
- Must confirm code is working
- Must confirm testing has been done via an image build **by someone other than the author**

### develop <-- hotfix/*
See develop <-- release/*
