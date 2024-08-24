
# To understand async I read this article https://medium.com/@henrebotha/how-to-write-an-asynchronous-zsh-prompt-b53e81720d32
# I wrote this code largly based off of   https://github.com/vincentbernat/zshrc/blob/d66fd6b6ea5b3c899efb7f36141e3c8eb7ce348b/rc/vcs.zsh
# As well as reading the async code       https://github.com/mafredri/zsh-async/tree/main

############################################################################################################

function __generate_async_worker_and_callback
{
    # Generate a worker and name it "git_information_worker". It's like a variable.
    # Workers can have multiple jobs assinged to them.
    async_start_worker "git_information_worker" -n

    # Register this worker to the function "git_information_worker_completed" when the worker
    # completes.
    async_register_callback "git_information_worker" __git_information_worker_completed
}

function __run_gather_git_info
{
    # This ensures that we gather git information from the current directory.
    cd -q $1

    # Information we'll parse for.
    local submodule
    local detached_head
    local branch_name
    # This is bugged. Need a different way to detect rebase / merge.
    # local rebase_or_merge
    local untracked_files
    local unstaged_changes
    local staged_changes

    # Submodule
    if [[ -n $(command git rev-parse --show-superproject-working-tree 2> /dev/null) ]];
    then
        # This logic is intentioanlly kept simple for both speed, but also simplicity
        # of the code. In the future it could be expanded to give more information about
        # the submoduled repo and the parent repo, but I think this is good for now.
        # We'll just have to rely on our developers using brain-power to figure out
        # the rest.
        submodule="submodule"
    fi

    # Branch name
    if branch_name="$(command git symbolic-ref -q --short HEAD 2> /dev/null)";
    then
        branch_name=$branch_name
    else
        # Detached head, either print whatever name we can get or a commit hash
        detached_head="detached"
        branch_name="$(command git name-rev --name-only --no-undefined --always HEAD 2> /dev/null)"
    fi

    # Merging / Rebasing
    # This is bugged. Need a different way to detect rebase / merge.
    # GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
    # if [[ -n "$GIT_DIR" ]];
    # then
    #     if test -r "$GIT_DIR/MERGE_HEAD";
    #     then
    #         rebase_or_merge="[MERGE]"
    #     fi
    #     if test -r "$GIT_DIR/REBASE_HEAD";
    #     then
    #         rebase_or_merge="[REBASE]"
    #     fi
    # fi

    # Untracked files
    if [[ -n $(command git ls-files --other --directory --exclude-standard --no-empty-directory 2> /dev/null) ]];
    then
        untracked_files="-"
    fi

    # Modified (unstaged) files
    if ! command git diff --quiet 2> /dev/null;
    then
        unstaged_changes="*"
    fi

    # Modified (staged) files
    if ! command git diff --cached --quiet 2> /dev/null;
    then
        staged_changes="+"
    fi

    # Generate a git information message
    local GIT_INFO_MESSAGE

    # If the piece of information exists then append it to the git prompt
    [ $submodule ] && GIT_INFO_MESSAGE=$GIT_INFO_MESSAGE"%B%F{magenta}$submodule%f%b "
    [ $detached_head ] && GIT_INFO_MESSAGE=$GIT_INFO_MESSAGE"%B%F{red}$detached_head%f%b "
    [ $branch_name ] && GIT_INFO_MESSAGE=$GIT_INFO_MESSAGE"%B%F{$GIT_REPO_BRANCH_NAME_COLOR}$branch_name%f%b "
    [ $rebase_or_merge ] && GIT_INFO_MESSAGE=$GIT_INFO_MESSAGE"%B%F{magenta}$rebase_or_merge%f%b "
    [ $untracked_files ] && GIT_INFO_MESSAGE=$GIT_INFO_MESSAGE"%B%F{red}$untracked_files%f%b"
    [ $unstaged_changes ] && GIT_INFO_MESSAGE=$GIT_INFO_MESSAGE"%B%F{yellow}$unstaged_changes%f%b"
    [ $staged_changes ] && GIT_INFO_MESSAGE=$GIT_INFO_MESSAGE"%B%F{green}$staged_changes%f%b"

    # Do some final cleanup of the git information message
    GIT_INFO_MESSAGE=${GIT_INFO_MESSAGE//^0/}      # Strip out the ^0
    GIT_INFO_MESSAGE=${GIT_INFO_MESSAGE//" )"/")"} # Strip out the last empty space

    # Return the git information message
    print -r - "$GIT_INFO_MESSAGE"
}

function __git_information_worker_completed
{
    # If the async process buffer becomes corrupt, the callback will be invoked with the first argument being `[async]` (job
    # name), non-zero return code and fifth argument describing the error (stderr).
    #
    # callback_function is called with the following parameters:
    # 	$1 = job name, e.g. the function passed to async_job
    # 	$2 = return code
    # 	$3 = resulting stdout from execution
    # 	$4 = execution time, floating point e.g. 2.05 seconds
    # 	$5 = resulting stderr from execution
    #	$6 = has next result in buffer (0 = buffer empty, 1 = yes)

    local job_name=$1
    local return_code=$2
    local std_out=$3

    case $job_name in
        \[async])
            # Handle all the errors that could indicate a crashed
			# async worker. See zsh-async documentation for the
			# definition of the exit codes.
            if (( $return_code == 2 )) || (( $return_code == 3 )) || (( $return_code == 130 ));
            then
                # Our worker died unexpectedly, try to recover immediately.
                __generate_async_worker_and_callback
            fi
            ;;
        __run_gather_git_info)
            GIT_INFO_MESSAGE=$std_out
            zle && zle reset-prompt
            ;;
    esac
}

function __start_git_async_job
{
    # Verify that the user is inside a git repository
    if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]];
    then
        # Set GIT_INFO_MESSAGE to '...' to let the user know git information is loading
        GIT_INFO_MESSAGE="%B%F{$GIT_REPO_BRANCH_NAME_COLOR}...%f%b"

        # Start getting git information given current directory as input argument
        async_job git_information_worker __run_gather_git_info $PWD
    fi
}

function __stop_git_async_job
{
    # Stop any running async jobs.
    async_flush_jobs "git_information_worker"

    # Unset the variable GIT_INFO_MESSAGE which is where the
    # prompt message with git information is stored
    unset GIT_INFO_MESSAGE
}

###
# Code starts down here
###

# Turn on prompt substitution
setopt PROMPT_SUBST

# Load in the async package
source $SCRIPT_PATH/external_dependencies/zsh-async-1.8.6/async.zsh

# Initialize the async package
async_init

# Make an async worker and register the callback function
__generate_async_worker_and_callback

# Refresh git information every time the prompt is re-drawn
add-zsh-hook precmd __start_git_async_job

# Stop a running async git job if the directory changed.
add-zsh-hook chpwd __stop_git_async_job
