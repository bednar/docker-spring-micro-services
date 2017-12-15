import groovy.text.SimpleTemplateEngine

println 'Building Dockerfile... '

def templateText = new File('./Dockerfile.tmpl').text
def recipesText = ""


// parse recipes
def jsonSlurper = new  groovy.json.JsonSlurper()
['maven', 'java'].each {

	def path = './recipes/' + it +'.json'
	def recipe = jsonSlurper.parseText(new File(path).text)

	// # Recipe name
	recipesText += sprintf('# %1$s [%2$s]\n', recipe.name, recipe.version)

	// commands

	recipe.cmd.each {
		recipesText += sprintf('%1$s\n', it)
	}


	recipesText += '\n'
}


templateText = new SimpleTemplateEngine()
		.createTemplate(templateText)
		.make(["recipes": recipesText])

def output = new File('./Dockerfile')
output.text = templateText

println 'Success'