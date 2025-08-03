# WowDoc
The purpose of this project is to wikify the [Blizzard API Documentation](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated).

## Overview
* [Documenter/](https://github.com/Ketho/WowDoc/tree/master/Documenter) - Generates wikitext from Blizzard API documentation.
* [Pywikibot/](https://github.com/Ketho/WowDoc/tree/master/Pywikibot) - [Pywikibot](https://pypi.org/project/pywikibot/) scripts for using the MediaWiki API.
    - See the [README-pywikibot.md](README-pywikibot.md) example for setting up Pywikibot.
* [Scribunto/](https://github.com/Ketho/WowDoc/tree/master/Scribunto) - [Scribunto](https://help.fandom.com/wiki/Extension:Scribunto) scripts running on the wiki that power the API [infoboxes](https://warcraft.wiki.gg/wiki/Module:API_info).
* [KethoWowpedia/](https://github.com/Ketho/WowDoc/tree/master/KethoWowpedia) - AddOn for dumping data in-game.
 
## Setup
This project is being developed on [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) and the VS Code [extension](https://code.visualstudio.com/docs/remote/wsl).
```
wsl --install
```

Installs the latest version of Lua 5.4 and LuaRocks via [hererocks](https://github.com/luarocks/hererocks) which is self-contained.
```sh
# wherever you want to clone the repo
cd ~
git clone https://github.com/Ketho/WowDoc
cd WowDoc

sudo apt update
# venv
sudo apt install python3-pip python3.12-venv -y
python3 -m venv .venv
source .venv/bin/activate
# hererocks
sudo apt install libreadline-dev unzip -y
pip install git+https://github.com/luarocks/hererocks
hererocks .lua -l latest -r latest
source .lua/bin/activate

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

Alternatively, installs Lua 5.4 and [LuaRocks](https://github.com/luarocks/luarocks/blob/main/docs/installation_instructions_for_unix.md) 3.12.2 (in `~/.local`) manually.

```sh
sudo apt update
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

# wherever you want to clone the repo
cd ~
git clone https://github.com/Ketho/WowDoc
```

## Usage
Exports wikitext to the `out/` folder. This is also available as the `Lua Documenter` VS Code task.
```sh
# wherever the repo is
cd ~/WowDoc
# if using hererocks
source .lua/bin/activate

lua Documenter/init.lua
```

![](https://i.imgur.com/MqdgasV.png)
