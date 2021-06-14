:whale: "Humpback" - a GCP Based Backup System
======================================

# :construction: THIS IS A WORK IN PROGRESS


<!-- ![Humpback Whale by Philipp Lehmann from the Noun Project](/humpback_whale.png) -->

This simple script is an evolution of the great work done by Rudiger Wolf ([rnwolf](https://gist.github.com/rnwolf)) as documented here: https://gist.github.com/rnwolf/533bf309bd84982c4b39d1ca7c03991f

*These scripts are designed for use on Debian based systems - and have been tested most thoroughly in Ubuntu*

----------------------------------------
## Setup

### OS Software Requirements

While it was attempted to use ONLY bash capabilities, things were MUCH easier with awk - this is most likely installed in your linux based OS, but its existence is checked and mawk is installed if it is not present.


### GCP Setup

1. Create a GCP account
2. Ensure billing is enabled
3. Create GCP Project
4. Create a GCS bucket

**Recommended bucket settings:**

* Class: Coldline](https://cloud.google.com/storage/docs/storage-classes#coldline) or [Archive Storage](https://cloud.google.com/storage/docs/storage-classes#archive)
* Region: Any (take into account data soverienty & [cost](https://cloud.google.com/storage/pricing))
* Access Control: Uniform
* Encryption: Google managed (take into account whether you are ok with this)
* Retention Policy: none


Make sure you understand the classes so that you make the right decision that suits your needs.

A single region bucket is fine - high availability is not the aim of this, and all regions have 99.999999999% annual durability (which *is* the aim of backups).


### Variables

**Config:**

These are found in the _variables.sh file in the includes folder.

`EXCLUDES`
- base excludes for use across all runs
- includes a series of sensible built-in exclusions
- extra excludes patterns can be sent in via runtime parameters - these are joined at runtime

**Runtime Parameters**

These can be sent into the script as runtime parameters

SOURCE_FILE
- Absolute path to the file to be loaded
- Multi-line file
- Structured as follows: `source | destination | [params] | [excludes]`

DESTINATION_BUCKET

DRY_RUN


### Software

* Ensure gcloud sdk is installed




----------------------------------------
## Running



----------------------------------------
## Automating




----------------------------------------
## TODO

- [ ] Externalize source dirs
  - [ ] Create a file which is just `source | destination | params`
  - [ ] Load in the shell script
  - [ ] Iterate the lines
  - [ ] Use awk '{print $1}' for source
  - [ ] Use awk '{print $3}' for destination
  - [ ] Use awk '{for(i=5;i<=NF;++i)print $i}' for params??? - will default to -c -C



----------------------------------------
## Legal

### Licence

MIT - see [LICENCE](/LICENCE)

### Attribution

* Original code by Rudiger Wolf ([rnwolf](https://gist.github.com/rnwolf))
* Humpback Whale by Philipp Lehmann from the Noun Project
