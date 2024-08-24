#!/usr/bin/python3

# pylint: disable=missing-function-docstring
# pylint: disable=missing-module-docstring
# pylint: disable=redefined-outer-name
# pylint: disable=consider-using-enumerate

import sys
import os
import re

THIS_DIR = os.path.abspath(os.path.dirname(__file__))
REPO_DIR = os.path.dirname(THIS_DIR)


def ReadInAvailableUserConfigurableFlags():
    available_user_configurable_flags = []

    defaults_zsh_file = os.path.join(REPO_DIR, "scripts", "defaults.zsh")
    with open(defaults_zsh_file, "r", encoding="utf-8") as file:
        for _, line in enumerate(file, 1):
            if re.search("[a-zA-Z]*=", line):
                line = line.strip()
                flag_name = line.split("=")[0]
                available_user_configurable_flags.append(flag_name)

    return available_user_configurable_flags


def ReadInSetUserConfigurableFlags(user_zshrc_file):
    set_user_configurable_flags = []

    with open(user_zshrc_file, "r", encoding="utf-8") as file:
        for _, line in enumerate(file, 1):
            if re.search("[a-zA-Z]*=", line) and not line.startswith("#"):
                line = line.strip()
                set_user_configurable_flags.append(line)

    return set_user_configurable_flags


def GenerateNewZshrcFile(already_set_user_customize_flags):

    zshrc_config_file = os.path.join(THIS_DIR, "zshrc.config")
    with open(zshrc_config_file, "r", encoding="utf-8") as file:
        zshrc_config_file = file.read()

    zshrc_config_file_list = zshrc_config_file.split("\n")

    insert_position = 0
    empty_line_counter = 0
    for line_num, line in enumerate(zshrc_config_file_list):
        if empty_line_counter == 2:
            insert_position = line_num
            break

        if line == "":
            empty_line_counter += 1

    for index in range(len(already_set_user_customize_flags)):
        zshrc_config_file_list.insert(
            index + insert_position, already_set_user_customize_flags[index]
        )

    return zshrc_config_file_list


if __name__ == "__main__":
    user_home_dir = os.path.expanduser("~")
    user_zshrc_file = os.path.join(user_home_dir, ".zshrc")

    # Verify user has old .zshrc
    with open(user_zshrc_file, "r", encoding="utf-8") as file:
        if "/volatile/msreleases/Ares" not in file.read():
            sys.exit(0)

    # Read in available override flags from defaults.zsh
    available_user_customize_flags = ReadInAvailableUserConfigurableFlags()

    # Read in old .zshrc to save any user override flags
    already_set_user_customize_flags = ReadInSetUserConfigurableFlags(user_zshrc_file)

    # Generate the new .zshrc file, retaining user flags that were already set
    new_zshrc_file = GenerateNewZshrcFile(already_set_user_customize_flags)

    # Write the new .zshrc file
    with open(user_zshrc_file, "w", encoding="utf-8") as file:
        for line in new_zshrc_file:
            file.write(line + "\n")
