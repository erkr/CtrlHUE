# CtrlHUE

Power-Shell based control script for setting lights, groups or scenes on the Philips HUE bridge

The script provides control for all Light and Group options in the HUE API
You can Toggle or Switch a light or group, optionally specify any of the additional setting:
Fixed CT,HUE,Bri,Sat, incremental CT,HUE,Bri,Sat, effect, alert...

First time the bridge IP address and a valid username need to be edited in the script. 
The -LinkBridge option makes it easier to get a username. 

## Link Bridge Example:

```
PS C:\Install> .\ctrlhue -link 192.168.1.100
Linking the HUE bridge is typically needed once. This option will retieve a username string needed in this script. 
Please press the link button on your HUE bridge. 
Then within 60 seconds, Press ENTER to continue...: 

Success! You can copy 6yozxxxxxxxxxxxx-cAh6vTidP7OEGyj58Sxxxxxj58S and 192.168.1.100 into the script like this: 
$HueBridge="http://192.168.1.100/api"
$username="6yozxxxxxxxxxxxx-cAh6vTidP7OEGyj58Sxxxxxj58S" 
PS C:\Install> 
```

## Run the script without options to get help for listing the calling syntax:

```
PS C:\Install> .\ctrlhue
CtrlHUE.ps1 Calling syntax:
   Options to display Light or Group information:
     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> [-Raw]
   Options to Toggle Light or Group (On/Off):
     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -toggle [-TransitionTime value] [-silent]
   Options to switch Light or Group OFF:
     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -OFF [-TransitionTime value] [-silent]
   Options to switch Group or Light ON. Optional with many additional Settings:
     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -ON [LightSettings] [-TransitionTime value] [-silent]
     Listing of the LightSettings:
       [-CT value]     : Color temp. Range(153-500). Note: 153 is Cold, 500 is Warm
       [-HUE value]    : HUE Color. Range(1-65535). Note: 1=65535=Red , 21845=Green, 43690=Blue
       [-Sat value]    : color saturation. Note: 0=min, 254=max
       [-Bri value]    : brightness. Note: 0=min, 254=max
       [-CT_INC value] : Incremental change (-65534, 65534)
       [-HUE_INC value]: Incremental change (-65534, 65534)
       [-Sat_INC value]: Incremental change (-254, 254)
       [-Bri_INC value]: Incremental change (-254, 254)
       [-Effect value] : none or colorloop=cycle through all HUEs for current brightness/saturation
   Options to trigger Group or Light Alert (select=blink short, lselect=15 seconds):
     .\CtrlHUE.ps1 <-LIGHT|-GROUP Nr> -Alert none|select|lselect  [-silent]
   Options to set a Scene. Use -ListScenes to lookup the required SceneID's:
     .\CtrlHUE.ps1 -SCENE SceneID [-TransitionTime value] [-silent]
   Listing Options. Use -Raw for Full JSON outputs:
     .\CtrlHUE.ps1 -ListLights  [-Raw]
     .\CtrlHUE.ps1 -ListGroups  [-Raw]
     .\CtrlHUE.ps1 -ListScenes  [-Raw]
   Interactive option to link your HUE bridge (typically a one time action):
   You can lookup your Bridge Ip address in the HUE app under Bridge info,
   to enter it in the format xxx.xxx.xxx.xxx for the -LinkBridge option:
     .\CtrlHUE.ps1 -LinkBridge Bridge_IP_Address
   Additional info on some parameters:
     Light         : number (1-99), Note: use -ListLights to look them up
     Group         : number (0-99), Note: use -ListGroups to look them up
     TransitionTime: transition time in steps of 100msec. Default=4(400msec)
     Raw           : show requested information in Full JSON
     Silent        : Only show errors
   Aliases for some parameters:
     L  = Light
     G  = Group
     S  = Scene
     LL = ListLights
     LG = ListGroups
     LS = ListScenes
   Examples:
     .\ctrlhue -S vLfBECf9gpnS1mm
     .\ctrlhue -L 2 -on -CT 300 -SAT 200 -BRI 150 -tra 20
PS C:\Install>
```
## Some calling examples:
```
PS C:\Install> .\ctrlhue -listgroups
Group Listing:
Group[1]=Bureau (Lights[3 7])
Group[2]=Living (Lights[1 3 4 5 7])
Group[3]=Kitchen (Lights[2 6])
Group[4]=Bedroom (Lights[15 26])
...
PS C:\Install>
PS C:\Install> .\ctrlhue -listlights
Lights Listing:
Light[1]=Couch  (type:On/Off plug-in unit, State:ON)
Light[2]=Table (type:On/Off plug-in unit, State:ON)
Light[3]=Drawer (type:On/Off plug-in unit, State:OFF)
Light[4]=Door (type:Dimmable light, State:OFF)
Light[5]=Wall (type:Dimmable light, State:OFF)
Light[6]=Roof (type:Extended color light, State:ON)
Light[7]=Reading Light (type:Dimmable light, State:ON)
...
PS C:\Install>
PS C:\Users\Gamers\OneDrive\Install> .\ctrlhue -listScenes
Scene Listing:
LightScene [Nightlight-Switch] of Lights[2 6 7], Use this SceneID: sd4GGkKzmmIv8Zd
GroupScene [Standaard] of group[4], Use this SceneID: GPJMtV6lecW0Xhm
LightScene [Relax] of Lights[5 7], Use this SceneID: 64NZW7a4h49vFWx
...
PS C:\Install>
PS C:\Install> .\ctrlhue -group 1 -toggle
Group[1] Bureau is ON
turning Group 1 OFF
success
-------
@{/groups/1/action/on=False}
PS C:\Install>
PS C:\Install> .\ctrlhue -scene GPJMtV6leaW0Xhm
Activating scene GPJMtV6leaW0Xhm
success
-------
@{/groups/0/action/scene=GPJMtV6leaW0Xhm}
PS C:\Install>
```
## Shortcut Example:
One option is to embed ctrlHUE in a windows shortcuts
```
"<Path to powershell>\powershell.exe" -File "<path to script>\CtrlHUE.ps1" <options>
```

```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File "C:\Install\CtrlHUE.ps1" -LIGHT 2 -ON -CT 375 -BRI 200 -Silent
```
## Call CtrlHUE within PowerShell scripts:
The TVMimmick script demonstates how to call CtrlHue within PowerShell scripts. 
The demo simulates a TV, for one group of 1 or more lights

Success...
