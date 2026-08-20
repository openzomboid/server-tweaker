# Server Tweaker
[![Steam Workshop](assets/steam.svg)](https://steamcommunity.com/sharedfiles/filedetails/?id=2951816996)

Server Tweaker contains careful edits that do not affect significant game mechanics and fixes some annoying bugs. First of all, the mod will be interesting for the owners of their servers, since all the changes are intended to improve the quality of life in multiplayer mode. Server Tweaker is developed for the need of [Last Day](https://last-day.wargm.ru) server.

## Features
* Fixed some game bugs.
* Many quality of life improvements that increase the convenience of the gameplay and administration.
* All improvements can be turned off in the sandbox settings. Don't require a server restart, and most of them don't require a client restart either.
* Provided libraries for use as API in other mods. The utilities located in the shared/openutils, client/clientutils and server/serverutils directories are designed in such a way that they can be easily used in other mods. There is no need to copy pieces of code, just call the functions themselves from shared libraries.

## Server Sandbox Options
* **HighlightSafehouse** `(default=true)` - Shows color highlight of area of players Safehouse to members. If the HighlightSafehouse option is enabled in the server sandbox settings, then the same setting becomes available to the player in the client settings. Each player will be able to choose for himself whether to highlight the territory or not.
* **ShowCoordinates** (default=true)` - Adds coordinates to the character view interface (J). The player must have any watch that displays the date.
* **EnableSuicideCommand** `(default=true)` - Adds suicide command to chat with confirmation window. The character will immediately die after entering this command and confirmation.
* **AdminSafehouseExtension** `(default=true)` - Turns on several changes at once in the interface for creating a custom Safezone.
  - Removes the restriction on the minimum size of an arbitrary Safezone - it becomes possible to create a Safezone with a size of 1x1 tiles.
  - The Savezone creation interface now allows you to specify all Safezone members. A comma is used as a separator.
  - Added the ability to create a Savezone for a player who is not online on the server.
* **SafehouseVehicleProtection** `(default=false)` - Protects vehicles wholly or partly in a safehouse. Hidden the radial menu of these vehicles for a non-Hideout character and disabled the ability to enter the vehicle and open the mechanics menu. Also, such cars cannot be towed by another car. In the original game, such cars are often stolen or parts are twisted from them, which causes discomfort on PVE servers. Enabling this setting will improve this user experience.
* **ElevatedStaffPermissions** `(default=false)` - Currently, this only enables the context menu on the global map for roles with the "SeeWorldMap" permission. Roles with the "TeleportToCoordinates" permission now have the ability to freely teleport on the global map.
* **BrushToolFix** `(default=false)` - Fixes synchronization issues with objects placed using the Brush Tool. Objects are now synchronized between players and are not deleted when rejoining the server. Special thanks to James "J" Kelly and his Astaroth server for their assistance in development.

### Modules for modders
* [ConsoleLogger.lua](src/b42/lua/shared/openutils/ConsoleLogger/ConsoleLogger.lua) - Allows to write debug information to the client and server consoles (depending on where you run it). Logging levels range from Debug to Error. It can parse and print objects, which can be useful for viewing logs during debugging.
* [OptionsStorage.lua](src/b42/lua/shared/openutils/OptionsStorage/OptionsStorage.lua) - Wraps Project Zomboid's native Java File I/O Streams to create an isolated, lightweight key-value configuration reader and writer. It parses and formats raw plain-text .ini data documents saved directly into the 'C:\Users\Username\Zomboid\Lua\' system user directories.
* [ClientOptions.lua](src/b42/lua/client/clientutils/ClientOptions/ClientOptions.lua) - Allows you to add client-side checkboxes to the UserPanel, allowing you to display your mods settings there so players can toggle them without having to go to the game's settings menu.
* [openutils.lua](src/b42/lua/shared/openutils/openutils.lua) - Swiss Army Knife with different functions.

## Compatibility
Game version: Build 44.20+ (Multiplayer)  
There is practically no rough patching in the mod with a complete replacement of the vanilla functions code, so good compatibility with all mods from the workshop is assumed. The mod is compatible with existing saves and safe for remove.

## Translations
This mod has full translations to following languages:

* English (EN)
* Russian (RU)

If you'd like to translate this mod, post your translations to [translations topic](https://steamcommunity.com/workshop/filedetails/discussion/2951816996/3824159062924268441) and I will add it with credits in-place.

## License
MIT License, see [LICENCE](LICENSE)  
