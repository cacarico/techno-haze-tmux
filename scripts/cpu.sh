#!/usr/bin/env bash


get-cpu() {
      percent=$(LC_NUMERIC=en_US.UTF-8 top -bn2 -d 0.01 | grep "Cpu(s)" | tail -1 | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

      echo -n "$percent"
}

main() {
    get-cpu
    sleep 5
}

main
