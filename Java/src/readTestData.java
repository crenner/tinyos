import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.StringTokenizer;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import net.tinyos.message.Message;
import net.tinyos.message.MessageListener;
import net.tinyos.message.MoteIF;
import net.tinyos.util.PrintStreamMessenger;
/**
 * TODO
 * gelegentlich verbindung zum SF trennen und neu aufbauen ???
 * 
 * @author anhtuan Nguyen
 * Class reads Test Forecasts from a data set file.
 * The encoded data sets will we sent to the sensor node and the data set will be logged in a debug file.
 * The decoded data received from the sensor node will be received and logged in a output file.
 * 
 * It is recommended to use the Serialforwarder implemented in C++ in /tinyOS/support/sdk/cpp/sf
 * It can happen that packages sent to the SF are lost or that response packages are duplicated or lost.
 * This can happen if the delay Time is too low or sometimes at random.
 * This test mode tries to cope with these limitations. The recommended delay time is 1 second
 * though it can work with 200ms delay if the C++ SF is used.
 * 
 * New data sets will only be sent if the previous data set was acknowledged.
 * The decoded data received acts as an acknowledgement.
 * 
 * Received packages will be buffered. This allows ignoring duplicate packages.
 * When an Ackowledgement was not received after 5 seconds the Application will terminate
 * but the last read line from the data set file will be stored in the file 'lastSession'
 * The application can then be restarted and it will continue on the given line or
 * at the beginning of the file, if no 'lastSession' file is given.
 * 
 * 
 */


public class readTestData implements MessageListener {
	//components for Encoding and Communication to Serial Forwarder
       private Encode encoder;
       private MoteIF mote;
       private Communication comm;
       
       private int delayTime; // delay time between each data set sent
       private int numberOfValues; // number of values sent
       
       private FileReader fr ;
       private BufferedReader br;
       private int nr; // Number of actual line
       private boolean sync = true;  // if true a timer will start after each package sent to terminate the application
       // in case no package is received
      
       String lastDataSet = ""; // buffered data set received
       
       ScheduledExecutorService scheduledThreadPool;
       ScheduledFuture<?> timer;
       readTestData ref;
       
       
       //Test
       //ScheduledThreadPoolExecutor pool;
       
	   /**
	    * Constructor
	    * @param file  filepath of data set file
	    */
       public readTestData(String file , int delayTime){
    	   // read parameter for encoding from parameter.txt
    	   nr= 0;
    	   encoder = new Encode();
   			try {
   				encoder.parseParameter("Parameter.txt");
   			} catch (IOException e) {
   				System.out.println("Fehler: Benutze default parameter");
   				encoder.setDefaultParameter();
   			}
   		
   			this.delayTime =delayTime;
   			this.numberOfValues = encoder.getNumberOfValues();
   			comm = new Communication();
   			comm.init(); // comm has no listener 
   			
   			// register listener to accept all incoming packages
   			mote = new MoteIF(PrintStreamMessenger.err);
   			mote.registerListener(new DdcTestMsg(), this);
   			
   			// initialize file reader
   			try{
   				fr = new FileReader(file);
   				br = new BufferedReader(fr);
   			} catch(IOException e){
   				System.out.println("File could not be found");
   			}
   			
   			// initialize Threadpool
   			scheduledThreadPool = Executors.newScheduledThreadPool(1);
   			ref = this;
   			
   			
       }
       
       /**
        * If lastSession File exists, skip directly to the given line in
        * the test file, else start at the beginning
        * @return
        */
       public boolean skipLine(){
    	   String zeile;
    	   int targetLine= -1;
    	   // read lines to skip from lastSession file;
    	   BufferedReader lastSession= null;
    	  
    	   try {
			lastSession = new BufferedReader(new FileReader("lastSession"));
			targetLine = Integer.parseInt(lastSession.readLine());
			
		} catch (FileNotFoundException e1) {
			System.out.println("File not found");
			return false;
		} catch (NumberFormatException e) {
			return false;
		} catch (IOException e) {
			return false;
		}finally {
			if (lastSession != null)
				try {
					lastSession.close();
				} catch (IOException e) {
					e.printStackTrace();
				}

		}
    	   
    	   if(targetLine == -1) return false;
    	  // if(targetLine-1 < 1) return false;
    	   
    	   // read lines until we reached our desired line number
    	   while((targetLine) != nr){
	   	    try {
	   	    	
	   	    	zeile = br.readLine();
	   	    	// if line is empty skip to next line 
	   	    	if( zeile == null) return false; 
	   	    	while(zeile.equals("")){
	      	      zeile = br.readLine();
	   	    	}
			} catch (IOException e) {
				return false;
			}
	   	    nr++;
	   	    
    		   
    	   }
    	   System.out.println("continue at line "+ nr);
    	   return true;
       }
       
       /**
        * This methods sends new Packages as long as there are data sets
        * After sending a package, the methods waits until the response package is received until sending again
        * 
        */
       
       public synchronized void getNextPackageReady(){
    	   //encode and send data set
    	   while(readAndEncode()){
    		   comm.sendPackage(encoder.getData(), encoder.get_HeaderSunset(), encoder.get_HeaderSunrise(),
   					encoder.get_HeaderResolution(), encoder.get_HeaderNumDays());
    		   
    		   /*
    		   if(nr == 4){

    			   mote.deregisterListener(new DdcTestMsg(), this);
    			   mote.getSource().shutdown();
    			   mote = null;
    		   }*/
    		   
    		   // start timer after package is sent
    		   // if no package arrives after 5 seconds, it its probably lost and will be resent by this thread
			   if(sync){
    		   timer =scheduledThreadPool.schedule(new Thread (){
    			   public void run(){
    				  /*
    				   System.out.println("Package lost! Resending........");
    				   comm.sendPackage(encoder.getData(), encoder.get_HeaderSunset(), encoder.get_HeaderSunrise(),
    		   					encoder.get_HeaderResolution(), encoder.get_HeaderNumDays());*/
        				   System.out.println("Package Lost!, Programm terminated at line: "+nr);
        				   writeDatatoFile(nr+"", "lastSession", false);
        				   System.exit(0); 
    			   		}
    		   		}, 5, TimeUnit.SECONDS);  // wait 5 seconds
			   }
    		   try { 
				wait(); // block until package received 
				// if no package is received after 5 seconds the application will be terminated

    		   } catch (InterruptedException e) {
				e.printStackTrace();
    		   }
    		   // if package was successfully sent and received we will print debug data 
    		   writeDebugData(false);
    	   }
    	   
    	   // clear lastSession
    	   writeDatatoFile("", "lastSession", false);  	   
    	   System.exit(0);
    
    	   
       }
       
       /**
        * read next line and encode data
        * @return encode object
        */
       public boolean readAndEncode(){
			String zeile;

	   	    try {
	   	    	
	   	    	zeile = br.readLine();
	   	    	// if line is empty skip to next line 
	   	    	if( zeile == null) return false; 
	   	    	while(zeile.equals("")){
	      	      zeile = br.readLine();
	   	    	}
			} catch (IOException e) {
				return false;
			}
	   	    
	   	    
	   	    // parse data set to receive sunrise, sunset, current hour and forecast
	        int timestamp= this.getTimeStamp(zeile);
	        int[] timeArray = this.getTimes(timestamp);
	        String data = this.getData(zeile);
	        
	        // send data to encoder and start encoding
		    encoder.setOriginalData(data);
		    encoder.setHour(timeArray[0]);
		    encoder.setNightEnd(timeArray[1]); // sunrise
		    encoder.setNightStart(timeArray[2]);//sunset
		    encoder.encodeV2(1);
		    return true;
       }

       /**
        * //Write information to debug file
        * @param extraInformation
        */
  	    public void writeDebugData(boolean extraInformation){
  	    	//Write information to debug file
  	    	String outputString = encoder.getHour()+"*"+encoder.getNightStart()+"*"+encoder.getNightEnd()+"*";
  			int[] debugData = encoder.parseString(encoder.getOriginalData());
  			for(int i = 0; i< encoder.getNumberOfValues(); i++){
  				outputString+=(debugData[i]+",");
  			}
  	
  			writeDatatoFile(outputString, "debug"+encoder.getNumberOfValues()+".txt",true);
  			nr++;
  			// Debugging Data 
  			if(extraInformation){
  				short encodedData[] = encoder.getData();
  		    	System.out.println("Daten: "+encoder.getOriginalData());  
  				System.out.print("Nachtframes: ");
  				int[] nD = encoder.getNightSlot(encoder.getNumberOfValues(), encoder.getHour());
  				for(int i = 0; i< nD.length; i++)		System.out.print(nD[i] +" "); // debug 
  		
  				System.out.print("\nZeile " +nr  + " Version :" + Encode.version);
  				System.out.print(" NumDays "+ (encoder.get_HeaderNumDays())+ 
  						         " NS:"+ encoder.getNightStart()+ " NE:"+ encoder.getNightEnd());
  				System.out.print( " Zeit: " + encoder.getHour()+ "\n");
  				System.out.println("Encode: " + encoder.result);		
  				System.out.print("Array: ");
  				for(int i = 0; i< encodedData.length; i++)		System.out.print(encodedData[i] +" "); // debug
  				System.out.print("\n");
  			}
  			
  			// Print out actual data before encoding 
  			
  			int[] sentData = encoder.parseString(encoder.getOriginalData());
  			System.out.print("Sent:     ");
  			for(int i = 0; i< encoder.getNumberOfValues(); i++){
  				System.out.print(sentData[i]+"*");
  			}
  			System.out.print("\n");
  			System.out.println(nr+"-----------------------------------------------------------------------------------");
  	    }
  	    
  

	@Override
	/**
	 * Lister Function
	 * Triggers whenever a package is received has to be of type 'DdcTestMsg'
	 * See file DdcTestMsg
	 */
	public void messageReceived(int arg0, Message arg1) {
		//Parse package
		DdcTestMsg msg = (DdcTestMsg)arg1;
		String tmp = getOutputString(msg);
		tmp+=msg.get_decodingTime();
		
		// check for duplicates
		int index =tmp.lastIndexOf('*');
		String line = tmp.substring(0, index);
		// if package is not a duplicate
		if(!line.equals(lastDataSet)){ 
			
			System.out.println("Received: "+tmp);
			writeDatatoFile(tmp, "output"+this.numberOfValues+".txt",true); 
			if(sync){
				// stop timer and continue loop in getNextPackageReady
				timer.cancel(true); // if correct package is received, stop timer 
				setReady(); // important for syncing
			}
		}else {
			System.out.println("Duplikat: " + tmp);
		}
		lastDataSet = line;

		
	}
	
	public void setReady(){

		synchronized (this) {
			try {
				//wait
				Thread.sleep(delayTime);
				
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			//deblock 
			notify();
		}
	}
	
	
//--------------------------------Helper Methods-----------------------------------------------
	// get forecasts from data set  by removing timestamp
	private String getData(String line){
		int index = line.indexOf(" ");
		String result = line.substring(index+1);
		result = result.replace(' ', ',');
		return result;
	}
	
	// read timestamp from the data set (first argument)
	private int getTimeStamp(String line){
		StringTokenizer tokenizer = new StringTokenizer(line, " ");
	      return (Integer.parseInt(tokenizer.nextToken()));

	}
	
	// calculate current hour, sunset hour, sunrise hour based on a timestamp
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
	
	public void writeDatatoFile(String text, String fileName, boolean append){
		Writer fw = null;
		// Write data into file 	
		try {
			fw = new FileWriter(fileName,append);

			fw.write(text);
			fw.append(System.getProperty("line.separator")); // neue zeile

		} catch (IOException e) {
			System.out.println("error writing");
		} finally {
			if (fw != null)
				try {
					fw.close();
				} catch (IOException e) {
					e.printStackTrace();
				}

		}
	}
	
	/**
	 * Each Value byte of a DdcTestMsg contains two CloudCover Values
	 * since each Cloud Cover Value ranged from 0 to 9 one value only needs 4 bit of a byte  
	 * @param msg Message Object of Type DdcTestMsg
	 * @return String contraining all decoded Values separated by '*'
	 */
	public String getOutputString(DdcTestMsg msg){
		String result ="";
		for(int i= 0; i< msg.get_numValues()/2; i++){
			int highBit = msg.getElement_values(i)>>4; // right shift 4 bit
			int lowBit = msg.getElement_values(i)& 15; // & 00001111
			result +=highBit+"*"+lowBit+"*";
		}
		return result;
	}
}
