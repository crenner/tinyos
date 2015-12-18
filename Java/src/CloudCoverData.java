import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.util.*;
/**
 * Parsing class for
 * - cloud cover
 * - sunrise
 * - sunset
 * data are gathered from external links
 * @author anhtuan
 *
 */
public class CloudCoverData {
	public String url = "http://www2.wetterspiegel.de/de/europa/deutschland/schleswig-holstein/14622x31.html";
	public String sunUrl = "http://www.sunrise-and-sunset.com/de/deutschland/lubeck";
	public String sunUrl2 ="";
	private Document doc = null;
	private String CCData=""; 
	private int sonnenUntergang;
	private int sonnenAufgang;
	
	
	public int getSonnenUntergang() {
		return sonnenUntergang;
	}

	public int getSonnenAufgang() {
		return sonnenAufgang;
	}

	public String getTimeStart() {
		return timeStart;
	}

	public String getTimeEnd() {
		return timeEnd;
	}

	private String timeStart ="";
	private String timeEnd="";


	public CloudCoverData() {

	}
	
	/**
	 * Generates correct link for parsing sunset and sunrise based on the current date
	 * @return verbindung erfolgreich oder nicht
	 */
	public boolean connectSun(){
		// get current date
		int jahr = Calendar.getInstance().get(Calendar.YEAR);
		int monat = Calendar.getInstance().get(Calendar.MONTH);
		int tag = Calendar.getInstance().get(Calendar.DATE);
		
		String monat_name = "";
		
		switch(monat+1){
		case 1:  monat_name = "januar"; break;
		case 2:  monat_name = "februar"; break;
		case 3:  monat_name = "marz"; break;
		case 4:  monat_name = "april"; break;
		case 5:  monat_name = "mai"; break;
		case 6:  monat_name = "juni"; break;
		case 7:  monat_name = "juli"; break;
		case 8:  monat_name = "august"; break;
		case 9:  monat_name = "september"; break;
		case 10: monat_name = "oktober"; break;
		case 11: monat_name = "november"; break;
		case 12: monat_name = "dezember"; break;
		
		}
		//get correct link for parsing sunset and sunrise
		String newUrl = sunUrl+"/"+jahr+"/"+monat_name+"/"+tag;
		//System.out.println(newUrl);
		try {
			doc = Jsoup.connect(newUrl).get();
			return true;
		} catch (Exception e) {
			System.out.println("Verbindung zur Website " + newUrl + " fehlgeschlagen");
			e.printStackTrace();
			return false;
	
		}
	
		
	}
	

	/**
	 * Connect to Website responsible for Cloud Cover Data
	 * @return true if connection was successful
	 */

	public boolean connectCC(){

		try {
			doc = Jsoup.connect(url).get();
			return true;
		} catch (Exception e) {
			System.out.println("Verbindung zur Website " + url + " fehlgeschlagen");
			e.printStackTrace();
			return false;
		}
		
	}
	
	/**
	 * parse Cloud Cover and time data
	 */
	public void parseData(){
		parseCCData();
		getTime();
	}

	/**
	 * Parse Cloud Cover data from given Link
	 * 
	 * @return String mit dem Bew�lkungsgrad (ungeparst)
	 */
	public void  parseCCData() {
		Elements skript = doc.getElementsByTag("script");

		Element ziel = skript.get(11);
		String data = ziel.data().substring( // entferne alle was nicht mit
												// cloud cover zu tun hat
				ziel.data().indexOf(
						"name: 'Gesamtbedeckungsgrad (1/8)',	//series 8"));
		data = data.substring(data.indexOf("[") + 1); // behalte alles was
														// zwischen den
														// klammern[]
														// steht.
		data = data.substring(0, data.indexOf("]")).trim();
		
		
		this.CCData = data;
	}

	
	/**
	 * Parse sunset and sunrise from given link
	 * 
	 * @return String containing cloud cover value(ungeparst)
	 */
	public void  parseSunData() {
		// suche Tabelle mit sonnendaten
		Elements skript = doc.getElementsByClass("table");
		Element tabelle = skript.get(0);
		Elements td = tabelle.getElementsByTag("td");
		// lese tabellenzellen mit zeitinformationen aus
		String aufgang = td.get(10).html();
		String untergang = td.get(11).html();
		
		// parse minuten und stunden
		int aStunde = Integer.parseInt(aufgang.substring(0, aufgang.indexOf(":")));
		int aMinute = Integer.parseInt(aufgang.substring(aufgang.indexOf(":")+1));
		int uStunde = Integer.parseInt(untergang.substring(0, untergang.indexOf(":")));
		int uMinute = Integer.parseInt(untergang.substring(untergang.indexOf(":")+1));
		
		// runden der stunden in abhängigkeit der minuten
		if(aMinute >30) aStunde +=1;
		if(uMinute >30) uStunde +=1;
		
		this.sonnenAufgang = aStunde;
		this.sonnenUntergang = uStunde;
		
		System.out.println("Aufgang " + this.sonnenAufgang + " Untergang "+ this.sonnenUntergang);
		
		

	}
		

	public String getCCData() {
		return CCData;
	}

	/**
	 * get time data

	 */
	public void getTime() {
		Element zeit = doc.getElementsByClass("contenthead").get(0);
		String zeitStart = zeit
				.text()
				.substring(zeit.text().indexOf("vom") + 3,
						zeit.text().indexOf("bis")).trim();

		String zeitEnde = zeit.text().substring(zeit.text().indexOf("bis") + 3)
				.trim();

		this.timeStart = zeitStart;
		this.timeEnd = zeitEnde;

	}

	/**
	 * Store all parsed data in a file containing
	 * 1. starting date + time from data set
	 * 2. end data + time from data set
	 * 3. actual weather data
	 * Where each data set is stored in a line
	 * 
	 * @param fileName Location of file
	 */
	public void writeData(String fileName) {
		Writer fw = null;
		try {
			fw = new FileWriter(fileName, true);

			fw.write("(" + this.timeStart + ") (" + this.timeEnd + ") "
					+ this.CCData);
			fw.append(System.getProperty("line.separator")); // neue zeile

		} catch (IOException e) {
			System.out.println("Fehler beim schreibe");
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
	 * Store only data used for encoding, this means that not all Cloud Cover data is stored
	 * but only the encoded data. This method for generating output data, which can be used for
	 * verifying the encoded data
	 * 1. Starttime of first Cloud Cover Value
	 * 2. Sunset
	 * 3. Sunrise
	 * 4. Cloud Cover Data
	 * @param fileName
	 */
	public void writeDebugData(String fileName, int numberOfData, int NightStart, int NightEnd, int time) {
		Writer fw = null;
		
		
		
		try {
			String usedData = this.CCData.substring(0, numberOfData*2);
			fw = new FileWriter(fileName, true);

			fw.write(time + "*" + NightStart + "*"+NightEnd+"*"
					+ usedData);
			fw.append(System.getProperty("line.separator")); // neue zeile

		} catch (IOException e) {
			System.out.println("Fehler beim schreiben");
		} finally {
			if (fw != null)
				try {
					fw.close();
				} catch (IOException e) {
					e.printStackTrace();
				}

		}
	}
//------------------------------Helper Methods-----------------------------------------------------------	
	public void setCCData(String cCData) {
		CCData = cCData;
	}

	public String getNthData(int n){
		return this.CCData.substring(0, n*2);
	}
	
	public int parseTime(String data){
		int start = data.indexOf(",");
		int ende = data.indexOf("Uhr");
		int result = Integer.parseInt(data.substring(start+1, ende).trim());
		return result;
		
	}
	

}
