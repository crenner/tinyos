import java.util.LinkedList;

public class LZW {

	final public static int BIT = 6; // Anzahl der Bits
	LinkedList<String> database;
	int bL;

	public int getDBSize() {
		return this.database.size();
	}

	public int getByteSize() {
		double bitLength = Math.ceil((Math.log(this.database.size()) / Math
				.log(2)));
		double result = Math.ceil((((double) bL * bitLength) / 8.0));
		return (int) result;
	}

	void initilizeDatabase() {
		database = new LinkedList<String>();
		/*
		 * database.add("0"); database.add("1"); database.add("10");
		 * database.add("11"); database.add("01"); database.add("00");
		 */
		database.add("10000");
		database.add("10001");
		database.add("10010");
		database.add("10011");
		database.add("10100");
		database.add("10101");
		database.add("10110");
		database.add("10111");
		database.add("11000");

		database.add("00000");
		database.add("00001");
		database.add("00010");
		database.add("00011");
		database.add("00100");
		database.add("00101");
		database.add("00110");
		database.add("00111");
		database.add("01000");
		/*
		 * database.add("00000"); database.add("00001"); database.add("00010");
		 * database.add("00011"); database.add("00100"); database.add("00101");
		 */
	}

	private String getChar(String text, int index) {
		String result = "";
		index = index * 5;
		if (index + 5 - 1 >= text.length())
			return "";
		for (int i = 0; i < 5; i++) {
			result += "" + text.charAt(index + i);
		}
		return result;
	}

	String compressNew(String text, int nov) {
		int counter = 0;
		String output = "";
		String current = "";
		String next = "";
		String curr = "";
		initilizeDatabase();
		boolean isNext = false;
		for (int i = 0; i < nov; i++) {
			// 1. Hole zeichen
			current = getChar(text, i);
			next = getChar(text, i + 1);

			// 2. Suche Database ab
			if (!isNext) { // neue suche
				curr = current + "" + next;
				// System.out.println("Neue Suche nach " + curr);
				// Suche nach Wörterbucheintrag
				if (getindex(curr) == -1) { // existiert nicht
					database.add(curr);
					output += " " + getindex(current);
					counter++;
					// System.out.println("Nicht gefunden. Füge als Eintrag " +
					// (database.size()-1) +" hinzu und gebe " +
					// getindex(current) +" aus" );
					isNext = false;
					curr = "";
				} else { // eintrag existiert
					isNext = true;// suche weiter
					// System.out.println("Gefunden. als Eintrag " +
					// getindex(curr));
				}

			} else {// Wenn suche fortgesetzt wird
				String temp = curr;
				curr += next;
				// System.out.println("Fortgesetzte Suche nach " + curr);
				if (getindex(curr) == -1) { // existiert nicht
					database.add(curr);
					output += " " + getindex(temp);
					counter++;
					// System.out.println("Nicht gefunden. Füge als Eintrag " +
					// (database.size()-1) +" hinzu und gebe " + getindex(temp)
					// +" aus" );
					isNext = false;
					curr = "";
				} else { // eintrag existiert
					isNext = true;// suche nochmal weiter
					// System.out.println("Nochmal gefunden. als Eintrag " +
					// getindex(curr));
				}
			}
			// System.out.println("");
		}

		// Randbetrachtung
		if (!curr.equals("")) {
			// System.out.println("Rand Betrachtung");
			if (getindex(curr) == -1) { // existiert nicht
				database.add(curr);
				// System.out.println("Nicht gefunden. Füge als Eintrag " +
				// (database.size()-1) +" hinzu und gebe " + getindex(curr)
				// +" aus" );
				output += " " + (database.size() - 1);
			} else { // eintrag existiert
				output += " " + getindex(curr);
				// System.out.println("Gebe als " + getindex(curr) +" aus" );
				counter++;
			}
		}

		bL = counter;
		return (int) counter + ": " + database.size() + ": " + output;
	}

	String compress(String text) {
		int i = 0;
		int counter = 0;
		String output = "";
		String current = "";
		String next = "";
		String curr = "";
		initilizeDatabase();
		boolean isNext = false;
		while (i < text.length()) {
			// 1. Hole zeichen
			current = "" + text.charAt(i);
			next = "";
			if (i < text.length() - 1)
				next = "" + text.charAt(i + 1);

			// 2. Suche Database ab
			if (!isNext) { // neue suche
				curr = current + "" + next;
				// System.out.println("Neue Suche nach " + curr);
				// Suche nach Wörterbucheintrag
				if (getindex(curr) == -1) { // existiert nicht
					database.add(curr);
					output += " " + getindex(current);
					counter++;
					// System.out.println("Nicht gefunden. Füge als Eintrag " +
					// (database.size()-1) +" hinzu und gebe " +
					// getindex(current) +" aus" );
					isNext = false;
					curr = "";
				} else { // eintrag existiert
					isNext = true;// suche weiter
					// System.out.println("Gefunden. als Eintrag " +
					// getindex(curr));
				}

			} else {// Wenn suche fortgesetzt wird
				String temp = curr;
				curr += next;
				// System.out.println("Fortgesetzte Suche nach " + curr);
				if (getindex(curr) == -1) { // existiert nicht
					database.add(curr);
					output += " " + getindex(temp);
					counter++;
					// System.out.println("Nicht gefunden. Füge als Eintrag " +
					// (database.size()-1) +" hinzu und gebe " + getindex(temp)
					// +" aus" );
					isNext = false;
					curr = "";
				} else { // eintrag existiert
					isNext = true;// suche nochmal weiter
					// System.out.println("Nochmal gefunden. als Eintrag " +
					// getindex(curr));
				}
			}
			// System.out.println("");

			i++;
		}

		// Randbetrachtung
		if (!curr.equals("")) {
			// System.out.println("Rand Betrachtung");
			if (getindex(curr) == -1) { // existiert nicht
				database.add(curr);
				// System.out.println("Nicht gefunden. Füge als Eintrag " +
				// (database.size()-1) +" hinzu und gebe " + getindex(curr)
				// +" aus" );
				output += " " + (database.size() - 1);
			} else { // eintrag existiert
				output += " " + getindex(curr);
				// System.out.println("Gebe als " + getindex(curr) +" aus" );
				counter++;
			}
		}

		bL = counter;
		return (int) counter + ": " + database.size() + ": " + output;
	}

	int getindex(String entry) {
		// Suche ob string schon vorhanden ist
		for (int i = 0; i < database.size(); i++) {
			if (database.get(i).equals(entry))
				return i;
		}
		return -1; // neues element ist das letzte Element
	}

}
