# Get-VMs-Without-Tags


## Introduction to vSphere Tags

Using vSphere tags in your VMware environment is no longer a secret. It gives you flexibility, easier management and control of your virtual machines.

If you want to see how to use vSphere Tags with Veeam check out my article here: [Using VM Tags with vSphere and Veeam Backup & Replication](https://www.virtualhome.blog/2019/01/03/using-vm-tags-within-vsphere-and-veeam-backup-replication/)

When it comes to backup virtual machines via vSphere Tags you will most likely force the strategy to give every single virtual machine a tag.

There is the famous "no backup" tag for virtual machines which are excluded from backup. Furthermore, all the other vSphere tags are necessary to declare your SLA policies.

To ensure that your tagging strategy is resilient, you will need to tag every single virtual machine in your environment. But what if your environment is in undergoing change and virtual machines are deployed and deleted heavily. You will moste likely have any kind of monitoring in place such as VeeamONE to monitor if all your virtual machines have a vSphere tag in place.

Today I want to show you a way on how to achieve this kind of monitoring with a simple PowerCLI script.

## What does this script do with your vSphere Tags?

The script does the following:

-   It connects to your vCenter Server
-   It checks all virtual machines if they have a vSphere Tag out a category you decide
-   When it finds virtual machines with no tags out of the desired category it writes an output
-   The outputs gets send via E-Mail to an email address you provide
-   It checks the output path for old files and deletes them if they are older than X days

My recommendation is to setup a scheduled task which runs once or twice a day to check your environment.

**The script:**

Here is the script: [Get VMs without Tags](https://github.com/falkobanaszak/Get-VMs-Without-Tags/blob/master/Get_VMs_without_Tags.ps1)
## How to set it up for your environment

Basically, you simply need to add all the relevant information in the variables which I framed in red in the below screenshot.

![How to setup the script](https://github.com/falkobanaszak/Get-VMs-Without-Tags/blob/master/environment_setup.png)

-   the path where you want to save the outputs
-   the e-mail settings
-   your vSphere credentials and connection
-   your desired tag category

As always, thanks for reading and have a nice day !

If you encounter errors or if you want to share feedback, don't hesitate to contact me !
