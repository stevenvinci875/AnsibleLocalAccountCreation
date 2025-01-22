#!/usr/bin/env bash

## Define variables
username='admin'
password='YouWillNeedToSetThis' ## Generate a random 16-character password
fullName='Administrator'

## Add the admin user to the HiddenUsersList
sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add $username
## Delete the current admin user, if it exists
sudo sysadminctl -deleteUser $username
## Add the new admin user with the random password
sudo sysadminctl -adminUser $username -adminPassword $password -addUser $username -fullName $fullName -password $password -admin