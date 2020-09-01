#Toggle or Switch a light or group, optionally specify any additional setting like CT, HUE, Bri, Sat, incremental, effect, alert...
#Run without any options to see the Help text
#Special thanks to DARREN ROBINSON for his examples I used as inspiration: https://blog.kloud.com.au/2018/03/19/commanding-your-philips-hue-lights-with-powershell/ 
#
#MIT License, Copyright (c) <2020> <Eric Kreuwels>
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#

[CmdletBinding(DefaultParameterSetName = "Help")] 
param (  #Extensive use of ParameterSetNames to ensure only valid combination of options can be entered (no checking required in the code)
        [parameter(ParameterSetName="LightInfo", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="LightOff", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="LightOnSettings", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="LightToggle", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="LightAlert", Position=0,Mandatory=$true)]
        [ValidateNotNullOrEmpty()][ValidateRange(1, 99)][Alias('L')][int] $LIGHT, 

        [parameter(ParameterSetName="GroupInfo", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="GroupOff", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="GroupOnSettings", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="GroupToggle", Position=0,Mandatory=$true)]
        [parameter(ParameterSetName="GroupAlert", Position=0,Mandatory=$true)]
        [ValidateNotNullOrEmpty()][ValidateRange(0, 99)][Alias('G')][int] $GROUP, 
		
        [parameter(ParameterSetName="LightOnSettings", Position=1,Mandatory=$true)]
        [parameter(ParameterSetName="GroupOnSettings", Position=1,Mandatory=$true)]
        [Switch] $On, # on is part of settings so you can specify additional light properties like color or brightness
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(153, 500)][int] $CT, 
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(0, 65535)][int] $HUE,
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(0, 254)][int] $BRI,
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(0, 254)][int] $SAT,
				
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(-65534, 65534)][int] $CT_INC, 
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(-65534, 65534)][int] $HUE_INC,
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(-254, 254)][int] $BRI_INC,
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateRange(-254, 254)][int] $SAT_INC,
		
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [ValidateNotNullOrEmpty()][ValidateSet("none", "colorloop")][string] $Effect,

        [parameter(ParameterSetName="LightOff", Position=1,Mandatory=$true)]
        [parameter(ParameterSetName="GroupOff", Position=1,Mandatory=$true)]
        [Switch] $Off,

        [parameter(ParameterSetName="LightToggle", Position=1,Mandatory=$true)]
        [parameter(ParameterSetName="GroupToggle", Position=1,Mandatory=$true)]
        [Switch] $Toggle, 

        [parameter(ParameterSetName="LightToggle")]
        [parameter(ParameterSetName="GroupToggle")]
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="LightOff")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [parameter(ParameterSetName="GroupOff")]
        [parameter(ParameterSetName="Scene")]
        [ValidateNotNullOrEmpty()][ValidateRange(0,65535)][int] $TransitionTime,
		
        [parameter(ParameterSetName="LightAlert", Position=1,Mandatory=$true)]
        [parameter(ParameterSetName="GroupAlert", Position=1,Mandatory=$true)]
        [ValidateNotNullOrEmpty()][ValidateSet("none", "select", "lselect")][string] $Alert,

        [parameter(ParameterSetName="Scene", Position=0,Mandatory=$true)]
        [ValidateNotNullOrEmpty()][Alias('S')][string] $SCENE,
		
        [parameter(ParameterSetName="ListLights", Position=0,Mandatory=$true)]
        [Alias('LL')][Switch] $ListLights,
        [parameter(ParameterSetName="ListGroups", Position=0,Mandatory=$true)]
        [Alias('LG')][Switch] $ListGroups,
        [parameter(ParameterSetName="ListScenes", Position=0,Mandatory=$true)]
        [Alias('LS')][Switch] $ListScenes,

        [parameter(ParameterSetName="GroupInfo", Position=1)]
        [parameter(ParameterSetName="LightInfo", Position=1)]
        [parameter(ParameterSetName="ListGroups", Position=1)]
        [parameter(ParameterSetName="ListScenes", Position=1)]
		[parameter(ParameterSetName="ListLights", Position=1)]
        [Switch] $Raw,
		
        [parameter(ParameterSetName="LightToggle")]
        [parameter(ParameterSetName="GroupToggle")]
        [parameter(ParameterSetName="LightOnSettings")]
        [parameter(ParameterSetName="LightOff")]
        [parameter(ParameterSetName="GroupOnSettings")]
        [parameter(ParameterSetName="GroupOff")]
        [parameter(ParameterSetName="LightAlert")]
        [parameter(ParameterSetName="GroupAlert")]
        [parameter(ParameterSetName="Scene")]
        [Switch] $Silent, #surpress normal output, only errors
		
        [parameter(ParameterSetName="LinkBridge", Position=0,Mandatory=$true)]
        [String] $LinkBridge,
		
		[parameter(ParameterSetName="Help", Position=0)]		
        [Alias('H')][Switch] $Help
)

# ATTENTION! These Two lines below require a one time configuration:
#$hueBridge = "http://xxx.xxx.xxx.xxx/api"   # You can lookup your Bridge Ip address in the HUE app under Bridge info
#$username = "specify"                       # Enter your username. You can retrieve it using the -LinkBridge option

function ShowResults {
	param ( [parameter(Position=0,Mandatory=$true)] [string] $message )
	if (-not $Silent ) {
		Write-host $message
	}
}

function GetLightState { 
	param( [int] $number )
    $result = Invoke-RestMethod -Method Get -Uri "$($hueBridge)/$($username)/lights/$($number)"
    If ($result[0].error) {
		write-Host ($result | Format-Table | Out-String).Trim()
		exit $false
	}
	$name = $result.Name	
	if ($Raw) {
	  $rawinfo = $result | ConvertTo-Json
	  Write-Host "$rawinfo"
	}
	If ($result.State.on.Equals($false)) { 
		ShowResults "Light[$number] $name is OFF"
		return $false, $result.State.bri # bri is needed to fix transition bug in the  bridge API. Bri is lost when switching back on 
	} else {
		ShowResults "Light[$number] $name is ON"
		return $true, $result.State.bri
	}
}

function GetGroupState { 
	param( [int] $number )
 	$result = Invoke-RestMethod -Method Get -Uri "$($hueBridge)/$($username)/groups/$($number)"
    If ($result[0].error) {
		write-Host ($result | Format-Table | Out-String).Trim()
		exit $false
	}
	$name = $result.Name 	
	if ($Raw) {
	  $rawinfo = $result | ConvertTo-Json
 	  Write-Host "$rawinfo"
	}
	If ($result.State.any_on.Equals($false) ){
 	    ShowResults "Group[$number] $name is OFF" # bri is needed to fix transition bug in the  bridge API. Bri is lost when switching back on
		return $false, $result.action.bri
	} else {
	    ShowResults "Group[$number] $name is ON"
		return $true, $result.action.bri
	}
}

function ChkResponse { 
	param( $response )
	If ($response[0].success) {
		ShowResults ($response | Format-Table | Out-String).Trim()
		return $true
	}
	Write-Host ($response | Format-Table | Out-String).Trim()
	return $false
}


function ShowHelp { 
	write-host "CtrlHUE.ps1 Calling syntax:"
	write-host "   Options to display Light or Group information: "
	write-host "     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> [-Raw] "
	write-host "   Options to Toggle Light or Group (On/Off): "
	write-host "     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -toggle [-TransitionTime value] [-silent]"
	write-host "   Options to switch Light or Group OFF: "
	write-host "     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -OFF [-TransitionTime value] [-silent]"
	write-host "   Options to switch Group or Light ON. Optional with many additional Settings: "
	write-host "     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -ON [LightSettings] [-TransitionTime value] [-silent]"
	write-host "     Listing of the LightSettings:"
	write-host "       [-CT value]     : Color temp. Range(153-500). Note: 153 is Cold, 500 is Warm"
	write-host "       [-HUE value]    : HUE Color. Range(1-65535). Note: 1=65535=Red , 21845=Green, 43690=Blue"
	write-host "       [-Sat value]    : color saturation. Note: 0=min, 254=max"
	write-host "       [-Bri value]    : brightness. Note: 0=min, 254=max"
	write-host "       [-CT_INC value] : Incremental change (-65534, 65534)"
	write-host "       [-HUE_INC value]: Incremental change (-65534, 65534)"
	write-host "       [-Sat_INC value]: Incremental change (-254, 254)"
	write-host "       [-Bri_INC value]: Incremental change (-254, 254)"
	write-host "       [-Effect value] : none or colorloop=cycle through all HUEs for current brightness/saturation"
	write-host "   Options to trigger Group or Light Alert (select=blink short, lselect=15 seconds): "
	write-host "     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -Alert none|select|lselect  [-silent]"
	write-host "   Options to set a Scene. Use -ListScenes to lookup the required SceneID's: "
	write-host "     .\CtrlHUE.ps1 -SCENE SceneID [-TransitionTime value] [-silent]"
	write-host "   Listing Options. Use -Raw for Full JSON outputs: "
	write-host "     .\CtrlHUE.ps1 -ListLights  [-Raw] "
	write-host "     .\CtrlHUE.ps1 -ListGroups  [-Raw] "
	write-host "     .\CtrlHUE.ps1 -ListScenes  [-Raw] "
	write-host "   Interactive option to link your HUE bridge (typically a one time action): "
	write-host "   You can lookup your Bridge Ip address in the HUE app under Bridge info,"
	write-host "   to enter it in the format xxx.xxx.xxx.xxx for the -LinkBridge option:"
	write-host "     .\CtrlHUE.ps1 -LinkBridge Bridge_IP_Address "
	write-host "   Additional info on some parameters:"
	write-host "     Light         : number (1-99), Note: use -ListLights to look them up" 
	write-host "     Group         : number (0-99), Note: use -ListGroups to look them up"
	write-host "     TransitionTime: transition time in steps of 100msec. Default=4(400msec)"
	write-host "     Raw           : show requested information in Full JSON"
	write-host "     Silent        : Only show errors"
	write-host "   Aliases for some parameters:"
	write-host "     L  = Light" 
	write-host "     G  = Group"
	write-host "     S  = Scene"
	write-host "     LL = ListLights"
	write-host "     LG = ListGroups"
	write-host "     LS = ListScenes"
	write-host "   Examples:"
	write-host "     .\ctrlhue -S vLfBECf9gpnS1mm" 
	write-host "     .\ctrlhue -L 2 -on -CT 300 -SAT 200 -BRI 150 -tra 20"
}


if ($PsCmdlet.ParameterSetName.Equals("Help")) {
	ShowHelp
	exit $true
}

if ($PsCmdlet.ParameterSetName.Equals("LinkBridge")) {
    $body = '{"devicetype":"CtrlHUE.ps1#' + $env:computername + '"}'
	#$body
	write-host "Linking the HUE bridge is typically needed once. This option will retieve a username string needed in this script."
	write-host "Please press the link button on your HUE bridge."
	read-host  "Then within 60 seconds, Press ENTER to continue..."
    $result = Invoke-RestMethod -Method POST -Uri "http://$($LinkBridge)/api" -Body $body
    If ($result[0].error) {
	 write-host "Link failed due Error: $($Result[0].error.description)"
	}
    ElseIf ($result[0].success) {
	 write-host "Success! You can copy $($Result[0].success.username) and $LinkBridge into the script like this:" 
	 $line = '$HueBridge="'+"http://$LinkBridge/api"+'"'
	 write-host $line
	 $line = '$username="'+$Result[0].success.username+'"' 
	 write-host $line
	 exit $true
    }
	Else {
     write-host "Link process failed. Check error below:"
     $result
	}
	exit $false
}

############################################################################ 
# From here onwards the script needs to be configured! A quick Check:
if ($Username.Contains("specify")  -or $HueBridge.Contains("xxx.xxx.xxx.xxx")) {
    write-host "ATTENTION: This Script needs to be configured before it can used to control the HUE Bridge!"
    write-host '           Two parameters need to be set (using an text editor): $HueBridge and $username'
	write-host '$HueBridge: Replace  <xxx.xxx.xxx.xxx> in $HueBridge with your Bridge IP Address (e.g. 192.168.0.30)'
	write-host "            Note: You can lookup your Bridge Ip address in the HUE app under Bridge info"
	write-host '$username : You can call this script with -LinkBridge to link the HUE Bridge. '
	write-host '            Replace <specify> in $username with the username provided by the output of this script'
	write-host "Once these two parameters in this script are configured, the script is ready to control HUE..."
	exit $false
}
############################################################################ 
# It is configured! Continue:

if ($PsCmdlet.ParameterSetName.Equals("LightInfo")) {
    $result = GetLightState $LIGHT
	exit $result[0]
}

if ($PsCmdlet.ParameterSetName.Equals("GroupInfo")) {
	$result = GetGroupState $GROUP
	exit $result[0]
}


if ($PsCmdlet.ParameterSetName.Equals("LightToggle")) { 
	#toggle the specified light
	$result = GetLightState $LIGHT
	if ( $result[0] ) {
	    $options = @{"on"=$false} 
	    ShowResults "turning Light $LIGHT OFF"
	} else {
       	$options = @{"on"=$true}  
		if ($result[1]) {
			$options.add("bri", $result[1]) # bri is needed to fix transition bug in the  bridge API.
		}
 	 	ShowResults "turning Light $LIGHT ON"
    }
 	if ($PSBoundParameters.ContainsKey('TransitionTime')) {
		$options.add("transitiontime", $TransitionTime)
	}
    $body = $options | ConvertTo-Json
	$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/lights/$($LIGHT)/state" -Body $body
    exit ChkResponse($result)
}

if ($PsCmdlet.ParameterSetName.Equals("GroupToggle")) { 
	#toggle the specified light
	$result = GetGroupState $GROUP
	if ( $result[0] ) {
	    $options = @{"on"=$false}  
	    ShowResults "turning Group $GROUP OFF"
	} else {
       	$options = @{"on"=$true}  
		if ($result[1]) {
			$options.add("bri", $result[1]) # bri is needed to fix transition bug in the  bridge API.
		}
 	 	ShowResults "turning Group $GROUP ON"
    }
 	if ($PSBoundParameters.ContainsKey('TransitionTime')) {
		$options.add("transitiontime", $TransitionTime)
	}
    $body = $options | ConvertTo-Json
	$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/groups/$($GROUP)/action" -Body $body
    exit ChkResponse($result)
}

if ($PsCmdlet.ParameterSetName.Equals("LightOnSettings") -or $PsCmdlet.ParameterSetName.Equals("GroupOnSettings")) {
	# set Light CT or HUE as specified
	$options = @{"on"=$true}
	if ($PSBoundParameters.ContainsKey('CT')) {
		$options.add("ct", $CT)
	}
	if ($PSBoundParameters.ContainsKey('HUE')) {
		$options.add("hue", $HUE)
	}
	if ($PSBoundParameters.ContainsKey('BRI')) {
		$options.add("bri", $BRI)
	}
	if ($PSBoundParameters.ContainsKey('SAT')) {
		$options.add("sat", $SAT)
	}
	if ($PSBoundParameters.ContainsKey('CT_INC')) {
		$options.add("ct_inc", $CT_INC)
	}
	if ($PSBoundParameters.ContainsKey('HUE_INC')) {
		$options.add("hue_inc", $HUE_INC)
	}
	if ($PSBoundParameters.ContainsKey('BRI_INC')) {
		$options.add("bri_inc", $BRI_INC)
	}
	if ($PSBoundParameters.ContainsKey('SAT_INC')) {
		$options.add("sat_inc", $SAT_INC)
	}
	if ($PSBoundParameters.ContainsKey('Effect')) {
		$options.add("effect", $Effect)
	}
 	if ($PSBoundParameters.ContainsKey('TransitionTime')) {
		$options.add("transitiontime", $TransitionTime)
	}
    $body = $options | ConvertTo-Json
	if ($PSBoundParameters.ContainsKey('LIGHT')) {
		ShowResults "Light $LIGHT will be set ON as specified"
		$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/lights/$($LIGHT)/state" -Body $body
	} else {
		ShowResults "Group $GROUP will be set ON as specified"
		$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/groups/$($GROUP)/action" -Body $body
	}
	exit ChkResponse($result)
} 

if ($PsCmdlet.ParameterSetName.Equals("LightOff")) {
	$options = @{"on"=$false} 
	ShowResults "turning Light $LIGHT OFF"
 	if ($PSBoundParameters.ContainsKey('TransitionTime')) {
		$options.add("transitiontime", $TransitionTime)
	}
    $body = $options | ConvertTo-Json
	$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/lights/$($LIGHT)/state" -Body $body
	exit ChkResponse($result)
}

if ($PsCmdlet.ParameterSetName.Equals("GroupOff")) {
    $options = @{"on"=$false} 
	ShowResults "turning Group $Group OFF"
 	if ($PSBoundParameters.ContainsKey('TransitionTime')) {
		$options.add("transitiontime", $TransitionTime)
	}
    $body = $options | ConvertTo-Json
	$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/groups/$($GROUP)/action" -Body $body
	exit ChkResponse($result)
}


if ($PsCmdlet.ParameterSetName.Equals("Scene")) {
    $options = @{"scene"=$SCENE}
 	ShowResults "Activating scene $SCENE"
 	if ($PSBoundParameters.ContainsKey('TransitionTime')) {
		$options.add("transitiontime", $TransitionTime)
	}
    $body = $options | ConvertTo-Json
	$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/groups/0/action" -Body $body
	exit ChkResponse($result)
}

if ($PsCmdlet.ParameterSetName.Equals("ListLights")) {
 	$result = Invoke-RestMethod -Method Get -Uri "$($hueBridge)/$($username)/lights"
	If ($result[0].error) {
		Write-Host ($result | Format-Table | Out-String).Trim()
		exit $false
	}
	write-host "Lights Listing:"
	if ($Raw) {
		$result = $result | ConvertTo-Json
		Write-Host ($result | Format-Table | Out-String).Trim()
	} else {
		$lights = $result.PSObject.Members | Where-Object {$_.MemberType -eq "NoteProperty"}
		foreach ($item in $lights) {
		   $number = $item | Select-Object Name -ExpandProperty Name
		   $name = $item.Value | Select-Object Name -ExpandProperty Name	
		   $deviceType = $item.Value | Select-Object type -ExpandProperty type
		   $currentState = $item.Value | select state	   
		   If ($currentState.state.on.Equals($false) ){
				write-host "Light[$number]=$name (type:$deviceType, State:OFF)"
		   } else {
				write-host "Light[$number]=$name (type:$deviceType, State:ON)"
		   }
		}
	}
	exit $true
}

if ($PsCmdlet.ParameterSetName.Equals("ListGroups")) {
 	$result = Invoke-RestMethod -Method Get -Uri "$($hueBridge)/$($username)/groups"
	If ($result[0].error) {
		Write-Host ($result | Format-Table | Out-String).Trim()
		exit $false
	}
	write-host "Group Listing:"
	if ($Raw) {
		$result = $result | ConvertTo-Json
		Write-Host ($result | Format-Table | Out-String).Trim()
	} else {
		$groups = $result.PSObject.Members | Where-Object {$_.MemberType -eq "NoteProperty"}
		foreach ($item in $groups) {
		    $number = $item | Select-Object Name -ExpandProperty Name
			$list = $item.value | Select-Object Lights -ExpandProperty Lights
			$friendly_name = $item.Value | Select-Object Name -ExpandProperty Name	   
			write-host "Group[$number]=$friendly_name (Lights[$list])"
		}
	}
	exit $true
}

if ($PsCmdlet.ParameterSetName.Equals("ListScenes")) {
 	$result = Invoke-RestMethod -Method Get -Uri "$($hueBridge)/$($username)/scenes"
	If ($result[0].error) {
		Write-Host ($result | Format-Table | Out-String).Trim()
		exit $false
	}
	write-host "Scene Listing:"
	if ($Raw) {
		$result = $result | ConvertTo-Json
		Write-Host ($result | Format-Table | Out-String).Trim()
	} else {
		$scenes = $result.PSObject.Members | Where-Object {$_.MemberType -eq "NoteProperty"}
		foreach ($item in $scenes) {
		   #$item
		   if ($item.Value.type.equals("GroupScene") ) {
				$name = $item | Select-Object Name -ExpandProperty Name
				$number = $item.value | Select-Object Group -ExpandProperty Group
				$friendly_name = $item.Value | Select-Object Name -ExpandProperty Name	   
				write-host "GroupScene [$friendly_name] of group[$number], Use this SceneID: $name"
		   }
		   if ($item.Value.type.equals("LightScene") ) {
				$name = $item | Select-Object Name -ExpandProperty Name
				$number = $item.value | Select-Object Lights -ExpandProperty Lights
				$friendly_name = $item.Value | Select-Object Name -ExpandProperty Name	   
				write-host "LightScene [$friendly_name] of Lights[$number], Use this SceneID: $name"
		   }
		}
	}
	exit $true
}

if ($PsCmdlet.ParameterSetName.Equals("LightAlert")) {
    $body = @{"alert"=$Alert} | ConvertTo-Json
 	ShowResults "Set Alert $Alert for Light $LIGHT"
	$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/lights/$($LIGHT)/state" -Body $body
	exit ChkResponse($result)
}

if ($PsCmdlet.ParameterSetName.Equals("GroupAlert")) {
    $body = @{"alert"=$Alert} | ConvertTo-Json
 	ShowResults "Set Alert $Alert for Group $GROUP "
	$result = Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/groups/$($GROUP)/action" -Body $body
	exit ChkResponse($result)
}

# If this point is reached, the ParameterSet was not handled
write-host "Script ERROR, nothing done..."
exit $false



