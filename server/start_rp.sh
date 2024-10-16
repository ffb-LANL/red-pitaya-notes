#!/bin/sh -e
#

cat /opt/recorder_4adc.bit > /dev/xdevcfg

/opt/trd_rp &

exit 0