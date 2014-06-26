package ca.dealsaccess.scout;

import java.util.regex.Pattern;

/**
 * Hello world!
 * 
 */
public class App {
	String url = "jdbc:mysql://localhost:3306/dealsaccess";
	String username = "foo_username";
	String passwd = "foo_password";

	private static final Pattern SLASH = Pattern.compile("/");
	
	public static void main(String[] args) throws ClassNotFoundException {
		App app = new App();
		app.testSlashSplit();
		//System.out.println("Hello World!");
		//System.out.println(Class.forName("ca.dealsaccess.scout.analyzer.DealsAnalyzerFilter").toString());
	}

	private void testSlashSplit() {
		String keyString = "/20news-bydate-test/alt.atheism/53315";
		String theLabel = SLASH.split(keyString)[1];
		System.out.println(theLabel);
	}

}
