using afIoc
using afBedSheet
using afEfanXtra
using afPillow
using afGoogleAnalytics::GoogleAnalytics

@Page
const mixin PodsIndexPage : PrPage {
		// TODO move this out to AppConfig
		// limit the potentially massive list of tags to just those wanted ones
		const static Str[] 				coreTags := "app database misc system templating testing web".split

	@Inject abstract Registry			registry
	@Inject abstract RepoPodDao			podDao
	@Inject abstract HttpResponse		httpResponse
	@Inject	abstract EggboxConfig		eggboxConfig
	@Inject	abstract GoogleAnalytics	googleAnalytics
			abstract RepoPod[]			allPods
			abstract Int				countPublicPods
			abstract Bool				sortByName
			abstract Str[]				allTags

	@InitRender
	Void initRender() {
		sortByName	= httpRequest.url.query.containsKey("sortByName")
		allPods	= podDao.findLatestPods.exclude { it.isDeprecated }
		if (sortByName)
			allPods = allPods.sort(RepoPodDao.byProjName)
		else
			allPods = allPods.sortr(RepoPodDao.byBuildDate)
		allTags = allPods.map { it.meta.tags }.flatten.unique.sort
		
		injector.injectRequireModule("podFiltering")
		
		// with all the params flying around on this page, ensure Google only indexes the main version
		// see https://support.google.com/webmasters/answer/139066
		canonicalUrl := bedServer.toAbsoluteUrl(pageMeta.pageUrl)
		httpResponse.headers["Link"] = "<${canonicalUrl.encode}>; rel=\"canonical\""
		injector.injectLink.fromExternalUrl(canonicalUrl).withRel("canonical")
		
		if (eggboxConfig.googleAnalyticsEnabled)
			googleAnalytics.renderPageView(pageMeta.pageUrl)
	}
	
	Str nameActive() {
		sortByName ? "active" : ""
	}
	
	Str dateActive() {
		sortByName ? "" : "active"
	}	
}
