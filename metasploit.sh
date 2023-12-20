#!/data/data/com.termux/files/usr/bin/bash

# Remove existing sources.list.d files
rm $PREFIX/etc/apt/sources.list.d/*

# Purge Ruby and related files
apt purge ruby -y
rm -fr $PREFIX/lib/ruby/gems

# Upgrade packages and install essential dependencies
pkg upgrade -y -o Dpkg::Options::="--force-confnew"
pkg install -y binutils python autoconf bison clang coreutils curl findutils \
    apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite \
    libgrpc libtool libxml2 libxslt ncurses make ncurses-utils ncurses git wget \
    unzip zip tar termux-tools termux-elf-cleaner pkg-config git ruby \
    -o Dpkg::Options::="--force-confnew"

# Install Python package 'requests'
python3 -m pip install requests

# Apply fix for Ruby's BigDecimal library
source <(curl -sL https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt)

# Remove existing Metasploit framework installation
rm -rf $PREFIX/opt/metasploit-framework

# Clone Metasploit framework from GitHub
mkdir $PREFIX/opt
cd $PREFIX/opt
git clone https://github.com/rapid7/metasploit-framework.git --depth=1
cd $PREFIX/opt/metasploit-framework

# Install Bundler and update Rubygems
gem install bundler
gem update --system 3.4.13

# Extract Nokogiri version from Gemfile.lock and install it
declare NOKOGIRI_VERSION=$(cat Gemfile.lock | grep -i nokogiri | sed 's/nokogiri [\(\)]/(/g' | cut -d ' ' -f 5 | grep -oP "(.).[[:digit:]][\w+]?[.].")
gem install nokogiri -v $NOKOGIRI_VERSION -- --use-system-libraries

# Configure Nokogiri build options and install dependencies
bundle config build.nokogiri "--use-system-libraries --with-xml2-include=$PREFIX/include/libxml2"
bundle install

# Install ActionPack and update ActiveSupport
gem install actionpack
bundle update activesupport

# Update Bundler and install project dependencies
bundle update --bundler
bundle install -j$(nproc --all)

# Remove existing symlinks for msfconsole, msfvenom, and msfrpcd
if [ -e $PREFIX/bin/msfconsole ]; then
    rm $PREFIX/bin/msfconsole
fi
if [ -e $PREFIX/bin/msfvenom ]; then
    rm $PREFIX/bin/msfvenom
fi
if [ -e $PREFIX/bin/msfrpcd ]; then
    rm $PREFIX/bin/msfrpcd
fi

# Create symlinks to Metasploit framework executables
ln -s $PREFIX/opt/metasploit-framework/msfconsole $PREFIX/bin/
ln -s $PREFIX/opt/metasploit-framework/msfvenom $PREFIX/bin/
ln -s $PREFIX/opt/metasploit-framework/msfrpcd $PREFIX/bin/

# Clean up unused ELF binaries
termux-elf-cleaner $PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so

# Clear the terminal screen
clear

# Launch Metasploit framework console
msfconsole
