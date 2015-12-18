#ifndef SINK_ACK_H
#define SINK_ACK_H

//Acknowledgement for Sink
enum {
  AM_SINKACK         = 67,
};


typedef nx_struct SinkAck {
  nx_uint8_t   nodeId;     // ID of acknowledging node
  nx_uint8_t   seqNr;      // sequence number
} SinkAck;

#endif
