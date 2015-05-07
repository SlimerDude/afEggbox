using afIoc
using afBedSheet
using afEfanXtra
using afPillow
using afFormBean

const mixin LoginPage : PrPage {

	@Inject abstract RepoUserDao	userDao
//	@Inject	abstract SystemActivity	systemActivity
//	@Inject abstract UserActivity	userActivity
//	@Inject	abstract FlashMsg		flash
	@Inject { type=LoginDetails# } 
			abstract FormBean		formBean
			abstract LoginDetails?	loginDetails

	@InitRender
	Void initRender() {
		loginDetails = LoginDetails()
		formBean.messages["field.submit.label"] = "Login"
	}
		
	Str loginUrl() {
		pageMeta.eventUrl(#onLogin).encode
	}
	
	Str formCss() {
		formBean.hasErrors ? "form-error" : "form-okay"
	}

	@PageEvent { name=""; httpMethod="POST" }
	Redirect? onLogin() {
		if (!formBean.validateForm(httpRequest.body.form))
			return null

		loginDetails = formBean.createBean
		
		user := userDao.findByEmail(loginDetails.email)
		if (user == null || user.generateSecret(loginDetails.password) != user.userSecret) {
//			systemActivity.logFailedLogin(loginDetails.email, loginDetails.password)
			formBean.errorMsgs.add(Msgs.login_incorrectDetails)
			return null
		}
		
		userSession.loginAs(user)
//		userActivity.logLoggedIn
		return Redirect.afterPost(pages[MyPodsPage#].pageUrl)
	}

}

class LoginDetails {
	
	@HtmlInput { type="email"; required=true; minLength=3; maxLength=128 }
	Uri?	email

	@HtmlInput { type="password"; required=true; minLength=3; maxLength=128 }
	Str?	password
}