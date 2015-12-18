import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.Calendar;
import java.util.Date;
import java.util.TimerTask;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import net.tinyos.message.Message;
import net.tinyos.message.MessageListener;
import net.tinyos.message.MoteIF;
import net.tinyos.util.PrintStreamMessenger;


/**
 * task for parsing data, encoding and sending
 * @author anh tuan nguyen
 */



public class WeatherTask extends TimerTask implements MessageListener{
    private MoteIF mote;
	private int connection_Tries; 
	private byte lastSeqNr;
	private String fileName;
	private int delayTime;
	
	boolean resend = false;
	
    ScheduledExecutorService scheduledThreadPool;
    ScheduledFuture<?> timer;
	
	
	public WeatherTask(int connectionTries, String fileName){
		mote = new MoteIF(PrintStreamMessenger.err);
	    mote.registerListener(new SinkAck(), this);
	    this.connection_Tries 	= connectionTries;
	    this.lastSeqNr 			= -1;
	    this.fileName  			= fileName;
	    this.delayTime 			= 1024; //minimum waiting time between each package sent
	    
		// initialize Threadpool
		scheduledThreadPool = Executors.newScheduledThreadPool(1);
	}

	@Override
	public synchronized void run() {
		sendPackage();
		// start timer after package is sent
	    // if no package arrives after 5 seconds, it its probably lost and will be resent by this thread
		timer =scheduledThreadPool.schedule(new Thread (){
			   public void run(){
				   synchronized(this){
					   System.out.println("Package Lost!, Resend Package");
					   //TODO handling, when second package is not acknowledged as well
					   sendPackage();
				   	   }
			   		}
		   		}, 5, TimeUnit.SECONDS);  // wait 5 seconds
		if(!resend){
			try { 
				wait(); // block until package received 
				// if no package is received after 5 seconds the application will be terminated

			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		resend = false;
		System.out.println("Package sent");
		

	}
	
	
	private void sendPackage(){
		Communication comm = new Communication();
		CloudCoverData CCD = new CloudCoverData();
		Encode encoder = new Encode();
		boolean connect = false;
		boolean sunConnect = false;
		int hour; // current hour

		// try connecting to the website and retry 
		for (int i = 0; i < connection_Tries; i++) {
			connect = CCD.connectCC();
			if (connect)
				break;
			System.out.println("Verbindungsversuch" + i + " fehlgeschlagen");
		}
		// if no connection is possible, end task
		if (!connect) {
			System.out
					.println("Keine Verbindung möglich, probiere beim Nächsten Zeitschlitz");
			return;
		}

		CCD.parseData(); // parse cloud cover data
		CCD.writeData("log.txt"); // store data
		
		
		// get data for sunset and sunrise	
		for (int i = 0; i < connection_Tries; i++) {
			sunConnect = CCD.connectSun();
			if (sunConnect)
				break;
			System.out.println("Verbindungsversuch für Sonnenaufgang" + i + " fehlgeschlagen");
		}
		//
		try{
			CCD.parseSunData();  // parse data
		} catch (Exception e){
			System.out.println("Test"); //TODO ordentliche ausgabe
		}

		
		

		// read parameter
		try {
			encoder.parseParameter("Parameter.txt");
		} catch (IOException e) {
			System.out.println("Fehler: Benutze default parameter");
			encoder.setDefaultParameter();
		}
		
		//set parameter for encoder
		hour = CCD.parseTime(CCD.getTimeStart());
		encoder.setOriginalData(CCD.getNthData(encoder.getNumberOfValues()));
		encoder.setHour(hour); // aktuelle Stunde einstellen
		encoder.setNightStart(CCD.getSonnenUntergang());
		encoder.setNightEnd(CCD.getSonnenAufgang());
		
		// Debug
		System.out.println("Stunde " + hour);
		System.out.println("Ausgelesene Daten   : " +CCD.getCCData());
		System.out.println("Tatsaechliche Daten : "+ CCD.getNthData(encoder.getNumberOfValues()));
		System.out.print(  "Nachtframes         : ");
		int[] nD = encoder.getNightSlotImp(encoder.getNumberOfValues(), hour,encoder.getResolution());
		for(int i = 0; i< nD.length; i++)		System.out.print(nD[i] +" "); // debug
		// Debug Ende
		
		// write debug data
		CCD.writeDebugData("debug.txt", encoder.getNumberOfValues(),
				encoder.getNightStart(), encoder.getNightEnd(), hour);
		
			
		// encode
		encoder.encodeV2(0);
		short data[] = encoder.getData();
		
		// Debug	
		System.out.println("\nEncode: " + encoder.result);		
		System.out.print("Array: ");
		for(int i = 0; i< data.length; i++)		System.out.print(data[i] +" "); // debug
		System.out.println("\n");
		System.out.println("Version :" + Encode.version);
		// Debug Ende
		
		
		// send packages
		comm.init();
		comm.sendPackage(data, encoder.get_HeaderSunset(), encoder.get_HeaderSunrise(),
				encoder.get_HeaderResolution(), encoder.get_HeaderNumDays());
	}

	@Override
	public void messageReceived(int arg0, Message arg1) {

		//Check Message type
		if(arg1.amType() == SinkAck.AM_TYPE){
			SinkAck ack = (SinkAck)arg1;
			System.out.println(ack.get_seqNr());
			//check only if seqNr are inequal
			if(this.lastSeqNr != ack.get_seqNr()){
				//System.out.println(lastSeqNr +"  A"+ ack.get_seqNr());
				lastSeqNr = (byte) ack.get_seqNr();
				timer.cancel(true); // if correct package is received, stop timer 
				setReady(); // important for syncing
			}

		} else {
			//TODO remove duplicates
			Date now = Calendar.getInstance().getTime();
			//Log Package 
			writeDatatoFile(now.toString()+ " : ", this.fileName, true);
			writeDatatoFile(arg1.toString(), this.fileName, true);
		}

	}
	
	
	public void setReady(){
		synchronized (this) {
		
			try {
				Thread.sleep(delayTime);				//wait
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			notify();			//deblock 
		}
	}
	
	
	private void writeDatatoFile(String text, String fileName, boolean append){
		Writer fw = null;
		// Write data into file 	
		try {
			fw = new FileWriter(fileName,append);

			fw.write(text);
			fw.append(System.getProperty("line.separator")); // new line

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
	

}
