/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'DdcForecastMsg'
 * message type.
 */

public class DdcForecastMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 22;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 200;

    /** Create a new DdcForecastMsg of size 22. */
    public DdcForecastMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new DdcForecastMsg of the given data_length. */
    public DdcForecastMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new DdcForecastMsg with the given data_length
     * and base offset.
     */
    public DdcForecastMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new DdcForecastMsg using the given byte array
     * as backing store.
     */
    public DdcForecastMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new DdcForecastMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public DdcForecastMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new DdcForecastMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public DdcForecastMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new DdcForecastMsg embedded in the given message
     * at the given base offset.
     */
    public DdcForecastMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new DdcForecastMsg embedded in the given message
     * at the given base offset and length.
     */
    public DdcForecastMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <DdcForecastMsg> \n";
      try {
        s += "  [header.numDays=0x"+Long.toHexString(get_header_numDays())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [header.resolution=0x"+Long.toHexString(get_header_resolution())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [header.sunrise=0x"+Long.toHexString(get_header_sunrise())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [header.sunset=0x"+Long.toHexString(get_header_sunset())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [data=";
        for (int i = 0; i < 20; i++) {
          s += "0x"+Long.toHexString(getElement_data(i) & 0xff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: header.numDays
    //   Field type: byte, unsigned
    //   Offset (bits): 0
    //   Size (bits): 3
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'header.numDays' is signed (false).
     */
    public static boolean isSigned_header_numDays() {
        return false;
    }

    /**
     * Return whether the field 'header.numDays' is an array (false).
     */
    public static boolean isArray_header_numDays() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'header.numDays'
     */
    public static int offset_header_numDays() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'header.numDays'
     */
    public static int offsetBits_header_numDays() {
        return 0;
    }

    /**
     * Return the value (as a byte) of the field 'header.numDays'
     */
    public byte get_header_numDays() {
        return (byte)getUIntBEElement(offsetBits_header_numDays(), 3);
    }

    /**
     * Set the value of the field 'header.numDays'
     */
    public void set_header_numDays(byte value) {
        setUIntBEElement(offsetBits_header_numDays(), 3, value);
    }

    /**
     * Return the size, in bytes, of the field 'header.numDays'
     * WARNING: This field is not an even-sized number of bytes (3 bits).
     */
    public static int size_header_numDays() {
        return (3 / 8) + 1;
    }

    /**
     * Return the size, in bits, of the field 'header.numDays'
     */
    public static int sizeBits_header_numDays() {
        return 3;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: header.resolution
    //   Field type: byte, unsigned
    //   Offset (bits): 3
    //   Size (bits): 2
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'header.resolution' is signed (false).
     */
    public static boolean isSigned_header_resolution() {
        return false;
    }

    /**
     * Return whether the field 'header.resolution' is an array (false).
     */
    public static boolean isArray_header_resolution() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'header.resolution'
     * WARNING: This field is not byte-aligned (bit offset 3).
     */
    public static int offset_header_resolution() {
        return (3 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'header.resolution'
     */
    public static int offsetBits_header_resolution() {
        return 3;
    }

    /**
     * Return the value (as a byte) of the field 'header.resolution'
     */
    public byte get_header_resolution() {
        return (byte)getUIntBEElement(offsetBits_header_resolution(), 2);
    }

    /**
     * Set the value of the field 'header.resolution'
     */
    public void set_header_resolution(byte value) {
        setUIntBEElement(offsetBits_header_resolution(), 2, value);
    }

    /**
     * Return the size, in bytes, of the field 'header.resolution'
     * WARNING: This field is not an even-sized number of bytes (2 bits).
     */
    public static int size_header_resolution() {
        return (2 / 8) + 1;
    }

    /**
     * Return the size, in bits, of the field 'header.resolution'
     */
    public static int sizeBits_header_resolution() {
        return 2;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: header.sunrise
    //   Field type: byte, unsigned
    //   Offset (bits): 5
    //   Size (bits): 5
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'header.sunrise' is signed (false).
     */
    public static boolean isSigned_header_sunrise() {
        return false;
    }

    /**
     * Return whether the field 'header.sunrise' is an array (false).
     */
    public static boolean isArray_header_sunrise() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'header.sunrise'
     * WARNING: This field is not byte-aligned (bit offset 5).
     */
    public static int offset_header_sunrise() {
        return (5 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'header.sunrise'
     */
    public static int offsetBits_header_sunrise() {
        return 5;
    }

    /**
     * Return the value (as a byte) of the field 'header.sunrise'
     */
    public byte get_header_sunrise() {
        return (byte)getUIntBEElement(offsetBits_header_sunrise(), 5);
    }

    /**
     * Set the value of the field 'header.sunrise'
     */
    public void set_header_sunrise(byte value) {
        setUIntBEElement(offsetBits_header_sunrise(), 5, value);
    }

    /**
     * Return the size, in bytes, of the field 'header.sunrise'
     * WARNING: This field is not an even-sized number of bytes (5 bits).
     */
    public static int size_header_sunrise() {
        return (5 / 8) + 1;
    }

    /**
     * Return the size, in bits, of the field 'header.sunrise'
     */
    public static int sizeBits_header_sunrise() {
        return 5;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: header.sunset
    //   Field type: byte, unsigned
    //   Offset (bits): 10
    //   Size (bits): 5
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'header.sunset' is signed (false).
     */
    public static boolean isSigned_header_sunset() {
        return false;
    }

    /**
     * Return whether the field 'header.sunset' is an array (false).
     */
    public static boolean isArray_header_sunset() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'header.sunset'
     * WARNING: This field is not byte-aligned (bit offset 10).
     */
    public static int offset_header_sunset() {
        return (10 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'header.sunset'
     */
    public static int offsetBits_header_sunset() {
        return 10;
    }

    /**
     * Return the value (as a byte) of the field 'header.sunset'
     */
    public byte get_header_sunset() {
        return (byte)getUIntBEElement(offsetBits_header_sunset(), 5);
    }

    /**
     * Set the value of the field 'header.sunset'
     */
    public void set_header_sunset(byte value) {
        setUIntBEElement(offsetBits_header_sunset(), 5, value);
    }

    /**
     * Return the size, in bytes, of the field 'header.sunset'
     * WARNING: This field is not an even-sized number of bytes (5 bits).
     */
    public static int size_header_sunset() {
        return (5 / 8) + 1;
    }

    /**
     * Return the size, in bits, of the field 'header.sunset'
     */
    public static int sizeBits_header_sunset() {
        return 5;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: data
    //   Field type: short[], unsigned
    //   Offset (bits): 16
    //   Size of each element (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'data' is signed (false).
     */
    public static boolean isSigned_data() {
        return false;
    }

    /**
     * Return whether the field 'data' is an array (true).
     */
    public static boolean isArray_data() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'data'
     */
    public static int offset_data(int index1) {
        int offset = 16;
        if (index1 < 0 || index1 >= 20) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'data'
     */
    public static int offsetBits_data(int index1) {
        int offset = 16;
        if (index1 < 0 || index1 >= 20) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return offset;
    }

    /**
     * Return the entire array 'data' as a short[]
     */
    public short[] get_data() {
        short[] tmp = new short[20];
        for (int index0 = 0; index0 < numElements_data(0); index0++) {
            tmp[index0] = getElement_data(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'data' from the given short[]
     */
    public void set_data(short[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_data(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a short) of the array 'data'
     */
    public short getElement_data(int index1) {
        return (short)getUIntBEElement(offsetBits_data(index1), 8);
    }

    /**
     * Set an element of the array 'data'
     */
    public void setElement_data(int index1, short value) {
        setUIntBEElement(offsetBits_data(index1), 8, value);
    }

    /**
     * Return the total size, in bytes, of the array 'data'
     */
    public static int totalSize_data() {
        return (160 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'data'
     */
    public static int totalSizeBits_data() {
        return 160;
    }

    /**
     * Return the size, in bytes, of each element of the array 'data'
     */
    public static int elementSize_data() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'data'
     */
    public static int elementSizeBits_data() {
        return 8;
    }

    /**
     * Return the number of dimensions in the array 'data'
     */
    public static int numDimensions_data() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'data'
     */
    public static int numElements_data() {
        return 20;
    }

    /**
     * Return the number of elements in the array 'data'
     * for the given dimension.
     */
    public static int numElements_data(int dimension) {
      int array_dims[] = { 20,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /**
     * Fill in the array 'data' with a String
     */
    public void setString_data(String s) { 
         int len = s.length();
         int i;
         for (i = 0; i < len; i++) {
             setElement_data(i, (short)s.charAt(i));
         }
         setElement_data(i, (short)0); //null terminate
    }

    /**
     * Read the array 'data' as a String
     */
    public String getString_data() { 
         char carr[] = new char[Math.min(net.tinyos.message.Message.MAX_CONVERTED_STRING_LENGTH,20)];
         int i;
         for (i = 0; i < carr.length; i++) {
             if ((char)getElement_data(i) == (char)0) break;
             carr[i] = (char)getElement_data(i);
         }
         return new String(carr,0,i);
    }

}
