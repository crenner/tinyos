interface SlotValue<value_t> {
  
  /**
   * obtain representative value of slot
   * @param slot slot index (0 <= slot < getNumSlots())
   * @return representativ slot value
   */
  command value_t get(uint8_t slot);
}
