from importlib import util
import pywikibot

site = pywikibot.Site("en", "wowpedia")

def load_file_as_module(name, location):
	spec = util.spec_from_file_location(name, location)
	module = util.module_from_spec(spec)
	spec.loader.exec_module(module)
	return module

mod = load_file_as_module("mymodule", "wowpedia/category/namespace.py")

fs = """[[Category:API namespaces|{!s}]]
===External links===
{{{{#invoke:API namespaces|main|filename={!s}|system={!s}}}}}"""

for v in mod.namespaces:
	fileName, systemName, sytemNamespace = v[0], v[1], v[2]
	if sytemNamespace:
		page = pywikibot.Page(site, "Category:API_namespaces/"+sytemNamespace)
		page.text = fs.format(sytemNamespace.replace("C_", ""), fileName, systemName)
		page.save(summary="Category sortkey")

print("done")
