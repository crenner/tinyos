 
#ifndef TEST_H
#define TEST_H
 
 // TODO FIXME
//#define DIP_TAU_LOW (1024L)
//#define DIP_TAU_HIGH (65535L)


#define SINK_ID            0
#define UPDATE_INTVL    10*60*1024UL
//#define UPDATE_INTVL    10*1024UL

// FIXME
// - QUEUE_SIZE? (CTP)

// from Orinoco
#define MSG_BURST_LEN      1    // number of packets per period (#)
#define DATA_PERIOD    122880UL  // data creation period (ms)
//#define DATA_PERIOD    15*1024UL  // data creation period (ms)
//#define SRC_WAKEUP_INTVL     768    // wake-up period (ms)
// -> see Makefile for general lpl setup!
//#define SINK_WAKEUP_INTVL    256    // wake-up period (ms)
#define SINK_WAKEUP_INTVL    0    // wake-up period (ms)

#define AM_PERIODIC_PACKET  128  // packet type
#define AM_CMD_CONF         129  // packet type


typedef enum {
  BLOOM_BYTES = 8,             // bytes in the Bloom filter (x8 for bits)
} orinoco_routing_parameters_t;

typedef nx_struct {
  nx_uint8_t       cmd;                 // The command to execute at destinations
  nx_uint8_t       bloom[BLOOM_BYTES];  // Bloom filter of recipient IDs
} orinoco_routing_t;

typedef nx_struct OrinocoCommandAckMsg {
  nx_uint8_t             cmd;       // see orinoco_routing_t
  nx_uint16_t            version;   // see orinoco_routing_t
  nx_uint8_t             result;    // allow for return codes (SUCCESS=0 FAIL=1)
} OrinocoCommandAckMsg;



#endif
