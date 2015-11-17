import java.io.*;
import java.util.StringTokenizer;

/**
 *  Test Class for reading data sets from a given test file.
 *  These data sets are encoded and set via Serialforwarder to a sink NOde
 * @author anh tuan nguyen
 *
 */
public class TestCoding {

	public TestCoding(){
		
	}
	public void start(String file) throws IOException{
	    FileReader fr = new FileReader(file);
	    BufferedReader br = new BufferedReader(fr);
		//Communication comm = new Communication();
		CloudCoverData CCD = new CloudCoverData();
		
		Encode encoder = new Encode();
		//read parameters from parameter.txt
		try {
			encoder.parseParameter("Parameter.txt");
		} catch (IOException e) {
			System.out.println("Fehler: Benutze default parameter");
			encoder.setDefaultParameter();
		}
		// create new output file
		Communication comm = new Communication(true,"output" +encoder.getNumberOfValues()+".txt");
	    int nr = 1;
	    String zeile = br.readLine();
	    
	    //skip empty lines
	    while( zeile != null )
	    {
          if(zeile.equals("")){
    	      zeile = br.readLine();
        	  continue;
          }
          // get current time, sunset and sunrise
          int timestamp= this.getTimeStamp(zeile);
          int[] timeArray = this.getTimes(timestamp);
          String data = this.getData(zeile);
          
          // deliver encoding data
	      encoder.setOriginalData(data);
	      CCD.setCCData(data);
	      System.out.println("Daten:       "+encoder.getOriginalData());  
	      encoder.setHour(timeArray[0]);
	      encoder.setNightEnd(timeArray[1]); // sunrise
	      encoder.setNightStart(timeArray[2]);//sunset
	      
		  CCD.writeDebugData("debug"+encoder.getNumberOfValues()+".txt", encoder.getNumberOfValues(),
					encoder.getNightStart(), encoder.getNightEnd(), timeArray[0]);
          
		  //start encoding and get encoded data
		  encoder.encodeV2(1);
		  short encodedData[] = encoder.getData();
		  
		  
		  //debug
			System.out.print("Nachtframes: ");
			int[] nD = encoder.getNightSlot(encoder.getNumberOfValues(), timeArray[0]);
			for(int i = 0; i< nD.length; i++)		System.out.print(nD[i] +" "); // debug 

			System.out.print("\nZeile " +nr  + " Version :" + Encode.version);
			System.out.print(" NumDays "+ (encoder.get_HeaderNumDays())+ 
					         " NS:"+ encoder.getNightStart()+ " NE:"+ encoder.getNightEnd());
			System.out.print( " Zeit: " + timeArray[0]+ "\n");
			System.out.println("Encode: " + encoder.result);		
			System.out.print("Array: ");
			for(int i = 0; i< encodedData.length; i++)		System.out.print(encodedData[i] +" "); // debug
			System.out.println("\n");
			nr++;
			
			
		

			//send data to serialforwarder
		  comm.sendPackage(encodedData, encoder.get_HeaderSunset(), encoder.get_HeaderSunrise(),
					encoder.get_HeaderResolution(), encoder.get_HeaderNumDays());

			// read next data set      	
	      zeile = br.readLine();
	      // Sleep to prevent package losses
	      try {
			Thread.sleep(1024*10);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	    }

	    br.close();
	}
//========================================Helper Methods
	private String getData(String line){
		int index = line.indexOf(" ");
		String result = line.substring(index+1);
		result = result.replace(' ', ',');
		return result;
	}
	
	private int getTimeStamp(String line){
		StringTokenizer tokenizer = new StringTokenizer(line, " ");
	      return (Integer.parseInt(tokenizer.nextToken()));

	}
	
	// calculate current hour, sunrise and sunset based on a timestamp
	private int[] getTimes(int timestamp){
		//calculate day and hour based on timestamp
		int curDayOfYear = 1 + ( timestamp / (86400)% 365 );
		int curHourOfDay = (int) Math.round( ((double)(timestamp% 86400)) / 3600.0 );
		
		//calculate sunrise and sunset
		 double latitude  = 53.834 / 180.0 * Math.PI;  // [rad]
		 double longitude= 10.704;             // [degree]
		 double decl = 0.4095*Math.sin(0.016906*(curDayOfYear-80.086)); //declination of the sun
		 
		 // correction for sunlight "beugung"
		 double h = (-50.0/60.0) / 180.0 * Math.PI;  
		 double dt = 12.0 * Math.acos((Math.sin(h) - Math.sin(latitude)*Math.sin(decl)) / (Math.cos(latitude)*Math.cos(decl))) / Math.PI;
		 double timeEq = -0.171*Math.sin(0.0337 * curDayOfYear + 0.465) - 0.1299*Math.sin(0.01787 * curDayOfYear - 0.168);
	  
		 double sunrise = 12 - dt - timeEq;
		 double sunset  = 12 + dt - timeEq;
		  
		  // correction for longitude position
		  double tz = 2.0; //% use ECT with DST for now
		  sunrise = sunrise - longitude / 15 + tz;
		  sunset  = sunset  - longitude / 15 + tz;
		  
		  int[] result = {curHourOfDay,(int) Math.floor(sunrise), (int) Math.floor(sunset)};
		  
		  
		  return result;

		 
	}

}
