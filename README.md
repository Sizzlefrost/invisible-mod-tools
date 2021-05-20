# Sizzle's Invisible Modding Tools

Currently adds two modding batch scripts to streamline the workflow of modding Invisible, Inc.

## 1) Mod Folder Renamer 

Renames Invisible, Inc. mod folders from their steam names (e.g. "workshop-1711205484") to their mod names, 
edited to be compatible with the game's Mod Manager (e.g. "Advanced_Cyberwarfare).

Useful for when you want to look up code in another mod, but don't remember which of the "workshop-XXXXXXXX" folders that mod was.

Usage: drop nameMods.bat in your InvisibleInc/mods folder. Run it to rename all mods in the same folder.

## 2) Quiksizzler

Workflow optimizer for Invisible, Inc. modding. Run to automatically assemble the next version.

### Features:
 - ZIPs up a new scripts.zip from a folder
 - packs new KWADs by calling the KWAD builder (for those who do not know, there is one included in the API Example mod)
 - updates modinfo.txt with the new version
 - option to run the game when done updating
 - Gigasizzler mode: a preset to perform a quick update and launch the game for a test, at the push of one button.
 - cleanup of .mdmp logs the game creates (and sometimes seems to not delete)

### Usage:
#### Setup
Place quiksizzler.bat inside the folder of the mod you're looking to work with, e.g. ".../InvisibleInc/mods/workshop-1711205484/"
#### Scripts update
Unzip the scripts.zip of the mod into a "/scripts/" folder in the same directory (".../InvisibleInc/mods/workshop-1711205484/scripts/"). You can then work on the code inside that folder. When Quiksizzler is run, it'll automatically update scripts.zip from this scripts folder.
#### KWADs update
Quiksizzler can locate the KWAD builder automatically, if it's installed in one of three locations (in order of priority):
 - the ".../InvisibleInc/" folder
 - Your desktop
 - the ".../InvisibleIncModUploader/" folder (I don't know why you'd put it there, but I'm a weirdo and used to have my modding tools stored in there).  

Worth noting that subfolders within these folders are searched too. It's slow, but it's easier to use that way.

When Quiksizzler is run, it'll be able to call the KWAD builder and then copy the resulting files into the mod folder.  
You still need to supply the KWAD builder with source files, as per usual, inside the folders you designate with KWAD builder's "build.lua" configuration file.
#### Modinfo update
Quiksizzler auto-detects the modinfo file, and can set one up if it wasn't there. If the file was detected, you'll be able to increment the version in it
according to the "Revision / Version / Feature / Build" syntax. It's possible to skip an increment. I recommend incrementing build for any code change (even a typo fix),
feature for small public releases such as hotfixes, version for major releases (with new additions and functionality) and revision for particularly large mod updates.
#### Customization
Most of the file is documented inside, so it should be fairly easy to edit to your needs. I won't claim it's anywhere near optimized, since I'm very poor at batch - it just gets the job done for me.
   
