using fandoc

class LinkResolverCtx {
	RepoPod?		pod
	Str?			type
	Doc?			doc
	
	// Users aboutMe has no pod ctx
	new make() { }

	new makeWithPod(RepoPod pod) { 
		this.pod = pod 
	}

	Obj? withDoc(Doc doc, |LinkResolverCtx->Obj?| func) {
		origDoc := this.doc
		try {
			this.doc = doc
			return func(this)
		} finally {
			this.doc = origDoc
		}
	}
}
