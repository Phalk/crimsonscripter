-------------------------------
-- TITLE SCREEN
-------------------------------
title_bgm = ""
title_img = "img/title.png"

if (title_bgm ~= "") then bgm(title_bgm) end
center("Crimson Scripter Default Title")
right("Version 0.3 Alpha")
right("Author: Phalk")
addline(" ")
addline("Press A to Start")
addline(" ")
if System.doesFileExist(dir.."save.sav") then newline("Press SELECT to LOAD") addline(" ") end
newline("Press HOME at any time during gameplay to return to the Homebrew Channel.")

titlescreen = true