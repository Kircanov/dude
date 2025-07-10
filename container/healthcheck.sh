#!/bin/bash

# Exit immediately if a pipeline, which may consist of a single simple command,
# a list, or a compound command returns a non-zero status
#set -e

#nc -z localhost 2210
#nc -z localhost 2211






# Бројач на отворени порти
OPEN_PORTS=0

# Провери дали The Dude слуша на 2210
if nc -z localhost 2210; then
  OPEN_PORTS=$((OPEN_PORTS+1))
fi

# Провери дали The Dude слуша на 2211
if nc -z localhost 2211; then
  OPEN_PORTS=$((OPEN_PORTS+1))
fi

# Ако барем еден порт е отворен, сервисот е здрав
if [ "$OPEN_PORTS" -ge 1 ]; then
  exit 0
else
  exit 1
fi