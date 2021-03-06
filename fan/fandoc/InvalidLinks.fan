using afIoc
using concurrent

const class InvalidLinks {

	@Inject private const Scope				scope
	@Inject private const RepoPodApiDao		podApiRepo
	@Inject private const RepoPodDocsDao	podDocsRepo
	@Inject private const FandocWriter		fandoc
	@Inject private const DirtyCash			dirtyCash

	new make(|This|in) { in(this) }
	
	InvalidLink[] findInvalidLinks(RepoPod pod) {
		dirtyCash.cash |->Obj?| {
			linkCtx		:= LinkResolverCtx(pod)
			fandocUri	:= (FandocUri) scope.build(FandocSummaryUri#, [pod.name, pod.version])
	
			return InvalidLinks.gather |->| {
				InvalidLinks.setWhereLinkIsFound(fandocUri.toSummaryUri)
				fandoc.writeStrToHtml(pod.aboutFandoc, linkCtx)

				if (pod.hasDocs)
					podDocsRepo.get(pod._id).fandocPages.each |page, fileUri| {
						InvalidLinks.setWhereLinkIsFound(fandocUri.toDocUri(fileUri))
						fandoc.writeStrToHtml(page, linkCtx)
					}
	
				if (pod.hasApi)
					podApiRepo.get(pod._id).allTypes.each |type| {
						linkCtx.type = type.name
						InvalidLinks.setWhereLinkIsFound(fandocUri.toApiUri(type.name))
						fandoc.writeStrToHtml(type.doc.text, linkCtx)
		
						type.slots.each |slot| {
							InvalidLinks.setWhereLinkIsFound(fandocUri.toApiUri(type.name, slot.name))
							fandoc.writeStrToHtml(slot.doc.text, linkCtx)
						}
					}
			}
		}
	}
	
	static Void	setWhereLinkIsFound(FandocUri uri) {
		if (Actor.locals["afEggbox.invalidLinks"] != null)
			Actor.locals["afEggbox.whereLinkIsFound"] = uri
	}
	static Void	setLinkBeingResolved(Str link) {
		if (Actor.locals["afEggbox.invalidLinks"] != null)
			Actor.locals["afEggbox.linkBeingResolved"] = link
	}

	static Obj? add(Str msg) {
		invalidLinks?.add(InvalidLink {
			it.where	= Actor.locals["afEggbox.whereLinkIsFound"]
			it.link		= Actor.locals["afEggbox.linkBeingResolved"] ?: ""	// FandocErrs aren't causes by links, see FandocWriter
			it.msg		= msg
		})
		return null
	}

	static InvalidLink[] gather(|->| func) {
		Actor.locals["afEggbox.invalidLinks"] = InvalidLink[,]
		try {
			func()
			return invalidLinks
		} finally {
			Actor.locals.remove("afEggbox.linkBeingResolved")
			Actor.locals.remove("afEggbox.whereLinkIsFound")
			Actor.locals.remove("afEggbox.invalidLinks")
		}
	}
	
	static InvalidLink[]? invalidLinks() {
		Actor.locals["afEggbox.invalidLinks"]
	}
}

const mixin InvalidLinkMsgs {
		
	static Str pathSegmentNotPods(Str? pods) {
		"Path segment `/${pods}` should be `/pods`"
	}
	
	static Str invalidPodName(Str? podName) {
		"Invalid pod name '${podName}'"
	}
	
	static Str tooManyPathSegments(Str[] path) {
		"Too many path segments: ${path}"
	}
	
	static Str invalidPathSegment(Str segment) {
		"Invalid path segment '${segment}'"
	}
	
	static Str invalidFantomUri() {
		"Invalid Fantom URI"
	}
	
	static Str podNotFound(Str podName, Version? podVersion) {
		"Could not find pod ${podName}" + (podVersion ?: "")
	}
	
	static Str invalidTypeSlotCombo() {
		"Invalid '<type>.<slot>' name"
	}
	
	static Str couldNotFindApiFiles(RepoPod pod) {
		"Pod ${pod} has no API files"
	}
	
	static Str couldNotFindType(RepoPod pod, Str typeName) {
		"Pod ${pod} does not have an API file for ${typeName}"
	}
	
	static Str couldNotFindSlot(RepoPod pod, Str typeName, Str slotName) {
		"Type ${pod}::${typeName} does not have a slot named: ${slotName}"
	}
	
	static Str couldNotFindSrcFiles(RepoPod pod) {
		"Pod ${pod} has no Src files"
	}
	
	static Str couldNotFindSrcFile(RepoPod pod, Str file) {
		"Pod ${pod} does not have an Src file for ${file}"
	}
	
	static Str couldNotFindDocFiles(RepoPod pod) {
		"Pod ${pod} has no Doc files"
	}
	
	static Str couldNotFindDocFile(RepoPod pod, Uri fileUri) {
		"Pod ${pod} does not have the Doc file `${fileUri}`"
	}

	static Str couldNotFindHeading(Str headingId, Str headings) {
		"Document does not contain the heading ID #${headingId} Available headings: ${headings}"
	}

	static Str fanSchemeDocDirOnly() {
		"fan:// scheme may only reference files in the `doc/` directory"
	}
}