# Google Cloud SQL Instance

We use TF here to simulate drift in the Google Cloud resource, demonstrating logic error on PATCH
when drift occurs and we skip [automatic state
refresh](https://developer.hashicorp.com/terraform/cloud-docs/run/modes-and-options#skipping-automatic-state-refresh).
This drift can occur for a variety of reasons, including automated tooling from the cloud provider
and operations users in the console.

## Reproducing the issue

This repository contains a script to reproduce the logic error, which is that the instance's
`settings.version` field is only _conditionally_ retrieved prior to PATCH, by simulating drift in
the settings version field.

Directory structure:
* `create`: the initial configuration of the Cloud SQL instance
* `drift`: a plan applied without saving state to simulate drift
* `update`: an update to the initial state, which fails due to drift
* `repro.sh`: a script to create the instance, apply the drift via an import & apply without using
  the initial tfstate, and apply an update using the initial tfstate.

We expect the `repro.sh` script to result in an error:

```
google_sql_database_instance.instance: Modifying... [id=bug-412-2023-09-07]
╷
│ Error: Error, failed to update instance settings for : googleapi: Error 412: Condition does not match., staleData
│
│   with google_sql_database_instance.instance,
│   on main.tf line 10, in resource "google_sql_database_instance" "instance":
│   10: resource "google_sql_database_instance" "instance" {
│
╵
```
