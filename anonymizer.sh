#!/bin/bash

unset -v FOLDER
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo
   echo "Anonymizer your IP jumper."
   echo
   echo "Syntax: ./anonymizer.sh -d {FOLDER}"
   echo
   echo "options:"
   echo "d     Folder containing the .ovpn file to use as rotation."
   echo "h     Print this Help."
   echo
}

function ctrl_c() {
        time=$(date)
        echo "$time - Will terminate VPN session"
        killall openvpn
        exit 1
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

DELAY_SEC=240

trap ctrl_c INT

while getopts ":hd:t" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      d) # use directory
         FOLDER=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option (use -h to see the help)"
         exit;;
   esac
done

shift "$(( OPTIND - 1 ))"

if [ -z "$FOLDER" ]; then
        echo 'Error: Missing -d {FOLDER} parameter' >&2
        Help
        exit 1
fi

while true 
    do
        VPN_FILE=$(ls $FOLDER |sort -R |tail -1)
        time=$(date)
        echo "$time - Will connect to $VPN_FILE"
        openvpn --daemon anonymizer --config "$FOLDER/$VPN_FILE"
        status=$?
        time=$(date)
        echo "$time - Connected to $VPN_FILE / Status: $status"
        if [ $status != 0 ]
        then
            time=$(date)
            echo "$time - Error while connecting to the vpn"
            killall openvpn
            exit -1
        fi
        time=$(date)
        echo "$time - Press Ctrl+C to quit or wait $DELAY_SEC seconds for new connection"
        sleep $DELAY_SEC
        time=$(date)
        echo "$time - Will terminate the connection to start the new one"
        killall openvpn
        sleep 10
done