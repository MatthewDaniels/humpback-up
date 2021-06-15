:whale: "Humpback" - a GCP Based Backup System
======================================

## :construction: THIS IS A WORK IN PROGRESS :construction:

Feel free to use it, I would suggest the works is feature complete, but please do report any issues (and pull requests!).
Also checkout the todo list at the bottom of this page.

This simple script is an evolution of the great work done by Rudiger Wolf ([rnwolf](https://gist.github.com/rnwolf)) as documented here: https://gist.github.com/rnwolf/533bf309bd84982c4b39d1ca7c03991f

### READ THE ABOVE TUTORIAL FROM RUDIGER FOR BACKGROUND AND EXTRA HOW TO'S

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

`LOG_FOLDER`
- where to log to
- should be an absolute location
- should NOT contain a trailing slash

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
- can be set at runtime using the `-f` or `--file` parameter

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
- default is no (noisy)
- can be set at runtime using the `-q` or `--quiet` parameter

----------------------------------------
## Running

How to run the thing...

1. Setup GCP (as above)
2. Run `setup.sh` script to get OS setup (GCloud SDK & awk if required)
3. Setup any config variables above in the `_variables.sh` script
4. Create a descriptor file that has source to destination mapping plus any extra parameters for gsutil (recommend `-e` & `-r` - exclude symlinks & recursive respectively) - see the file [example_input](/example_input)
5. Run the main script with the appropriate parameters as per **Runtime Parameters** above (minimum requirements are `-f` & `-d`)
6. Relax, knowing your files are redundantly and securely stored (also, automate it)

----------------------------------------
## Automating

How to automate the thing...

Example cron job that backs up twice a day at 03:52 and 15:52:
`$ crontab -e`
`52 03,15 * * * ~/scripts/humpbackup -f ~/humpbackkup_input -d gs://some_gcs_bucket`

----------------------------------------
## TODO

- [x] Externalize source dirs
  - [x] Create a file which is just `source || destination || params || excludes`
  - [x] Load in the shell script
  - [x] Iterate the lines
  - [x] Use awk to parse the variables for use
- [x] create send function
  - [x] make sure the source & destination are set in the lines (log an error if not)
  - [x] log each response to file
- [x] handle dryrun
- [x] parse input vars
- [ ] docs
  - [x] config variables
  - [x] runtime parameters
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
