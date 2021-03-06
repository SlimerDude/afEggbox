using afIoc
using afIocConfig
using afDuvet
using afEfanXtra
 
const mixin TopNavBarPrivate : PrComponent { 

	@Config
	@Inject abstract Bool			aboutFandocExists

	@InitRender
	Void init() {
//		injector.injectRequireModule("bootstrap")
	}
	
	Str pageLink(Type page, Str name) {
		html := (pageMeta.pageType == page) ? """<li class="active">""" : "<li>"
		html += """<a href="${pageUrl(page)}">${name}</a>"""
		html += "</li>"
		return html
	}

	Str userLink(Str name) {
		html := (pageMeta.pageType == UsersPage# && pageMeta.pageContext.first == loggedInUser.screenName) ? """<li class="active">""" : "<li>"
		html += loggedInUser.isAdmin ? """<a title="Admin User" href="${pageUrl(UsersPage#, [loggedInUser])}"><span class="text-danger">${name}</span></a>""" : """<a href="${pageUrl(UsersPage#, [loggedInUser])}">${name}</a>"""
		html += "</li>"
		return html
	}
	
	Str helpDdCss() {
		pageMeta.pageType.fits(PrHelpPage#) ? "active" : ""
	}
}
