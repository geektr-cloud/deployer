#!/usr/bin/env bash

dp::usage() {
  tee << END
Usage: $0 [command] project_name
$0 deploy service for geektheripper

Examples:
  $0 update foo/bar           # Update service to latest or pull the service
  $0 up foo/bar               # Start the service
  $0 init-secrets foo/bar     # initialize secrets directory (remove if existed)
  $0 init-data foo/bar        # initialize data directory (remove if existed)
  $0 backup-secrets foo/bar   # backup secrets directory
  $0 backup-data foo/bar      # backup data directory

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
