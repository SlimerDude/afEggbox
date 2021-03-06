using afIoc
using afBedSheet
using afFormBean

const mixin BootstrapSkin : InputSkin {
	Str renderFormGroup(Str groupCss, SkinCtx skinCtx, |Str->Str| inputStr) {
		html	:= Str.defVal
		errCss	:= skinCtx.fieldInvalid ? " has-error" : Str.defVal
		hint	:= skinCtx.formField.hint ?: skinCtx.msg("field.${skinCtx.name}.hint")
		attMap	:= ["class":"form-control"]
		if (hint != null)
			attMap["aria-describedby"] = "${skinCtx.name}-helpBlock"
		attrs	:= skinCtx.renderAttributes(attMap)

		html	+= """<div class="form-group${errCss} ${groupCss}">"""
		html	+= """<label for="${skinCtx.name}">${skinCtx.label}</label>"""
		html	+= inputStr(attrs)

		if (hint != null)
			html += """<span id="${skinCtx.name}-helpBlock" class="help-block">${hint}</span>"""

		html	+= """</div>"""

		return html + "\n"
	}
}

const class BootstrapTextSkin : BootstrapSkin {
	override Str render(SkinCtx skinCtx) {
		renderFormGroup("", skinCtx) |attrs| {
			"""<input ${attrs} type="${skinCtx.formField.type}" value="${skinCtx.value}">"""
		}
	}
}

const class BootstrapHoneyPotSkin : BootstrapSkin {
	override Str render(SkinCtx skinCtx) {
		renderFormGroup("passwordAgain", skinCtx) |attrs| {
			"""<input ${attrs} type="${skinCtx.formField.type}" value="${skinCtx.value}">"""
		}
	}
}

const class BootstrapTextAreaSkin : BootstrapSkin {
	override Str render(SkinCtx skinCtx) {
		renderFormGroup("", skinCtx) |attrs| {
			"""<textarea ${attrs}>${skinCtx.value}</textarea>"""
		}
	}
}

const class BootstrapStaticSkin : BootstrapSkin {
	override Str render(SkinCtx skinCtx) {
		renderFormGroup("", skinCtx) |attrs| {
			"""<p ${attrs}>${skinCtx.value.toXml}</p><input name="${skinCtx.name}" type="hidden" value="${skinCtx.value}">"""
		}
	}
}

const class BootstrapCheckboxSkin : InputSkin {
	override Str render(SkinCtx skinCtx) {
		hint	:= skinCtx.formField.hint ?: skinCtx.msg("field.${skinCtx.name}.hint")
		checked := (skinCtx.value == "true" || skinCtx.value == "on") ? " checked" : Str.defVal
		attMap	:= hint == null ? Str:Str[:] : ["aria-describedby" : "${skinCtx.name}-helpBlock"]
		attrs	:= skinCtx.renderAttributes(attMap)
		html	:= Str.defVal
		html	+= """<div class="checkbox">"""
		html	+= """<label>"""
		html	+= """<input type="checkbox" ${attrs}${checked}> ${skinCtx.label}"""
		html	+= """</label>"""

		if (hint != null)
			html += """<span id="${skinCtx.name}-helpBlock" class="help-block">${hint}</span>"""
		
		html	+= """</div>"""
		return html + "\n"
	}
}

const class BootstrapSelectSkin : BootstrapSkin {
	@Inject private const	ValueEncoders		valueEncoders
	@Inject private const	OptionsProviders	optionsProviders

	new make(|This| in) { in(this) }
	
	override Str render(SkinCtx skinCtx) {
		renderFormGroup("", skinCtx) |attrs| {
			html	:= "<select ${attrs}>"
	
			formField := skinCtx.formField
			optionsProvider := formField.optionsProvider ?: optionsProviders.find(skinCtx.field.type)
	
			showBlank := formField.showBlank ?: optionsProvider.showBlank(formField) 
			if (showBlank) {
				blankLabel := formField.blankLabel ?: optionsProvider.blankLabel(formField)
				html += """<option value="">${blankLabel?.toXml}</option>"""
			}
			
			optionsProvider.options(formField, skinCtx.bean).each |value, label| {
				optLabel := skinCtx.msg("option.${label}.label") ?: label
				optValue := skinCtx.toClient(value)
				optSelec := (optValue.equalsIgnoreCase(skinCtx.value)) ? " selected" : Str.defVal
				html += """<option value="${optValue}"${optSelec}>${optLabel}</option>"""
			}
	
			html	+= "</select>"
			return html
		}
	}
}

const class BootstrapErrorSkin : ErrorSkin {
	override Str render(FormBean formBean) {
		if (!formBean.hasErrors) return Str.defVal
		
		banner := formBean.messages["errors.banner"]

		html := ""
		html += """<div class="alert alert-danger" role="alert">"""
		html += banner
		html += """<ul>"""
		formBean.errorMsgs.each {
			html += """<li>${it}</li>"""
		}
		formBean.formFields.vals.each {
			if (it.errMsg != null)
				html += """<li>${it.errMsg}</li>"""
		}
		html += """</ul>"""
		html += """</div>"""

		return html
	}
}