using afIoc
using afIocEnv
using afIocConfig
using afMorphia

@SubModule { modules=[FanrModule#, WebModule#] }
const class CoreModule {
	
	static Void defineServices(RegistryBuilder defs) {
		
		defs.addService(UserSession#)
		
		defs.addService(RepoUserDao#)
		defs.addService(RepoPodDao#)
		defs.addService(RepoPodFileDao#)
		defs.addService(RepoPodDocsDao#)
		defs.addService(RepoPodSrcDao#)
		defs.addService(RepoPodApiDao#)
		defs.addService(RepoPodDownloadDao#)
		defs.addService(RepoActivityDao#)
		
		defs.addService(DirtyCash#)
		defs.addService(CorePods#)
	}

	@Build
	static EggboxConfig buildEggboxConfig(IocEnv iocEnv) {
		EggboxConfig(iocEnv)
	}

	@Contribute { serviceType=Converters# }
	static Void contributeConverters(Configuration config) {		
		config[RepoPodMeta#] 	= config.build(RepoPodMetaConverter#)
		config[FandocUri#] 		= config.build(FandocUriConverter#)
	}

	internal static Void onRegistryStartup(Configuration config) {
		config.set("afEggbox.ensureIndexes", |->| {
			indexes := (Indexes) config.build(Indexes#)
			indexes.ensureIndexes
		}).after("afMorphia.testConnection")
	}
	
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(Configuration config, EggboxConfig eggboxConfig) {
		config[MorphiaConfigIds.mongoUrl]	= eggboxConfig.mongoDbUrl
	}
}
