# BYOR-VotingApp [infrastructure]

Welcome to the repository for the infrastructure setup of **BYOR-VotingApp**!

You can find more information about the BYOR-VotingApp in the web-app Github [repository](https://github.com/thoughtworks/byor-voting-web-app).


#### Table Of Contents

[Running BYOR-VotingApp locally](#running-byor-votingapp-locally)

[Deploy BYOR-VotingApp to AWS Lambda](#deploy-byor-votingapp-to-aws-lambda)
-   [Prerequisites](#prerequisites-1)
-   [Setting up AWS](#setting-up-aws-1)
-   [Deploying the application](#deploying-the-application-1)
-   [Updating the application](#updating-the-application-1)

[Deploy BYOR-VotingApp to Kubernetes](#deploy-byor-votingapp-to-kubernetes)
-   [Provisioning AWS EKS Kubernetes cluster](#provisioning-aws-eks-kubernetes-cluster)
    -   [Setting up AWS](#setting-up-aws-2)
    -   [Provisioning with Terraform](#provisioning-with-terraform)
-   [Setting up an already provisioned cluster](#setting-up-an-already-provisioned-cluster)
-   [Deploying the application](#deploying-the-application-2)
-   [Updating the application](#updating-the-application-2)
-   [HOWTOs](#howtos)
    -   [Access Kubernetes Dashboard](#access-kubernetes-dashboard)
    -   [Validating certificate issuer](#validating-certificate-issuer)
    -   [Generating certificates with Let's encrypt](#generating-certificates-with-lets-encrypt)
    -   [How to manage secrets](#how-to-manage-secrets)

[How to contribute to the project](#how-to-contribute-to-the-project)
## Running BYOR-VotingApp locally

1) install [Docker](https://www.docker.com/get-started)
1) open the terminal
1) clone the project
    ```shell
    git clone https://github.com/thoughtworks/byor-voting-web-app.git
    ```
1) move into the project folder
    ```shell
    cd byor-voting-web-app
    ```
1) :warning: **[*TODO*]** startup web app, server, and a local MongoDB
    ```shell
    docker-compose up 
    ```
1) access the application on [http://localhost:4200](http://localhost:4200)

> Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for more options on running the web app locally.

> Please refer to [BYOR-VotingApp \[server\]](https://github.com/thoughtworks/byor-voting-server) Github repository for more options on running the server locally and connect to a MongoDB database.

## Deploy BYOR-VotingApp to AWS Lambda

### Prerequisites

-    install [GNU Bash](https://www.gnu.org/software/bash/)
-    install [GNU Make](https://www.gnu.org/software/make/)
-    install [npm](https://www.npmjs.com/get-npm)
-    install [AWS Command Line interface](https://aws.amazon.com/cli/)
-    clone **VotingApp [web-app]**
```shell
git clone https://github.com/thoughtworks/byor-voting-web-app.git
```
-    clone **VotingApp [server]**
```shell
git clone https://github.com/thoughtworks/byor-voting-server.git
```

### Setting up AWS

-   create a S3 bucket for deploying the web-app
>   if you want you can use [aws/create_s3_bucket.sh](aws/create_s3_bucket.sh) script to perform the operation

-   configure the S3 bucket to act as [static contents' web server](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)

### Deploying the application

1)    open terminal and login into AWS
1)    1)    move into the **VotingApp [server]** project folder
1)    get last updates
        ```shell
        git pull
        ```
1)    install the required packages
        ```shell
        make install
        ```
1)    deploy on AWS infrastructure via Serverless framework:
        ```shell
        make deploy
        ```
        > By default, the target stage is `dev`, but, at the user prompt you can specify any other stages as target for the deployment.
        >
        > At the user prompt, you'll also have to enter your AWSkeys.
        >
        > For any stage, the following variables are expected toexist as parameters in AWS Systems Manager Parameter Store:
        > -   **&lt;stage&gt;ByorMongoUri (_secure_)**: the fullURI to let the application connecting to MongoDB
        > -   **&lt;stage&gt;ByorMongoUriAdmin (_secure_)**: thefull URI to perform admin operations on MongoDB (createdelete collections and indexes)
        > -   **&lt;stage&gt;ByorMongoDbName**: the mongo databasename
        >
        > After a successful deploy, pending database migrations(if any) are automatically run against the target stage'sdatabase.
1)    take note of the backend url generated during deploy
1)    move into the **VotingApp [web-app]** project folder
1)    get last updates
        ```shell
        git pull
        ```
1)    install the required packages
        ```shell
        make install
        ```
1)    build the application for production
        ```shell
        make build
        ```
        > The script will ask for the backend url, paste the value captured at step 6.
>Please refer to [BYOR-VotingApp \[web-app\]](https://github.com/thoughtworks/byor-voting-web-app/CONTRIBUTING.md) for more options about how to build for production

1)    clear the existing content of the S3 bucket with:
        ```shell
        aws s3 rm s3://<your-bucket-name-here>/ --recursive
        ```
1)    deploy the new files with:
        ```shell
        aws s3 cp dist/byor-voting-web-app s3://<your-bucket-name-here>/ --recursive
        ```

### Updating the application
To update the **web-app** or the **server**, just repeat the steps above.


## Deploy BYOR-VotingApp to Kubernetes

### Provisioning AWS EKS Kubernetes cluster

-    install [AWS Command Line interface](https://aws.amazon.com/cli/)
-    install [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
-    install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
-    install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

#### Setting up AWS

1)    login into AWS console:
        -    create [programmatic access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) for provisioning resources using Terraform and attach the right EC2 policies.
        -   configure AWS [cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) to interact with AWS
        -    [create EC2 keypair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
        -    [create AMI](https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/tkv-create-ami-from-instance.html)
        -    create S3 bucket to store Terraform state file
        >   if you want you can use [aws/create_s3_bucket.sh](aws/create_s3_bucket.sh) script to perform the operation
        -    set [permission on S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-configure-bucket.html) to ensure to be accessible only by your organization
1)    inside [terraform.tf](terraform.tf)
        -    replace ``<terraform-state-storage>`` with the S3 bucket you create above
        -    replace ``<region>`` with the AWS region of your choice
1)    inside [variable.tf](variable.tf)
        -    replace ``<AMI-ID>`` with the AMI ID
        -    replace ``<keypair name>`` with the Keypair name
        -    customize other settings for eks (e.g. node_instance_type) based on your needs.
1)    inside [terraform.tfvars](terraform.tfvars) replace ``<aws_access_key>``, ``<aws_secret_key>``,``<aws_zones>`` with your AWS settings

#### Provisioning with Terraform

1)    open terminal and login into AWS
1)    move into the **VotingApp [infrastructure]** project folder
1)    duplicate terraform template files to replace sample variables:
        ```shell
        cp terraform.tf.sample terraform.tf
        cp terraform.tfvars.sample terraform.tfvars
        cp variables.rf.sample variables.rf
        ```
1)    if this is the first time you run terraform, execute:
        ```shell
        terraform init
        ```
1)    review the plan outputs:
        ```shell
        terraform plan
        ```
1)    if everything looks good, run:
        ```shell
        terraform apply
        ```
1)    if everything looks good, run:
        ```shell
        terraform apply
        ```
1)    to install Isto, Cert-Manager, Kiali secrets, and Let's encrypt secrets:
        ```shell
        source k8s/k8s_setup.sh
        ```
1)    if you want to delete all the resources managed by terraform, run:
        ```shell
        terraform destroy
        ```

## Setting up an already provisioned Kubernetes cluster

1)    set the ``KUBECONFIG`` context
        ```shell
        export KUBECONFIG=<path-to-kubeconfig>
        echo "export KUBECONFIG=${KUBECONFIG}" >> ${HOME}/.bashrc
        ```
1)    if you don't have already installed Isto, Cert-Manager, Kiali secrets, and Let's encrypt secrets, you can do it running:
        ```shell
        k8s/k8s_setup.sh
        ```


## Deploying the application

1)    install [helm](https://helm.sh/docs/using_helm/)
1)    add the repositories for **web-app**, **server**, and **infrastructure**
        ```shell
        helm repo add byor-voting-web-app https://raw.githubusercontent.com/thoughtworks/byor-voting-web-app/master/charts
        helm repo add byor-voting-server https://raw.githubusercontent.com/thoughtworks/byor-voting-server/master/charts
        helm repo add byor-voting-infrastructure https://raw.githubusercontent.com/thoughtworks/byor-voting-infrastructure/master/charts
        ```
1)    deploy BYOR-VotingApp:
        ```shell
        helm install byor-voting-chart
        ```

### Updating the application
To update the **VotingApp**, just repeat the step 3 above.


### HOWTOs

#### Access Kubernetes Dashboard:

Admin Username : k8s-admin
1)    get token
        ```shell
        kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep k8s-admin | awk '{print $1}')
        ```
1)    run the proxy
        ```shell
        kubectl proxy`` command in provision machine.
        ```
1)    access the dashboard at [http://localhost:8001/api/v1/namespaces/kube-system/services/](http://localhost:8001/api/v1/namespaces/kube-system/services/)


#### Validating certificate issuer.
```shell
kubectl describe clusterissuer <cluster issuer name>
kubectl -n istio-system describe certificate <certificate name>
```

### Access Kiali dashboard
```shell
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001 &
```

### Access Jaeger dashboard
:warning: **[*TODO*]**  
```shell
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686  &
```

### Access Grafana dashboard
:warning: **[*TODO*]**  
```shell
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &
```

### Generating certificates with Let's encrypt
:warning: **[*TODO*]**

### How to manage secrets
:warning: **[*TODO*]**  

## How to contribute to the project

Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for all the information about how to contribute.