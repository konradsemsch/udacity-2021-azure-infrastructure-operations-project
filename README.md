# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

#### Packer

1. ``server.json`` contains your Packer VM image configuration

2.  There are a couple of items you might need to modify before running it:
    1. Make sure to export the environment variables listed under section ``variables``. For that you might want to create a ``.env`` file and then you can export then in your current terminal session with with the following command ``export $(cat .env | xargs)``
    
    > NOTE: remember not to add the `.env`` file under version control! That might reveal your secrets to 3rd parties.

    2. Depending on your needs you might want to change your VM image configuration under ``builders``. For starters, I would suggest to continue with the default version. You might just want to update the ``managed_image_resource_group_name`` and ``managed_image_name`` keys as you need.
    
    > NOTE: ``managed_image_resource_group_name`` value will need to match your resource group in your ``main.tf`` file and ``managed_image_name`` will need to match ``packer_image_name`` from ``vars.tf`` (see below)

3. Build and deploy your image with the following command: ``packer build server.json``.

#### Terraform

1. ``make.tf`` and ``vars.tf`` contains your Terraform infrastructure configuration

2. Possible adjustments to the ``make.tf`` file:
    1. ``"azurerm_resource_group`` - ``name`` must match the resource group name you gave in Packer's ``managed_image_resource_group_name``. The main part of the name is imported from the ``vars.tf`` file from ``prefix``.

3. Possible adjustments to the ``vars.tf`` file:
    1. ``prefix`` - defines the beginning of the name of all resources created for this deployment. Defaults to ``project-web-server``
    2. ``location`` - defines the deployment location. Defaults to ``West Europe``
    3. ``packer_image_name`` - defines the name of the image. Defaults to ``packer_image_name``
    4. ``n_update_domains`` - defines the number of update domains of the VM in the availability set. Depending on your needs, you might want to adjust this number during deployment to increase/ decrease availability. Defaults to ``5``
    5. ``admin_username`` - defines the name to use as the admin account on the VMs that will be part of the VM scale set. Defaults to ``konradino``
    6. ``admin_password`` - defines the password for you VMs admin account. There is no default and Terraform will ask you to provide it during the deployment
    7. ``tags`` - defines a set of tags attached to created resources. Defaults to ``project = "udacity-ws"``

4. Create and persist your Terraform plan using the following command: ``terraform plan -out solution.plan``

5. Deploy your created plan using: ``terraform apply "solution.plan"``.

### Output

Once your terminal is filled with green notifications saying: 

```diff
+ "Builds finished" 
```

and

```diff
+ "Apply complete! Resources ..." 
```

it means your resources are up and running! :)
