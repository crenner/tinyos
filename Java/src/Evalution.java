import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
/**
 * Evaluation Class for comparing the performance in terms of compression size.
 * V2, LZW and Golomb Rice kompression and no compression are compared 
 * @author anh tuan nguyen
 *
 */
public class Evalution {
	int nov = 24;
	int reso = 0;
	String name = "";
	String file = "";

	public Evalution() {

	}

	/**
	 *  Ergebnisse werden in eine Textdatei geschrieben
	 * @param line
	 * @param time
	 * @param NightStart
	 * @param NightEnd
	 * @param code1
	 * @param code2
	 * @param code3
	 * @param db
	 * @param code4
	 */
	public void wirteEvaluation(int line, int time, int NightStart,
			int NightEnd, int code1, int code2, int code3, int db, int code4) {
		Writer fw = null;

		try {
			fw = new FileWriter(name, true);
			fw.write(line + " " + time + " " + NightStart + " " + NightEnd
					+ " " + code1 + " " + code2 + " " + code3 + " " + db + " "
					+ code4);
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

	/**
	 * nützliche methode um mehrer Dateien nacheinander einzulesen
	 * @param random
	 * @throws IOException
	 */
	public void startWrapper(boolean random) throws IOException {
		for (int i = 1; i <= 14; i++) {
			nov = 12 * i;
			name = "Nev" + nov + ".log";
			file = "NTest" + nov + ".txt";
			start(random);
		}
	}

	// liest dateien ein und komprimiert sie
	private void start(boolean random) throws IOException {
		FileReader fr = new FileReader(file);
		BufferedReader br = new BufferedReader(fr);
		Encode encoder = new Encode();
		LZW lzw = new LZW();
		int hour = -1; // aktuelle Stunde
		String zeile = br.readLine();
		int nr = 1;

		// parameter einlesen
		try {
			encoder.parseParameter("Parameter.txt");
		} catch (IOException e) {
			System.out.println("Fehler: Benutze default parameter");
			encoder.setDefaultParameter();
		}

		while (zeile != null) {
			if (zeile.equals("")) {
				zeile = br.readLine();
				continue;
			}

			// Code Teil für Random Data
			if (random == true) {
				int numberOfValues = Integer.parseInt(zeile.substring(0,
						zeile.indexOf(" ")));
				zeile = zeile.substring(zeile.indexOf("*") + 1);
				int nightStart = Integer.parseInt(zeile.substring(0,
						zeile.indexOf("*")));
				zeile = zeile.substring(zeile.indexOf("*") + 1);
				int nightEnd = Integer.parseInt(zeile.substring(0,
						zeile.indexOf("*")));
				zeile = zeile.substring(zeile.indexOf("*") + 1);

				encoder.setNumberOfValues(numberOfValues);
				encoder.setNightStart(nightStart);
				encoder.setNightEnd(nightEnd);
			} else {
				int nightEnd = Integer.parseInt(zeile.substring(0,
						zeile.indexOf(",")));
				zeile = zeile.substring(zeile.indexOf(",") + 1);
				int nightStart = Integer.parseInt(zeile.substring(0,
						zeile.indexOf(",")));
				zeile = zeile.substring(zeile.indexOf(",") + 1);
				encoder.setNightStart(nightStart);
				encoder.setNightEnd(nightEnd);
				encoder.setNumberOfValues(nov);
				encoder.setResolution(reso);
			}
			// Code Teil für Random Data ende
			encoder.setOriginalData(zeile);

			hour = (hour + 1) % 24;
			// Schreibe debug Datei

			// V0 KODIERUNG
			encoder.setHour(hour); // aktuelle Stunde einstellen
			encoder.encodeV2(0);
			short v0[] = encoder.getData();
			String v0Res = encoder.result;

			// GOLOMB RICE
			encoder.setHour(hour); // aktuelle Stunde einstellen
			encoder.encodeGolombRice();
			short gr[] = encoder.getData();
			String grRes = encoder.result;

			// UNKOMPRIMIERT
			encoder.setHour(hour);
			encoder.getUnencoded();
			short naiv[] = encoder.getData();
			String naivRes = encoder.result;

			// LZW
			String lzwRes = lzw.compressNew(naivRes, nov);
			this.wirteEvaluation(nr, hour, encoder.getNightStart(),
					encoder.getNightEnd(), v0.length, naiv.length,
					lzw.getByteSize(), lzw.getDBSize(), gr.length);

			// debug
			System.out.print("\nNachtframes: ");
			int[] nD = encoder.getNightSlot(encoder.getNumberOfValues(), hour);
			for (int i = 0; i < nD.length; i++)
				System.out.print(nD[i] + " "); // debug
			System.out.print("\n");

			System.out.print("Org Data ");
			int[] orgData = encoder.parseString(encoder.getOriginalData());
			for (int j = 0; j < orgData.length; j++) {
				System.out.print(orgData[j] + " ");
			}
			System.out.print("\n");

			System.out.print("Res Data ");
			int[] resData = encoder.applyResolution(reso, orgData);

			for (int j = 0; j < resData.length; j++) {
				System.out.print(resData[j] + " ");
			}
			System.out.print("\n");

			int[] resNight = encoder.getNightSlotImp(nov, hour, reso);
			System.out.print("Res Nght ");
			for (int j = 0; j < resNight.length; j++) {
				System.out.print(resNight[j] + " ");
			}
			System.out.print("\n");

			System.out
					.print("Zeile: " + nr + " Anzahl: "
							+ (encoder.getNumberOfValues() / 12 - 1) + " NS: "
							+ encoder.getNightStart() + " NE: "
							+ encoder.getNightEnd());
			System.out.print(" Zeit: " + hour + "\n");
			System.out.println("Encode " + v0.length + " v0: " + v0Res);
			System.out.println("Encode " + naiv.length + " RAW: " + naivRes);
			System.out.println("Encode " + gr.length + " Rice: " + grRes);
			System.out.println("Encode " + lzw.getByteSize() + ","
					+ lzw.getDBSize() + " LZW: " + lzwRes);
			nr++;

			zeile = br.readLine();
		}

		br.close();
	}

}
