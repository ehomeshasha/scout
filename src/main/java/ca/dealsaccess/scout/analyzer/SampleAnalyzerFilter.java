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

import com.google.common.io.Closeables;

public class SampleAnalyzerFilter extends SequenceFilesFromDirectoryFilter {

	private static final Logger LOG = LoggerFactory.getLogger(SampleAnalyzerFilter.class);
	
	private StringBuilder key = new StringBuilder();
	
	public SampleAnalyzerFilter(Configuration conf, String keyPrefix, Map<String, String> options, ChunkedWriter writer,
			Charset charset, FileSystem fs) {
		super(conf, keyPrefix, options, writer, charset, fs);
	}

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
			fs.listStatus(fst.getPath(), new SampleAnalyzerFilter(getConf(), dirPath, getOptions(), writer,
					getCharset(), fs));
		} else {
			if(fst.getPath().getName().equals("_SUCCESS")) {
				return;
			}
			String parentDir = fst.getPath().getParent().getName();
			LOG.info("Reading sample from {}", fst.getPath());
			
			InputStream in = null;
			try {
				in = fs.open(fst.getPath());
				
				key.setLength(0);
				for (String line : new FileLineIterable(in, getCharset(), false)) {
					key.append(line).append(" ");
				}
				String text = AnalyzerUtils.getTokenedString(key.toString());
				writer.write(parentDir, text);
				
			} finally {
				Closeables.close(in, false);
			}
		}
	}

}
