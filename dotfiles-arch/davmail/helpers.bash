#######################################
# The davmail config will be occupied with sensitive information hence it is
# copied to the config directory instead of a symlink. The config contains
# documentation for setting up calendar synchronization
#######################################
copy_config() { 
    source=$1
    directory_config=$2
    destination="$directory_config/davmail.properties"

    rm "$destination" 2>/dev/null || mkdir "$directory_config"
    cp $source $destination
    lg "Davmail: copied $source to $destination"
}
