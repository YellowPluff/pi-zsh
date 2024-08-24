#!/bin/env python3

"""
uninstall_zsh.py:
Easy way to remove zsh files
"""

import os
import shutil

if __name__ == "__main__":
    print("Removing ZSH For User...")

    # Define the files this script will create
    userHomeDir = os.path.expanduser("~")
    userLoginName = os.getlogin()
    user_zshrc_file = os.path.join(userHomeDir, ".zshrc")
    user_zsh_files = os.path.join(userHomeDir, "zsh")
    user_zsh_login = os.path.join(userHomeDir, ".login")

    print(f"\nRemoving... {user_zshrc_file}")
    os.remove(user_zshrc_file)

    print(f"\nRemoving... {user_zsh_login}")
    os.remove(user_zsh_login)

    print(f"\nRemoving... {user_zsh_files}")
    shutil.rmtree(user_zsh_files)

    print("\nZSH removal complete!\n")
