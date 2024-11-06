maglab_rp_server replaces trd_rp

maglab_rp_server depends on RedPitaya vendor libraries rp-hw-calib, rp-hw-profiles
Refer/edit Makefile regarding default lib and include dirs

Development notes

Calibration structures versions:
per getDefault() in 'RedPitaya/rp-api/api-hw-calib/src/calib_common.c'
STEM_125_14 : v1
STEM_250_12 : v2
STEM_125_14_Z7020_4IN : v3
STEM_122_16SDR_v1_0 / _1 : v4

Calibration version in EEPROM:
per calib_GetEEPROM() in 'RedPitaya/rp-api/api-hw-calib/src/calib.c'
dataStructureId = header[0] returned by readHeader()

Applying calibration
per cmn_CalibCntsSigned() and cmn_convertToVoltSigned() in RedPitaya/rp-api/api/src/common.c

int32_t calib_cnts = gain*(cnts - offset)base;
float ret_val = ((float)calib_cnts * fullScale / (float)(1 << (bits - 1)));

Initialization of Calib API:
rp_CalibInit();



