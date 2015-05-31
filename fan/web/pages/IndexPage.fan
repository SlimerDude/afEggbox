using afIoc
using afIocConfig
using afBedSheet
using afDuvet
using afEfanXtra

const mixin IndexPage : PrPage {

	@Inject abstract BedSheetServer	bedServer
	
	@InitRender
	Void initRender() {
	}
	
	** Need to wait until *after* layout has rendered to find the HTML tag.
	@AfterRender
	Void afterRender(StrBuf buf) {
		htmlIndex	:= buf.toStr.index("<html ") + "<html ".size
//		absImgUrl	:= bedServer.toAbsoluteUrl(fileHandler.fromLocalUrl(`/images/index/fantomFactory.ogimage.png`).clientUrl)

		// ---- Open Graph Meta ---- Mandatory
		buf.insert(htmlIndex, "prefix=\"og: http://ogp.me/ns#\" ")
		injector.injectMeta.withProperty("og:type"	).withContent("website")
		injector.injectMeta.withProperty("og:title"	).withContent("Fantom Pod Repository")
		injector.injectMeta.withProperty("og:url"	).withContent(bedServer.host.encode)
		// TODO: website ogimage
//		injector.injectMeta.withProperty("og:image"	).withContent(absImgUrl.encode)
		
		// ---- Open Graph Meta ---- Optional
		injector.injectMeta.withProperty("og:description"	).withContent("3rd Party Libraries for the Fantom programming language")
		injector.injectMeta.withProperty("og:locale"		).withContent("en_GB")
		injector.injectMeta.withProperty("og:site_name"		).withContent("Fantom Pod Repository")
	}	
}
