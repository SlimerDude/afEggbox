using afIoc
using afBedSheet
using afPillow

const class PodRoutes : Route {
	
	@Inject	private const UserSession	userSession
	@Inject	private const Pages	 		pages
	@Inject	private const RepoPodDao	podDao
	@Inject private const Backdoor		backdoor
	@Inject private const Registry		reg

	new make(|This|in) { in(this) }
	
	** Returns a hint at what this route matches on. Used for debugging and in 404 / 500 error pages. 
	override Str matchHint() { "GET - /pods/***" }

	** Returns a hint at what response this route returns. Used for debugging and in 404 / 500 error pages. 
	override Str responseHint() { "Pod Pages" }

	override Obj? match(HttpRequest httpReq) {
		reqPath := httpReq.url.pathOnly.path.rw
		pods	:= chomp(reqPath)
		if (pods != "pods")
			return null

		if (httpReq.httpMethod == "POST")
			return matchEvents(httpReq, reqPath)

		if (httpReq.httpMethod != "GET")
			return null

		podName		:= chomp(reqPath)
		if (podName == null)
			return pages.renderPage(PodsPage#)
		
		podVersion	:= Version((reqPath.isEmpty ? null : reqPath.first) ?: "", false)
		if (podVersion != null)	chomp(reqPath)
		podSection	:= chomp(reqPath)

		// --> /pods/afSlim/edit
		// --> /pods/afSlim/1.1.14/edit
		if (podSection == "edit" && reqPath.isEmpty) {
			if (!userSession.isLoggedIn && backdoor.isOpen)
				backdoor.login

			if (userSession.isLoggedIn) {
				pod := podDao.findOne(podName, podVersion)
				if (pod == null) {
					v := (podVersion != null) ? " v${podVersion}" : ""
					return HttpStatus(404, "Pod ${podName}${v} not found")
				}

				if (userSession.user.owns(pod)) 
					return pages.renderPage(PodEditPage#, [pod])
				throw HttpStatusErr(401, "Unauthorised")
			}
			throw ReProcessErr(Redirect.movedTemporarily(pages[LoginPage#].pageUrl))
		}

		fandocUri := FandocUri.fromClientUrl(reg, LinkResolverCtx(), httpReq.url)
		if (fandocUri == null)
			return null
		
		ctx := LinkResolverCtx(fandocUri.pod)
		if (fandocUri.validate(ctx, httpReq.url) == false) 
			return HttpStatus(404, ctx.invalidLinks.vals.first)
		
		if (fandocUri is FandocSummaryUri)
			return pages.renderPage(PodSummaryPage#, [fandocUri])

		if (fandocUri is FandocDocUri)
			// TODO: handle images and other files
			return pages.renderPage(PodDocPage#, [fandocUri])
		
		if (fandocUri is FandocSrcUri)
			return pages.renderPage(PodSrcPage#, [fandocUri])
		
		if (fandocUri is FandocApiUri)
			return (fandocUri as FandocApiUri).typeName == null
				? pages.renderPage(PodApiIndexPage#, [fandocUri])
				: pages.renderPage(PodApiPage#, [fandocUri])
		
		return null
	}

	
	Obj? matchEvents(HttpRequest httpReq, Str[] reqPath) {
		podName		:= chomp(reqPath)
		podVersion	:= Version((reqPath.isEmpty ? null : reqPath.first) ?: "", false)
		if (podVersion != null)	chomp(reqPath)
		podSection	:= chomp(reqPath)
		
		// --> /pods
		// --> /pods/
		if (podName == null)
			return null

		pod := podDao.findOne(podName, podVersion)
		if (pod == null) {
			v := (podVersion != null) ? " v${podVersion}" : ""
			return HttpStatus(404, "Pod ${podName}${v} not found")
		}
		
		podEvent	:= chomp(reqPath)
		
		// --> /pods/afSlim/edit/delete
		// --> /pods/afSlim/1.1.14/edit/delete
		if (podSection == "edit" && podEvent == "delete" && reqPath.isEmpty) {
			if (userSession.isLoggedIn) {
				if (userSession.user.owns(pod)) 
					return pages.callPageEvent(PodEditPage#, [pod], PodEditPage#onDelete, null)
				throw HttpStatusErr(401, "Unauthorised")
			}
			throw ReProcessErr(Redirect.movedTemporarily(pages[LoginPage#].pageUrl))
		}
		
		// --> /pods/afSlim/edit/save
		// --> /pods/afSlim/1.1.14/edit/save
		if (podSection == "edit" && podEvent == "save" && reqPath.isEmpty) {
			if (userSession.isLoggedIn) {
				if (userSession.user.owns(pod)) 
					return pages.callPageEvent(PodEditPage#, [pod], PodEditPage#onSave, null)
				throw HttpStatusErr(401, "Unauthorised")
			}
			throw ReProcessErr(Redirect.movedTemporarily(pages[LoginPage#].pageUrl))
		}
		
		return null
	}

	
	private Str? chomp(Str[] path) {
		path.isEmpty ? null : path.removeAt(0) 
	}
	
	private static const Int[] delims := ":/?#[]@\\".chars

	// Encode the Str *to* URI standard form
	// see http://fantom.org/sidewalk/topic/2357
	private static Str? encodeUri(Str? str) {
		if (str == null) return null
		buf := StrBuf(str.size + 8) // allow for 8 escapes
		str.chars.each |char| {
			if (delims.contains(char))
				buf.addChar('\\')
			buf.addChar(char)
		}
		return buf.toStr
	}
}
