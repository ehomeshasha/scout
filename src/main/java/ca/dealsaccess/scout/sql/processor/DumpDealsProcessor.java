package ca.dealsaccess.scout.sql.processor;

import java.sql.ResultSet;
import java.sql.SQLException;

public class DumpDealsProcessor implements NoReturnedProcessor {

	public DumpDealsProcessor() {
		
	}
	
	
	
	
	
	
	@Override
	public void process(ResultSet rs) throws SQLException {
		if (!rs.next()) {
            return;
        }

		do {
            processRow(rs);
        } while (rs.next());

		
	}

	private void processRow(ResultSet rs) throws SQLException {
		System.out.println(rs.getString(1));
		
	}

	
		
	

}
