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
  * oci ons topic create.
  * oci ons subscription create.
  * oci monitoring alarm create.
  
  
## SQL Developer Web


## OCI Cloud Shell
