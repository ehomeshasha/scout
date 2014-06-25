package ca.dealsaccess.scout.export;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Pattern;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.FileUtil;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.util.ToolRunner;
import org.apache.mahout.common.AbstractJob;
import org.apache.mahout.common.Pair;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileIterator;
import org.apache.mahout.math.Vector;
import org.apache.mahout.math.VectorWritable;
import org.apache.mahout.utils.vectors.VectorHelper;

import ca.dealsaccess.scout.sql.JdbcUtils;
import ca.dealsaccess.scout.sql.VO.Deals;
import ca.dealsaccess.scout.sql.handlers.NoReturnedHandler;
import ca.dealsaccess.scout.sql.processor.DumpDealsProcessor;
import ca.dealsaccess.scout.utils.JsonUtils;

import org.apache.hadoop.mapred.Utils.OutputFileUtils.OutputFilesFilter;

public class LabelDeals extends AbstractJob {
	
	private String jdbcurl;
	
	private String username;
	
	private String password;
	
	private final Pattern POUND = Pattern.compile("#");
	
	public static void main(String[] args) throws Exception {
		ToolRunner.run(new LabelDeals(), args);
	}

	@Override
	public int run(String[] args) throws Exception {

		addInputOption();
		addOption("docIndex", "d", "docIndex file path", true);
		addOption("jdbcurl", "jdbc", "jdbc url to access database", true);
		addOption("username", "un", "username to access database", true);
		addOption("password", "pwd", "password to access database", true);
		addOption("numLabels", "n", "number of labels for deals", false);

		if (parseArguments(args, true, false) == null) {
			return -1;
		}
		jdbcurl = getOption("jdbcurl");
		username = getOption("username");
		password = getOption("password");
		Connection conn = JdbcUtils.getConnection(jdbcurl, username, password);
		
		
		StringBuilder sb = new StringBuilder();
		Path[] pathArr;
		Path docIndexPath = new Path(getOption("docIndex"));
		Configuration conf = new Configuration();
		Path input = getInputPath();
		FileSystem fs = input.getFileSystem(conf);
		if (fs.getFileStatus(input).isDir()) {
			pathArr = FileUtil.stat2Paths(fs.listStatus(input, new OutputFilesFilter()));
		} else {
			pathArr = new Path[1];
			pathArr[0] = input;
		}
		int numLabels = 5;
		if(hasOption("numLabels")) {
			numLabels = Integer.parseInt(getOption("numLabels"));
		}

		try {
			for (Path path : pathArr) {

				SequenceFileIterator<IntWritable, VectorWritable> IndexTopicIterator = new SequenceFileIterator<IntWritable, VectorWritable>(
						path, true, conf);
				SequenceFileIterator<IntWritable, Text> docIndexIterator = new SequenceFileIterator<IntWritable, Text>(
						docIndexPath, true, conf);

				while (IndexTopicIterator.hasNext()) {
					Pair<IntWritable, VectorWritable> IndexTopicRecord = IndexTopicIterator.next();
					Pair<IntWritable, Text> docIndexRecord = docIndexIterator.next();
					String docString = docIndexRecord.getSecond().toString();
					Vector topicVector = IndexTopicRecord.getSecond().get();
					String topicVectorString = IndexTopicRecord.getSecond().toString();
					String[] docSplits = POUND.split(docString);
					if(docSplits.length < 2) {
						continue;
					}
					
					List<Pair<Integer, Double>> topics = VectorHelper.topEntries(topicVector, numLabels);
					sb.setLength(0);
					boolean flag = false;
					for(Pair<Integer, Double> topic : topics) {
						if (flag) {
							sb.append(",");
						}else {
							flag=true;
						}
						sb.append(topic.getFirst());
					}
					String tags = sb.toString();
					
					String dbName = docSplits[0];
					int id = Integer.parseInt(docSplits[1]);
					
					
					QueryRunner run = new QueryRunner();
					
					
					try {
						run.update(conn, "UPDATE `"+dbName+"` SET tags=?, docTopics=? WHERE id=?", tags, topicVectorString, id);
					} catch (SQLException e) {
						//ignore
						e.printStackTrace();
					}
				}
			}

		} finally {
			DbUtils.close(conn);
		}

		return 0;
	}
	
}
