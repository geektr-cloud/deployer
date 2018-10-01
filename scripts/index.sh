#!/usr/bin/env bash

dp::usage() {
  tee << END
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
END
}

action=$1
project=$2

if [ -z "$action" ] || [ -z "$project" ]; then
  dp::usage
  exit 1
fi

dp::load_service_conf "$project"

case "$action" in
  update) dp::update ;;
  up) dp::up ;;
  init-secrets) dp::init-secrets ;;
  init-data) dp::init-data ;;
  backup-secrets) dp::backup-secrets ;;
  backup-data) dp::backup-data ;;
  *) dp::usage ;;
esac
