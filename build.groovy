import groovy.text.SimpleTemplateEngine

class StartupOptions { List<StartupOptionsRecipe> recipes = []}
class StartupOptionsRecipe { String name; String version; String service; List<String> logFiles = []; List<String> provisioningScripts = [] }

println '[1/3] Processing Recipes... '

def startupOptions = new StartupOptions()
def templateText = new File('./Dockerfile.tmpl').text
def recipesText = ""
def logFiles = []
def exposePorts = []
def services = []
def provisioningScripts = ['echo Start provisioning']

// parse recipes
def jsonSlurper = new  groovy.json.JsonSlurper()
['java', 'maven', 'gradle', 'elasticsearch', 'kibana', 'logstash', 'zookeeper', 'kafka'].each {

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
		provisioningScripts = provisioningScripts.plus(recipe.provisioningScripts)
		startupOptionsRecipe.provisioningScripts.addAll(recipe.provisioningScripts)
	}

	// Log files
	if (recipe.logFiles)
	{
		logFiles = logFiles.plus(recipe.logFiles)
		startupOptionsRecipe.logFiles.addAll(recipe.logFiles)
	}

	// Service
	if (recipe.service)
	{
		services << recipe.service
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

def multiTailColors = ["green", "yellow", "blue", "magenta", "cyan", "white", "red"] as LinkedList
def multiTailArgs = logFiles.collect
{
	// get first and remove
	def color = multiTailColors.poll();
	// add to end
	multiTailColors.add(color)

	"-ci $color -I $it"
}.join(' ')

templateText = new SimpleTemplateEngine()
		.createTemplate(templateText)
		.make(["recipes": recipesText,
			   "logFiles": logFiles.join(' '),
			   "multiTailArgs": multiTailArgs,
			   "exposePorts": exposePorts.join(' '),
			   "provisioningScripts" : provisioningScripts.join('; '),
			   "services": services.join(' ')])

print '[2/3] Generating the Dockerfile... '

def dockerfile = new File('./Dockerfile')
dockerfile.text = templateText

println()


println '[3/3] Generating the startup.options... '

def startupOptionsFile = new File('./startup.options')
startupOptionsFile.text = groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(startupOptions))

println('\nAll successfully finished :-)')