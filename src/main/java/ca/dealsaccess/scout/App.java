package ca.dealsaccess.scout;

/**
 * Hello world!
 * 
 */
public class App {
	String url = "jdbc:mysql://localhost:3306/dealsaccess";
	String username = "foo_username";
	String passwd = "foo_password";

	public static void main(String[] args) throws ClassNotFoundException {
		System.out.println("Hello World!");
		System.out.println(Class.forName("ca.dealsaccess.scout.analyzer.DealsAnalyzerFilter").toString());
	}

}
