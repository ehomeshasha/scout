package ca.dealsaccess.scout.analyzer;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.Map;
import java.util.regex.Pattern;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.mahout.common.iterator.FileLineIterable;
import org.apache.mahout.text.SequenceFilesFromDirectoryFilter;
import org.apache.mahout.utils.io.ChunkedWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Charsets;
import com.google.common.io.Closeables;

public class DealsAnalyzerFilter extends SequenceFilesFromDirectoryFilter {

	private static final Logger LOG = LoggerFactory.getLogger(DealsAnalyzerFilter.class);
	
	private StringBuilder key = new StringBuilder();
	
	private Pattern TAB = Pattern.compile("\t");
	
	public DealsAnalyzerFilter(Configuration conf, String keyPrefix, Map<String, String> options, ChunkedWriter writer,
			FileSystem fs) {
		this(conf, keyPrefix, options, writer, Charsets.UTF_8, fs);
	}
	
	
	public DealsAnalyzerFilter(Configuration conf,
            String keyPrefix,
            Map<String, String> options, 
            ChunkedWriter writer,
            Charset charset,
            FileSystem fs) {
		super(conf, keyPrefix, options, writer, charset, fs);
	}
	
//	
//	public DealsAnalyzerFilter(Configuration conf, String keyPrefix, Map<String, String> options, ChunkedWriter writer, Charset charset,
//			 FileSystem fs) {
//		super(conf, keyPrefix, options, writer, charset, fs);
//	}

	@Override
	protected void process(FileStatus fst, Path current) throws IOException {
		FileSystem fs = getFs();
		ChunkedWriter writer = getWriter();
		if (fst.isDir()) {
			if(fst.getPath().getName().equals("_logs") || fst.getPath().getName().equals("history")) {
				return;
			}
			String dirPath = getPrefix() + Path.SEPARATOR + current.getName() + Path.SEPARATOR
					+ fst.getPath().getName();
			fs.listStatus(fst.getPath(), new DealsAnalyzerFilter(getConf(), dirPath, getOptions(), writer, getCharset(),
					 fs));
		} else {
			if(fst.getPath().getName().equals("_SUCCESS")) {
				return;
			}
			String parentDir = fst.getPath().getParent().getName();
			LOG.info("Reading deals from {}", fst.getPath());
			
			InputStream in = null;
			try {
				in = fs.open(fst.getPath());
				
				for (String line : new FileLineIterable(in, getCharset(), false)) {
					String[] lineSplits = TAB.split(line);
					if(lineSplits.length < 2) {
						continue;
					}
					key.setLength(0);
					key.append(parentDir).append('#').append(lineSplits[0]);
					String text = AnalyzerUtils.getTokenedString(lineSplits[1]);
					writer.write(key.toString(), text);
				}
			} finally {
				Closeables.close(in, false);
			}
		}
	}

}
