#!/bin/sh -e
#

cat /opt/recorder_4adc.bit > /dev/xdevcfg

/opt/trd_rp v > /dev/null &

exit 0