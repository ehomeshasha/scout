package ca.dealsaccess.scout.analyzer;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.apache.lucene.analysis.util.CharArraySet;
import org.apache.lucene.util.Version;

import ca.dealsaccess.scout.utils.JsonUtils;

import com.google.common.base.Strings;
import com.google.common.io.Files;

public class AnalyzerUtils {
	
	private static final String STOPWORDS_PATH = "ca.dealsaccess.scout.StopwordsPath";
	
	private static final String DEFAULT_STOPWORDS_PATH = "conf/stopwords.txt";
	
	private static String stopwordsPath;
	
	private static Analyzer analyzer;
	
	private static StringBuilder tokenedString = new StringBuilder();
	
	static {
		stopwordsPath = System.getProperty(STOPWORDS_PATH);
		if(stopwordsPath == null) {
			stopwordsPath = DEFAULT_STOPWORDS_PATH;
		}
		try {
			Collection<String> stopwordsList = Files.readLines(new File(stopwordsPath), Charset.forName("UTF-8"));
			CharArraySet stopwordsSet = new CharArraySet(Version.LUCENE_CURRENT, stopwordsList, false);
			analyzer = new DealsAnalyzer(Version.LUCENE_46, stopwordsSet);
		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
	
	public static final String getTokenedString(String input) throws IOException {
		tokenedString.setLength(0);
		StringReader in = new StringReader(input);
		TokenStream ts = analyzer.tokenStream("deals", in);
		CharTermAttribute termAtt = ts.addAttribute(CharTermAttribute.class);
		
		ts.reset();
		 
		while(ts.incrementToken()){
			String term = termAtt.toString();
			if(Strings.isNullOrEmpty(term)) {
				continue;
			}
			tokenedString.append(term).append(' ');
		}
		
		ts.end();
	    ts.close();
	    
	    return tokenedString.toString();
	}
	
	
}
