import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.StringTokenizer;
/**Klase enthält alle methoden zur Kompression
 * 
 * @author anh tuan nguyen
 *
 */

public class Encode {
	
	private final int DEFAULT_FREQUENCY = 1; 
	private final int DEFAULT_NUMBER_OF_VALUES = 24;
	private final int DEFAULT_RESOLUTION = 0;
	private final int DEFAULT_VALUE =5;

	
	private int frequency;
	private int numberOfValues;
	private int resolution;
	private int nightStart;
	private int nightEnd;
	
	private int nightStartRelative; // sonnenuntergang relativ zur aktuellen stunde 
	private int nightEndRelative; // sonnenuntergang relativ zur aktuellen stunde 
	private int hour=0;
	
	public int getHour() {
		return hour;
	}

	public void setHour(int hour) {
		this.hour = hour;
	}

	public static int version = 0;
	
	public String result; // string mit komprimieren daten
	public String originalData; // string mit wetterdaten, die ausgelesen wurden

	

	
	public Encode(){
		version= (version +1)% 16;
		
	}
	
	
	public String getOriginalData() {
		return originalData;
	}

	public void setOriginalData(String originalData) {
		this.originalData = originalData;
	}

	/**
	 * Parset einen gegebene String mit CC daten in ein array mit den entsprechenden Daten
	 * @param text
	 * @return
	 */
	public int[] parseString(String text){
		text = text + ",";
		int[] data = new int[text.length()/2];
		int i = 0;
		StringTokenizer token = new StringTokenizer(text, ",");
		while(token.hasMoreTokens()){
			data[i]= Integer.parseInt(token.nextToken());
			i++;
		}

		return data;
	}
	
	public int getFrequency() {
		return frequency;
	}

	public void setFrequency(int frequency) {
		this.frequency = frequency;
	}

	public int getNumberOfValues() {
		return numberOfValues;
	}

	public void setNumberOfValues(int numberOfValues) {
		this.numberOfValues = numberOfValues;
	}

	public int getResolution() {
		return resolution;
	}

	public void setResolution(int resolution) {
		this.resolution = resolution;
	}

	public int getNightStart() {
		return nightStart;
	}

	public void setNightStart(int nightStart) {
		this.nightStart = nightStart;
	}

	public int getNightEnd() {
		return nightEnd;
	}

	public void setNightEnd(int nightEnd) {
		this.nightEnd = nightEnd;
	}



	/**
	 * liest aus einer ini File die parameter aus
	 * @param file
	 * @throws IOException 
	 */
	public void parseParameter(String file) throws IOException{
		FileReader fr;
		BufferedReader br;
		String zeile;
		

			fr = new FileReader(file);
			br = new BufferedReader(fr);

		// Lese Frequenz ein:
		zeile = br.readLine();	
		// lese den attributsnamen links vom = Zeichen
		String wert = zeile.substring(0, zeile.indexOf("=")).trim();
		if(wert.equals("Frequency")){
			try{ this.frequency = Integer.parseInt(zeile.substring(zeile.indexOf("=")+1).trim());}
			catch(Exception e){this.frequency = DEFAULT_FREQUENCY;}
		}else{
			this.frequency = DEFAULT_FREQUENCY;
		}
		
		// Lese Anzahl Werte ein:
		zeile = br.readLine();	
		wert = zeile.substring(0, zeile.indexOf("=")).trim();
		if(wert.equals("Number of values")){
			try{ this.numberOfValues = Integer.parseInt(zeile.substring(zeile.indexOf("=")+1).trim());}
			catch(Exception e){this.numberOfValues = DEFAULT_NUMBER_OF_VALUES;}
		}else{
			this.numberOfValues = DEFAULT_NUMBER_OF_VALUES;
		}
		
		// Lese Aufl�sung ein:
		zeile = br.readLine();	
		wert = zeile.substring(0, zeile.indexOf("=")).trim();
		if(wert.equals("Resolution")){
			try{ this.resolution = Integer.parseInt(zeile.substring(zeile.indexOf("=")+1).trim());}
			catch(Exception e){this.resolution = DEFAULT_RESOLUTION;}
		}else{
			this.resolution = DEFAULT_RESOLUTION;
		}
		
		this.resolution = Math.min(3, this.resolution); // maximale auflösung ist 3
		
		br.close();
		fr.close();

	}


	
	//  Neuer DdcForecastMsg.h header
	public byte get_HeaderNumDays(){
		
		return (byte) (((double)this.numberOfValues/24.0)-1.0);
	}
	
	public byte get_HeaderResolution(){
		return (byte) this.resolution;
	}
	
	public byte get_HeaderSunset(){
		return (byte)this.nightStartRelative;
	}
	
	public byte get_HeaderSunrise(){
		return (byte) this.nightEndRelative;
	}
	
	
	/**
	 * sets f�r die parameter die default werte ein
	 */
	public void setDefaultParameter(){
		this.frequency = DEFAULT_FREQUENCY;
		this.resolution = DEFAULT_RESOLUTION;
		this.numberOfValues= DEFAULT_NUMBER_OF_VALUES;
	}
	
	/**
	 * Darstellung in Unkomprimierter Form
	 * @param data
	 * @return
	 */
	public void getUnencoded(){
		int[] data = parseString( originalData);
		data = applyResolution(resolution, data);
		String output = "";
	    // Berechne ob der betrachtete zeitraum in der nacht liegt
	    int[] nightSlot =getNightSlotImp(this.numberOfValues, hour, resolution);
	    int nov = Math.min(numberOfValues, data.length);
	    
	    for(int i= 0; i< nov; i++){

	        if(nightSlot[i]!= 0){ // nacht fängt an
	        	output += "0"+toNBinaryString(data[i],4);
	        }
	        else if(nightSlot[i]== 0){ // es ist tag
	        	output += "1"+toNBinaryString(data[i], 4);
	        }
	        hour = (hour + resolution+1) %24;
	    }
	    result = output;
	}
	
	/**
	 * Passt daten an auflösung an,
	 * wenn die Anzahl der Werte nicht durch die Auflösung teilbar ist, werden die letzten Werte abgeschnitten  
	 * @param aufl
	 * @param data
	 * @return
	 */
	public int[] applyResolution(int aufl, int[] data){
		aufl = aufl +1;
		int quotient = data.length/(aufl);
		int anzahl = quotient;
		int[] result = new int[anzahl] ;
		for(int i= 0; i< anzahl; i++){ // werte werden gemittelt und gespeichert
			int sum = 0;
			for(int j= 0; j< (aufl); j++){
				sum += data[(aufl)*i+j];
			}
			 result[i]= (int)Math.round(((double)sum)/(double)aufl); // wird automatisch abgerundet
		}
		return result;
	}
	
	
	/**
	 * Verwendet die Codierung 0 V2
	 * Die ersten 10 bit geben die Anzahl der Stunden bis Sonnenaufgang gefolgt Stunden bis Sonnenuntergang an
	 * Nachtframe fällt weg
	 * 
	 * @param data
	 * @return
	 */
	public void encodeV2(int eMode){
		int[] data = parseString(originalData);

		String output = "";
	    // Berechne ob der betrachtete zeitraum in der nacht liegt
	    int[] nightSlot =getNightSlotImp(this.numberOfValues, hour, resolution);
	    // Auflösung anpassen
	      data = applyResolution(resolution, data);  
	    // Berechne Stunden bis Nacht bzw Tag anhand der Nachtframes
	    int ns=24;
	    int ne=24;
	    for(int i= 1; i< nightSlot.length;i++){
	    	if(nightSlot[0]== 0){ // erster frame ist am tag
	    		if(nightSlot[i-1] == 0 && nightSlot[i]> 0){ // Nachtanfang
	    		  ne = i + nightSlot[i]; // anzahl Frames for nightslot[i] + nachtdauert die in nightslot[i] liegt
	    		  ns = i; // anzahl der nullen vor nightslot[i]
	    		  break;
	    		}
	    	}else{ // erst frme liegt in der Nacht
	    		
	    		if(nightSlot[i-1] == 0 && nightSlot[i] > 0){ // Nachtanfang
		    		  ns = i;
		    		  ne = nightSlot[0]; // im ersten frame steht direkt wann die nacht endet
		    		  break;
		    		}
	    		else if(nightStart == hour){ // sonderfall
		    		  ns = 24;
		    		  ne = nightSlot[0];
		    		  break;
	    		}
	    	}
	    }
	    this.nightStartRelative = ns;
	    this.nightEndRelative = ne;
	    
	    // Überprüfung , dass numberof Values kleiner der maximalen anzahl ist
	    int nov = Math.min(numberOfValues, data.length);

	    for(int i= 0; i< nov; i++){

	        if((nightSlot[i]> 0)||(nightSlot[i]== -1)){ // nacht f�ngt zum ersten mal an oder es ist noch nacht
	        }
	        else if(i> 0 && nightSlot[i-1]!= 0 && nightSlot[i]== 0){ // nacht ist vorbei erzeuge wert anhand des default wertes 4
	            output += getCode0V2(data[i],DEFAULT_VALUE);
	        }
	        else if(i== 0 && nightSlot[i]== 0){ // erster zeitschlitz und es ist Tag
	        	output += getCode0V2(data[i],DEFAULT_VALUE);
	        }
	        else{
	        output += getCode0V2(data[i],data[i-1]);
	        }
	        hour = (hour + resolution+1) %24;
	    }
	    result = output;
	}
	
	/**
	 * Encoding mittels Golomg Rice Codes, NUR FUER TESTZWECKE
	 */	
	public void encodeGolombRice(){
		int[] data = parseString(originalData);
		String output = "";
	    int ns=24;
	    int ne=24;
	    // Berechne ob der betrachtete zeitraum in der nacht liegt
	    int[] nightSlot =getNightSlotImp(this.numberOfValues, hour, resolution);
	    // Auflösung anpassen
	      data = applyResolution(resolution, data);  
	    // Berechne Stunden bis Nacht bzw Tag anhand der Nachtframes
	    for(int i= 1; i< nightSlot.length;i++){
	    	if(nightSlot[0]== 0){ // erster frame ist am tag
	    		if(nightSlot[i-1] == 0 && nightSlot[i]> 0){ // Nachtanfang
	    		  ne = i + nightSlot[i]; // anzahl Frames for nightslot[i] + nachtdauert die in nightslot[i] liegt
	    		  ns = i; // anzahl der nullen vor nightslot[i]
	    		  break;
	    		}
	    	}else{ // erst frme liegt in der Nacht
	    		
	    		if(nightSlot[i-1] == 0 && nightSlot[i] > 0){ // Nachtanfang
		    		  ns = i;
		    		  ne = nightSlot[0]; // im ersten frame steht direkt wann die nacht endet
		    		  break;
		    		}
	    		else if(nightStart == hour){ // sonderfall
		    		  ns = 24;
		    		  ne = nightSlot[0];
		    		  break;
	    		}
	    	}
	    }
	    String nightString = toNBinaryString(ne%24, 5) + toNBinaryString(ns, 5);
	    output += nightString;
	    
	    // Überprüfung , dass numberof Values kleiner der maximalen anzahl ist
	    int nov = Math.min(numberOfValues, data.length);

	    for(int i= 0; i< nov; i++){

	        if((nightSlot[i]> 0)||(nightSlot[i]== -1)){ // nacht f�ngt zum ersten mal an oder es ist noch nacht
	        }
	        else if(i> 0 && nightSlot[i-1]!= 0 && nightSlot[i]== 0){ // nacht ist vorbei erzeuge wert anhand des default wertes 4
	            output += getCodeGolombRice(data[i],DEFAULT_VALUE);
	        }
	        else if(i== 0 && nightSlot[i]== 0){ // erster zeitschlitz und es ist Tag
	        	output += getCodeGolombRice(data[i],DEFAULT_VALUE);
	        }
	        else{
	        output += getCodeGolombRice(data[i],data[i-1]);
	        }
	        hour = (hour + resolution+1) %24;
	    }
	    result = output;
	}
	
	
	
	/**
	 * Generiert das integer array aus dem Code
	 * @param code encodierte Wetterdaten
	 * @return
	 */
	public short[] getData(){
		String code = this.result;
		int extraSize = 8-code.length()%8; // bestimme wieviel nullen wir hinten extra anfügen müssen
		if(extraSize == 8) extraSize = 0; // damit die Stringlänge durch 8 teilbar ist
		
		// padding
		for(int i = 0; i < extraSize; i++){
			code += "0";
		}
		
		short data[] = new short[code.length()/8];
		for(int i = 0; i< data.length; i++){
			data[i] =(short) Integer.parseInt(code.substring(0,8), 2);
			code = code.substring(8);
		}
	
		
		// array spiegeln 
		short data2[] = new short[data.length];
		for(int i = 0; i< data.length;i++){
			data2[data.length-i-1]= data[i];
		}
		
		//return data2;
		return data; //daten werden nicht gespiegeln
	}
	

	/**
	 *Berechnet die l�nge einer Nacht und speichert sie in einem Array
	 * @param n  anzahl der Zeitslots ab der aktuellen Stunden f�r die die Nacht berechnet werdne soll
	 * @return array wo jeder index i f�r einen zeitschlitz steht
	 * X > 0: ab diesem schlitz geht die Nacht X stunden
	 * x= 0: es ist Tag
	 * x= -1: es ist mitten in der Nacht
	 */
	public int[] getNightSlot(int n, int stunde)
	{
	    int[] nightSlot = new int[n];
	    for(int i = n-1; i>=0;i--){
	        int tempHour = (stunde + i) %24;
	        if((nightStart>nightEnd &&!(tempHour< nightStart && tempHour >nightEnd))||
	           (nightStart<=nightEnd &&(tempHour>= nightStart && tempHour <=nightEnd))){
	            if(i< numberOfValues-1 && nightSlot[i+1] > 0){
	                nightSlot[i]= nightSlot[i+1]+1;
	                nightSlot[i+1]= -1;
	            }else{
	                nightSlot[i]= 1;
	            }
	        }
	        else {
	            nightSlot[i] = 0;
	        }
	    }

	    return nightSlot;
	}
	
	/**
	 * 
	 * @param nOrg original anzahl an elementen ohne auflösungsanpassung
	 * @param stunde aktuelle Stunde
	 * @param aufl  Auflösung
	 * @return
	 */
	public int[] getNightSlotImp(int nOrg, int stunde, int aufl)
	{
		int tempHour;
	    int[] nightSlot;
	    int[] tempSlot = new int[nOrg];
	    
	    // 1. Markiere alle Zeitschlitze, die in der Nacht liegen mit 1
	    for(int i = 0; i< nOrg;i++){
	    	tempHour = (stunde + i) %24; // die letztend slots besitzen eine auflösung von 1
	        if((nightStart>nightEnd &&!(tempHour< nightStart && tempHour >nightEnd))||
	           (nightStart<=nightEnd &&(tempHour>= nightStart && tempHour <=nightEnd))){
	                tempSlot[i]= 1;
	            }
	        else {
	            tempSlot[i] = 0;
	        }
	    }
	    // 2. mittle diese Zeitschlitze 
        nightSlot = applyResolution(aufl, tempSlot);
	    
        // 3. passe werte an
        for(int i= nightSlot.length-2; i>= 0;i--){
        	if(nightSlot[i] == 1 && nightSlot[i+1] > 0){
                nightSlot[i]= nightSlot[i+1]+1;
                nightSlot[i+1]= -1;
            }
        }
        

	    return nightSlot;
	}
	
	
	
	/**
	 * wandelt number in binärstring der länge length um
	 * @param number
	 * @param length
	 * @return
	 */
	private String toNBinaryString(int number, int length)
	{
	    if(number < 0) number = 0;
	    if(number > Math.pow(2,length)-1) number = ((int) Math.pow(2,length))-1;

	    String result = Integer.toBinaryString(number);

	    for(int i= result.length(); i< length; i++){
	        result = "0"+ result;

	    }

	    return result;

	}
	
	/**
	 * Hilfsmethode für V0
	 * @param value1
	 * @param value2
	 * @return
	 */
	private String getCode0V2(int value1, int value2)
	{
	    String output = "";
	    if(value1-value2== 0)  output = "0";
	    else if(value1-value2== 1)  output = "10";
	    else if(value1-value2== -1) output = "110";
	    else{ // erzeuge startframe
	        output ="111"+toNBinaryString(value1,4);
	    }

	    return output;
	}

	/**
	 * Hilfsmethode Golomb Rice Code
	 * @param value1
	 * @param value2
	 * @return
	 */
	private String getCodeGolombRice(int value1, int value2)
	{
	    String output = "";
	    if(value1-value2== 0)  output = "00";
	    else if(value1-value2== 1)  output = "01";
	    else if(value1-value2== -1) output = "100";
	    else{ // erzeuge startframe
	        output ="101"+toNBinaryString(value1,4);
	    }

	    return output;
	}
	
}
