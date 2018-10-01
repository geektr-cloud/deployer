# Deployer

Deployer is a simple deploy util for update and up docker-compose service.

## Install

```bash
sudo curl -L https://raw.githubusercontent.com/geektr-cloud/deployer/master/deployer -o /usr/local/bin/deployer
sudo chmod +x /usr/local/bin/deployer
```

## Usage

```bash
Usage: deployer [command] project_name
deployer deploy service for geektheripper

Examples:
  deployer update foo/bar           # Update service to latest or pull the service
  deployer up foo/bar               # Start the service
  deployer init-secrets foo/bar     # initialize secrets directory (remove if existed)
  deployer init-data foo/bar        # initialize data directory (remove if existed)
  deployer backup-secrets foo/bar   # backup secrets directory
  deployer backup-data foo/bar      # backup data directory

Don't forget configure secrets files before up your service
```

## More about this project

I use `/srv` directory to store everthing of services.

`/srv`'s sub directories are used as namespace, for example: `geektr.cloud`, `geektr.me`, `deaf-mutes.us`

Every docker service cost two or three directories.

In following project, `example` stores the project code, I use git to update this directory. `example.data` stores active data created by service or upload by manager or CI system. `example.secrets` stores the secrets data like password or private key.

```bash
/srv/geektr.cloud
│
├── example
│   ├── .deployer/deployer.conf
│   ├── conf
│   ├── data
│   ├── secrets
│   ├── deploy.sh
│   └── docker-compose.yml
├── example.data
│   ├── ...
│   └── ...
└── example.secrets
    └── ...
```

To make project 'deployeable', you should create `.deployer` directory which contains a `deployer.conf` file.

And then edit deployer and write config in `KEY=VALUE` format. (`deployer.conf` will run in bash envioment by `source` command)

|key|example|description|
|-|-|-|
|DEPLOYER_SERVICE_GROUP|geektr.cloud||
|DEPLOYER_SERVICE_NAME|example||
|DEPLOYER_TYPE|github_repo|github_repo or github_archive, this options tells deployer get code by git pull or download from git release|
|DEPLOYER_SECRET|true|not set or true, it tells project have a secret directory or not|
|DEPLOYER_DATA|true|same with previous item|
|DEPLOYER_BEFORE_UPDATE||run this command before update the project|
|DEPLOYER_AFTER_UPDATE||after update the project|
|DEPLOYER_SERVICE_UP|'docker-compose exec ftp ./init.sh'|after up the service|
