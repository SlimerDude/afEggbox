using afIoc
using afMorphia

const class RepoPodMetaConverter : Converter {

	@Inject private const |->Converters| converters
	
	new make(|This|in) { in(this) }
	
	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		
		meta := converters().toFantom([Str:Str]#, mongoObj)
		return RepoPodMeta { it.meta = meta }
	}

	override Obj? toMongo(Type fantomType, Obj? fantomObj) {
		if (fantomObj == null) return null

		meta := ((RepoPodMeta) fantomObj).meta
		return converters().toMongo(meta.typeof, meta)
	}
}
