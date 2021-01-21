#!/bin/bash
set -e

# Default Variables
BASE_GPIO_PATH=/sys/class/gpio  # Common path for all GPIO access
UP=24           # BCM 24 is Up
DOWN=23         # BCM 23 is Down
ON="1"          # 1 to turn on
OFF="0"         # 0 to turn off
CYCLES=1            # How many cycles to run in a batch
BATCHES=1           # How many batches to run, with pauses in between
RUN_TIME=10         # Time to simulate pressing the UP/DOWN buttons
BREAK_TIME=5        # Time between cycles


args=(-c --cycles -b --batches -r --runtime -B --breaktime -h -help --help)

usage() {
    echo ""
    echo "Usage:    mtest [OPTIONS]"
    echo ""
    echo "A tool to stress test an actuator."
    echo ""
    echo "OPTIONS:"
    echo "-c    --cycles INT        The number of Up/Down cycles to run. (Default is: 1)"
    echo "-b    --batches INT       The number of batches of cycles to run. (Default is: 1)"
    echo "-r    --runtime INT       How long to simulate an Up/Down press in seconds. (Default is: 10 seconds)"
    echo "-B    --breaktime INT     How long to wait between batches of cycles in seconds. (Default is: 5 seconds)"
    echo "-u    --up INT            The BCM Pin to use for the 'Up' relay. (Default is: BCM 23)"
    echo "-d    --down INT          The BCM Pin to use for the 'Down' relay. (Default is: BCM 24)"
    echo "-h    --help              Displays this help information."
    echo ""
    exit 1
}

err_msg1() {
    echo ""
    echo "\"$1\" is an invalid argument."
    echo "Run test.sh -h for help."
    echo ""
    exit 1
}

err_msg2() {
    echo ""
    echo "\"$2\" is an invalid argument for \"$1\"."
    echo "Run test.sh -h for help."
    echo ""
    exit 1
}

err_chk() {
    if [[ ${args[*]} =~ $2 ]] || [[ -z "$2" ]]; then
        err_msg2 "$1" "$2"
    fi
}

if [ $# -eq 0 ]; then
    echo ""
    echo "Running with defaults..."
fi

while [[ $# -gt 0 ]]; do
    case "$1" in

    -c | --cycles)
        err_chk "$1" "$2"
        CYCLES=$2
        shift # past argument
        shift # past value
        ;;
    -b | --batches)
        err_chk "$1" "$2"
        BATCHES=$2
        shift # past argument
        shift # past value
        ;;
    -r | --runtime)
        err_chk "$1" "$2"
        RUN_TIME=$2
        shift # past argument
        shift # past value
        ;;
    -B | --breaktime)
        err_chk "$1" "$2"
        BREAK_TIME=$2
        shift # past argument
        shift # past value
        ;;
    -u | --up)
        err_chk "$1" "$2"
        UP=$2
        shift # past argument
        shift # past value
        ;;
    -d | --down)
        err_chk "$1" "$2"
        DOWN=$2
        shift # past argument
        shift # past value
        ;;
    -h | -help | --help)
        usage
        shift # past argument
        ;;
    *) # any option
        err_msg1 "$1"
        shift # past argument
        ;;
    esac
done

# Utility function to export a pin if not already exported
exportPin(){
  if [ ! -e $BASE_GPIO_PATH/gpio$1 ]; then
    echo "$1" > $BASE_GPIO_PATH/export
  fi
}

# Utility function to set a pin as an output
setOutput(){
  echo "out" > $BASE_GPIO_PATH/gpio$1/direction
}

# Utility function to change state of a light
setPinState(){
  echo $2 > $BASE_GPIO_PATH/gpio$1/value
}

# Export pins so that we can use them
exportPin $UP
exportPin $DOWN

# Set pins as outputs
setOutput $UP
setOutput $DOWN

cycle(){
    for (( i=1; i<=CYCLES; i++ )); do  
        echo "     Cycle: $i Starting..."
        # Move actuator Up
        setPinState $UP $ON
        sleep $RUN_TIME
        setPinState $UP $OFF

        # Move actuator down
        setPinState $DOWN $ON
        sleep $RUN_TIME
        setPinState $DOWN $OFF
        echo "     Cycle: $i Complete!"
    done
}

run(){
    if (( BATCHES <= 1 )); then
        echo "Running $CYCLES cycles."
        cycle
        echo "Complete!"
    else
        echo "Running $CYCLES cycles $BATCHES times with a $BREAK_TIME second break in between batches."
        for (( j=1; j<=BATCHES; j++ )); do 
            echo "Batch: $j Starting..."
            cycle
            echo "Batch: $j Complete!"
            echo "Waiting $BREAK_TIME seconds..."
            sleep $BREAK_TIME
        done
    fi

}

run