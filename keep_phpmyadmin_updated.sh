#!/bin/bash

# Requires sed, wget, gzip

# Paramters:
# $1 Path to Install
# $2 PMA Language (defaults to english)
# $3 Owner:Group (defaults to www-data:www-data)

# Check install path
if [ -z $1 ]; then
	echo "No install path given (path, language, owner)";
	exit;
fi

# Check language
if [ -z $2 ]; then
	LANGUAGE='english';
else
	LANGUAGE=$2;
fi

# Check owner/group
if [ -z $3 ]; then
	OWNERGROUP='www-data:www-data';
else
	OWNERGROUP=$3
fi

# Check installed version
if [ -f $1/README ]; then
	version_installed=$(sed -n 's/^Version \(.*\)$/\1/p' $1/README);
else
	version_installed=0;
fi

# Check available version
version_available=$(wget -q -O /tmp/kpu_version https://www.phpmyadmin.net/home_page/version.php && head -n 1 /tmp/kpu_version && rm /tmp/kpu_version);

# Update
if [ $version_available != $version_installed ]; then
	echo "Updating local installation of $version_installed to $version_available...";
	wget -q -O /tmp/kpu_install.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${version_available}/phpMyAdmin-${version_available}-${LANGUAGE}.tar.gz;
	if [ -f /tmp/kpu_install.tar.gz ]; then
		tar -xzf /tmp/kpu_install.tar.gz -C /tmp;

		# Copy existing config, if exists
		if [ -f $1/config.inc.php ]; then
			cp $1/config.inc.php /tmp/phpMyAdmin-${version_available}-${LANGUAGE}/config.inc.php
		fi

		rm -R $1
		mv /tmp/phpMyAdmin-${version_available}-${LANGUAGE} $1
		chown -R $OWNERGROUP $1
		rm /tmp/kpu_install.tar.gz
		rm -R $1/setup $1/examples

		echo "Done!";
	else
		echo "An error occured trying to download";
	fi
else
	echo "We are good - $version_available == $version_installed";
fi
