using afIoc
using afMorphia

@Entity { name = "user" }
class RepoUser {
	
	@Property { name="_id" } Str	userName
	@Property { }	Str					realName
	@Property { }	Uri					email
	@Property { }	Str					userSalt
	@Property { }	Str					userSecret

	@Inject
	new make(|This| in) { in(this) }
	
	new makeNewUser(Str userName, Str password, |This| f) {
		this.userName 	= userName
		this.userSalt	= Buf.random(16).toHex
		this.userSecret	= generateSecret(password) 
		f(this)
	}
	
	Str generateSecret(Str password) {
		Buf().print("${userName}:${userSalt}").hmac("SHA-1", password.toBuf).toBase64
	}
}
