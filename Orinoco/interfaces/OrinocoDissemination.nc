/**
 * This interface resides between the Orinoco Dissemination 
 * layer and the actual dissemination storage instance.
 * The dissemination layer only attaches version numbers to 
 * outgoing data packets and receives updates piggy-backed on
 * incoming beacons and informs the data storage layer.
 */

interface OrinocoDissemination {
  /**
   * get current version from data owner
   */
  event uint8_t version();
  
  /**
   * get data (reference) from owner to send in 
   * outgoing beacon
   */
  event const uint8_t * data(uint8_t * size);
  
  /**
   * signal there is a new update
   * the user must copy the data out
   */
  event void update(uint8_t rversion, const uint8_t * rdata, uint8_t size);
}

