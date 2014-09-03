package ca.dealsaccess.scout.analyzer;

import java.io.Reader;
import java.util.Set;
import java.util.regex.Pattern;

import org.apache.lucene.analysis.CharArraySet;
import org.apache.lucene.analysis.LowerCaseFilter;
import org.apache.lucene.analysis.PorterStemFilter;
import org.apache.lucene.analysis.StopAnalyzer;
import org.apache.lucene.analysis.StopFilter;
import org.apache.lucene.analysis.StopwordAnalyzerBase;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.Tokenizer;
//import org.apache.lucene.analysis.core.LowerCaseFilter;
//import org.apache.lucene.analysis.core.StopFilter;
import org.apache.lucene.analysis.en.EnglishPossessiveFilter;
//import org.apache.lucene.analysis.en.PorterStemFilter;
//import org.apache.lucene.analysis.miscellaneous.SetKeywordMarkerFilter;
//import org.apache.lucene.analysis.pattern.PatternReplaceFilter;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.analysis.standard.StandardFilter;
import org.apache.lucene.analysis.standard.StandardTokenizer;
//import org.apache.lucene.analysis.util.CharArraySet;
//import org.apache.lucene.analysis.util.StopwordAnalyzerBase;
import org.apache.lucene.util.Version;

public final class DealsAnalyzer extends StopwordAnalyzerBase {
	
	private final Pattern numbericPattern = Pattern.compile("\\d+.{0,1}\\d*?");
	
	private final CharArraySet stemExclusionSet;

	public static Set getDefaultStopSet() {
		return DefaultSetHolder.DEFAULT_STOP_SET;
	}

	private static class DefaultSetHolder {
		static final Set DEFAULT_STOP_SET = StopAnalyzer.ENGLISH_STOP_WORDS_SET;
	}

	public DealsAnalyzer(Version matchVersion) {
		this(matchVersion, DefaultSetHolder.DEFAULT_STOP_SET);
	}

	public DealsAnalyzer(Version matchVersion, Set stopwords) {
		this(matchVersion, stopwords, CharArraySet.EMPTY_SET);
	}

	public DealsAnalyzer(Version matchVersion, Set stopwords, CharArraySet stemExclusionSet) {
		super(matchVersion, stopwords);
		this.stemExclusionSet = CharArraySet.unmodifiableSet(CharArraySet.copy(matchVersion, stemExclusionSet));
	}

	@Override
	protected TokenStreamComponents createComponents(String fieldName, Reader reader) {
		final Tokenizer source = new StandardTokenizer(matchVersion, reader);
		TokenStream result = new StandardFilter(matchVersion, source);
		// prior to this we get the classic behavior, standardfilter does it for
		// us.
		if (matchVersion.onOrAfter(Version.LUCENE_31))
			result = new EnglishPossessiveFilter(matchVersion, result);
		result = new LowerCaseFilter(matchVersion, result);
		result = new StopFilter(matchVersion, result, stopwords);
		result = new PorterStemFilter(result);
		
		//result = new PatternReplaceFilter(result, numbericPattern, null, true);
                
		
		return new TokenStreamComponents(source, result);
	}
}
