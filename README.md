# AutoPilot Import GUI

Website, Linkedin

## Introduction

The goal of this script is to help with the import process of a device into AutoPilot and simplifying this by using a User Interface (GUI). You will be able to select a Group Tag if you use them and the script will reboot after the deployment profile was successfully assigned. It will also help to troubleshoot possible Network requirements by running a connectivitiy check. This GUI uses the Powershell Script Get-WindowsAutoPilotInfo of Michael Niehaus.

Here is the link to [Powershell Gallery](https://www.powershellgallery.com/packages/Get-WindowsAutopilotImportGUI) where you will find the source code. This is the same as the .ps1 file you find in this repository.

## How it looks like

## How to use the GUI

Attention: This GUI does not work in WinPE because WinPE does not support Powershell natively. 

Step by Step:

1. In OOBE: Start the Command Line by simultaneously pressing Shift + F10.
2. Open Powershell by typing in Powershell.
3. Run "Set-Executionpolicy RemoteSigned"
4. Run "Install-Script Get-WindowsAutopilotImportGUI"
5. Run "Get-WindowsAutopilotImportGUI"

See below for Videos.

## Examples - Videos

1. [With Group Tag](https://ugurkoc.de/wp-content/uploads/2022/08/Import-with-Group-Tag.mp4)
2. [Without Group Tag](https://ugurkoc.de/wp-content/uploads/2022/08/Import-without-Group-Tag.mp4)
3. [Network Connectivity Check](https://ugurkoc.de/wp-content/uploads/2022/08/Network-Connectivity-Check-2.mp4)
