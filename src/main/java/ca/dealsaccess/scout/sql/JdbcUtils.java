package ca.dealsaccess.scout.sql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class JdbcUtils {

	static {
		try {
			Class.forName("com.mysql.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			
		}
	}
	
	public static Connection getConnection(String url, String username, String passwd) throws SQLException {
		return DriverManager.getConnection(url, username, passwd);
	}
}
