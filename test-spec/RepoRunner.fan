using afIoc
using afIocEnv
using afBounce
using afFancordion

class RepoRunner : FancordionRunner {
    private BedServer? server

    new make(|This|? f := null) : super(f) {
        outputDir = `fancordion-results/`.toFile
    }

    override Void suiteSetup() {
        super.suiteSetup
        server = BedServer(PodRepoModule#).addModule(WebTestModule#).startup		
    }

    override Void suiteTearDown(Type:FixtureResult resultsCache) {
        server?.shutdown
        super.suiteTearDown(resultsCache)
    }

    override Void fixtureSetup(Obj fixtureInstance) {
        webFixture := ((RepoFixture) fixtureInstance)

        super.fixtureSetup(fixtureInstance)
        webFixture.client = server.makeClient
        server.injectIntoFields(webFixture)
        webFixture.setupFixture
    }

    override Void fixtureTearDown(Obj fixtureInstance, FixtureResult result) {
        webFixture := ((RepoFixture) fixtureInstance)

        webFixture.tearDownFixture
        super.fixtureTearDown(fixtureInstance, result)
    }
}

class WebTestModule {

    @Override
    static IocEnv overrideIocEnv() {
        IocEnv.fromStr("Testing")
    }

    // other test specific services and overrides...
}

