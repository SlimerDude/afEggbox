using afIoc
using afEfanXtra
using afPillow

@Page { disableRoutes = true }
const mixin PodsPage : PrPage {

	@Inject abstract RepoPodDao		podDao
			abstract RepoPod[]		allPods

	@InitRender
	Void initRender() {
		allPods = podDao.findPublic(userSession.user)
		injector.injectRequireModule("fileInput")
	}
	
	Str downloads(Obj o) {
		""
	}
}