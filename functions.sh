set -e

function check() {
    if [ -z "$2" ]; then
        echo
        echo "    💥 ** Can not get $1 **"
        exit 2
    else
        echo "    ➤ $1 => $2"
    fi
}
function check_arg() {
    if [ -z "$2" ]; then
        echo
        echo "    💥 ** You must specify $2 with $1 option **"
        exit 2
    else
        echo "    ➤ $1 => $2"
    fi
}

function ojbk() {
    if [ $1 -ne 0 ]; then
        echo "  💥 ** Error info: 👆 **"
        exit 3
    fi
}

function DONE() {
    echo
    echo "|------------------|"
    echo "|  🏆 ALL DONE 🏆  |"
    echo "|------------------|"
    echo "    /         \     "
    exit 0
}
