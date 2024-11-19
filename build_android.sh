function build() {
        if [ -f "../CMakeLists.txt" ]; then
                printf "\033[31m%s\033[0m\n" "Failed to build MeetX: the CMakeLists.txt file does not exists"4
                exit -1
        fi

        if [ -d "../build" ]; then
                mkdir "../build"
        fi

	cd ../build

        if [[ "$1" == "YES" ]]; then
                sudo cmake -GNinja ..
        else
                cmake -GNinja ..
        fi

        ninja
        printf "\033[32m%s\033[0m\n" "Congratulations! Now you need to go in ../build and start the meetx"
        exit 0
}

function installDependencies() {
        if [[ "$1" == "YES" ]]; then
                sudo apt update && sudo apt upgrade
                sudo apt install libspdlog postgresql boost-static boost-headers ninja cmake clang
        else
                apt update && apt upgrade
                apt install libspdlog postgresql boost-static boost-headers ninja cmake clang
        fi
}

function checkEnivronment() {
        if [[ "$1" == "-root" ]]; then
                printf "\033[34m%s\033[0m\n" "Run without 'sudo' prefix"
                installDependencies
        else
                printf "\033[34m%s\033[0m\n" "Run with 'sudo' prefix"
                installDependencies "YES"
        fi
}

checkEnivronment "$1"
build "$1"
