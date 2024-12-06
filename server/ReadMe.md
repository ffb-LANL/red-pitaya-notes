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

channel_calib_t to  uint_gain_calib_t conversion
per calib_GetFastADCCalibValue(rp_channel_calib_t channel,rp_acq_ac_dc_mode_calib_t mode, double *gain,int32_t *offset, uint_gain_calib_t *calib) in rp-api/api-hw-calib/src/calib.c 787:
and convertFloatToInt(channel_calib_t *param,uint8_t precision) in rp-api/api-hw-calib/src/calib_common.c 20

precision = 15
base = pow(2,precision) = 32768 (?)
gain = gainCalc*base
offset = offset

Applying calibration
per cmn_CalibCntsSigned(uint32_t cnts, uint8_t bits, uint32_t gain, uint32_t base, int32_t offset) and cmn_convertToVoltSigned() in RedPitaya/rp-api/api/src/common.c 272

int32_t calib_cnts = gain*(cnts - offset)/base;
float ret_val = ((float)calib_cnts * fullScale / (float)(1 << (bits - 1)));

actual volts 
per acq_GetDataVEx(rp_channel_t channel,  uint32_t pos, uint32_t* size, void* in_buffer,bool is_float) in /rp-api/api/src/acq_handler.c 1422

uint_gain_calib_t calib;

static rp_calib_params_t g_calib;  // initilized by init call

int rp_AcqGetData(uint32_t pos, buffers_t *out)
  acq_GetData(pos, out)
     acq_GetDataInBuffer(RP_CH_1,pos,&size,0,out)
        acq_GetGainV(channel, &gainValue) // 1.0 low, 20.0 high
        rp_HPGetHWADCFullScale(&fullScale) // 1.0
        uint_gain_calib_t calib;
        rp_CalibGetFastADCCalibValueI(convertCh(channel),convertPower(power_mode),&calib);
           calib_GetFastADCCalibValue(channel,mode,&gain,&calib->offset,calib)
            *gain = g_calib.fast_adc_1_1[channel].gainCalc; // 1.0
            *offset = g_calib.fast_adc_1_1[channel].offset;
            *calib = convertFloatToInt(&g_calib.fast_adc_1_1[channel],15);
                uint_gain_calib_t calib;
                calib.precision = precision;   // 15
                calib.base = pow(2,precision); // 32768 
                calib.gain = param->gainCalc * calib.base;  32768.0
                calib.offset = param->offset;   
            break; 
        iPtr[dataIndex] = cmn_CalibCntsSigned(cnts,bits,gain_raw,g_base_raw,offset_raw);
        value = cmn_convertToVoltSigned(cnts,bits,fullScale,calib.gain,calib.base,calib.offset) * gainValue + offset_value;
           int32_t calib_cnts = cmn_CalibCntsSigned(cnts, bits, gain, base, offset);
		calib_cnts = ((int32_t)gain * (cnts-offset) / (int32_t)base;
           float ret_val = ((float)calib_cnts * fullScale / (float)(1 << (bits - 1)));
	ret_val = ((float)calib_cnts * fullScale / (float)(1 << (bits - 1)));
rp_CalibGetFastADCCalibValueI(convertCh(channel),convertPower(power_mode),&calib);
value = cmn_convertToVoltSigned(cnts,bits,fullScale,calib.gain,calib.base,calib.offset) * gainValue + offset


Initialization of Calib API:
rp_CalibInit();



