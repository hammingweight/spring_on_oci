# OCI Platform Tools
The OCI console provides many tools for monitoring and managing infrastructure. This section discusses only three of them briefly.

## The Notification Service
Once an application is up and running, it's important to monitor that the application remains healthy. The [load balancer](../../1_provision/load_balancer.tf) regularly polls the
backend servers to check that they're healthy and you can view the health of the backends in the console. However, it would be better to have notifications pushed to you when
the application is unhealthy rather than have to poll the console or OCI API. To get notifications requires that you create three OCI objects:
 * A notification topic which is a descriptive name for related issues that you want to be notified about.
 * A subscription that is associated with the topic which could be, e.g., an email subscription or a PagerDuty notification.
 * An alarm which is triggered when some monitored object goes above a certain threshhold such as that the backend services are unhealthy or CPU utilization goes exceeds some limit.
 
 The easiest way to create alarms and notifications is via the console but they can also be created using Terraform or the CLI. The applicable CLI commands are:
  * `oci ons topic create`.
  * `oci ons subscription create`.
  * `oci monitoring alarm create`.
  
 The corresponding Terraform resources are:
  * `oci_ons_notificaton_topic`.
  * `oci_ons_notification_subscription`.
  * `oci_monitoring_alarm`.
    
  
## SQL Developer Web
The [configuration](../../2_configure) of our servers installed SQLcl and a database wallet on our servers. An alternative to use the SQLcl to administer the database is to use
`SQL Developer Web`. To access `SQL Developer Web` from the OCI console, select your database from the Autonomous Transaction Processing page and then select the `Tools` tab.


## OCI Cloud Shell
Creating a developern environment to access OCI can be time-consuming. Typically you need to install the oci CLI, generate an API signing key, installing Terraform and Ansible and probably install Git. If you use the browser-based terminal, `cloud shell`, all of those tools are installed for you. You don't even need to generate a signing key; instead the
CLI uses a *delegation token* for authentication (open the OCI configuration file, `/etc/oci/config`, to see how the shell is cconfigured.)
