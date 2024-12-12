# MeetX build script for bash/zsh(?)

pm=""
pm_install_prefix=""
build_directory=""
platfrom=""

function setup_command() {
    if command -v $1 &> /dev/null; then
        printf "\033[32m%s\033[0m\n" "$2 is already installed"
        return 0
    else
        if [[ -z $pm || -z $pm_install_prefix ]]; then
            printf "\033[31m%s\033[0m\n" "Failed to setup $2: the package manager is not defined"
            exit -1
        else
            printf "%s\n" "Trying to install $2..."
            eval "$pm_install_prefix $2"
        fi
    fi
}

function meetx_install_init_submodules() {
    git submodule update --init --recursive
}

function meetx_install_build_debug() {
    eval cd "$build_directory/build/debug"
    printf "%s\n" "Select the compiler:"
    if [[ $(gum choose "Clang" "GCC") == "Clang" ]]; then
        setup_command "clang" "clang"
    else
        setup_command "g++" "gcc"
    fi

    printf "%s\n" "Select the generator:"
    if [[ $(gum choose "Ninja" "Makefile") == "Ninja" ]]; then
        setup_command "ninja" "ninja"
        cmake -GNinja ../..
        ninja
    else
        setup_command "make" "make"
        cmake ../..
        make
    fi
}

function meetx_install_build_release() {
    eval cd "$build_directory/build/release"
    printf "%s\n" "Select the generator:"
    if [[ $(gum choose "Ninja" "Makefile") == "Ninja" ]]; then
        setup_command "ninja" "ninja"
        cmake -GNinja -DCMAKE_BUILD_TYPE=Release ../..
        ninja
    else
        setup_command "make" "make"
        cmake -DCMAKE_BUILD_TYPE=Release ../..
        make
    fi
}

function meetx_install_build() {
    printf "%s\n" "Would you want to install MeetX with this script?"
    if [[ $(gum choose "Yes" "No") == "No" ]]; then
        exit 0
    fi

    if [[ -z $build_directory ]]; then
        printf "%s\n" "Specify the MeetX directory:"
        build_directory=$(gum input --placeholder "Path to the MeetX directory")
    fi
    eval cd $build_directory
    mkdir -p build/release
    mkdir build/debug
    meetx_install_init_submodules
    printf "%s\n" "Specify the build type:"
    if [[ $(gum choose "Debug" "Release") == "Release" ]]; then
        meetx_install_build_release
    else
        meetx_install_build_debug
    fi
}

function meetx_install_clone_repo() {
    printf "%s\n" "Select the branch: main -- Stable(Recommended) (more branches soon(maybe))"
    local meetx_repo_branch=$(gum choose "main")
    local meetx_repo_directory=$(gum input --placeholder "Specify the path(just type 'Enter' for defaults path(in this directory))")
    if [[ -z $meetx_repo_directory ]]; then
        meetx_repo_directory=$(pwd)
    elif [[ -d $meetx_repo_directory ]]; then
        mkdir -p $meetx_repo_directory
    fi
    printf "%s\n" "You specify this dir: $meetx_repo_directory and this branch: $meetx_repo_branch, right?"
    if [[ $(gum choose "Yes" "No") == "No" ]]; then
        meetx_install_clone_repo
    fi
    eval "git clone -b $meetx_repo_branch https://github.com/MeetXTelegram/MeetX.git $meetx_repo_directory"
    cd $meetx_repo_directory
    build_directory=$meetx_repo_directory
    meetx_install_build
}

function find_package_manager() {
    if command -v apt &> /dev/null; then
        pm="apt"
        pm_install_prefix="apt install"
        return 0
    elif command -v dnf &> /dev/null; then
        pm="dnf"
        pm_install_prefix="dnf -i"
        return 0
    elif command -v pacman &> /dev/null; then
        pm="pacman"
        pm_install_prefix="pacman -S"
        return 0
    elif command -v pkg &> /dev/null; then
        pm="pkg"
        pm_install_prefix="pkg install"
        return 0
    fi
}


function main() {
    printf "%s\n" "Select your platform:"
    platform=$(gum choose "Android" "Linux" "Windows" "MacOS")
    if [[ $platform != "Linux" ]]; then
        printf "\033[31m%s\033[0m\n" "BUILD ON LINUX ONLY(yet)"
        exit 0
    fi
    find_package_manager
    setup_command "gum" "gum"
    setup_command "git" "git"
    setup_command "cmake" "cmake"
    printf "%s\n" "Select action:"
    if [[ $(gum choose "Build" "Clone") == "Build" ]]; then
        meetx_install_build
    else
        meetx_install_clone_repo
    fi
}

main
