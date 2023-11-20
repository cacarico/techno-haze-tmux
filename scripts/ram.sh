#!/usr/bin/env bash

get-ram() {
    usage="$(free -h | awk 'NR==2 {print $3}')"
    total="$(free -h | awk 'NR==2 {print $2}')"
    formated="${usage}/${total}"

    echo "${formated//i/B}"
}

main() {
    get-ram
    sleep 5
}

main
