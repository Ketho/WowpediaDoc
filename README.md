# WowpediaDoc
The purpose of this project is to wikify the [Blizzard API Documentation](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated).

## Overview
* [Documenter/](https://github.com/Ketho/WowpediaDoc/tree/master/Documenter) - Generates wikitext from Blizzard API documentation.
* [Pywikibot/](https://github.com/Ketho/WowpediaDoc/tree/master/Pywikibot) - [Pywikibot](https://pypi.org/project/pywikibot/) scripts for using the MediaWiki API.
    - See the [README-pywikibot.md](README-pywikibot.md) example for setting up Pywikibot.
* [Scribunto/](https://github.com/Ketho/WowpediaDoc/tree/master/Scribunto) - [Scribunto](https://help.fandom.com/wiki/Extension:Scribunto) scripts running on the wiki that power the API [infoboxes](https://warcraft.wiki.gg/wiki/Module:API_info).
* [KethoWowpedia/](https://github.com/Ketho/WowpediaDoc/tree/master/KethoWowpedia) - AddOn for dumping data in-game.
 
## Setup
Installs Lua 5.4 and [LuaRocks](https://github.com/luarocks/luarocks/blob/main/docs/installation_instructions_for_unix.md) on [WSL](https://code.visualstudio.com/docs/remote/wsl), which should be easier to set up compared to on Windows.

```sh
# if this is a fresh WSL ubuntu install
sudo apt update
cd ~

# lua
sudo apt install lua5.4

# luarocks
sudo apt install liblua5.4-dev -y
sudo apt install build-essential unzip -y
version=3.12.2
wget https://luarocks.github.io/luarocks/releases/luarocks-$version.tar.gz
tar -xvf luarocks-$version.tar.gz
cd luarocks-$version/
./configure --prefix=$HOME/.local
make
make install

# update luarocks and package paths
echo 'eval "$(~/.local/bin/luarocks path --bin)"' >> ~/.bashrc
source ~/.bashrc

# modules
luarocks install luafilesystem
luarocks install lua-path
luarocks install luasocket
sudo apt install libssl-dev -y
luarocks install luasec
luarocks install xml2lua
luarocks install lua-cjson
luarocks install gumbo
```

## Usage
Exports wikitext to `out/`.
```sh
cd ~
git clone https://github.com/Ketho/WowpediaDoc
cd WowpediaDoc
lua Documenter/init.lua
```

![](https://i.imgur.com/MqdgasV.png)
