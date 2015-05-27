using afIoc
using afFancordion

** Fandoc URI
** ##########
** 
**   table:
**   col[0]+exe:parseFandocUri(#TEXT)
**   col[1]+eq:fandocUri
**   col[2]+eq:clientUrl
** 
**   Fandoc URI In                  Fandoc URI Out                 Client URL Out                
**   -----------------------------  -----------------------------  -------------------------
**   fandoc:/foo/                   fandoc:/foo/?v=2.0             /pods/foo/            
**   fandoc:/foo/api/               fandoc:/foo/api/?v=2.0         /pods/foo/api/        
**   fandoc:/foo/api/Bar            fandoc:/foo/api/Bar?v=2.0      /pods/foo/api/Bar     
**   fandoc:/foo/api/Bar/src        fandoc:/foo/api/Bar/src?v=2.0  /pods/foo/api/Bar/src 
**   fandoc:/foo/api/Bar#poo        fandoc:/foo/api/Bar?v=2.0#poo  /pods/foo/api/Bar#poo 
**   fandoc:/foo/doc/               fandoc:/foo/doc/?v=2.0         /pods/foo/doc/        
**   fandoc:/foo/doc/foo            fandoc:/foo/doc/foo?v=2.0      /pods/foo/doc/foo 
**   fandoc:/foo/doc/bar.txt        fandoc:/foo/doc/bar.txt?v=2.0  /pods/foo/doc/bar.txt 
**   fandoc:/foo/?v=1.0             fandoc:/foo/?v=1.0             /pods/foo/1.0/            
**   fandoc:/foo/api/?v=1.0         fandoc:/foo/api/?v=1.0         /pods/foo/1.0/api/        
**   fandoc:/foo/api/Bar?v=1.0      fandoc:/foo/api/Bar?v=1.0      /pods/foo/1.0/api/Bar     
**   fandoc:/foo/api/Bar/src?v=1.0  fandoc:/foo/api/Bar/src?v=1.0  /pods/foo/1.0/api/Bar/src 
**   fandoc:/foo/api/Bar#poo?v=1.0  fandoc:/foo/api/Bar?v=1.0#poo  /pods/foo/1.0/api/Bar#poo 
**   fandoc:/foo/doc/?v=1.0         fandoc:/foo/doc/?v=1.0         /pods/foo/1.0/doc/        
**   fandoc:/foo/doc/foo?v=1.0      fandoc:/foo/doc/foo?v=1.0      /pods/foo/1.0/doc/foo     
**   fandoc:/foo/doc/bar.txt?v=1.0  fandoc:/foo/doc/bar.txt?v=1.0  /pods/foo/1.0/doc/bar.txt 
** 
** Pod Version at the end, in a query string, in fandoc schemes because linking to a specific version usually is just an afterthought.
** 
**   table:
**   col[0]+exe:parseClientUrl(#TEXT)
**   col[1]+eq:fandocUri
** 
**   Client URL In                  Fandoc URI Out
**   -----------------------------  ------------------------------
**   /pods/foo/                     fandoc:/foo/?v=2.0
**   /pods/foo/api/                 fandoc:/foo/api/?v=2.0
**   /pods/foo/api/Bar              fandoc:/foo/api/Bar?v=2.0
**   /pods/foo/api/Bar/src          fandoc:/foo/api/Bar/src?v=2.0
**   /pods/foo/api/Bar#poo          fandoc:/foo/api/Bar?v=2.0#poo
**   /pods/foo/doc/                 fandoc:/foo/doc/?v=2.0
**   /pods/foo/doc/foo              fandoc:/foo/doc/foo?v=2.0
**   /pods/foo/doc/bar.txt          fandoc:/foo/doc/bar.txt?v=2.0
**   /pods/foo/1.0/                 fandoc:/foo/?v=1.0
**   /pods/foo/1.0/api/             fandoc:/foo/api/?v=1.0
**   /pods/foo/1.0/api/Bar          fandoc:/foo/api/Bar?v=1.0
**   /pods/foo/1.0/api/Bar/src      fandoc:/foo/api/Bar/src?v=1.0
**   /pods/foo/1.0/api/Bar#poo      fandoc:/foo/api/Bar?v=1.0#poo
**   /pods/foo/1.0/doc/             fandoc:/foo/doc/?v=1.0
**   /pods/foo/1.0/doc/foo          fandoc:/foo/doc/foo?v=1.0
**   /pods/foo/1.0/doc/bar.txt      fandoc:/foo/doc/bar.txt?v=1.0
**
** . 
** 
**   table:
**   col[0]+exe:parseFantomUri(#TEXT)
**   col[1]+eq:fandocUri
** 
**   Fantom URI In                  Fandoc URI Out
**   -----------------------------  ------------------------------
**   foo::index                     fandoc:/foo/?v=2.0
**   foo::pod-doc                   fandoc:/foo/doc/?v=2.0
**   foo::Bar                       fandoc:/foo/api/Bar?v=2.0
**   foo::Bar.poo                   fandoc:/foo/api/Bar?v=2.0#poo
**   foo::foo                       fandoc:/foo/doc/foo?v=2.0
**   foo::foo#frag                  fandoc:/foo/doc/foo?v=2.0#frag
**   foo::src-Bar                   fandoc:/foo/api/Bar/src?v=2.0
**   Bar                            fandoc:/foo/api/Bar?v=2.0
**   Bar.poo                        fandoc:/foo/api/Bar?v=2.0#poo
**   poo                            fandoc:/foo/api/Bar?v=2.0#poo
**   foo                            fandoc:/foo/doc/foo?v=2.0
**   src-Bar                        fandoc:/foo/api/Bar/src?v=2.0
**   foo#frag                       fandoc:/foo/doc/foo?v=2.0#frag
**   bar.txt                        fandoc:/foo/doc/bar.txt?v=2.0
**
** .
**  
**   table:
**   col[0]+exe:parseFandocUri(#TEXT)
**   col[1]+eq:clientUrl
** 
**   Fandoc URI In                       Client URL Out
**   -----------------------------       ------------------------------
**   fandoc:/sys/                        http://fantom.org/doc/sys/index.html
**   fandoc:/sys/api/                    http://fantom.org/doc/sys/index.html
**   fandoc:/sys/api/Uri                 http://fantom.org/doc/sys/Uri.html
**   fandoc:/sys/api/Uri/src             http://fantom.org/doc/sys/src-Uri.fan
**   fandoc:/sys/api/Uri#frag            http://fantom.org/doc/sys/Uri.html#frag
**   fandoc:/docLang/doc/                http://fantom.org/doc/docLang/index.html
**   fandoc:/docLang/doc/Slots           http://fantom.org/doc/docLang/Slots.html
**   fandoc:/docLang/doc/deployment.png  http://fantom.org/doc/docLang/deployment.png
** 
** .
**  
**   table:
**   col[0]+exe:parseFantomUri(#TEXT)
**   col[1]+eq:clientUrl
** 
**   Fantom URI In                       Client URL Out
**   -----------------------------       ------------------------------
**   sys::index                          http://fantom.org/doc/sys/index.html
**   sys::Uri                            http://fantom.org/doc/sys/Uri.html
**   sys::src-Uri                        http://fantom.org/doc/sys/src-Uri.fan
**   sys::Uri.frag                       http://fantom.org/doc/sys/Uri.html#frag
**   docLang::pod-doc                    http://fantom.org/doc/docLang/index.html
**   docLang::Slots                      http://fantom.org/doc/docLang/Slots.html
**   docLang::deployment.png             http://fantom.org/doc/docLang/deployment.png
** 
** Note 'deployment.png' with ctx 'docLang' should resolve to 'fandoc:/docLang/doc/deployment.png'.
** 
@Fixture { failFast=false }
class TestFandocUri : RepoFixture {
	
	@Inject{}	Registry?	reg
				Str?		fandocUri
				Str?		clientUrl
	
	override Void setupFixture() {
		super.setupFixture
		user := getOrMakeUser("foo@bar.com")
		fanrRepo.publish(user, `test/res/foo-1.0.pod`.toFile.in)
		fanrRepo.publish(user, `test/res/foo-2.0.pod`.toFile.in)
	}
	
	Void parseFandocUri(Str uri) {
		InvalidLinks.gather |->| {
			fandocUri := FandocUri.fromUri(reg, uri.toUri)
			if (!fandocUri.validate) {
				this.fandocUri = "${fandocUri?.toUri} - ${InvalidLinks.invalidLinks}"
				this.clientUrl = "${fandocUri?.toClientUrl} - ${InvalidLinks.invalidLinks}"
				return
			}
			this.fandocUri = fandocUri.toUri.toStr
			this.clientUrl = fandocUri.toClientUrl.toStr
		}
	}

	Void parseClientUrl(Str uri) {
		InvalidLinks.gather |->| {
			fandocUri := FandocUri.fromClientUrl(reg, uri.toUri)
			if (!fandocUri.validate) {
				this.fandocUri = "${fandocUri?.toUri} - ${InvalidLinks.invalidLinks}"
				this.clientUrl = "${fandocUri?.toClientUrl} - ${InvalidLinks.invalidLinks}"
				return
			}
			this.fandocUri = fandocUri.toUri.toStr
			this.clientUrl = fandocUri.toClientUrl.toStr
		}
	}

	Void parseFantomUri(Str uri) {
		InvalidLinks.gather |->| {
			pod := podDao["foo-2.0"]
			ctx := LinkResolverCtx(pod) { it.type = "Bar" }
			fandocUri := FandocUri.fromFantomUri(reg, ctx, uri)
			if (!fandocUri.validate) {
				this.fandocUri = "${fandocUri?.toUri} - ${InvalidLinks.invalidLinks}"
				this.clientUrl = "${fandocUri?.toClientUrl} - ${InvalidLinks.invalidLinks}"
				return
			}
			this.fandocUri = fandocUri.toUri.toStr
			this.clientUrl = fandocUri.toClientUrl.toStr
		}
	}
}
