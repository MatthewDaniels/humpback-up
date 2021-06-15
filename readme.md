:whale: "Humpback" - a GCP Based Backup System
======================================

# :construction: THIS IS A WORK IN PROGRESS


<!-- ![Humpback Whale by Philipp Lehmann from the Noun Project](/humpback_whale.png) -->

This simple script is an evolution of the great work done by Rudiger Wolf ([rnwolf](https://gist.github.com/rnwolf)) as documented here: https://gist.github.com/rnwolf/533bf309bd84982c4b39d1ca7c03991f

*These scripts are designed for use on Debian based systems - and have been tested most thoroughly in Ubuntu*

----------------------------------------
## Setup

### OS Software Requirements

OS Requirements are as follows:
- `gsutil` (part of the GCloud SDK) to interface with Google Cloud Storage
- `awk` (of some description) - if an alternative (ie: `gawk` or `mawk`) is used, make sure there is a symlink or reference to use the command `awk` (this is done on most linux distros)


**Note:** While it was attempted to use ONLY bash capabilities, things were MUCH easier with awk - this is most likely installed in your linux based OS, but its existence is checked and mawk is installed if it is not present.


### GCP Setup

1. Create a GCP account
2. Ensure billing is enabled
3. Create GCP Project
4. Create a GCS bucket

**Recommended bucket settings:**

* Class: [Coldline](https://cloud.google.com/storage/docs/storage-classes#coldline) or [Archive Storage](https://cloud.google.com/storage/docs/storage-classes#archive)
* Region: Any (take into account data soverienty & [cost](https://cloud.google.com/storage/pricing))
* Access Control: Uniform
* Encryption: Google managed (take into account whether you are ok with this)
* Retention Policy: none


Make sure you understand the classes so that you make the right decision that suits your needs.

A single region bucket is fine - high availability is not the aim of this, and all regions have 99.999999999% annual durability (which *is* the aim of backups).

### Variables

**Config:**

These are found in the _variables.sh file in the includes folder.

`GCLOUD_CONFIG_NAME`
- the [gcloud sdk configuration](https://cloud.google.com/sdk/docs/configurations) to use
- defaults to `personal-backups`
- can be set at runtime using the `-cn` or `--config_name` parameter


`BASE_EXCLUDES`
- base excludes for use across all runs
- includes a series of sensible built-in exclusions
- extra excludes patterns can be sent in PER source via the include file - these are joined at runtime to the base excludes


`GSUTIL`
- the location of the gsutil command on your machine
- requires full path, ~/gsutil/gsutil: No such file or directory
- use `$ whereis gsutil` to determine the locations of it


**Runtime Parameters**

These can be sent into the script as runtime parameters

`GCLOUD_PROJECT`
- *OPTIONAL*
- the Google Cloud project to use
- configurations can be updated to use different projects, so checks are put in to ensure the correct config AND project are used
- if no prokect is sent in, then whatever is set on the config is used
- can be set at runtime using the `-p` or `--project` parameter

`SOURCE_FILE`
- *REQUIRED*
- Absolute path to the mapping file to be loaded
- Multi-line file
- Structured as follows: `source | destination | [params] | [excludes]`
- can be set at runtime using the `-dr` or `--dry_run` parameter

`DESTINATION_BUCKET`
- *REQUIRED*
- the gsutil URI to the bucket (eg: gs://my-unique-bucket-name)
- can be copied from [Google Cloud Console UI > Storage Browser](https://console.cloud.google.com/storage/browser) > { bucket} > COnfiguration tab 
- should NOT contain a trailing slash (as per the copied value from Google Cloud Console UI)
- can be set at runtime using the `-d` or `--destination` parameter

`DRY_RUN`
- *OPTIONAL*
- whether or not this run will be a dry run 
- default is no (NOT y or yes or true or 1)
- can be set at runtime using the `-dr` or `--dry_run` parameter

`QUIET`
- *OPTIONAL*
- whether or not the run will be noisy (ie: using the gsutil -q parameter) 
- default is yes (NOT n or no or false or 0)
- can be set at runtime using the `-q` or `--quiet` parameter

----------------------------------------
## Running

How to run the thing...


----------------------------------------
## Automating

How to automate the thing...


----------------------------------------
## TODO

- [ ] Externalize source dirs
  - [ ] Create a file which is just `source || destination || params || excludes`
  - [x] Load in the shell script
  - [x] Iterate the lines
  - [x] Use awk to parse the variables for use
- [x] create send function
  - [ ] make sure the source & destination are set (log an error if not)
  - [x] log each response to file
- [ ] handle dryrun
- [ ] parse input vars
- [ ] docs
  - [ ] config variables
  - [ ] runtime parameters
  - [ ] executing
  - [ ] automating
- [ ] windows version
- [ ] mac / darwin version

----------------------------------------
## Legal

### Licence

MIT - see [LICENCE](/LICENCE)

### Attribution

* Original code by Rudiger Wolf ([rnwolf](https://gist.github.com/rnwolf))
