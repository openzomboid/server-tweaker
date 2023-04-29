# Server Tweaker
[![Steam Workshop](assets/steam.svg)](https://steamcommunity.com/sharedfiles/filedetails/?id=2951816996)

Server Tweaker contains careful edits that do not affect significant game mechanics and fixes some annoying bugs. First of all, the mod will be interesting for the owners of their servers, since all the changes are intended to improve the quality of life in multiplayer mode. Server Tweaker is developed for the need of [Last Day](https://last-day.wargm.ru) server.

## Features
* Store the selection of checkboxes in the "Client" menu.
* Added caching of some "heavy" frequently requested data. It should have a positive effect on FPS. At the moment, caching is used only by the Server Tweaker mod itself, but in the future it is planned to switch to cache and original vanilla mechanics.
* The utilities located in the shared directory are designed in such a way that they can be easily used in other mods. There is no need to copy pieces of code, just call the functions themselves from shared libraries.
* Fixed some game bugs.
* Many interface improvements that increase the convenience of the gameplay and administration.
* Redistribution of the role model: allowing GMs and Moderators to use some features previously available only to Administrators.
* All improvements can be turned off in the sandbox settings. Don't require a server restart, and most of them don't require a client restart either.

## Server Sandbox Options
* **SaveClientOptions** `(default=true)` - adds storage for client options. The values of the checkboxes in the client menu are saved and the player does not need to change options after rejoining the server. In the original game, these settings are reset after restarting the game on the client.
* **SaveAdminPower** `(default=false)` - adds storage for admin powers. The values of the checkboxes in the admin powers window are saved and powered user does not need to change options after rejoining the server. In the original game, these settings are reset after restarting the game on the client. Also adds "Show admin tag" option to Admin Powers checkboxes.
* **AddClientCache** `(default=true)` - adds caching of some frequently requested data. For example, in order to display the player's SafeHouse, a complete enumeration of all the shelters on the server is performed, which can cause an FPS drop. Enabling this option allows you to keep the player's SafeHouse always "at hand" and avoid a complete enumeration. The list of cached data will be extended.
* **AllowAdminToolsForGM** `(default=true)` - allows players with GM access to use tools from the admin context menu. Painting cars, removing corpses and objects from the ground, the ability to summon thunder and noise are available. Also adds the ability to perform teleports through a click in the world map display interface (M) for GMs and Moderators.
* **DisallowSpawnItemsForObservers** `(default=false)` - disallows to spawn items for Observer.
* **DisableAimOutline** `(default=false)` - allows you to force the players to turn off the outline on the target. Turning this setting on is not recommended, as it turns off the outline in the players options. The player will need to go into the settings themselves and return the aim outline if he wants to use it in a single player game or on another server.
* **DisableTradeWithPlayers** `(default=false)` - allows you to disable trade interface with players. There are several bugs with trade in vanilla game. For example, players can transfer huge amounts of things in this way and exceed the maximum available weight. This option is disabled by default, but it is recommended to enable it.
* **ProtectVehicleInSafehouse** `(default=false)` - protects vehicles wholly or partly in a safehouse. Hidden the radial menu of these vehicles for a non-Hideout character and disabled the ability to enter the vehicle and open the mechanics menu. Also, such cars cannot be towed by another car. In the original game, such cars are often stolen or parts are twisted from them, which causes discomfort on PVE servers. Enabling this setting will improve this user experience.
* **ScreenBlackoutOnDeath** `(default=true)` - sets blackout the screen after characters death. In the original game, after death, the player can still see what is happening near. On PVP servers, this can be abused to coordinate players in a faction, thus highlighting the movements of opponents. Also, after death, the character ceases to be an object of the Player class and loses some of its restrictions. In particular, he begins to see invisible server administrators standing nearby. Screen blackout is a fix for these bugs.
* **HighlightSafehouse** `(default=true)` - shows color highlight of area of players Safehouse to members. If the **HighlightSafehouse** option is enabled in the server sandbox settings, then the same setting becomes available to the player in the client settings. Each player will be able to choose for himself whether to highlight the territory or not.
* **TweakFirearmsSoundRadius** `(default=false)` - resets firearms sound radius parameters to values from v41.56 build. Read more in [Reddit](https://www.reddit.com/r/projectzomboid/comments/ref3if/b4160_weapos_changes_guns_sound_radius).
* **SetGeneralChatStreamAsDefault** `(default=false)` - sets the General (/all) chat as the default chat. The original game opens a local chat (/say) and some inexperienced players may have difficulty finding how to write to the public chat.
* **DisplayCharacterCoordinates** `(default=true)` - adds coordinates to the character view interface (J). The player must have any watch that displays the date.
* **AddSatelliteViewToMap** `(default=true)` - adds a "satellite" view switch to the map interface (M). The display becomes close to that of the [online map](https://map.projectzomboid.com).
* **DisplaySafehouseAreaSize** `(default=true)` - in the player's Safehouse view interface, it shows the Safehouse area in tiles.
* **CustomSafezoneAdminTweaks** `(default=true)` - turns on several changes at once in the interface for creating a custom Safezone.
    - in the original game, only the Administrator can create such Safezone - after enabling this option, the creation will become available for the Moderator.
    - removes the restriction on the minimum size of an arbitrary Safezone - it becomes possible to create a Safezone with a size of 1x1 tiles.
    - in the interface for creating an arbitrary Safezone, an additional field is added. You can list all members in the Safezone separated by commas.
    - fixes the calculation of the area of the Safezone, which is displayed when creating custom Safezone.
* **TweakOverlayText** `(default=true)` - comprehensively modifies the text that is displayed in the lower right corner:
    - when visiting a PVE territory, a green inscription with the text "YOU'RE IN A NON PVP ZONE" is displayed.
    - lines with information about the server are combined into one more compact and informative one.
* **PinOverlayServerInfoText** `(default=true)` - a separate setting that prevents players from changing the "Show connection info" and "Show server info" switches in the client settings. The ping display toggle remains enabled and its position is remembered by the game across restarts.
* **HideServerOptionsFromPlayers** `(default=true)` - a separate setting that prevents players from viewing the server settings in the client settings.
* **HideTicketsFromPlayers** `(default=true)` - a separate setting that prevents players from creating tickets in the client panel.
* **AddSafehouseToSpawnLocations** `(default=true)` - Adds Safehouse to spawn locations and moves it as first location.
* **AdminsFreeAddToSafehouse** `(default=true)` - Allows for GM (and higher levelled users) to add anyone to safehouse without limits.
* **TakeSafehouseLimitations** `(default=true)` - Turns on limits to take Safehouse function. It's include Safehouse area limit, intersection with another Safehouses and dead zone between Safehouses.
* **SafehouseAreaLimit** `(default=0)` - Sets the maximum size of the Safehouse in tiles. If the building has a larger area than `SafehouseAreaLimit`, it cannot be taken as a Safehouse. For enable this tweak `TakeSafehouseLimitations` must be true in sandbox options. If `SafehouseAreaLimit` is 0, no limit applies.
* **CheckSafehouseIntersections** `(default=true)` - Disables "Take Safehouse" option if the building intersects with another Safehouse. There ara a lot of such buildings in Louisville. For enable this tweak `TakeSafehouseLimitations` must be true in sandbox options.
* **SafehouseDeadZone** `(default=0)` - Disables "Take Safehouse" option if the building is nearby with another Safehouse. For enable this tweak `TakeSafehouseLimitations` and `CheckSafehouseIntersections` must be true in sandbox options.

## Compatibility
Game version: Build 41.78+ (Multiplayer)  
There is practically no rough patching in the mod with a complete replacement of the vanilla functions code, so good compatibility with all mods from the workshop is assumed. The mod is compatible with existing saves and safe for remove.

## Translations
This mod has full translations to following languages:

* English (EN)
* Russian (RU)
* Thai (TH) - Thanks to [rikoprushka](https://github.com/rikoprushka)
* Brazilian Portuguese (PTBR) - Thanks to [Xim](https://steamcommunity.com/id/BryanXim)

If you'd like to translate this mod, post your translations to [translations topic](https://steamcommunity.com/workshop/filedetails/discussion/2951816996/3824159062924268441) and I will add it with credits in-place.

## License
MIT License, see [LICENCE](LICENSE)  
