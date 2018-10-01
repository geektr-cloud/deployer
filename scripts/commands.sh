#!/usr/bin/env bash

dp::backup-data() {
  mkdir -p "$backups_dir"
  backup_file="$data_bak-$(date '+%y%m%d%H%M%S').zip"
  zip -rq "$backup_file" "$data_dir"
}

# initialize data directory
dp::init-data() {
  # if data dir already exist, backup it and then remove
  if [ -d "$data_dir" ]; then
    docker run --rm -it -v "$data_dir:/data" alpine:3.8 chown -R "$UID:$GID" /data
    dp::backup-data
    echo "$data_dir will be removed, you can find the backup in $backups_dir"
  fi

  dp::sync "$data_src" "$data_dir"
}

dp::backup-secrets() {
  mkdir -p "$backups_dir"
  backup_dir="$secrets_bak-$(date '+%y%m%d%H%M%S')"
  dp::sync "$secrets_dir" "$backup_dir"
}

# initialize secret directory
dp::init-secrets() {
  # if secrets dir already exist, backup it and then remove
  if [ -d "$secrets_dir" ]; then
    dp::backup-secrets
    echo "$secrets_dir will be removed, you can find the backup in $backups_dir"
  fi

  dp::sync "$secrets_src" "$secrets_dir"
  hash tree && {
    echo
    echo "Configure these files before you up the service:"
    echo "================================================"
    tree "$secrets_dir"
    echo "================================================"
  }
}

dp::update() {
  if [ "$DEPLOYER_BEFORE_UPDATE" ]; then $DEPLOYER_BEFORE_UPDATE; fi

  # update to latest code
  case "$DEPLOYER_TYPE" in
    github_repo)    dp::pull_github_project "$current_project" "$service_dir" ;;
    github_archive) dp::pull_github_archive "$current_project" "$service_dir" ;;
    *) echo "DEPLOYER_TYPE error: $DEPLOYER_TYPE"; exit 1 ;;
  esac

  if [ "$DEPLOYER_AFTER_UPDATE" ]; then $DEPLOYER_AFTER_UPDATE; fi

  if [ "$DEPLOYER_DATA" = "true" ] && [ ! -d "$data_dir" ]; then
    dp::init-data
  fi

  if [ "$DEPLOYER_SECRET" = "true" ] && [ ! -d "$secrets_dir" ]; then
    dp::init-secrets
  fi
}

dp::up() {
  pushd "$service_dir"

  if [ -f "./.env.template" ]; then
    envsubst < "./.env.template" > ".env"
  fi

  if [ -f "./docker-compose.yml" ] || [ -f "./docker-compose.yaml" ]; then
    docker-compose up -d
  fi

  if [ "$DEPLOYER_SERVICE_UP" ]; then
    $DEPLOYER_SERVICE_UP
  fi

  popd
}
