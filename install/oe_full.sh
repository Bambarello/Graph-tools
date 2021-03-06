#!/bin/bash

echo "Installer for 'Graph-OpenEthereum full node' on 'Ubuntu 18.04'"
echo "Will install with '--config non-standard-ports' as parameter"

# variables
useraccount="oefull"
blockstart=10760000
unitname=oefull

if [ $USER != "$useraccount" ]; then

	# CHECK root
	if ! [ $(id -u) = 0 ]; then
	   echo "Script must be run as root / sudo."
	   exit 1
	fi
	
	# user account
	adduser --disabled-password --gecos "" $useraccount
	
	# packages
	apt-get install unzip
	
	# create unitfile
	# --base-path=$HOME/data
	# Warning: Warp Sync is disabled because tracing is turned on.
	tee "/etc/systemd/system/$unitname.service" <<EOD
[Unit]
Description=ETH full node (openethereum)
After=network-online.target

[Service]
User=$useraccount
WorkingDirectory=/home/$useraccount/
#ExecStart=/home/$useraccount/oe/openethereum --pruning=fast --pruning-history=2048 --tracing=on --warp-barrier=$blockstart --db-compaction=ssd --mode=active --no-periodic-snapshot --no-serve-light --min-peers=100 --max-peers=250 --jsonrpc-interface=all --no-ws --no-ipc --cache-size=20000  --config=non-standard-ports
ExecStart=/home/$useraccount/oe/parity --pruning=fast --pruning-history=2048 --tracing=on --warp-barrier=$blockstart --db-compaction=ssd --mode=active --no-periodic-snapshot --no-serve-light --min-peers=100 --max-peers=250 --jsonrpc-interface=all --no-ws --no-ipc --cache-size=20000  --config=non-standard-ports --bootnodes enode://68f46370191198b71a1595dd453c489bbfe28036a9951fc0397fabd1b77462930b3c5a5359b20e99677855939be47b39fc8edcf1e9ff2522a922b86d233bf2df@144.217.153.76:30303,enode://ffed6382e05ee42854d862f08e4e39b8452c50a5a5d399072c40f9a0b2d4ad34b0eb5312455ad8bcf0dcb4ce969dc89a9a9fd00183eaf8abf46bbcc59dc6e9d5@51.195.3.238:30303
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=3
StartLimitInterval=0
TimeoutStopSec=18000
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target
EOD
	
	# switch user
	echo "login as $gebruiker by running 'su $gebruiker' and start script again"
	su $useraccount
	exit 0
	
else
	
	# download openethereum
	mkdir oe
	cd oe
	# # version 3.0
	# wget https://github.com/openethereum/openethereum/releases/download/v3.0.1/openethereum-linux-v3.0.1.zip
	# unzip openethereum-linux-v3.0.1.zip
	# chmod +x ethkey
	# chmod +x ethstore
	# chmod +x openethereum
	# chmod +x openethereum-evm
	
	# version 2.5
	wget https://releases.parity.io/ethereum/v2.5.13/x86_64-unknown-linux-gnu/parity
	chmod +x parity
	
	
	echo -e "Run 'sudo systemctl start $unitname' & 'sudo systemctl enable $unitname'"
	echo "To see how your indexer is doing, run 'sudo journalctl --follow -o cat -u $unitname' (ctrl+c to stop the logview)."
	
fi
