import groovy.text.SimpleTemplateEngine

println 'Building Dockerfile... '

def templateText = new File('./Dockerfile.tmpl').text
def recipesText = ""
def logFiles = []
def exposePorts = []
def services = []
def provisioningScripts = ['echo test', '/usr/share/elasticsearch/bin/elasticsearch-provisioning']

// parse recipes
def jsonSlurper = new  groovy.json.JsonSlurper()
['java', 'maven', 'gradle', 'elasticsearch', 'kibana', 'logstash', 'zookeeper', 'kafka'].each {

	def path = './recipes/' + it +'.json'
	def recipe = jsonSlurper.parseText(new File(path).text)

	// # Recipe name
	recipesText += "# $recipe.name [$recipe.version]\n"

	// Expose ports
	if (recipe.exposePorts)
	{
		exposePorts = exposePorts.plus(recipe.exposePorts)
	}

	// Log files
	if (recipe.logFiles)
	{
		logFiles = logFiles.plus(recipe.logFiles)
	}

	// Service
	if (recipe.service)
	{
		services << recipe.service
	}

	// commands
	recipe.cmd.each {
		recipesText += "$it\n"
	}

	recipesText += '\n'
}

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

def output = new File('./Dockerfile')
output.text = templateText

println 'Success'