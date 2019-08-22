#!/bin/bash

echo "down branch: $1"

# 1 cd branch dir
# 2 docker-compose down
# 3 remove dir
# 4 remove service hook
#   4.1 list all hooks
#   4.2 search by .publisherInputs.branch
#   4.3 remove
# 5 remove nginx conf / restart