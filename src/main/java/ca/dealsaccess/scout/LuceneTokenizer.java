package ca.dealsaccess.scout;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.en.EnglishAnalyzer;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.apache.lucene.analysis.util.CharArraySet;
import org.apache.lucene.util.Version;

import com.google.common.base.Strings;
import com.google.common.io.Files;

import ca.dealsaccess.scout.analyzer.DealsAnalyzer;
import ca.dealsaccess.scout.utils.JsonUtils;

import java.nio.charset.Charset;

public class LuceneTokenizer {
	
	private final String testFilePath = "dataset/dealsaccess-out-seqdir/lucene_test.txt";
	
	private final String stopwordsPath = "dataset/stopwords.txt";
	
	
	
	public static void main(String args[]) throws IOException {
		LuceneTokenizer l = new LuceneTokenizer();
		l.run();
	}

	private void run() throws IOException {
	
		//get stopwords
		Collection<String> stopwordsList = Files.readLines(new File(stopwordsPath), Charset.forName("UTF-8"));
		CharArraySet stopwordsSet = new CharArraySet(Version.LUCENE_CURRENT, stopwordsList, false);
		
		
		Analyzer analyzer = new DealsAnalyzer(Version.LUCENE_46, stopwordsSet);
		
		
		File file = new File(testFilePath);
		
		
		BufferedReader br = new BufferedReader(new FileReader(file));
		String line = null;
		while((line = br.readLine()) != null) {
			StringReader in = new StringReader(line);
			TokenStream ts = analyzer.tokenStream("deals", in);
			CharTermAttribute termAtt = ts.addAttribute(CharTermAttribute.class);
			
			ts.reset();
			List<String> list = new ArrayList<String>(); 
			while(ts.incrementToken()){
				String term = termAtt.toString();
				if(Strings.isNullOrEmpty(term)) {
					continue;
				}
				list.add(term);
			}
			JsonUtils.println(list);
			ts.end();
		    ts.close();
		}
		br.close();
		
		analyzer.close();
	}
	
	
}
