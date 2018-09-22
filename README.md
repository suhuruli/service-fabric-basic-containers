# service-fabric-basic-container

## Overview 

This demo will create a two nodetype Ubuntu cluster with five VM's each based on the latest Service Fabric Ubuntu runtime. Next, it will deploy a container based solution which contains a frontend Javascript application communicating with a backend Python application. Service endpoint resolution from the frontend to the backend is done using Service Fabric's DNS service. Platform capabilites and tooling will be then be illustrated by using the CLI to control placement of the services on the nodetypes, scaling instances of services in and out and performing a zero downtime rolling upgrade of the application. 

## Setting up the demo 
 
* Must have Azure account - will make things faster if you have the following handy: subscription id, 
* Install Azure CLI 
* Install the Service Fabric CLI (SFCTL) 

1. Download the source code. If you are running Windows on your machine, the following steps need to be executed with Ubuntu (16.04 or higher).
    ```bash
    git clone https://github.com/Azure-Samples/service-fabric-demos.git
    ```
2. Change directories into the `service-fabric-demos` folder
    ```bash
    cd service-fabric-demos/service-fabric-basic-container
    ```   
3. Open `parameters.json` and enter a password of your choosing. Make sure password  complies to Azure password constraints (> 6 characters, upper case, lower case and digits). Check azure credentials for latest password restrictions:
    ```json
    "adminPassword":{
    "value":"<password>"
   }
    ```
4. Exit `parameters.json` and run the `deploy.sh` script providing the necessary details in the prompt. 

    ```bash
    Subscription Id: `aaaaaaaa-1111-bbbb-cccc-22222222222
    Password (VM password): <password>
    ```
5. Upon completion of this step (approximately, 15 minutes), the script will create a two nodetype Ubuntu Service Fabric cluster in your subscription (in West US). The details of the cluster are as follows: 
    * Resource Group name - demolinuxsecure
    * Cluster name - demolinuxsecure
    * Key Vault name - demolinuxsecure
    * VM Username - DemoLinux
6. On Mac and Windows machines, import the [PFX](https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-connect-to-secure-cluster) file found inside your cloned repository into your Keychain or certificate store. On Linux based machines, you will need to import these certificates into Firefox or Chrome. If you are prompted for a password, leave it empty.

## Steps to run demo 

1. Access `https://demolinuxsecure.westus.cloudapp.azure.com:19080/Explorer/index.html#/` to view Service Fabric Explorer which is a dashboard for the state of the Service Fabric cluster and it's applications. If the **Nodes** dropdown is expanded, there will be five **Backend** and five **Frontend** nodes. 

2. Run the `containers.sh` script. The certificate (.PEM) file will be in the same directory as the one in which the `deploy.sh` script ran. 

    ```bash
    sh containers.sh <path_to_pem_file>
    ```
3. The script will deploy the container applications on to the cluster. The frontend application listens on port 8080. However, accessing `http://demolinuxsecure.westus.cloudapp.azure.com:8080` will not work. This is because the initial deployment placed the frontend service on the backend nodes (which do not have port 8080 opened) and the backend nodes on the front end nodes (which do have port 8080 opened). Pressing `Enter` will run two CLI commands which will fix the placement. Accessing `http://demolinuxsecure.westus.cloudapp.azure.com:8080` will confirm this. 

4. Currently, there are one instance of each frontend and backend service. Pressing `Enter` again will scale each up to five instances. This can be visualized  on Service Fabric Explorer by expanding the **Applications** tab. 

5. Press `Enter` once more to scale the frontend to three instances and backend to two instances. This can also be visualized on Service Fabric Explorer by expanding the **Applications** tab. 

6. Before you press `Enter` to trigger the zero downtime upgrade, click on the **Applications** tab on the left panel and then on the **Upgrades in Progress** tab. This tab will show status of the upgrade.

7. Go ahead and press `Enter` to start the rolling upgrade. This starts a rolling monitored upgrade. Service Fabric splits the cluster nodes into upgrade domains and upgrades service instances one upgrade domain at a time. Once all instances within an upgrade domain are upgraded and health checks are passing, the upgrade proceeds to the next domain, eventually upgrading all instances (assuming health checks are passing).

8. Press `Enter` one last time to clean up the resources in your cluster. 
