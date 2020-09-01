# TV Mimmick demonstrates how ctrlHue.ps1 can be reused in other scripts.
# This demo simulates a TV for either one group of a number of lights
# Run without any options to see the Help text
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
param (  
	[parameter(ParameterSetName="Lights", Position=0, Mandatory=$true)]        
	[ValidateNotNullOrEmpty()][ValidateRange(1, 100)] [int[]] $LIGHTS,
	[parameter(ParameterSetName="Group", Position=0, Mandatory=$true)]        
	[ValidateNotNullOrEmpty()][ValidateRange(0, 200)] [int] $GROUP,
	[parameter(Position=1)]
	[ValidateNotNullOrEmpty()][ValidateRange(1, 240)] [int] $MINUTES=60,
	
	
	#typically TV changes brightness more often then saturation and/or colors
	[ValidateRange(0, 100)] [int]$pctHUE=20,
	[ValidateRange(0, 100)] [int]$pctBRI=80,
	[ValidateRange(0, 100)] [int]$pctSAT=70,
	[ValidateRange(0, 100)] [int]$pctFreeze=20, 

	[parameter(ParameterSetName="Help", Position=0)]		
        [Alias('H')][Switch] $Help
)

if ($PsCmdlet.ParameterSetName.Equals("Help")) {
	write-host "TVMimmick.ps1 Calling syntax:"
	write-host "     .\TVMimmick.ps1 <-LIGHT|-GROUP Nr> [-Minutes <int>] [-pctHUE <int>] [-pctBRI <int>] [-pctSAT <int>] [-pctFreeze <int>]"
	exit 
}

#arbitrary start values
$HUE=0
$BRI=200
$SAT=200
$EndDate = (Get-Date) + (New-TimeSpan -min $MINUTES)

write-host "TV mimmick will automatically stop after $MINUTES. Press any key to stop earlier..."
write-host "Percentage of changes for HUE:$pctHUE%, BRI:$pctBRI%, SAT:$pctSAT%, Freezes:$pctFreeze% "

while ( [console]::KeyAvailable -eq $false ) {
    if ($EndDate -lt (Get-Date)) {
	   break
	}
	$Update=$false
    #Random Updates of Light Settings
	if ( (Get-Random 100) -le $pctHUE  ) {
	   $HUE = Get-Random -min 10000 -max 50000 #65535
	   $Update=$true
	   #write-host "change HUE: $HUE"
	}
	if ( (Get-Random 100) -le $pctBRI  ) {
	   $BRI = Get-Random -Minimum 100 -Maximum 254
	   $Update=$true
	   #write-host "change BRI: $BRI"
	}
	if ( (Get-Random 100) -le $pctSAT  ) {
	   $SAT = Get-Random -Minimum 10 -Maximum 254
	   $Update=$true
	   #write-host "change SAT: $SAT"
	}
	if ($Update) { #avoid useless commands to the bridge
		if ($PsCmdlet.ParameterSetName.Equals("Lights")) {
			foreach ($LIGHT in $LIGHTS) {
				& "$PSScriptRoot\ctrlhue.ps1" -light $LIGHT -on -hue $HUE -sat $SAT -bri $BRI -Transition 0 -silent
			}
			# short jitter in color changes; according the official HUE API the bridge can handle 10 light calls per sec
			#$duration =  50, 75, 75, 100, 125, 150 | Get-Random
			Start-Sleep -Milliseconds (100*$LIGHTS.count)
		}
		if ($PsCmdlet.ParameterSetName.Equals("Group")) {
			& "$PSScriptRoot\ctrlhue.ps1" -group $GROUP -on -hue $HUE -sat $SAT -bri $BRI -Transition 0 -silent
			# short jitter in color changes; according the official HUE API the bridge can handle 1 group call per sec
			#$duration =  800, 900, 1000 | Get-Random
			Start-Sleep -Milliseconds 1000
		}
	}
	#Random Freezes 
	if ( (Get-Random 100) -le $pctFreeze  ) {
	   $duration = Get-Random -min 1 -max 7
	   #write-host "Freeze: $duration"
	   Start-Sleep -s $duration
	}
}

write-host "End of TV mimmick animation..."
if ($PsCmdlet.ParameterSetName.Equals("Lights")) {
	foreach ($LIGHT in $LIGHTS) {
		& "$PSScriptRoot\ctrlhue.ps1" -light $LIGHT -off -silent
	}
}
if ($PsCmdlet.ParameterSetName.Equals("Group")) {
	& "$PSScriptRoot\ctrlhue.ps1" -group $GROUP -off -silent
}

exit
