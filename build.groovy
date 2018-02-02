import groovy.text.SimpleTemplateEngine

class StartupOptions { List<StartupOptionsRecipe> recipes = []}
class StartupOptionsRecipe { String name; String version; String service = ""; List<String> logFiles = []; List<String> provisioningScripts = [] }

println '[1/3] Processing Recipes... '

def startupOptions = new StartupOptions()
def templateText = new File('./Dockerfile.tmpl').text
def recipesText = ""
def exposePorts = []

// parse recipes
def jsonSlurper = new  groovy.json.JsonSlurper()
['java', 'maven', 'gradle', 'elasticsearch', 'kibana', 'logstash', 'zookeeper', 'kafka', 'couchbase'].each {

	def path = './recipes/' + it +'.json'
	def recipe = jsonSlurper.parseText(new File(path).text)
	def recipeInfo = "$recipe.name [$recipe.version]"
	def startupOptionsRecipe = new StartupOptionsRecipe(name: "$recipe.name", version: "$recipe.version")

	print " * $recipeInfo... "

	// # Recipe name
	recipesText += "# $recipeInfo\n"

	// Expose ports
	if (recipe.exposePorts)
	{
		exposePorts = exposePorts.plus(recipe.exposePorts)
	}

	if (recipe.provisioningScripts)
	{
		startupOptionsRecipe.provisioningScripts.addAll(recipe.provisioningScripts)
	}

	// Log files
	if (recipe.logFiles)
	{
		startupOptionsRecipe.logFiles.addAll(recipe.logFiles)
	}

	// Service
	if (recipe.service)
	{
		startupOptionsRecipe.service = recipe.service
	}

	// commands
	recipe.cmd.each {
		recipesText += "$it\n"
	}

	recipesText += '\n'

	startupOptions.recipes.add(startupOptionsRecipe)

	print "done\n"
}

println()

templateText = new SimpleTemplateEngine()
		.createTemplate(templateText)
		.make(["recipes": recipesText, "exposePorts": exposePorts.join(' ')])

print '[2/3] Generating the Dockerfile... '

def dockerfile = new File('./Dockerfile')
dockerfile.text = templateText

println()


println '[3/3] Generating the startup.options... '

def startupOptionsFile = new File('./startup.options')
startupOptionsFile.text = groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(startupOptions))

println('\nAll successfully finished :-)')