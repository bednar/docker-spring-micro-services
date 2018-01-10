import groovy.text.SimpleTemplateEngine

println 'Building Dockerfile... '

def templateText = new File('./Dockerfile.tmpl').text
def recipesText = ""
def logFiles = []

// parse recipes
def jsonSlurper = new  groovy.json.JsonSlurper()
['java', 'maven', 'gradle', 'elasticsearch'].each {

	def path = './recipes/' + it +'.json'
	def recipe = jsonSlurper.parseText(new File(path).text)

	// # Recipe name
	recipesText += sprintf('# %1$s [%2$s]\n', recipe.name, recipe.version)

	if (recipe.logFile)
	{
		logFiles << recipe.logFile
	}

	// commands
	recipe.cmd.each {
		recipesText += sprintf('%1$s\n', it)
	}

	recipesText += '\n'
}

templateText = new SimpleTemplateEngine()
		.createTemplate(templateText)
		.make(["recipes": recipesText, "logFiles": logFiles.join(' ')])

def output = new File('./Dockerfile')
output.text = templateText

println 'Success'