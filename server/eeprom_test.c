#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>


#define LINE_LENGTH 0x400

// from rp-api/api-hw-calib/src/calib_structs.h

/**
 * Calibration parameters, stored in the EEPROM device
 *  used in 125-14 4Ch models
 */

typedef struct {
    char dataStructureId;
    char wpCheck;
    char reserved[6];

    uint32_t chA_g_hi;          //!< High gain front end full scale voltage, channel A
    uint32_t chB_g_hi;          //!< High gain front end full scale voltage, channel B
    uint32_t chC_g_hi;          //!< High gain front end full scale voltage, channel C
    uint32_t chD_g_hi;          //!< High gain front end full scale voltage, channel D

    uint32_t chA_g_low;         //!< Low gain front end full scale voltage, channel A
    uint32_t chB_g_low;         //!< Low gain front end full scale voltage, channel B
    uint32_t chC_g_low;         //!< Low gain front end full scale voltage, channel C
    uint32_t chD_g_low;         //!< Low gain front end full scale voltage, channel D

    int32_t  chA_hi_offs;       //!< Front end DC offset, channel A
    int32_t  chB_hi_offs;       //!< Front end DC offset, channel B
    int32_t  chC_hi_offs;       //!< Front end DC offset, channel C
    int32_t  chD_hi_offs;       //!< Front end DC offset, channel D

    int32_t  chA_low_offs;      //!< Front end DC offset, channel A
    int32_t  chB_low_offs;      //!< Front end DC offset, channel B
    int32_t  chC_low_offs;      //!< Front end DC offset, channel C
    int32_t  chD_low_offs;      //!< Front end DC offset, channel D

    uint32_t chA_hi_aa;         //!< Filter equalization coefficients AA for High mode, channel A
    uint32_t chA_hi_bb;         //!< Filter equalization coefficients BB for High mode, channel A
    uint32_t chA_hi_pp;         //!< Filter equalization coefficients PP for High mode, channel A
    uint32_t chA_hi_kk;         //!< Filter equalization coefficients KK for High mode, channel A

    uint32_t chA_low_aa;        //!< Filter equalization coefficients AA for Low mode, channel A
    uint32_t chA_low_bb;        //!< Filter equalization coefficients BB for Low mode, channel A
    uint32_t chA_low_pp;        //!< Filter equalization coefficients PP for Low mode, channel A
    uint32_t chA_low_kk;        //!< Filter equalization coefficients KK for Low mode, channel A

    uint32_t chB_hi_aa;         //!< Filter equalization coefficients AA for High mode, channel B
    uint32_t chB_hi_bb;         //!< Filter equalization coefficients BB for High mode, channel B
    uint32_t chB_hi_pp;         //!< Filter equalization coefficients PP for High mode, channel B
    uint32_t chB_hi_kk;         //!< Filter equalization coefficients KK for High mode, channel B

    uint32_t chB_low_aa;        //!< Filter equalization coefficients AA for Low mode, channel B
    uint32_t chB_low_bb;        //!< Filter equalization coefficients BB for Low mode, channel B
    uint32_t chB_low_pp;        //!< Filter equalization coefficients PP for Low mode, channel B
    uint32_t chB_low_kk;        //!< Filter equalization coefficients KK for Low mode, channel B

    uint32_t chC_hi_aa;         //!< Filter equalization coefficients AA for High mode, channel C
    uint32_t chC_hi_bb;         //!< Filter equalization coefficients BB for High mode, channel C
    uint32_t chC_hi_pp;         //!< Filter equalization coefficients PP for High mode, channel C
    uint32_t chC_hi_kk;         //!< Filter equalization coefficients KK for High mode, channel C

    uint32_t chC_low_aa;        //!< Filter equalization coefficients AA for Low mode, channel C
    uint32_t chC_low_bb;        //!< Filter equalization coefficients BB for Low mode, channel C
    uint32_t chC_low_pp;        //!< Filter equalization coefficients PP for Low mode, channel C
    uint32_t chC_low_kk;        //!< Filter equalization coefficients KK for Low mode, channel C

    uint32_t chD_hi_aa;         //!< Filter equalization coefficients AA for High mode, channel D
    uint32_t chD_hi_bb;         //!< Filter equalization coefficients BB for High mode, channel D
    uint32_t chD_hi_pp;         //!< Filter equalization coefficients PP for High mode, channel D
    uint32_t chD_hi_kk;         //!< Filter equalization coefficients KK for High mode, channel D

    uint32_t chD_low_aa;        //!< Filter equalization coefficients AA for Low mode, channel D
    uint32_t chD_low_bb;        //!< Filter equalization coefficients BB for Low mode, channel D
    uint32_t chD_low_pp;        //!< Filter equalization coefficients PP for Low mode, channel D
    uint32_t chD_low_kk;        //!< Filter equalization coefficients KK for Low mode, channel D

} rp_calib_params_v2_t;

uint8_t* readParams(uint16_t *size, bool use_factory_zone);

void testcalb_4ch();

int main(){
	char *buf;
	char *name, *value;
    char *model = NULL;
    char *eth_mac = NULL;

       // snipet from  hp_cmn_Init() in RedPitaya/rp-api/api-hw-profiles/src/common.c

	FILE *fp = fopen("/sys/bus/i2c/devices/0-0050/eeprom", "r");
	if (!fp){
		fprintf(stderr,"Error open eeprom:\n");
		return 1;
	}

	if(fseek(fp, 0x1804	, SEEK_SET) < 0) {
        fclose(fp);
		fprintf(stderr,"Error seek eeprom\n");
        return 1;
    }

	buf = (char *)malloc(LINE_LENGTH);
	if (!buf) {
		fclose(fp);
		fprintf(stderr,"Error mem allocation\n");
		return 1;
	}


	int size = fread(buf, sizeof(char), LINE_LENGTH, fp);
	int position = 0;
	while(position <  size){
		int slen = strlen(&buf[position]);
		if (!slen) break;
		name = &buf[position];
		value = strchr(name, '=');
	 	if (!value){
			position += slen + 1;
	 		continue;
		}
		*value++ = '\0';
		if (!strlen(value))
			value = NULL;

		if (!strcmp(name,"hw_rev") && value != NULL){
                      if (strlen(value)+1 < 255){
                        model = (char*)malloc(strlen(value)+1);
                        if (model)
                                strcpy(model,value);
            }
        }

        if (!strcmp(name,"ethaddr") && value != NULL){
            if (strlen(value)+1 < 20){
                eth_mac = (char*)malloc(strlen(value)+1);
                if (eth_mac)
                    strcpy(eth_mac,value);
            }
        }
		position += slen + 1;

	}

	fclose(fp);
	free(buf);
	printf("%s, %s\n",model,eth_mac );
    if (model) free(model);
    if (eth_mac) free(eth_mac);
    testcalb_4ch();
    return 0;
}

// from RedPitaya/rp-api/api-hw-calib/src/calib_common.c

static const char eeprom_device[]="/sys/bus/i2c/devices/0-0050/eeprom";
static const int  eeprom_calib_off=0x0000;
static const int  eeprom_calib_factory_off = 0x1c00;

uint8_t* readParams(uint16_t *size, bool use_factory_zone)
{
    FILE   *fp;

    /* open EEPROM device */
    fp = fopen(eeprom_device, "r");
    if(fp == NULL) {
        fprintf(stderr,"Error opening eeprom file.");
        return NULL;
    }

    /* ...and seek to the appropriate storage offset */
    int offset = use_factory_zone ? eeprom_calib_factory_off : eeprom_calib_off;
    if(fseek(fp, offset, SEEK_SET) < 0) {
        fclose(fp);
        return NULL;
    }

    uint8_t* buf = (uint8_t *)malloc(*size);
	if (!buf) {
        fprintf(stderr,"Memory allocation error.");
		fclose(fp);
		return NULL;
	}

	*size = fread(buf, sizeof(char), *size, fp);
    fclose(fp);
    return buf;
}

void testcalb_4ch()
{
                uint16_t size = sizeof(rp_calib_params_v2_t);
                uint8_t* buffer =  readParams(&size,true);
                if (buffer && size == sizeof(rp_calib_params_v2_t)){
                    rp_calib_params_v2_t calib_v2;
                    memcpy(&calib_v2,buffer,size);
		    printf("ch_a low gain = %d,ch_a low off = %d,ch_d low gain = %d,ch_d low off = %d\n", calib_v2.chA_g_low,calib_v2.chA_low_offs,calib_v2.chD_g_low,calib_v2.chD_low_offs);
                }else{
                    fprintf(stderr,"Can't load calibration v2. Set by default.");
                    return;
                }
		free(buffer);
}