normal=$'\e[0m'
purple=$(tput setaf 5);
bold=$(tput bold)
purple="$bold$purple"
echo "${purple}This script will create the correct directory structure and install a couple dependencies for the Lokt Password manager.${normal}"
while true; do
    read -p "${purple}Do you wish to continue? (y/n) ${normal}" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "${purple}Too bad, you wont be able build the app without this script ;)${normal}" && exit;;
        * ) echo "${purple}Please answer yes or no.${normal}";;
    esac
done

rc_file="$HOME/.bashrc"
if [ $0 == "zsh" ]; then
    rc_file="$HOME/.zshrc"
fi

command_name=brew
if ! type "$command_name" > /dev/null; then
    echo "\n${purple}Installing Homebrew${normal}\n"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "\n${purple}Homebrew already exists, updating homebrew.${normal}\n"
    brew update
fi

for command_name in node yarn watchman pyenv
do
    echo "\n\n${purple}Installing/upgrading $command_name.${normal}\n"
    brew install $command_name
    brew upgrade $command_name
done

brew link node

command_name=xcode-select
if ! type "$command_name" > /dev/null; then
    echo "\n${purple}Installing Xcode command line tools.${normal}\n"
    $command_name --install
else
    echo "\n${purple}Xcode command line tools already exists, skipping install.${normal}\n"
fi

echo "\n${purple}Installing React Native dependencies using homebrew and npm.${normal}\n"
brew tap AdoptOpenJDK/openjdk
brew cask install adoptopenjdk8
npm install -g react-native-cli

echo "\n\n${purple}Installing fbs/PyQt5 dependencies using pyenv and pip, this might take a while.${normal}\n\n"
pyenv init
echo "\n"eval '"$(pyenv init -)"' >> $rc_file
pyenv uninstall -f 3.6.0
PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.6.0
pyenv local 3.6.0
pip install --upgrade pip

mv server/* .
pip install -Ur requirements.txt
echo "\n\n${purple}Starting the fbs project. For app name, you should enter Lokt. You should just press enter through the next fields${normal}\n\n"
fbs startproject
rm -rf src/main/icons/*
mkdir target
mv lib/fbs/Icon.inconset target/Icon.inconset
mv lib/fbs/main.py src/main/python/main.py
mv lib/fbs/helpers.py src/main/python/helpers.py
echo "\n\n${purple}Starting the React Native project.${normal}\n\n"
react-native init --version="0.59.9" Lokt
cd Lokt
mv ../lib/react-native/helpers.js ../lib/react-native/App.js .
npm install react-native-base64 crypto-js big-integer react-native-fs fernet buffer react-native-elements react-native-vector-icons
react-native link react-native-vector-icons react-native-fs
npm install -g yo generator-rn-toolbox
yo rn-toolbox:assets --icon ../lib/react-native/icon.png
mv ../lib/react-native/fernet.js node_modules/fernet/fernet.js
cd ..
rm -rf .git lib server startup.sh