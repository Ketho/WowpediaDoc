```sh
sudo apt update
mkdir ~/heretest
cd ~/heretest

sudo apt install python3-pip
python3 -m venv .venv
source .venv/bin/activate
pip install git+https://github.com/luarocks/hererocks
hererocks luah -l latest -r latest
source luah/bin/activate
```
