import java.io.IOException;
import java.util.TimerTask;

/**
 * task for parsing data, encoding and sending
 * @author anh tuan nguyen
 *
 */

public class WeatherTask extends TimerTask {
	public int connection_Tries = 3; 

	@Override
	public void run() {
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

}
