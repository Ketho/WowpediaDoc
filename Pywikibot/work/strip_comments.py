import util.warcraftwiki

comments = {
	"<!-- or {{wowapievent}}, {{luapi}}, {{widgethandler}}, {{widgetmethod}}, {{framexmlfunc}} -->",
	"<!-- Describe the purpose of the function as concisely as possible. -->\n",
	"<!-- Describe the purpose of the function, exhausting detail can be saved for a later section -->\n",
	"<!-- Describe the purpose of the function, though exhausting detail can be saved for a later section -->\n",
	"<!-- List return values and arguments as well as function name, follow Blizzard usage convention for args -->\n",
	"<!-- List each argument, together with its type -->\n",
	"<!-- List each argument, together with its type; Remove entire section if the function takes no arguments -->\n",
	"<!-- List each return value, together with its type -->\n",
	"<!-- List each return value, together with its type; Remove entire section if the function does not return anything -->\n",
	"<!-- List API functions, events, HOWTO guides, etc, related to using this function. Remove the section if none are applicable. -->\n",
	"<!-- If it helps, include an example here, though it's not required if the usage is self-explanatory -->\n",
	"<!-- If it helps, include example results here, though they are not required-->\n",
	"<!-- If it helps, include example results here, though they are not required. You're allowed to cheat liberally since WoW isn't a command line language. -->\n",
	"<!-- Please read https://wow.gamepedia.com/Wowpedia:External_links_policy before adding new links. -->\n",
	"<!-- Please read https://wowpedia.fandom.com/Wowpedia:External_links_policy before adding new links. -->\n",
	"<!-- Details not appropriate for the main description can go here -->\n",
	"<!-- Details not appropriate for the main description can go here. REMOVE the section if you're just going to restate the intro line! -->\n",
	"<!-- Details not appropriate for the main description can go here. \n     REMOVE the section if you're just going to restate the intro line! -->\n",
	"<!-- Details not appropriate for the concise description can go here. \n     REMOVE the section if you're just going to restate the intro line! -->\n",
}

def strip_comments(text):
	for s in comments:
		text = text.replace(s, "")
	return text

def update_text(name: str, text: str):
	if "<!--" in text:
		new_text = strip_comments(text)
		if text != new_text:
			return new_text

def main():
	util.warcraftwiki.main(update_text, summary="Strip comments")

if __name__ == "__main__":
	main()
