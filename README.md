# WowpediaDoc
The purpose of this project is to wikify the [Blizzard API Documentation](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated).

## Overview
* [Documenter/](https://github.com/Ketho/WowpediaDoc/tree/master/Documenter) - Generates wikitext from Blizzard API documentation.
* [Pywikibot/](https://github.com/Ketho/WowpediaDoc/tree/master/Pywikibot) - [Pywikibot](https://pypi.org/project/pywikibot/) scripts for using the MediaWiki API.
    - See the [README-pywikibot.md](README-pywikibot.md) example for setting up Pywikibot.
* [Scribunto/](https://github.com/Ketho/WowpediaDoc/tree/master/Scribunto) - [Scribunto](https://help.fandom.com/wiki/Extension:Scribunto) scripts running on the wiki that provide data for the API [infoboxes](https://wowpedia.fandom.com/wiki/Module:API_info).
* [KethoWowpedia/](https://github.com/Ketho/WowpediaDoc/tree/master/KethoWowpedia) - AddOn for dumping data in-game.
 
## Setup
Install Lua 5.4 and [LuaRocks](https://github.com/luarocks/luarocks/blob/main/docs/installation_instructions_for_unix.md) on [WSL](https://code.visualstudio.com/docs/remote/wsl), which should be easier to set up compared to Windows.

```sh
# lua
sudo apt install lua5.4

# luarocks
sudo apt install liblua5.4-dev
sudo apt install build-essential libreadline-dev unzip
wget https://luarocks.github.io/luarocks/releases/luarocks-3.11.1.tar.gz
tar -xvf luarocks-3.11.1.tar.gz
cd luarocks-3.11.1/
.configure
make
make install

# modules
sudo luarocks install luafilesystem
sudo luarocks install lua-path
sudo luarocks install luasocket
sudo apt install libssl-dev
sudo luarocks install luasec
sudo luarocks install xml2lua
sudo luarocks install lua-cjson
sudo luarocks install gumbo
```

## Usage
Exports wikitext to `out/`. Requires cloning the FrameXML mirror.
```sh
git clone https://github.com/Gethe/wow-ui-source 
git -C wow-ui-source pull
lua Documenter/Documenter.lua
```

![](https://i.imgur.com/MqdgasV.png)
