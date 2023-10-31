# hetzner-one-node-k8s
One node k8s clusters on Hetzner with k3s

## Local Setup

This will create .env file in the root of the repository for service principal credentials. Use the file to setup CI/CD pipelines:

```
make bootstrap
export USE_DOT_ENV=true
export TF_VAR_hcloud_token=token
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
