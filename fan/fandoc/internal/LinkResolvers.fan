
** (Service) - 
@NoDoc	// don't overwhelm the masses
class LinkResolvers {
	private const LinkResolver[] 	resolvers

	new make(LinkResolver[] resolvers, |This|in) { 
		in(this) 
		this.resolvers = resolvers
	}
	
//          if (elem.uri.startsWith("examples::"))
//            elem.uri = "http://fantom.org/doc/" + elem.uri.replace("::", "/")	
	
	Uri? resolve(Uri uri, LinkResolverCtx? ctx := null) {
		ctx = ctx ?:LinkResolverCtx()
		invalidCount := ctx.invalidLinks.size
		resolved := resolvers.eachWhile { it.resolve(uri, ctx) }
		if (resolved == null && invalidCount == ctx.invalidLinks.size)
			ctx.invalidLink(uri, "Could not resolve link - $uri")
		
		ctx.invalidLinks.keys.eachRange(invalidCount..-1) { echo("$it -> ${ctx.invalidLinks[it]}") }
		return resolved
	}
}