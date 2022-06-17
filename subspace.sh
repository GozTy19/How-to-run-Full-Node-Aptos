#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1 && curl -s https://raw.githubusercontent.com/GozTy19/How-to-run-Full-Node-Aptos/main/logo.sh | bash && sleep 1


cd $HOME
rm -rf subspace*
wget -O subspace-node https://github.com/subspace/subspace/releases/download/gemini-1b-2022-jun-13/subspace-node-ubuntu-x86_64-gemini-1b-2022-jun-13-aarch64
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/gemini-1b-2022-jun-13/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-jun-13-aarch64 
chmod +x subspace*
mv subspace* /usr/local/bin/

systemctl stop subspaced subspaced-farmer &>/dev/null
rm -rf ~/.local/share/subspace*

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-node) --chain gemini-1 --execution wasm --keep-blocks 1024 --pruning 1024 --validator --name $SUBSPACE_NODENAME
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service


echo "[Unit]
Description=Subspaced Farm
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-farmer) farm --reward-address $SUBSPACE_WALLET --plot-size 64G
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced-farmer.service


mv $HOME/subspaced* /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer

echo "==================================================="
echo -e '\n\e[42mKiểm tra trạng thái node\e[0m\n' && sleep 1
if [[ `service subspaced status | grep active` =~ "running" ]]; then
  echo -e "Subspace node \e[32mđang làm việc\e[39m!"
  echo -e "Bạn có thể kiểm tra trạng thái node bằng lệnh \e[7mservice subspaced status\e[0m"
  echo -e "Nhấn \e[7mQ\e[0m để thoát menu trạng thái"
else
  echo -e "Subspace node của bạn \e[31mchưa được cài đặt\e[39m, hãy cài lại."
fi
sleep 2
echo "==================================================="
echo -e '\n\e[42mKiểm tra trạng thái farmer\e[0m\n' && sleep 1
if [[ `service subspaced-farmer status | grep active` =~ "running" ]]; then
  echo -e "Subspace farmer của bạn\e[32mđang hoạt động\e[39m!"
  echo -e "Bạn có thể kiển tra trạng thái farmer bằng lệnh \e[7mservice subspaced-farmer status\e[0m"
  echo -e "Nhấn \e[7mQ\e[0m để thoát menu trạng thái"
else
  echo -e "Subspace farmer của bạn\e[31mchưa được cài đặt\e[39m, hãy cài lại."
fi
