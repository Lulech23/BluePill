# 💻 BluePill (Color Calibration Fixer)
Ditch green tint on the default Aya Neo display configuration!

## About
The Aya Neo is an amazing handheld PC, but early units shipped with a default display calibration that leaves much to be desired. Like its namesake movie, it possesses a strong green tint out of the box. That's fine for moody action films, not so great for an entire user experience.

BluePill is a PowerShell script designed to automate applying a better color profile, which I calibrated myself. Achieving true white balance is probably impossible on the current-gen Neo panel, but I was able to reach a pleasing compromise, at the very least. 

Proper calibration is not simple, requires lots of time, and the tools are somewhat hidden beneath a tree of outdated Windows settings screens. That's a hurdle for end users, so take the BluePill instead.

#### You could go from this...
![`Original color profile (simulated)`](/screenshots/original.jpg)

#### .. To this!
![`BluePill color profile (simulated)`](/screenshots/bluepill.jpg)

### Why BluePill?
Or more specifically, why not "RedPill"? Frankly, because I'm not fond of the recent trend of manufacturers intentionally calibrating their displays too warm. White should be white, but true white is hard. If you must err on one side or the other, slightly blue whites are more appealing than slightly red ones.

Also, in Matrix lingo, the blue pill was associated with green tint, which is what spawned this script in the first place.

## How to Use
If you're using an IndieGoGo edition Aya Neo, setup is simple!

#### To Install:
1. Download the latest version of BluePill from [releases](https://github.com/Lulech23/BluePill/releases). 
2. Run `BluePill.bat`.

#### To Uninstall:
1. Run `BluePill.bat` again and it'll undo all changes to your system.

#### To Update:
1. Run `BluePill.bat` to uninstall previous versions (new versions are backwards-compatible!)
2. Run `BluePill.bat` again to install the new version

Note that changes made by BluePill are permanent until uninstalled, so you do not need to keep downloaded files on your PC after installation.

## Advanced Usage
If you're using a different edition Aya Neo or other device entirely, your default display calibration may be substantially different from the one BluePill was designed to fix. But if you have an \*.ICC or \*.ICM profile, you can apply it with BluePill as well!

#### To Install Custom Profile:
1. Open PowerShell or CMD and navigate to the directory where `BluePill.bat` is stored
2. Enter `BluePill.bat` followed by the **fully qualified** path to your custom profile (no relative paths). _Example:_ `.\BluePill.bat "C:\Users\Me\Downloads\MyCustomProfile.icc"`
3. Run the command to apply your custom profile

## Known Issues
* **None for now! Hooray!**