# Team 10 Visualizer
## Quick Setup

 1. Download latest release
 2. Extract zip contents
 3. Open the file /data/userinfo.txt
 4. Fill in the following parameters
 
| Line |  Entry|
|--|--|
| 1 | Team Name (no space) |
| 2 | Client name (no space)|
| 3 | MQTT password|
| 4 | Default Board Size|

5. Save userinfo.txt
6. launch VIsualizer.exe
7. Use the 'p' command to test connection (see [commands](#commands))

## Editing Source
This program is written in [Proccessing](https://processing.org/). Once you have the proccessing IDE installed, clone the repo and open Visualizer.pde, all the code is stored in one file.

## Commands
|Shortcut| Command |
|--|--|
| r | Resize |
| p | ping (puts object in MQTT server at (2, 2) to test connection|
| s | Save File (saves as csv in /data/saves |
| l | Load File (loads from csv in /data/saves |
| b | Blur |
| t | Show grid numbers |
| m | Apply mask to data (use a mask of -1 to remove mask |

