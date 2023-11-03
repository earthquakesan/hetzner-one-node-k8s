# hetzner-one-node-k8s
One node k8s clusters on Hetzner with k3s

## Why do you need 1 node k8s cluster?

* Costs: 5.77 Euros + 0.60 Euros for IPv4 + 0.50 Euros for DNS zone (Route53)
* Still getting all the goodies of k8s: self-healing, rolling upgrades, operators for the cloud resources etc.
* [There are people running k3s in space](https://www.suse.com/success/hypergiant/)

The downsides are:
* No automatic failover. If the node fails - that's it!

## Local Setup

This will create .env file in the root of the repository for service principal credentials. Use the file to setup CI/CD pipelines:

```
make bootstrap
export USE_DOT_ENV=true
# hcloud token to provision k3s instance in Hetzner Cloud
export TF_VAR_hcloud_token=token
# AWS access: e.g., iam user with AmazonRoute53FullAccess policy
# Can also trim the permissions down more - refer to the external DNS documentation
export AWS_ACCESS_KEY_ID=key
export AWS_SECRET_ACCESS_KEY=secret
make tf-init
make tf-plan
```

## Service Principal: Rotate Credentials

The following command will not recreate any of the storage account/containers, but will rotate the service principal secret (saved to .env file locally):

```
make bootstrap
```

## Clean Up Environment

Run the following command to remove resource group and service principal in Azure:

```
make clean
```

## Resources
* [miro board](https://miro.com/app/board/uXjVNUrcV7I=/?share_link_id=600413404192)
