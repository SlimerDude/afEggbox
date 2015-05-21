using afIoc
using afBedSheet
using afEfanXtra
using afPillow

@Page { disableRoutes = true }
const mixin PodSummaryPage : PrPage {

	@PageContext	abstract FandocSummaryUri	fandocUri
	
		// TODO: seo this page!
	
	RepoPod pod() {
		fandocUri.pod
	}

	Str aboutHtml() {
		fandocUri.aboutHtml
	}

	Str editUrl() {
		fandocUri.toClientUrl.plusSlash.plusName("edit").encode
	}

	Str apiUrl() {
		// FIXME: check if pod has API
		fandocUri.toClientUrl.plusSlash.plusName("api").encode
	}
	
	Str docUrl() {
		// FIXME: check if pod has pod docs
		fandocUri.toClientUrl.plusSlash.plusName("doc").encode
	}
	
}
