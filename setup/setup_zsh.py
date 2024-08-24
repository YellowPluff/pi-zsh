#!/bin/env python3

"""
setup_zsh.py:
Sets up zsh for the user
"""

import os
from datetime import datetime
import re
import shutil

THIS_DIR = os.path.abspath(os.path.dirname(__file__))
REPO_DIR = os.path.dirname(THIS_DIR)
MAIN_ZSH_SCRIPT = os.path.join(REPO_DIR, "scripts", "main.zsh")


def check_for_existing_zshrc(user_home_dir_in, existing_zsh_files_in):
    """
    Function:
        Checks for (and backs up) existing zsh files

    Args:
        user_home_dir_in    (string): The user home directory on the system
        existing_zsh_files_in (list): A list of possibly existing zsh files

    Returns:
        None
    """
    # Backup existing files if they're found
    existing_files = [file for file in existing_zsh_files_in if os.path.exists(file)]
    if existing_files:
        current_time = datetime.now()
        backup_dir_path = os.path.join(
            user_home_dir_in, current_time.strftime("ZSHRC_BACKUP_%B%d-%Y_%H:%M:%S")
        )
        if not os.path.exists(backup_dir_path):
            os.mkdir(backup_dir_path)
        for file in existing_files:
            shutil.move(file, os.path.join(backup_dir_path, file.split("/")[-1]))
            print(
                f"\nBacking up {file} into {os.path.join(backup_dir_path, file.split('/')[-1])}\n"
            )


def copy_default_zshrc_files(user_home_dir_in):
    """
    Function:
        Copy the zsh template files into the user home directory

    Args:
        user_home_dir_in    (string): The user home directory on the system

    Returns:
        None
    """
    # Make the ~/zsh directory if it doesn't already exist
    user_zsh_dir = os.path.join(user_home_dir_in, "zsh")
    if not os.path.exists(user_zsh_dir):
        print(f"\nMaking directory {user_zsh_dir}\n")
        os.mkdir(user_zsh_dir)

    zshrc_copy_from = os.path.join(THIS_DIR, "zshrc.config")
    zshrc_copy_to = os.path.join(user_home_dir_in, ".zshrc")
    shutil.copy(zshrc_copy_from, zshrc_copy_to)
    os.chmod(zshrc_copy_to, 0o755)
    print(f"\nCopied {zshrc_copy_from} into {zshrc_copy_to}\n")

    aliases_copy_from = os.path.join(THIS_DIR, "aliases.config")
    aliases_copy_to = os.path.join(user_zsh_dir, "aliases.zsh")
    shutil.copy(aliases_copy_from, aliases_copy_to)
    os.chmod(aliases_copy_to, 0o755)
    print(f"\nCopied {aliases_copy_from} into {aliases_copy_to}\n")

    functions_copy_from = os.path.join(THIS_DIR, "functions.config")
    functions_copy_to = os.path.join(user_zsh_dir, "functions.zsh")
    shutil.copy(functions_copy_from, functions_copy_to)
    os.chmod(functions_copy_to, 0o755)
    print(f"\nCopied {functions_copy_from} into {functions_copy_to}\n")

    prompt_copy_from = os.path.join(THIS_DIR, "prompt.config")
    prompt_copy_to = os.path.join(user_zsh_dir, "prompt.zsh")
    shutil.copy(prompt_copy_from, prompt_copy_to)
    os.chmod(prompt_copy_to, 0o755)
    print(f"\nCopied {prompt_copy_from} into {prompt_copy_to}\n")

    os.chmod(user_zsh_dir, 0o755)


def parse_user_existing_csh_alias(user_home_dir_in, user_login_name_in, found_files):
    """
    Function:
        Parses through users existing csh files looking for aliases to
        transfer for zsh

    Args:
        user_home_dir_in   (string): The user home directory on the system
        user_login_name_in (string): The login name of the user
        found_files          (list): The csh files found for this user

    Returns:
        found_aliases   (list): A list of csh aliases converted to zsh
        found_functions (list): A list of csh functions converted to zsh
    """
    found_aliases = []
    found_functions = []

    for csh_file in found_files:
        if os.path.exists(csh_file):
            with open(csh_file, "r", encoding="utf-8") as file:
                for line_num, line in enumerate(file, 1):
                    if line.strip().startswith("alias"):
                        try:
                            # Strip the alias down to a list of raw words. No spaces or tabs
                            alias_line_list = line.replace("\t", "    ").strip().split(" ")
                            alias_line_list = [part for part in alias_line_list if part]
                            alias_line_list.insert(2, "=")

                            # Perform common formatting between aliases and functions
                            for index, _ in enumerate(alias_line_list):
                                alias_line_list[index] = alias_line_list[index].replace(
                                    "$user", user_login_name_in
                                )
                                alias_line_list[index] = alias_line_list[index].replace(
                                    "$USER", user_login_name_in
                                )
                                alias_line_list[index] = alias_line_list[index].replace(
                                    "$home", user_home_dir_in
                                )
                                alias_line_list[index] = alias_line_list[index].replace(
                                    "$HOME", user_home_dir_in
                                )
                                alias_line_list[index] = alias_line_list[index].replace(
                                    "setenv", "export"
                                )
                                # This isn't perfect because it'll catch words like 'settings' but
                                # it'll  basically be null impact to people on this floor. It also
                                # must come after 'setenv' search so you don't catch the 'set' in
                                # 'setenv' first
                                alias_line_list[index] = alias_line_list[index].replace(
                                    "set", "export"
                                )

                            # Check to see if it should be a function
                            is_function = False
                            # Diabling pylint check because it thinks the strings
                            #   should have a r prefix.
                            # pylint: disable=anomalous-backslash-in-string
                            is_exclamation_star = "\!*" in " ".join(alias_line_list)
                            is_exclamation_one = "\!:1" in " ".join(alias_line_list)
                            # pylint: disable=anomalous-backslash-in-string
                            if is_exclamation_star or is_exclamation_one:
                                is_function = True

                            if is_function:
                                # pylint: disable=line-too-long
                                cshrc_file = os.path.join(user_home_dir_in, ".cshrc")
                                if (
                                    "`" in " ".join(alias_line_list) or
                                    f"source {cshrc_file}" in " ".join(alias_line_list) # fmt: skip
                                ):
                                    # If the user alias has backticks (`) in it, chances are they're using advanced function-like logic.
                                    # This script cannot handle those well and they upset ZSH, leading to finding an error that is a needle
                                    # in the haystack so to speak. So we just won't move that alias and we'll print a warning to the user
                                    # to move that alias manually.
                                    # Additionally, any alias that sources the users .cshrc file will not be moved. This was common in the
                                    # CSH days but is unneccessary in ZSH.
                                    raise Exception()  # pylint: disable=broad-exception-raised
                                # pylint: enable=line-too-long

                                # Construct function from list of raw words
                                # Next line removes the 'alias' keyword
                                function_line_list = alias_line_list[1:]  # fmt: skip
                                del function_line_list[1]  # Remove the = sign
                                function_name = function_line_list[0]  # Extract function name
                                function_code = " ".join(
                                    function_line_list[1:]
                                )  # Extract function code

                                # Format the function code
                                # Remove the quote at the beginning of the function
                                # (if it already exists)
                                if function_code.startswith("'") or function_code.startswith('"'):
                                    function_code = function_code[1:]

                                # Remove the quote at the end of the function
                                # (if it already exists)
                                if function_code.endswith("'") or function_code.endswith('"'):
                                    function_code = function_code[:-1]

                                # fmt: off
                                # pylint: disable=anomalous-backslash-in-string
                                function_code = function_code.replace("\n", "\\n")
                                function_code = function_code.replace(";", "\n   ")
                                function_code = function_code.replace("\!:1", "$1")
                                function_code = function_code.replace("\!*", "$@")
                                # pylint: enable=anomalous-backslash-in-string
                                # fmt: on

                                new_function = (
                                    f"function {function_name}\n{{\n    {function_code}\n}}\n"
                                )
                                found_functions.append(new_function)
                            else:
                                # Construct alias from list of raw words
                                # Insert a quote at the beginning of the alias
                                # (if it doesn't already exist)
                                if not (
                                    alias_line_list[3].startswith("'")
                                    or alias_line_list[3].startswith('"')
                                ):
                                    alias_line_list[3] = "'" + alias_line_list[3]

                                # Insert a quote at the end of the alias
                                # (if it doesn't already exist)
                                if not (
                                    alias_line_list[-1].endswith("'")
                                    or alias_line_list[-1].endswith('"')
                                ):
                                    alias_line_list[-1] = alias_line_list[-1] + "'"

                                new_alias_line = " ".join(alias_line_list)
                                new_alias_line = new_alias_line.replace(" = ", "=")
                                found_aliases.append(new_alias_line)
                        # fmt: off
                        except Exception as err:  # pylint: disable=broad-except,unused-variable
                            # Diabled pylint broad-except and unused-variable because any number
                            #   of things could go wrong here and we don't care about the
                            #   exception.
                            # fmt: on
                            print(
                                "\n\033[91m## ERROR: Couldn't parse user alias:\033[0m\n"
                                "\033[93mIf you wish to keep it, you will need to convert this alias to ZSH yourself.\033[0m\n"  # pylint: disable=line-too-long
                                f"File:        {csh_file}\n"
                                f"Line Number: {line_num}\n"
                                f"Alias:       {line}\n"
                            )

    for csh_file in found_files:
        csh_file_new = f"{csh_file}_{datetime.now().strftime('%B%d-%Y_%H:%M:%S')}"

        print(f"Renaming {csh_file} to {csh_file_new}")
        shutil.move(csh_file, csh_file_new)

    return "\n".join(found_aliases), "\n".join(found_functions)


def generate_user_aliases(
    user_home_dir_in,
    user_login_name_in,
    user_zshrc_file_in,
    user_zsh_alias_file_in,
    user_zsh_functions_file_in,
):
    """
    Function:
        Put the transformed csh aliases into the zsh files

    Args:
        user_home_dir_in           (string): The user home directory on the system
        user_login_name_in         (string): The login name of the user
        user_zshrc_file_in         (string): File path to the user .zshrc file
        user_zsh_alias_file_in     (string): File path to the user zsh alias file
        user_zsh_functions_file_in (string): File path to the user zsh functions file

    Returns:
        None
    """
    files_to_search = [
        os.path.join(user_home_dir_in, ".cshrc"),
        os.path.join(user_home_dir_in, ".alias"),
        os.path.join(user_home_dir_in, ".cshrc.alias"),
    ]

    found_files = [file for file in files_to_search if os.path.exists(file)]
    print("\nGenerating aliases from:\n{}\n".format("\n".join(found_files)))

    aliases_from_csh, functions_from_csh = parse_user_existing_csh_alias(
        user_home_dir_in, user_login_name_in, found_files
    )

    # Write ZSH converted aliases
    alias_file = None
    with open(user_zsh_alias_file_in, "r", encoding="utf-8") as file:
        alias_file = file.read()

    alias_file = re.sub(r"_ALIASES_FROM_CSH_\b", aliases_from_csh, alias_file)

    with open(user_zsh_alias_file_in, "w", encoding="utf-8") as file:
        file.write(alias_file)

    # Write ZSH converted functions
    functions_file = None
    with open(user_zsh_functions_file_in, "r", encoding="utf-8") as file:
        functions_file = file.read()

    functions_file = re.sub(r"_FUNCTIONS_FROM_CSH_\b", functions_from_csh, functions_file)

    with open(user_zsh_functions_file_in, "w", encoding="utf-8") as file:
        file.write(functions_file)

    # Write source location for main.zsh
    zshrc_file = None
    with open(user_zshrc_file_in, "r", encoding="utf-8") as file:
        zshrc_file = file.read()

    zshrc_file = re.sub(r"_MAIN_SOURCE_LOCATION_\b", MAIN_ZSH_SCRIPT, zshrc_file)

    with open(user_zshrc_file_in, "w", encoding="utf-8") as file:
        file.write(zshrc_file)


def generate_new_cshrc(user_home_dir_in):
    """
    Function:
        Makes a new cshrc file for umask and cluster reasons

    Args:
        user_home_dir_in (string): The user home directory on the system

    Returns:
        None
    """
    print("\nGenerating new ~/.cshrc file for umask and cluster interaction")

    user_cshrc_file = os.path.join(user_home_dir_in, ".cshrc")
    with open(user_cshrc_file, "w", encoding="utf-8") as file:
        file.write("umask 002" + "\n")
        file.write("source /sw/uge/default/common/settings.csh")


def set_zsh_default_shell(user_home_dir_in):
    """
    Function:
        Generates a .login file to make zsh the "default" shell

    Args:
        user_home_dir_in (string): The user home directory on the system

    Returns:
        None
    """
    print("\nSetting ZSH as the default shell using the ~/.login file.")

    login_need_update = True

    user_login_file = os.path.join(user_home_dir_in, ".login")
    if os.path.exists(user_login_file):
        with open(user_login_file, "r", encoding="utf-8") as file:
            for _, line in enumerate(file, 1):
                if line.strip().startswith("/usr/bin/zsh -l"):
                    login_need_update = False

    if login_need_update:
        with open(user_login_file, "a", encoding="utf-8") as login_file:
            login_file.write("\n" + 'echo "Starting ZSH Shell (from ~/.login)"')
            login_file.write("\n" + "/usr/bin/zsh -l")


if __name__ == "__main__":
    print("Running ZSH Setup...")

    # Define the files this script will create
    user_home_dir = os.path.expanduser("~")
    user_login_name = os.getlogin()
    user_zshrc_file = os.path.join(user_home_dir, ".zshrc")
    user_zsh_alias_file = os.path.join(user_home_dir, "zsh", "aliases.zsh")
    user_zsh_functions_file = os.path.join(user_home_dir, "zsh", "functions.zsh")
    user_zsh_prompt_file = os.path.join(user_home_dir, "zsh", "prompt.zsh")

    existingZSHFiles = [
        user_zshrc_file,
        user_zsh_alias_file,
        user_zsh_functions_file,
        user_zsh_prompt_file,
    ]

    # Check for and backup existing ZSHRC files
    check_for_existing_zshrc(user_home_dir, existingZSHFiles)

    # Copy over default ZSHRC files
    copy_default_zshrc_files(user_home_dir)

    # Generate user aliases from existing CSH files
    generate_user_aliases(
        user_home_dir,
        user_login_name,
        user_zshrc_file,
        user_zsh_alias_file,
        user_zsh_functions_file,
    )

    # Generate user .cshrc file
    generate_new_cshrc(user_home_dir)

    # Set ZSH as the default shell
    set_zsh_default_shell(user_home_dir)

    print("\nZSH setup complete!\n")

    # Launch the user into zsh
    os.system("/usr/bin/zsh -l")
