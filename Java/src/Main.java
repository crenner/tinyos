import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
//import java.util.Timer;

/**
 * Main class with different execution modes 
 * see documentation
 * @author phu anh tuan nguyen
 *
 */



public class Main {

	public static void main(String[] args) {
	
		
		if(args.length == 0){
			System.out.println("please enter a mode or see documentation");
			return;
		}
		// Standard mode for reading weather data and encoding
		if(args[0].equals("weather")){
			startWeatherTask();
		}
		// Testing mode to send a greater amount of test forecast data 
		//requires file location, and delay time parameter
		else if(args[0].equals("test")){
				if(args.length < 3){
					System.out.println("Please enter a file Location");
					return;
				}else {
					int time = Integer.parseInt(args[2]);
					testMode(args[1],time);
				}
		}
		//Evaluation mode
		else if(args[0].equals("evaluation")){
			evaluationMode();
		// Seconds test mode
		// new data will only be sent, if sink node can send an acknowledgement package to this application
		// main purpose was for verifying the encoding algorithm efficiently	
		}else if(args[0].equals("test2")){
			if(args.length < 2){
				System.out.println("Please enter a file Location");
				return;
			}
			testMode2(args[1]);
		}
		
	
	


	}
	
	
	/**
	 * Method for initialising Weather tast
	 */
	public static void startWeatherTask(){
    	FileReader fr;
		BufferedReader br;
		String zeile;
		int frequency;
		int DEFAULT_FREQUENCY= 1440000; // 1 hour in ms
	    
	    while(true){
	    	//Timer timer = new Timer();
	    	//timer.schedule( new WeatherTask(), 2000, 120000 );

			// read parameter
	    	try{
				fr = new FileReader("Parameter.txt");
				br = new BufferedReader(fr);

			// Read frequency from parameter file
			// frequency is read each iteration in case it was changed in the parameter file	
	
			zeile = br.readLine();	
			String wert = zeile.substring(0, zeile.indexOf("=")).trim();
			// if no valid frequency is defined, use default value
			if(wert.equals("Frequency")){
				frequency = Integer.parseInt(zeile.substring(zeile.indexOf("=")+1).trim());
			}else{
				frequency = DEFAULT_FREQUENCY;
			}
			br.close();
			fr.close();
	    	} catch(Exception e){
	    		frequency = DEFAULT_FREQUENCY;
	    	}
	    	
	    	// start task
	    	WeatherTask x = new WeatherTask();
	    	x.run();
	    	// After each task execution, wait <frequency> time until the task is started again
	    	try{
	    	Thread.sleep(frequency);
	    	} catch (Exception e){
	    		
	    	}
	    	// neuen task starten
	    	System.out.println("beendet");
	    }
	}
	
	/**
	 * method for initialising first test mode
	 * for further information see readTestData.java
	 * @param file location of test data
	 * @param time delay time
	 */
	public static void testMode(String file, int time){
		readTestData test = new readTestData(file,time);
		test.skipLine();
		test.getNextPackageReady();

	}
	/**
	 * method for initialising second test mode
	 * for furhter Information see TestCoding.java
	 * @param file location of test data
	 */
	public static void testMode2(String file){
		TestCoding test = new TestCoding();
		try {
			test.start(file);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * method for initialising evaluation mode
	 */
	public static void evaluationMode(){
		Evalution ev = new Evalution();
		try {
			ev.startWrapper(false);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}


}
