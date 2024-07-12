# sudo apt-get install jq -y

# PRODUCT=$(sudo lshw -json | jq '.product') || PRODUCT=$(sudo lshw -json | jq '.[].product')

# if [[ $PRODUCT == *"Xavier"* ]]; then
#   echo "Detected $PRODUCT setting to Xavier Installation"
#   archBin="7.2,8.7"
# fi
# if [[ $PRODUCT == *"Nano"* ]]; then
#   echo "Detected $PRODUCT setting to Nano Installation"
#   archBin="5.3"
# fi

# version=$(python3 --version)
# version=${version:7:3}
# echo $version

# SWAP=$(free -m | grep Swap)
# SWAPtotal=${SWAP:10:15}
# echo $SWAPtotal

# if [ $SWAPtotal -gt 4096 ]; then
#   echo "Swap is "${SWAPtotal}"mb which is enough"
# else
#   echo "Swap is "${SWAPtotal}"mb which is not enough"
#   echo ""
# fi

# TEMP=$(dpkg -s postfix)
# if [[ $TEMP == *"installed"* ]]; then
#   echo "Found postfix"
# else
#   echo ""
#   echo "To solve: sudo apt install postfix and select 'Local Only' on the configuration screen which shows"
#   echo ""
# fi

torch_url="https://nvidia.box.com/shared/static/mp164asf3sceb570wvjsrezk1p4ftj8t.whl"
torch_name="torch-2.3.0-cp310-cp310-linux_aarch64.whl"

wget -q --show-progress ${torch_url} -O ${torch_name}
