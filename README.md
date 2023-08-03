# AutoPilot Import GUI

[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/UgurKocDe/) [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ugur-koc-302b9817a/) [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://ugurkoc.de) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

The goal of this script is to help with the import process of a device into AutoPilot and simplifying this by using a User Interface (GUI). You will be able to select a Group Tag if you use them and the script will reboot after the deployment profile was successfully assigned. It will also help to troubleshoot possible Network requirements by running a connectivitiy check. This GUI uses the Powershell Script Get-WindowsAutoPilotInfo of Michael Niehaus.

Blog post with additional infos: https://ugurkoc.de/autopilot-import-gui/

Here is the link to [Powershell Gallery](https://www.powershellgallery.com/packages/Get-WindowsAutopilotImportGUI) where you will find the source code. This is the Script which will be downloaded if you run "Install-Script Get-WindowsAutopilotImportGui" which is the same as the .ps1 file you find in this repository.

## How it looks like

![grafik](https://github.com/ugurkocde/AutoPilot_Import_GUI/assets/43906965/a9e57af2-ac35-453b-a32f-1a6e6f414b78)

## How to use the GUI

Attention: This GUI does not work in WinPE because WinPE does not support Powershell natively. 

Step by Step:

1. In OOBE: Start the Command Line by simultaneously pressing Shift + F10.
2. Open Powershell by typing in Powershell.
3. Run "Set-Executionpolicy RemoteSigned"
4. Run "Install-Script Get-WindowsAutopilotImportGUI"
5. Run "Get-WindowsAutopilotImportGUI"
6. Done. See below for Walkthrougs in three different scenarios.

The third step is particulary important to tell Powershell to trust the downloaded script from step four. The Executionpolicy in Powershell is a security layer to block malicious scripts. By default the executionpolicy is set to Restricted which we have to change to successfully run our script. There are multiple options but we will use RemoteSigned. This way Powershell still has the security layer by only trusting signed scripts which this is by downloading it from PowerShell Gallery. 

## Examples - Videos

1. [With Group Tag](https://ugurkoc.de/wp-content/uploads/2022/08/Import-with-Group-Tag.mp4)
2. [Without Group Tag](https://ugurkoc.de/wp-content/uploads/2022/08/Import-without-Group-Tag.mp4)
3. [Network Connectivity Check](https://ugurkoc.de/wp-content/uploads/2022/08/Network-Connectivity-Check-2.mp4)
