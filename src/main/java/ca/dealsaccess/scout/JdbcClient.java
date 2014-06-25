package ca.dealsaccess.scout;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.mahout.common.AbstractJob;

import ca.dealsaccess.scout.sql.JdbcUtils;
import ca.dealsaccess.scout.sql.VO.Deals;
import ca.dealsaccess.scout.sql.handlers.NoReturnedHandler;
import ca.dealsaccess.scout.sql.processor.DumpDealsProcessor;
import ca.dealsaccess.scout.utils.JsonUtils;

public class JdbcClient extends AbstractJob {
	String url = "jdbc:mysql://localhost:3306/dealsaccess";
	String username = "foo_username";
	String passwd = "foo_password";
	String dumpDir = "dataset/dealsaccess-out";
	
	
	public static void main(String[] args) throws Exception {
		JsonUtils.println(args);
	    new JdbcClient().run(args);
	  }
	@Override
	public int run(String[] args) throws Exception {
		
		JsonUtils.println(args);
		
		
		addInputOption();
	    addOutputOption();
	    addOption("username", "un", "Username", false);
	    
	    if (parseArguments(args) == null) {
	      return -1;
	    }
	    String username = null;
	    if (hasOption("username")) {
            username = getOption("username");
            
        }
		
		System.out.println(username);
		
		
		
		
		
		
		
		
		
		
		return 0;
	}
	/*
	public static void main(String[] args) throws SQLException {
		JdbcClient client = new JdbcClient();
		client.run();

	}
	*/
	private void run() throws SQLException {
		Connection conn = JdbcUtils.getConnection(url, username, passwd);
		/*
		ResultSetHandler<Object[]> h = new ResultSetHandler<Object[]>() {
			public Object[] handle(ResultSet rs) throws SQLException {
				/*
				if (!rs.next()) { 
					return null; 
				}
				
				ResultSetMetaData meta = rs.getMetaData(); 
				int cols = meta.getColumnCount(); 
				Object[] result = new Object[cols];
				System.out.println(cols);
				
				
				for (int i = 0; i < cols; i++) { 
					result[i] = rs.getObject(i + 1); 
				}
				*/
			/*	
				ResultSetMetaData meta = rs.getMetaData();
				int cols = meta.getColumnCount();

				List<String[]> dataList = new LinkedList<String[]>();
				while (rs.next()) {
					String[] rowArray = new String[cols];
					for (int i = 0; i < cols; i++) {
						rowArray[i] = rs.getString(i + 1);
					}
					dataList.add(rowArray);
				}

				Object[] result = dataList.toArray();
				
				return result;
			}
		};
		*/
		
		ResultSetHandler<Object> h = new NoReturnedHandler<Object>(new DumpDealsProcessor());
		
		
		//ResultSetHandler<List<Deals>> h = new BeanListHandler<Deals>(Deals.class);
		QueryRunner run = new QueryRunner();

		try {
			Object result = run.query(conn,
					"SELECT subject, starttime FROM dw_sdb_deal WHERE 1 ORDER BY starttime DESC LIMIT 10", h);
			JsonUtils.println(result);
			// do something with the result
			//System.out.println(result.length);
			//for (Object o : result) {
			//	JsonUtils.println(o);
			//}

		} finally {
			// Use this helper method so we don't have to check for null
			DbUtils.close(conn);
		}

	}
}
