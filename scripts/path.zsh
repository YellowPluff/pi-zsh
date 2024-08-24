# Only perform this check the first time ZSH is launched as the parent process
# I.E. If you launch into ZSH from ZSH (child ZSH) then do NOT change the path
# I.E. If you reload ZSH using `source ~/.zshrc` then a second check will NOT be performed
if (( ! ${+PATH_SET} ));
then
    local temp_path=$PATH
    path=('/sw/apache-maven-3.5.0/bin/' '/sw/git-2.38.0/bin' '/sw/anaconda3-2022.05/bin' '/sw/gcc8.2.0/bin' '/usr/local/bin' '/sw/uge/bin/lx-x86' '/sw/hdf5-1.8.7/bin' '$HOME/scripts' '/usr/bin' '/bin' '/usr/sbin' "$SCRIPT_PATH/external_dependencies/bin")

    # Loop over the original PATH to add paths back to our defined PATH
    while read -d ':' path_element
    do
        # Check that the original PATH element isn't already in the list
        if [ ! "$(echo ${path[@]} | grep -ow \"$path_element\")" ];
        then
            # If this is a new PATH element that doesn't exist in our PATH, add it.
            path+=$path_element
        fi
    done <<< "$temp_path:"

    path+="." # Working directory last for security
    export PATH

    # Mark the path as set for this process and child processes
    export PATH_SET=1
fi