#!/usr/bin/env bash

# this function makes path to be a empty directory (clean content or create directory)
dp::ensure_empty_dir() {
  target="$1"
  # lesson written in blood
  # if $service_dir unset, following rm command will remove '/*'
  if [ ! -n "$target" ]; then return 1; fi

  if [ -d "$target" ]; then
    rm -rf "$target"/* "$target"/.*
  elif [ -f "$target" ]; then
    mv "$target" "$target.bak"
    mkdir -p "$target"
  else
    mkdir -p "$target"
  fi
}

# this function sync conents in a directory to another
dp::sync() {
  source="$1"
  target="$2"

  dp::ensure_empty_dir "$target"
  cp -r "$source/." "$target"
}

dp::randname() {
  echo "deployer-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
}

dp::github_latest_version() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

dp::pull_github_archive() {
  project=$1
  project_name=$(echo "$project" | sed -E 's|.+/||')
  target=$2

  project_version=$(dp::github_latest_version "$project")

  tmp_dir="/tmp/$(dp::randname)"

  archive_file="$tmp_dir/$project_version.tar.gz"

  mkdir -p "$tmp_dir"
  wget -q -O "$archive_file" "https://github.com/$project/archive/$project_version.tar.gz"

  tar -xzf "$archive_file" -C "$tmp_dir"

  archive_path="$tmp_dir/$project_name-$(echo "$project_version" | sed -E 's/v//')"

  dp::clear_gitkeep "$archive_path"

  dp::sync "$archive_path" "$target"

  rm -r "$tmp_dir"
}

dp::pull_github_project() {
  project=$1
  target=$2
  
  dp::ensure_empty_dir "$target"

  git clone -b master --single-branch --depth=1 "https://github.com/$project.git" "$target"

  dp::clear_gitkeep "$target"
}

dp::clear_gitkeep() {
  target=$1
  find "$target" -name ".gitkeep" -exec rm -rf '{}' +
}

dp::is_config_loaded() {
  if [ "$current_project" ]; then return 0; fi
  return 1
}

dp::load_service_conf() {
  project=$1

  if [ "$current_project" = "$project" ]; then return 0; fi

  source <(wget -qO- "https://raw.githubusercontent.com/$project/master/.deployer/deployer.conf")
  # DEPLOYER_SERVICE_GROUP=<string>
  # DEPLOYER_SERVICE_NAME=<string>
  # DEPLOYER_TYPE=<github_repo|github_archive>
  # DEPLOYER_SECRET=<null|true>
  # DEPLOYER_DATA=<null|true>
  # DEPLOYER_BEFORE_UPDATE=<command>
  # DEPLOYER_AFTER_UPDATE=<command>
  # DEPLOYER_SERVICE_UP=<command>

  export service_group=${DEPLOYER_SERVICE_GROUP:-others}
  export service_name=$DEPLOYER_SERVICE_NAME

  deploy_dist="$DEPLOYER_SRV_DIR/$service_group"
  backups_dir="$deploy_dist/.backups"

  export service_dir="$deploy_dist/$service_name"

  export secrets_src="$deploy_dist/$service_name/secrets"
  export secrets_dir="$deploy_dist/$service_name.secrets"
  export secrets_bak="$backups_dir/$service_name.secrets"

  export data_src="$deploy_dist/$service_name/data"
  export data_dir="$deploy_dist/$service_name.data"
  export data_bak="$backups_dir/$service_name.data"

  export current_project=$project
}
