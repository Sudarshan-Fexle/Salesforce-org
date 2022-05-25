public with sharing class IntranetWordpressSearch {
	private static String mPortalSearchUrl;

	public static String PortalSearchUrl {
		get {
			if(mPortalSearchUrl == null) {
				mPortalSearchUrl = IntranetHomeUtility.LookupIntranetSetting('PortalSearchUrl');
			}

			return mPortalSearchUrl;
		}
	}

	public static List<SearchResultInfo> search(string term) {
		List<SearchResultInfo> searchResult = new List<SearchResultInfo>();

		HTTPRequest req = new HttpRequest();
		req.setTimeout(120000);
		req.setEndpoint(PortalSearchUrl + EncodingUtil.urlEncode(term, 'UTF-8'));
		req.setMethod('GET');
		HTTP http = new HTTP();
		//send the callout and return the response body
		HTTPResponse res = http.send(req);

		String jsonBody = res.getBody();
		// Verify the response
		List<Object> results = (List<Object>) JSON.deserializeUntyped(jsonBody);

		for(Object row : results) {
			Map<String, Object> result = (Map<String, Object>) row;
			SearchResultInfo info = new SearchResultInfo();
			info.PostTitle = String.valueOf(result.get('post-title')).unescapeHtml3();
			info.Permalink = String.valueOf(result.get('permalink'));
			info.PostContent = Cleanup(String.valueOf(result.get('post-content')));
			info.Site = String.valueOf(result.get('site'));
			SearchResult.add(info);
		}

		return searchResult;
	}

	private static String Cleanup(String input) {
		input = input.unescapeHtml3().unescapeHtml3();
		input = input.replace('[&hellip;]', '...');
		input = input.replaceAll('\\[[^\\]]+\\]', '');
		return input.replaceAll('\\[[^\\]]+\\.\\.\\.\\z', '...');
	}

	public class SearchResultInfo {
		public string PostTitle { get; set; }
		public string Permalink { get; set; }
		public string PostContent { get; set; }
		public string Site { get; set; }
	}
}