package ca.dealsaccess.scout.sql.processor;

import java.sql.ResultSet;
import java.sql.SQLException;

public interface NoReturnedProcessor {

	void process(ResultSet rs) throws SQLException;
	
}
