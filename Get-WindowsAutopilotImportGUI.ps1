<#PSScriptInfo

.VERSION 1.3

.GUID fd8d0caf-802d-443f-9bff-2e3a03754791

.AUTHOR Ugur Koc

.COMPANYNAME

.COPYRIGHT

.TAGS Windows, AutoPilot, Powershell, Intune, AzureAD, EntraID

.LICENSEURI

.PROJECTURI https://www.github.com

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
1.0 New Features, Bugfixes, etc.
1.1 Bugfixes, etc.
1.2 Bugfixes, etc.
1.3 Bugfixes, etc.

.PRIVATEDATA

#>

<#

.DESCRIPTION
The goal of this script is to help with the import process of a device into AutoPilot and simplifying this by using a User Interface (GUI). You will be able to select a Group Tag if you use them and the script will reboot after the deployment profile was successfully assigned. It will also help to troubleshoot possible Network requirements by running a connectivitiy check. This GUI uses the Powershell Script Get-WindowsAutoPilotInfo of Michael Niehaus.

.SYNOPSIS
GUI to import Device to Autopilot.

MIT LICENSE
Copyright (c) 2023 Ugur Koc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.LINK
Github: https://github.com/ugurkocde/AutoPilot_Import_GUI

#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# XAML file
$xamlFile = @'
<Window x:Class="WpfApp1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp1"
        mc:Ignorable="d"
        ResizeMode="NoResize"
        Title="Autopilot Import GUI" Height="636" Width="399">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="33*"/>
            <RowDefinition Height="29*"/>
        </Grid.RowDefinitions>
        <Rectangle HorizontalAlignment="Left" Height="44" Margin="30,228,0,0" Stroke="Black" VerticalAlignment="Top" Width="331"/>
        <Rectangle HorizontalAlignment="Left" Height="108" Margin="30,104,0,0" Stroke="Black" VerticalAlignment="Top" Width="331"/>
        <Button x:Name="button_register" Content="Login and register device in AutoPilot" HorizontalAlignment="Left" Margin="29,28,0,0" VerticalAlignment="Top" Width="332" Height="26" Background="#FF8EFF8B" FontWeight="Bold" BorderBrush="Black" Grid.Row="1"/>
        <TextBlock x:Name="text_author" HorizontalAlignment="Left" Margin="30,233,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Grid.Row="1"><Run Language="de-de" Text="Author"/></TextBlock>
        <TextBlock x:Name="text_version" HorizontalAlignment="Left" Margin="234,233,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Grid.Row="1" Width="127" TextAlignment="Right"><Run Language="de-de" Text="Version"/></TextBlock>
        <TextBox x:Name="text_output" HorizontalAlignment="Left" Margin="29,67,0,0" TextWrapping="WrapWithOverflow" VerticalAlignment="Top" Width="332" Height="161" IsReadOnly="True" HorizontalScrollBarVisibility="Visible" VerticalScrollBarVisibility="Visible" Grid.Row="1"/>
        <Button x:Name="button_check_connectivity" Content="Network Connectivity Check" HorizontalAlignment="Left" Margin="29,315,0,0" VerticalAlignment="Top" Width="332" Height="26" Background="#FFA1CEFF" FontWeight="Bold" BorderBrush="Black" Grid.RowSpan="2"/>
        <TextBlock HorizontalAlignment="Left" Margin="16,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="356" FontSize="20" TextAlignment="Center" FontWeight="Bold" Text="Autopilot Import GUI"/>
        <TextBlock HorizontalAlignment="Left" Margin="239,94,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Background="White" Width="110" TextAlignment="Center" Height="19" FontWeight="Bold" FontStyle="Italic"><Run Language="de-de" Text="Device Information"/></TextBlock>
        <Button x:Name="button_howto" Content="Help" HorizontalAlignment="Left" Margin="30,64,0,0" VerticalAlignment="Top" Background="White" Width="127"/>
        <TextBlock x:Name="text_time" HorizontalAlignment="Left" Margin="212,42,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="84"><Run Language="de-de" Text="Time"/></TextBlock>
        <TextBlock x:Name="text_date" HorizontalAlignment="Left" Margin="123,42,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="84"><Run Language="de-de" Text="Date"/></TextBlock>
        <TextBlock x:Name="text_serialnumber" HorizontalAlignment="Left" Margin="128,182,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="146" Height="20"><Run Language="de-de" Text="Serialnumber"/></TextBlock>
        <TextBlock x:Name="text_devicemodel" HorizontalAlignment="Left" Margin="128,116,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="146" Height="18"><Run Language="de-de" Text="Device Model"/></TextBlock>
        <TextBlock x:Name="text_manufacturer" HorizontalAlignment="Left" Margin="126,160,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="18"><Run Language="de-de" Text="Manufacturer"/></TextBlock>
        <TextBlock x:Name="text_devicename" HorizontalAlignment="Left" Margin="128,138,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="146" Height="20"><Run Text="Device "/><Run Language="de-de" Text="Name"/></TextBlock>
        <TextBlock x:Name="text_freespace" HorizontalAlignment="Left" Margin="325,116,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="59" Height="18"><Run Language="de-de" Text="Free Space"/></TextBlock>
        <TextBlock HorizontalAlignment="Left" Margin="41,116,0,0" TextWrapping="Wrap" Text="Device Model:" VerticalAlignment="Top" Height="18" FontWeight="Bold"/>
        <TextBlock HorizontalAlignment="Left" Margin="41,138,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="19" FontWeight="Bold"><Run Text="Device "/><Run Language="de-de" Text="Name"/><Run Text=":"/></TextBlock>
        <TextBlock HorizontalAlignment="Left" Margin="40,160,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="19" FontWeight="Bold"><Run Language="de-de" Text="Manufacturer:"/></TextBlock>
        <TextBlock HorizontalAlignment="Left" Margin="41,182,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="20" FontWeight="Bold"><Run Language="de-de" Text="Serialnumber:"/></TextBlock>
        <TextBlock HorizontalAlignment="Left" Margin="212,115,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="19" FontWeight="Bold"><Run Language="de-de" Text="Free Storage in GB:"/></TextBlock>
        <TextBlock x:Name="text_internet_connection" HorizontalAlignment="Left" Margin="165,64,0,0" TextWrapping="Wrap" Text="Internet Connection Button" VerticalAlignment="Top" Height="20" Width="194" TextAlignment="Center"/>
        <TextBox x:Name="text_grouptag" HorizontalAlignment="Left" Margin="36,235,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="192" Height="30" FontSize="14" BorderBrush="Black"/>
        <Button x:Name="button_grouptag" Content="Save Group Tag" HorizontalAlignment="Left" Margin="234,235,0,0" VerticalAlignment="Top" Height="30" Width="120" BorderBrush="Black" Background="#FFEFFF5C" FontWeight="Bold"/>
        <TextBlock HorizontalAlignment="Left" Margin="262,217,0,0" TextWrapping="Wrap" VerticalAlignment="Top" FontWeight="Bold" Width="64" Background="White" TextAlignment="Center" FontStyle="Italic"><Run Text="Group"/><Run Text=" T"/><Run Text="ag"/></TextBlock>
        <Button x:Name="button_windowsupdate" Content="Start Windows Update" HorizontalAlignment="Left" Margin="29,284,0,0" VerticalAlignment="Top" Width="162" Height="26" Background="#FFFFC28B" FontWeight="Bold" BorderBrush="Black" />
        <Button x:Name="button_exportcsv" Content="Export Hash to CSV" HorizontalAlignment="Left" Margin="200,284,0,0" VerticalAlignment="Top" Width="161" Height="26" Background="#FFFF8B8B" FontWeight="Bold" BorderBrush="Black"/>
    </Grid>
</Window>

'@

#create window
$inputXML = $xamlFile
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
}
catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    }
    catch {
        throw
    }
}

# Get-Variable var_*

function Update-ScriptVersion {
    $ScriptName = "Get-WindowsAutopilotImportGUI"

    # Get the currently installed version
    $LocalVersion = (Get-InstalledScript -Name $ScriptName).Version

    # Get the latest version from the PowerShell Gallery
    $GalleryVersion = (Find-Script -Name $ScriptName).Version

    # Compare the versions
    if ($LocalVersion -lt $GalleryVersion) {
        # If a newer version is found in the PowerShell Gallery, update the script
        Update-Script -Name $ScriptName
        Write-Output "The script has been updated to version $GalleryVersion."
    }
    else {
        Write-Output "You are already using the latest version of the script."
    }
}

# Signaling that the script starts
Write-Output "Starting the script..."

# Search and download updated version of the script if available
#Update-ScriptVersion

$button_windowsupdate = $Window.FindName('button_windowsupdate')
$button_windowsupdate.Add_Click({
        $script = {
            $host.UI.RawUI.ForegroundColor = 'Green'
            Write-Output "`nInstalling PSWindowsUpdate module..."
            Install-Module PSWindowsUpdate -Force
            Write-Output "`nPSWindowsUpdate module installed successfully."

            $host.UI.RawUI.ForegroundColor = 'Yellow'
            Write-Output "`nImporting PSWindowsUpdate module..."
            Import-Module PSWindowsUpdate
            Write-Output "`nPSWindowsUpdate module imported successfully."

            $host.UI.RawUI.ForegroundColor = 'Cyan'
            Write-Output "`nListing available Windows updates... This may take a while ..."
            Get-WUlist -MicrosoftUpdate

            Write-Output "`nInstalling Windows updates..."
            Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
            Write-Output "`nWindows updates installation initiated."
            $host.UI.RawUI.ForegroundColor = 'White'
        }

        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script.ToString()))
        Start-Process powershell -ArgumentList "-NoExit", "-EncodedCommand $encodedCommand" -Verb runAs
    })


# Find the button in the window object
$button_exportcsv = $Window.FindName('button_exportcsv')

# Function to show folder browser dialog and get selected folder path
function Get-FolderPath {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a folder to save the Autopilot CSV file"
    $folderBrowser.RootFolder = "MyComputer"
    $result = $folderBrowser.ShowDialog()
    if ($result -eq "OK") {
        return $folderBrowser.SelectedPath
    }
    else {
        return $null
    }
}

# Add click event handler
$button_exportcsv.Add_Click({
        # Get the folder path
        $folderPath = Get-FolderPath
        if ($folderPath -eq $null) {
            Write-Output "Export process cancelled by user."
            return
        }
    
        # Build the output file path
        $filePath = Join-Path -Path $folderPath -ChildPath 'AutopilotHWID.csv'

        # Start a new PowerShell process to run the command
        Start-Process powershell -ArgumentList '-NoExit', "-Command & {
    param(`$filePath)

    `$host.UI.RawUI.ForegroundColor = 'Green'
    Write-Output '`nInstalling Get-WindowsAutopilotInfo module...'
    Install-Module -Name Get-WindowsAutopilotInfo -Force

    `$host.UI.RawUI.ForegroundColor = 'Cyan'
    Write-Output '`nGetting Windows Autopilot Info and saving to CSV...'
    Get-WindowsAutopilotInfo -OutputFile `$filePath
    Write-Output '`nOperation completed successfully. CSV file is saved at '`$filePath

    `$host.UI.RawUI.ForegroundColor = 'White'
    } $filePath" -Verb runAs
    })



# function to check internet connection
function connectivity_check {

    $ErrorActionPreference = 'SilentlyContinue'
    $WarningPreference = 'SilentlyContinue'
    $OriginalProgressPreference = $Global:ProgressPreference
    $Global:ProgressPreference = 'SilentlyContinue'

    $ComputerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
    $ComputerName = $ComputerInfo.Name
    $Serialnumber = Get-CimInstance win32_SystemEnclosure | Select-Object -Property serialnumber

    Write-Output "--- Basic Info ---"

    Write-Output "Computername:" $ComputerName
    Write-Output "Serialnumber:" $Serialnumber.serialnumber

    Write-Output `n

    # MDM Registration Test reachability
    # https://docs.microsoft.com/de-de/mem/intune/enrollment/windows-enroll

    Write-Output -BackgroundColor DarkBlue "--- Checking connectivity for: Enterprise regitration ---"

    $MDM_registration = (Test-NetConnection enterpriseregistration.windows.net -Port 443 ).TcpTestSucceeded
    If ($MDM_registration -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "MDM_registration - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "MDM_registration - Error "
        Write-Output @ErrorIcon
    }

    $MDM_enrollment = (Test-NetConnection enterpriseenrollment-s.manage.microsoft.com -Port 443 ).TcpTestSucceeded
    If ($MDM_enrollment -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "MDM_enrollment - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "MDM_enrollment - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    # Autopilot Test reachability
    # https://docs.microsoft.com/de-de/mem/autopilot/networking-requirements

    Write-Output -BackgroundColor DarkBlue "--- Checking connectivity for: Windows Autopilot Deployment Services ---"

    $AutoPilot_ztd = (Test-NetConnection ztd.dds.microsoft.com -Port 443 ).TcpTestSucceeded
    If ($AutoPilot_ztd -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "AutoPilot_ztd - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "AutoPilot_ztd - Error "
        Write-Output @ErrorIcon
    }

    $AutoPilot_cs = (Test-NetConnection cs.dds.microsoft.com -Port 443 ).TcpTestSucceeded
    If ($AutoPilot_cs -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "AutoPilot_cs - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "AutoPilot_cs - Error "
        Write-Output @ErrorIcon
    }

    $AutoPilot_login = (Test-NetConnection login.live.com -Port 443 ).TcpTestSucceeded
    If ($AutoPilot_login -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "AutoPilot_login - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "AutoPilot_login - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    # License Test reachability
    # https://support.microsoft.com/en-us/topic/windows-activation-or-validation-fails-with-Error -code-0x8004fe33-a9afe65e-230b-c1ed-3414-39acd7fddf52

    Write-Output -BackgroundColor DarkBlue "--- Checking connectivity for: License activation service ---"

    $Licensing_activation = (Test-NetConnection activation.sls.microsoft.com -Port 443 ).TcpTestSucceeded
    If ($Licensing_activation -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Licensing_activation - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Licensing_activation - Error "
        Write-Output @ErrorIcon
    }

    $Licensing_validation = (Test-NetConnection validation.sls.microsoft.com -Port 443 ).TcpTestSucceeded
    If ($Licensing_validation -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Licensing_validation - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Licensing_validation - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    # WufB Test reachability

    Write-Output -BackgroundColor DarkBlue "--- Checking connectivity for: Windows Update for Business Service ---"

    $WufB = (Test-NetConnection update.microsoft.com -Port 443 ).TcpTestSucceeded
    If ($WufB -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "WufB - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "WufB - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    # SSO Test reachability

    Write-Output -BackgroundColor DarkBlue "--- Checking connectivity for: Single Sign-On ---"

    $SSO = (Test-NetConnection autologon.microsoftazuread-sso.com -Port 443 ).TcpTestSucceeded
    If ($SSO -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "SSO - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "SSO - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    # TPM Test reachability
    # https://docs.microsoft.com/de-de/mem/autopilot/networking-requirements

    Write-Output -BackgroundColor DarkBlue "--- TPM Connectivity to Intel, Qualcomm and AMD ---"

    $TPM_Intel = (Test-NetConnection ekop.intel.com -Port 443).TcpTestSucceeded
    If ($TPM_Intel -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "TPM_Intel - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "TPM_Intel - Error "
        Write-Output @ErrorIcon
    }

    $TPM_Qualcomm = (Test-NetConnection ekcert.spserv.microsoft.com -Port 443).TcpTestSucceeded
    If ($TPM_Qualcomm -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "TPM_Qualcomm - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "TPM_Qualcomm - Error "
        Write-Output @ErrorIcon
    }

    $TPM_AMD = (Test-NetConnection ftpm.amd.com -Port 443).TcpTestSucceeded
    If ($TPM_AMD -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "TPM_AMD - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "TPM_AMD - Error "
        Write-Output @ErrorIcon
    }

    $TPM_Azure = (Test-NetConnection azure.net -Port 443).TcpTestSucceeded
    If ($TPM_Azure -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "TPM_Azure - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "TPM_Azure - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    # Intune (Config deployment) Test reachability

    Write-Output -BackgroundColor DarkBlue "--- Checking connectivity for: Config deployment and access for managed devices ---"

    $Intune_ConfigDeployment_microsoftonline = (Test-NetConnection login.microsoftonline.com -Port 443).TcpTestSucceeded
    If ($Intune_ConfigDeployment_microsoftonline -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Intune_ConfigDeployment_microsoftonline - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Intune_ConfigDeployment_microsoftonline - Error "
        Write-Output @ErrorIcon
    }

    $Intune_ConfigDeployment_configoffice = (Test-NetConnection config.office.com -Port 443).TcpTestSucceeded
    If ($Intune_ConfigDeployment_configoffice -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Intune_ConfigDeployment_configoffice - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Intune_ConfigDeployment_configoffice - Error "
        Write-Output @ErrorIcon
    }

    $Intune_ConfigDeployment_graph = (Test-NetConnection graph.windows.net -Port 443).TcpTestSucceeded
    If ($Intune_ConfigDeployment_graph -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Intune_ConfigDeployment_graph - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Intune_ConfigDeployment_graph - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    # Intune (POSH and Win32 Apps deployment) Test reachability

    Write-Output -BackgroundColor DarkBlue "--- Checking connectivity for: Network requirements for PowerShell scripts and Win32 apps ---"

    $Intune_AppDeployment_pri = (Test-NetConnection euprodimedatapri.azureedge.net -Port 443).TcpTestSucceeded
    If ($Intune_AppDeployment_pri -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Intune_AppDeployment_pri - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Intune_AppDeployment_pri - Error "
        Write-Output @ErrorIcon
    }

    $Intune_AppDeployment_sec = (Test-NetConnection euprodimedatasec.azureedge.net -Port 443).TcpTestSucceeded
    If ($Intune_AppDeployment_sec -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Intune_AppDeployment_sec - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Intune_AppDeployment_sec - Error "
        Write-Output @ErrorIcon
    }

    $Intune_AppDeployment_hotfix = (Test-NetConnection euprodimedatahotfix.azureedge.net -Port 443).TcpTestSucceeded
    If ($Intune_AppDeployment_hotfix -eq "True") {
        Write-Output -NoNewline -ForegroundColor DarkGreen "Intune_AppDeployment_hotfix - Success "
        Write-Output @CheckIcon
    }
    else {
        Write-Output -NoNewline -ForegroundColor DarkRed "Intune_AppDeployment_hotfix - Error "
        Write-Output @ErrorIcon
    }

    Write-Output `n

    $Global:ProgressPreference = $OriginalProgressPreference

    Read-Host -Prompt "Press Enter to exit"
}

function Get-TimeStamp {
    return "[{0:HH:mm:ss}]" -f (Get-Date)
}

function Write-Log {
    Param
    (
        $text
    )

    "$text" | out-file "c:\Autopilot_Import_GUI_log.txt" -Append -Force
}

Write-Log -text "--- Start Logging: $(Get-TimeStamp) ---"



#Time and Date

$timer1 = New-Object 'System.Windows.Forms.Timer'
$timer1_Tick = {
    $var_text_time.Text = (Get-Date).ToString("HH:mm:ss")
}

$timer1.Enabled = $True
$timer1.Interval = 1000 # in ms -> 1000 = Update clock every second
$timer1.add_Tick($timer1_Tick)

$var_text_date.Text = (Get-Date).ToString("MM/dd/yyyy")

#endregion

#Region Icons

$CheckIcon = @{
    Object          = [Char]8730
    ForegroundColor = 'Green'
    NoNewLine       = $false
}

$ErrorIcon = @{
    Object          = [Char]8709
    ForegroundColor = 'Red'
    NoNewLine       = $false
}
#endregion

#endregion

$var_button_grouptag.Add_Click{
    $Grouptag_input = $var_text_grouptag.text
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Selected Group Tag: $Grouptag_input")
}

$var_text_serialnumber.Text = (Get-WmiObject -class win32_bios).SerialNumber
$var_text_devicemodel.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
$var_text_devicename.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$var_text_manufacturer.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$var_text_freespace.Text = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID, @{'Name' = 'FreeSpace (GB)'; Expression = { [int]($_.FreeSpace / 1GB) } } | Measure-Object -Property 'FreeSpace (GB)' -Sum).Sum

$var_button_register.Add_Click{
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Installing Powershell Module Get-WindowsAutopilotInfo.")
    Write-Log -text "`r`n$(Get-TimeStamp) Installing Powershell Module Get-WindowsAutopilotInfo."
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Running import process.")
    Write-Log -text "`r`n$(Get-TimeStamp) Running import process."
    $scriptlocation = "$env:ProgramFiles\WindowsPowerShell\Scripts"
    Set-Location $scriptlocation
    $GroupTag = $var_text_grouptag.text

    if ([string]::IsNullOrWhiteSpace($GroupTag) -eq "True") {

        $Start_Register = (Start-Process PowerShell -Argumentlist "
        -NoExit
        #-NoProfile
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
        Install-PackageProvider -Name NuGet -Force
        Write-Output 'Installing Get-WindowsAutopilotInfo:'`n
        Install-Script -Name Get-WindowsAutoPilotInfo -Force

        Write-Output 'No Group Tag is selected'

        Write-Output 'Installing dependencies (Module: WindowsAutopilotIntune).'`n
        Write-Output 'Opening Login Window after the installation was successfull:'`n

        .\Get-WindowsAutopilotInfo.ps1 -online

        Write-Output 'Everything completed. Rebooting now ...'`n
        Start-Sleep -s 2
        Restart-Computer
        " -Wait)

    }
    else {

        $Start_Register = (Start-Process PowerShell -Argumentlist "
        -NoExit
        #-NoProfile
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
        Install-PackageProvider -Name NuGet -Force
        Write-Output 'Installing Get-WindowsAutopilotInfo:'`n
        Install-Script -Name Get-WindowsAutoPilotInfo -Force

        Write-Output 'Selected Group Tag: $GroupTag'

        Write-Output 'Installing dependencies (Module: WindowsAutopilotIntune).'`n
        Write-Output 'Opening Login Window after the installation was successfull:'`n

        .\Get-WindowsAutopilotInfo.ps1 -online -assign -GroupTag '$GroupTag' -reboot

        Write-Output 'Everything completed. Rebooting now ...'`n
        Start-Sleep -s 2
        Restart-Computer
        " -Wait)
    }

    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Running: Get-WindowsAutoPilotInfo.ps1 -GroupTag $GroupTag -online -assign -reboot")
    # Scroll to bottom of the output box.
    $var_text_output.ScrollToEnd()
}

if (Test-Connection 8.8.8.8 -Quiet -ErrorAction "SilentlyContinue") {
    Write-Output "Connected to the Internet."
    Write-Log -text "`r`n$(Get-TimeStamp) Connected to the Internet."
    $var_text_internet_connection.text = "Connected to the Internet."
    $var_text_internet_connection.Fontweight = "Bold"
    $var_text_internet_connection.Foreground = "#00a300"
}
else {
    Write-Output "Not connected to the Internet."
    Write-Log -text "`r`n$(Get-TimeStamp) Not connected to the Internet."
    $var_text_internet_connection.text = "Not connected to the Internet."
    $var_text_internet_connection.Fontweight = "Bold"
    $var_text_internet_connection.Foreground = "#a30000"
}

$var_button_check_connectivity.Add_Click{
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Running Network connectivity check.")
    Write-Log -text "`r`n$(Get-TimeStamp) Running Network connectivity check."
    $getfunction = (Get-Command -Type Function connectivity_check)
    $fullgetfunction = 'Function ' + $getfunction.Name + " {`n" + $getfunction.Definition + "`n}"

    Start-Process powershell -args '-noprofile', '-EncodedCommand', ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("$fullgetfunction; connectivity_check")))
}

$var_button_howto.Add_Click({
        $howToText = @"
1. Login and Register Device in AutoPilot: This will log you in and register your current device in Microsoft Autopilot.
2. Network Connectivity Check: This checks if your device is connected to the internet.
3. Device Information: This area displays relevant information about your device like the device model, name, manufacturer, serial number and available storage.
4. Save Group Tag: You can input a group tag for your device and save it using this functionality.
5. Start Windows Update: This will start the Windows Update process on your device.
6. Export Hash to CSV: This will export the hash of your device to a CSV file for future reference or use.
"@
        [System.Windows.MessageBox]::Show($howToText, "How does it work?")
    })

$var_text_author.Text = "@ugurkocde"

function Get-ScriptVersion {
    $ScriptName = "Get-WindowsAutopilotImportGUI"
    # Get the currently installed version
    $LocalVersion = (Get-InstalledScript -Name $ScriptName).Version
    return $LocalVersion
}

$var_text_version.text = "Version: " + (Get-ScriptVersion)

# Open GUI

$Null = $window.ShowDialog()