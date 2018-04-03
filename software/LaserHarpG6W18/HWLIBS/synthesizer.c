#include "synthesizer.h"
#include "options.h"

#include  <app_cfg.h>
#include  <lib_mem.h>

#include  <bsp.h>
#include  <bsp_int.h>
#include  <bsp_os.h>
#include  <cpu_cache.h>

#include  <cpu.h>
#include  <cpu_core.h>

#include  <os.h>
#include  <hps.h>
#include  <socal.h>
#include  <hwlib.h>
#include  <math.h>


void writeFreqToSynthesizer(void *diode, float frequnecy) {
	alt_write_word(diode, frequnecy);
}

INT32S readFromSythesizer(void *diode, int enabled) {
	if(enabled) {
		return (alt_read_word(diode));
	}
	return 0;
}

float readFromEnvelope(void *envelopeLocation, int diode, int reset, int instrument) {
	int envelopeOptions = EnvelopeOptions(diode, reset, instrument);
	alt_write_word(envelopeLocation, envelopeOptions);
	INT32S transport_bits = alt_read_word(envelopeLocation);
	float envelope = *((float*)&transport_bits);
	return envelope;
}

int EnvelopeOptions(int diode, int reset, int instrument) {
	int combined = 0;
	combined = (combined | instrument) << 1;
	combined = (combined | reset) << 3;
	combined = (combined | diode);
	return combined;
}
