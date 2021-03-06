using afIoc
using afBedSheet
using afFormBean
using afEfanXtra
using afPillow
using afSitemap

const mixin UsersPage : PrPage, SitemapSource {
	
	@Inject 		abstract RepoPodDao		podDao
	@Inject			abstract RepoUserDao	userDao
	@PageContext	abstract RepoUser		user
					abstract RepoPod[]		allPods
					abstract Int			countPublicVersions
					abstract Int			countPublicPods

	@BeforeRender
	Void beforeRender() {
		allPods = podDao.findLatestPods(user).exclude { it.isDeprecated }
		injector.injectRequireModule("rowLink")
		countPublicVersions = podDao.countVersions(user)
		countPublicPods		= podDao.countPods(user)
	}
	
	Str s(Int size) {
		size > 1 ? "s" : "" 
	}

	Str podSummaryUrl(RepoPod pod) {
		pod.toSummaryUri.toClientUrl.encode
	}

	Str podDocsHtml(RepoPod pod) {
		apiUri := pod.toSummaryUri.toApiUri
		docUri := pod.toSummaryUri.toDocUri
		if (pod.hasApi && pod.hasDocs)
			return "<a href=\"${apiUri.toClientUrl.encode}\">API</a> / <a href=\"${docUri.toClientUrl.encode}\">User Guide</a>" 
		if (pod.hasApi)
			return "<a href=\"${apiUri.toClientUrl.encode}\">API</a>" 
		if (pod.hasDocs)
			return "<a href=\"${docUri.toClientUrl.encode}\">User Guide</a>"
		return ""
	}

	override SitemapUrl[] sitemapUrls() {
		userDao.findAll.map |user| {
			SitemapUrl(bedServer.toAbsoluteUrl(Uri.decode(userUrl(user)))) {
				lastMod		= DateTime.boot
				changefreq	= SitemapFreq.yearly
				priority 	= 0.3f
			}
		}
	}
}
