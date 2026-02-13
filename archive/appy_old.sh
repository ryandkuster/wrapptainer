#!/usr/bin/env bash

#=============================================================================
# Parse arguments
#=============================================================================
run_type="exec"
ignore_command=false
VERBOSE=1

while getopts "r:iq" opt; do
    case $opt in
        r) run_type="$OPTARG" ;;
        i) ignore_command=true ;;
        q) VERBOSE=0 ;;
        \?) exit 1 ;;
    esac
done

#=============================================================================
# Validate inputs
#=============================================================================
if [[ ! "$run_type" =~ ^(exec|run|shell)$ ]]; then
    echo "Error: -r must be 'exec', 'run', or 'shell'" >&2
    exit 1
fi

shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
    echo "Error: At least one argument required" >&2
    echo "Usage: $0 [args...] <tool> [tool args...]" >&2
    exit 1
fi

#=============================================================================
# Define tool and args
#=============================================================================
# First positional arg is tool, rest are the commands
tool="$1"
shift
args="$@"
args_search=("$@")


parse_tool_config() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    source "$SCRIPT_DIR/conf/images.conf"
    source "$SCRIPT_DIR/conf/special.conf"
    
    if [ -n "${!tool}" ]; then
            tool_img="${!tool}"
        else
            echo "No variable found for '$tool' found in images.conf. You sure about that?" >&2
            tool_img=""
            exit 1
    fi
    
    if [ -n "${!tool}" ]; then
            var_name="${tool}_sp"
            tool_special="${!var_name}"
        else
            tool_special=""
    fi
}

find_bind_dirs() {
    declare -A bind_dirs_map
    bind_dirs=""
    
    bind_dirs_map[$PWD]=1
    bind_dirs="-B $PWD"
    
    for arg in "${args_search[@]}"; do
        if [ -d "$arg" ]; then
            dir=$(realpath "$arg")
        elif [ -f "$arg" ]; then
            real_path=$(realpath "$arg")
            dir=$(dirname "$real_path")
        fi
            
        if [ -n "$dir" ] && [ -z "${bind_dirs_map[$dir]}" ]; then
            bind_dirs_map[$dir]=1
            bind_dirs="$bind_dirs -B $dir"
        fi
    done
    
    bind_dirs="${bind_dirs# }"
}

run_verbose() {
    if [ $VERBOSE -eq 1 ]; then
        echo "================================================================================" >&2
        echo "${tool^^}" >&2
        echo "================================================================================" >&2
        echo "Apptainer : $(which apptainer)" >&2
        echo "            $(apptainer --version)" >&2
        echo "            $run_type" >&2
        echo "Image     : $tool_img" >&2
        echo "Cache     : $APPTAINER_CACHEDIR" >&2
        echo "Run       : $args" >&2
        echo "Bind dirs : $bind_dirs" >&2
        echo "================================================================================" >&2
    fi
}
    
run_apptainer() {
    if [ $ignore_command == false ]; then
        if [ $run_type == "exec" ]; then
            apptainer exec $tool_special $bind_dirs $tool_img $tool $args
        elif [ $run_type == "run" ]; then
            apptainer run $tool_special $bind_dirs $tool_img $tool $args
        elif [ $run_type == "shell" ]; then
            apptainer shell $tool_special $bind_dirs $tool_img
        fi
    elif [ $ignore_command == true ]; then
        if [ $run_type == "exec" ]; then
            apptainer exec $tool_special $bind_dirs $tool_img $args
        elif [ $run_type == "run" ]; then
            apptainer run $tool_special $bind_dirs $tool_img $args
        elif [ $run_type == "shell" ]; then
            apptainer shell $tool_special $bind_dirs $tool_img
        fi
    fi
}

parse_tool_config
find_bind_dirs
run_verbose
run_apptainer

