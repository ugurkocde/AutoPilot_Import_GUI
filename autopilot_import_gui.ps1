<#
    .SYNOPSIS
    GUI to import Device to Autopilot.

    MIT LICENSE
    Copyright (c) 2022 Ugur Koc
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

    .DESCRIPTION
    The goal of this script is to help with the import process of a device into AutoPilot and simplifying this by using a User Interface (GUI). You will be able to select a Group Tag if you use them and the script will reboot after the deployment profile was successfully assigned. It will also help to troubleshoot possible Network requirements by running a connectivitiy check. This GUI uses the Powershell Script Get-WindowsAutoPilotInfo of Michael Niehaus.

    .EXAMPLE
    Blog post with examples and explanations @ ugurkoc.de

    .LINK
    Online version: http://www.fabrikam.com/extension.html

    .LINK
    Github: https://github.com/ugurkocde/AutoPilot_Import_GUI
#>


Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# XAML file
$xamlFile = @'
<Window x:Class="WpfApp2.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp2"
        mc:Ignorable="d"
        ResizeMode="NoResize"
        Title="Autopilot Import GUI with Group Tag" Height="576" Width="399">
    <Grid Background="White">
        <Grid.RowDefinitions>
            <RowDefinition Height="33*"/>
            <RowDefinition Height="29*"/>
        </Grid.RowDefinitions>
        <Rectangle HorizontalAlignment="Left" Height="108" Margin="30,104,0,0" Stroke="Black" VerticalAlignment="Top" Width="331"/>
        <ComboBox x:Name="dropdown" HorizontalAlignment="Left" Margin="29,242,0,0" VerticalAlignment="Top" Width="330" Height="30" FontSize="18" IsEditable="True" BorderBrush="White" FontStyle="Italic">
            <ComboBox.Background>
                <LinearGradientBrush EndPoint="0,1">
                    <GradientStop Color="#FFF0F0F0"/>
                    <GradientStop Color="White" Offset="1"/>
                </LinearGradientBrush>
            </ComboBox.Background>
        </ComboBox>
        <Button x:Name="button_register" Content="Login and register device in AutoPilot" HorizontalAlignment="Left" Margin="29,282,0,0" VerticalAlignment="Top" Width="330" Height="26" Background="#FF8EFF8B" Grid.RowSpan="2" FontWeight="Bold"/>
        <TextBlock x:Name="text_author" HorizontalAlignment="Left" Margin="236,233,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Grid.Row="1"><Run Language="de-de" Text="Author"/></TextBlock>
        <TextBlock x:Name="text_version" HorizontalAlignment="Left" Margin="320,233,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Grid.Row="1"><Run Language="de-de" Text="Version"/></TextBlock>
        <TextBlock HorizontalAlignment="Left" Margin="30,221,0,0" TextWrapping="Wrap" VerticalAlignment="Top" FontWeight="Bold" Width="117"><Run Text="Choose Group"/><Run Language="de-de" Text=" T"/><Run Text="ag:"/></TextBlock>
        <TextBox x:Name="text_output" HorizontalAlignment="Left" Margin="29,67,0,0" TextWrapping="WrapWithOverflow" VerticalAlignment="Top" Width="330" Height="161" IsReadOnly="True" HorizontalScrollBarVisibility="Visible" VerticalScrollBarVisibility="Visible" Grid.Row="1"/>
        <Button x:Name="button_check_connectivity" Content="Run Network Connectivity Check" HorizontalAlignment="Left" Margin="29,30,0,0" VerticalAlignment="Top" Width="330" Height="26" Background="#FFA1CEFF" Grid.Row="1" FontWeight="Bold"/>
        <TextBlock HorizontalAlignment="Left" Margin="16,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="356" FontSize="20" TextAlignment="Center" FontWeight="Bold"><Run Language="de-de" Text="Autopilot Import GUI with Group Tag"/></TextBlock>
        <TextBlock HorizontalAlignment="Left" Margin="239,94,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Background="White" Width="110" TextAlignment="Center" Height="19" FontWeight="Bold" FontStyle="Italic"><Run Language="de-de" Text="Device Information"/></TextBlock>
        <Button x:Name="button_howto" Content="How does it work?" HorizontalAlignment="Left" Margin="30,64,0,0" VerticalAlignment="Top" Background="White" Width="127"/>
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
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
   }
}

# Get-Variable var_*


# function
function connectivity_check {

    $ErrorActionPreference = 'SilentlyContinue'
    $WarningPreference = 'SilentlyContinue'
    $OriginalProgressPreference = $Global:ProgressPreference
    $Global:ProgressPreference = 'SilentlyContinue'

    $ComputerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
    $ComputerName = $ComputerInfo.Name
    $Serialnumber = Get-CimInstance win32_SystemEnclosure | select serialnumber

    Write-Host "--- Basic Info ---"

    Write-Host "Computername:" $ComputerName
    Write-Host "Serialnumber:" $Serialnumber.serialnumber

    Write-Host `n

    # MDM Registration Test reachability
    # https://docs.microsoft.com/de-de/mem/intune/enrollment/windows-enroll

    Write-Host -BackgroundColor DarkBlue "--- Checking connectivity for: Enterprise regitration  ---" 

    $MDM_registration = (Test-NetConnection enterpriseregistration.windows.net -Port 443 ).TcpTestSucceeded
    If($MDM_registration -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "MDM_registration - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "MDM_registration - Error "
        Write-Host @ErrorIcon
    }

    $MDM_enrollment = (Test-NetConnection enterpriseenrollment-s.manage.microsoft.com -Port 443 ).TcpTestSucceeded
    If($MDM_enrollment -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "MDM_enrollment - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "MDM_enrollment - Error "
        Write-Host @ErrorIcon
    }
    

    Write-Host `n

    # Autopilot Test reachability
    # https://docs.microsoft.com/de-de/mem/autopilot/networking-requirements

    Write-Host -BackgroundColor DarkBlue "--- Checking connectivity for: Windows Autopilot Deployment Services ---" 

    $AutoPilot_ztd = (Test-NetConnection ztd.dds.microsoft.com -Port 443 ).TcpTestSucceeded
    If($AutoPilot_ztd -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "AutoPilot_ztd - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "AutoPilot_ztd - Error "
        Write-Host @ErrorIcon
    }

    $AutoPilot_cs = (Test-NetConnection cs.dds.microsoft.com -Port 443 ).TcpTestSucceeded
    If($AutoPilot_cs -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "AutoPilot_cs - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "AutoPilot_cs - Error "
        Write-Host @ErrorIcon
    }

    $AutoPilot_login = (Test-NetConnection login.live.com -Port 443 ).TcpTestSucceeded
    If($AutoPilot_login -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "AutoPilot_login - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "AutoPilot_login - Error "
        Write-Host @ErrorIcon
    }

    Write-Host `n

    # License Test reachability
    # https://support.microsoft.com/en-us/topic/windows-activation-or-validation-fails-with-Error -code-0x8004fe33-a9afe65e-230b-c1ed-3414-39acd7fddf52

    Write-Host -BackgroundColor DarkBlue "--- Checking connectivity for: License activation service ---" 

    $Licensing_activation = (Test-NetConnection activation.sls.microsoft.com -Port 443 ).TcpTestSucceeded
    If($Licensing_activation -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Licensing_activation - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Licensing_activation - Error "
        Write-Host @ErrorIcon
    }

    $Licensing_validation = (Test-NetConnection validation.sls.microsoft.com -Port 443 ).TcpTestSucceeded
    If($Licensing_validation -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Licensing_validation - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Licensing_validation - Error "
        Write-Host @ErrorIcon
    }

    Write-Host `n

    # WufB Test reachability

    Write-Host -BackgroundColor DarkBlue "--- Checking connectivity for: Windows Update for Business Service ---"

    $WufB = (Test-NetConnection update.microsoft.com -Port 443 ).TcpTestSucceeded
    If($WufB -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "WufB - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "WufB - Error "
        Write-Host @ErrorIcon
    }

    Write-Host `n

    # SSO Test reachability

    Write-Host -BackgroundColor DarkBlue "--- Checking connectivity for: Single Sign-On  ---"

    $SSO = (Test-NetConnection autologon.microsoftazuread-sso.com -Port 443 ).TcpTestSucceeded
    If($SSO -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "SSO - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "SSO - Error "
        Write-Host @ErrorIcon
    }

    Write-Host `n

    # TPM Test reachability
    # https://docs.microsoft.com/de-de/mem/autopilot/networking-requirements

    Write-Host -BackgroundColor DarkBlue "--- TPM Connectivity to Intel, Qualcomm and AMD ---" 

    $TPM_Intel = (Test-NetConnection ekop.intel.com -Port 443).TcpTestSucceeded
    If($TPM_Intel -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "TPM_Intel - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "TPM_Intel - Error "
        Write-Host @ErrorIcon
    }

    $TPM_Qualcomm = (Test-NetConnection ekcert.spserv.microsoft.com -Port 443).TcpTestSucceeded
    If($TPM_Qualcomm -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "TPM_Qualcomm - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "TPM_Qualcomm - Error "
        Write-Host @ErrorIcon
    }

    $TPM_AMD = (Test-NetConnection ftpm.amd.com -Port 443).TcpTestSucceeded
    If($TPM_AMD -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "TPM_AMD - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "TPM_AMD - Error "
        Write-Host @ErrorIcon
    }

    $TPM_Azure = (Test-NetConnection azure.net -Port 443).TcpTestSucceeded 
    If($TPM_Azure -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "TPM_Azure - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "TPM_Azure - Error "
        Write-Host @ErrorIcon
    }

    Write-Host `n

    # Intune (Config deployment) Test reachability

    Write-Host -BackgroundColor DarkBlue "--- Checking connectivity for: Config deployment and access for managed devices ---"

    $Intune_ConfigDeployment_microsoftonline = (Test-NetConnection login.microsoftonline.com -Port 443).TcpTestSucceeded
    If($Intune_ConfigDeployment_microsoftonline -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Intune_ConfigDeployment_microsoftonline - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Intune_ConfigDeployment_microsoftonline - Error "
        Write-Host @ErrorIcon
    }

    $Intune_ConfigDeployment_configoffice = (Test-NetConnection config.office.com -Port 443).TcpTestSucceeded
    If($Intune_ConfigDeployment_configoffice -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Intune_ConfigDeployment_configoffice - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Intune_ConfigDeployment_configoffice - Error "
        Write-Host @ErrorIcon
    }

    $Intune_ConfigDeployment_graph = (Test-NetConnection graph.windows.net -Port 443).TcpTestSucceeded
    If($Intune_ConfigDeployment_graph -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Intune_ConfigDeployment_graph - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Intune_ConfigDeployment_graph - Error "
        Write-Host @ErrorIcon
    }

    Write-Host `n

    # Intune (POSH and Win32 Apps deployment) Test reachability

    Write-Host -BackgroundColor DarkBlue "--- Checking connectivity for: Network requirements for PowerShell scripts and Win32 apps ---"

    $Intune_AppDeployment_pri = (Test-NetConnection euprodimedatapri.azureedge.net -Port 443).TcpTestSucceeded
    If($Intune_AppDeployment_pri -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Intune_AppDeployment_pri - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Intune_AppDeployment_pri - Error "
        Write-Host @ErrorIcon
    }

    $Intune_AppDeployment_sec = (Test-NetConnection euprodimedatasec.azureedge.net -Port 443).TcpTestSucceeded
    If($Intune_AppDeployment_sec -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Intune_AppDeployment_sec - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Intune_AppDeployment_sec - Error "
        Write-Host @ErrorIcon
    }

    $Intune_AppDeployment_hotfix = (Test-NetConnection euprodimedatahotfix.azureedge.net -Port 443).TcpTestSucceeded
    If($Intune_AppDeployment_hotfix -eq "True"){
        Write-Host -NoNewline -ForegroundColor DarkGreen "Intune_AppDeployment_hotfix - Success "
        Write-Host @CheckIcon
    } else {
        Write-Host -NoNewline -ForegroundColor DarkRed "Intune_AppDeployment_hotfix - Error "
        Write-Host @ErrorIcon
    }

    Write-Host `n

    $Global:ProgressPreference = $OriginalProgressPreference

    Read-Host -Prompt "Press Enter to exit"
}

function Get-TimeStamp {
    return "[{0:HH:mm:ss}]" -f (Get-Date)
}

function Write-Log
{
    Param
    (
        $text
    )

    "$text" | out-file "c:\Autopilot_Import_GUI_log.txt" -Append -Force
}

Write-Log -text "--- Start Logging: $(Get-TimeStamp) ---"



#Time and Date

$timer1 = New-Object 'System.Windows.Forms.Timer'
$timer1_Tick={
    $var_text_time.Text = (Get-Date).ToString("HH:mm:ss")
}

$timer1.Enabled = $True
$timer1.Interval = 1000 # in ms -> 1000 = Update clock every second
$timer1.add_Tick($timer1_Tick)

$var_text_date.Text = (Get-Date).ToString("MM:dd:yyyy")

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


# Add Grouptags:
$var_dropdown.Items.Add("")
$var_dropdown.Items.Add("GroupTag 1")
$var_dropdown.Items.Add("GroupTag 2")
$var_dropdown.Items.Add("GroupTag 3")
$var_dropdown.Items.Add("GroupTag 4")
$var_dropdown.Items.Add("GroupTag 5")
$var_dropdown.Items.Add("GroupTag 6")

$var_text_serialnumber.Text = (Get-WmiObject -class win32_bios).SerialNumber
$var_text_devicemodel.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
$var_text_devicename.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$var_text_manufacturer.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$var_text_freespace.Text = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }} | Measure-Object -Property 'FreeSpace (GB)' -Sum).Sum

$var_dropdown.Add_SelectionChanged(
    {
    $grouptag_list = $var_dropdown.selectedItem
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Selected Group Tag: " + $grouptag_list)
    $GroupTag = $grouptag_list
    $var_text_output.ScrollToEnd()
    })



$var_button_register.Add_Click{
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Installing Powershell Module Get-WindowsAutopilotInfo.")
    Write-Log -text "`r`n$(Get-TimeStamp) Installing Powershell Module Get-WindowsAutopilotInfo."
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Running import process.")
    Write-Log -text "`r`n$(Get-TimeStamp) Running import process."
    $scriptlocation = "$env:ProgramFiles\WindowsPowerShell\Scripts"
    cd  $scriptlocation
    $grouptag_list = $var_dropdown.selectedItem
    $GroupTag = $grouptag_list

    if ([string]::IsNullOrWhiteSpace($GroupTag) -eq "True"){
        

        $Start_Register = (Start-Process PowerShell -Argumentlist "
        -NoExit
        #-NoProfile
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned 
        Install-PackageProvider -Name NuGet -Force
        Write-Host 'Installing Get-WindowsAutopilotInfo:'`n
        Install-Script -Name Get-WindowsAutoPilotInfo -Force
        
        Write-Host 'No Group Tag is selected'
        
        Write-Host 'Installing dependencies (Module: WindowsAutopilotIntune).'`n
        Write-Host 'Opening Login Window after the installation was successfull:'`n

        .\Get-WindowsAutopilotInfo.ps1 -online
        
        Write-Host 'Everything completed. Rebooting now ...'`n
        Start-Sleep -s 2
        Restart-Computer
        " -Wait)


    } else {

        $Start_Register = (Start-Process PowerShell -Argumentlist "
        -NoExit
        #-NoProfile
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned 
        Install-PackageProvider -Name NuGet -Force
        Write-Host 'Installing Get-WindowsAutopilotInfo:'`n
        Install-Script -Name Get-WindowsAutoPilotInfo -Force
        
        Write-Host 'Selected $GroupTag'

        Write-Host 'Installing dependencies (Module: WindowsAutopilotIntune).'`n
        Write-Host 'Opening Login Window after the installation was successfull:'`n

        .\Get-WindowsAutopilotInfo.ps1 -online -assign -GroupTag '$GroupTag' -reboot
        
        Write-Host 'Everything completed. Rebooting now ...'`n
        Start-Sleep -s 2
        Restart-Computer
        " -Wait)
    }



                                    
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Running: Get-WindowsAutoPilotInfo.ps1 -GroupTag $GroupTag -online -assign -reboot")
     # Scroll to bottom of the output box.
    $var_text_output.ScrollToEnd()
}


if (Test-Connection 8.8.8.8 -Quiet -ErrorAction "SilentlyContinue"){
    Write-Host "Internet connection available."
    Write-Log -text "`r`n$(Get-TimeStamp) Connected to the Internet."
    $var_text_internet_connection.text = "Internet connection available."
    $var_text_internet_connection.Fontweight = "Bold"
    $var_text_internet_connection.Foreground = "#00a300"
} else {
    Write-Host "Internet connection not available."
    Write-Log -text "`r`n$(Get-TimeStamp) Not connected to the Internet."
    $var_text_internet_connection.text = "Internet connection not available."
    $var_text_internet_connection.Fontweight = "Bold"
    $var_text_internet_connection.Foreground = "#a30000"
}


$var_button_check_connectivity.Add_Click{
    $var_text_output.AppendText("`r`n$(Get-TimeStamp) Running Network connectivity check.")
    Write-Log -text "`r`n$(Get-TimeStamp) Running Network connectivity check."
    $getfunction = (Get-Command -Type Function connectivity_check)
    $fullgetfunction = 'Function ' + $getfunction.Name + " {`n" + $getfunction.Definition + "`n}"

    Start-Process powershell -args '-noprofile', '-EncodedCommand', ` ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("$fullgetfunction; connectivity_check")))
}

$var_button_howto.Add_Click{
    Start-Process www.ugurkoc.de
}

$var_text_author.Text = "Ugur Koc"
$var_text_version.text = "Version 0.1"


# Open GUI

$Null = $window.ShowDialog()