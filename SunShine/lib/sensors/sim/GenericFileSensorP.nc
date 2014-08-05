//Sensormoduleinterface that reads from a formated File

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <FixPointMath.h>
#include <stdint.h>

#define GFS_FILENAME_MAX_LEN   100
#define GFS_MAX_LINE_LEN       100

#define GFS_DESCRIPTION_TAG    "description:"
#define GFS_FIRSTDAYOFFSET_TAG "firstDayOffset:"
#define GFS_SAMPLERATE_TAG     "sampleRate:"

#define GFS_SECS_PER_DAY       (24*60*60)


module GenericFileSensorP {
  provides {
    interface Read<fp_t>;
    //interface Get<fp_t>;
    interface Init as Init;
  }
  uses {
    interface LocalTime<TMilli> as Clock;	
  }
}
implementation {
  FILE    * file_;
  char      buf_[GFS_MAX_LINE_LEN];
  
  char      traceDescr_[GFS_MAX_LINE_LEN];
  uint32_t  firstDayOffset_;
  uint16_t  sampleRate_;
  
  // interpolation values (left sample value, right sample value, time of right sample value)
  // the time delta between values is always sampleRate_
  double    sampleValueL_ = 0, sampleValueR_ = 0;
  uint32_t  sampleTimeR_  = 0;
  
  
  
  /*** Internal helpers *************************************************/
  fp_t readValue()
  {
    double    res = 0;
    uint32_t  curTime = call Clock.get() / 1024; // binary ms -> sec

    // if there is no known value, assume zero (TODO or FP_NAN?)
    if (curTime < firstDayOffset_) {
      return 0;
    } else if (feof(file_)) {
      return 0;
    }
    
    // ok, we're in the known region, so interpolate
    
    // we're outside the last window => move it
    while (curTime > sampleTimeR_) {
      fgets(buf_, GFS_MAX_LINE_LEN, file_);
      if (feof(file_)) {
        return 0;
      }
      
      sampleTimeR_  += sampleRate_;
      sampleValueL_  = sampleValueR_;
      sampleValueR_  = atof(buf_);
    }
    
    // we're inside the window => interpolate
//     res  = sampleValueL_ * (sampleTimeR_ - curTime) +
//            sampleValueR_ * (curTime + sampleRate_ - sampleTimeR_);
//     res /= sampleRate_;
    // for the moment, use mean from current window (i.e., the right value)
    res = sampleValueL_;
    
    //dbg("GenericFileSensor", "@%u: %u %g %g -> %g\n", curTime, sampleTimeR_, sampleValueL_, sampleValueR_, res);

    // TODO ??? fp_value = (fp_t)round(ret * (1 << FP_FRACT_SIZE));
    return FP_UNFLOAT(res);
  }
  
  
  
  /*** Init *************************************************************/

  /**
   * load solar trace for node with id TOS_NODE_ID
   *
   * expected format:
   * 1: description:string
   * 2: firstDayOffset:int
   * 3: sampleRate:int       (in seconds)
   * 4: double               (solar current in mA)
   * 5: double ...
   */
  command error_t Init.init()
  {
    char filename[GFS_FILENAME_MAX_LEN];
    
    // create file name
    // TODO check return value
    snprintf(filename, GFS_FILENAME_MAX_LEN, "./simdata/%u/solartrace.dat", TOS_NODE_ID);
    
    // open trace file
    file_ = fopen(filename, "rt");
    if (file_ == NULL) {
      perror("Could not open solar trace");
      abort();
    }
    dbg("GenericFileSensor", "Opened solar trace for node %u: '%s'\n", TOS_NODE_ID, filename);
    
    // read description
    fgets(buf_, GFS_MAX_LINE_LEN, file_);
    if (strncmp(buf_, GFS_DESCRIPTION_TAG, strlen(GFS_DESCRIPTION_TAG))) {
      perror("Solar trace does not contain description field");
      abort();
    }
    strcpy(traceDescr_, buf_ + strlen(GFS_DESCRIPTION_TAG));
    if (strlen(traceDescr_) > 0) {  // chop newline
      traceDescr_[strlen(traceDescr_) - 1] = '\0';
    }
    dbg("GenericFileSensor", "description: %s\n", traceDescr_);
    
    // read first-day offset
    fgets(buf_, GFS_MAX_LINE_LEN, file_);
    if (strncmp(buf_, GFS_FIRSTDAYOFFSET_TAG, strlen(GFS_FIRSTDAYOFFSET_TAG))) {
      perror("Solar trace does not contain first day offset field");
      abort();
    }
    firstDayOffset_ = GFS_SECS_PER_DAY * atoi(buf_ + strlen(GFS_FIRSTDAYOFFSET_TAG));
    dbg("GenericFileSensor", "first day offset: %u\n", firstDayOffset_);
    
    // read sample rate
    fgets(buf_, GFS_MAX_LINE_LEN, file_);
    if (strncmp(buf_, GFS_SAMPLERATE_TAG, strlen(GFS_SAMPLERATE_TAG))) {
      perror("Solar trace does not contain sample rate field");
      abort();
    }
    sampleRate_ = atoi(buf_ + strlen(GFS_SAMPLERATE_TAG));
    dbg("GenericFileSensor", "sample rate: %u\n", sampleRate_);    
    
    // read first value
    fgets(buf_, GFS_MAX_LINE_LEN, file_);
    sampleValueL_ = 0;
    sampleValueR_ = atof(buf_);
    sampleTimeR_  = firstDayOffset_;
    dbg("GenericFileSensor", "initial value: (%u,%g,%g)\n", sampleTimeR_, sampleValueL_, sampleValueR_);
    
    return SUCCESS;
  }



  /*** Read *************************************************************/
  
  void task readValueTask() {
    signal Read.readDone(SUCCESS, readValue());
  }
  
  
  command error_t Read.read() {
    post readValueTask();
    return SUCCESS;
  }
  
}


/* eof */