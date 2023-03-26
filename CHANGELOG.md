# Changelog
All notable changes to this project will be documented in this file.

**ATTN**: This project uses [semantic versioning](http://semver.org/).

## [Unreleased]
### Added
- Added Thai translation. Thanks [rikoprushka](https://github.com/rikoprushka) for first PR!

### Removed
- Removed changing the names of books, paints, colored bulbs and seeds.

## [v0.1.0] - 2023-03-25
### Added
- Added tweak to change default chat stream to /all instead /say. To enable this tweak set `SetGeneralChatStreamAsDefault` to true in sandbox options.
- Added tweak to display coordinates in character info screen (needs Digital Watch in main inventory). To enable this tweak set `DisplayCharacterCoordinates` to true in sandbox options.
- Added tweak to forced disabling of Aim Outline client option. To enable this tweak set `DisableAimOutline` to true in sandbox options.
- Added tweak to returning ranged weapons sound radius as in b41.56 values. To enable this tweak set `TweakFirearmsSoundRadius` to true in sandbox options.
- Added tweak to protection Vehicles in safehouses. It hides Radial Menu, Forbids to enter vehicle and forbids to click on "Vehicles Mechanics". To enable this tweak set `ProtectVehicleInSafehouse` to true in sandbox options.
- Added tweak to allowing Moderators and GM to make teleports on world map (M). To enable this tweak set `AllowAdminToolsForGM` to true in sandbox options.
- Added tweak to allowing GMs to use admin tools in context menu. To enable this tweak set `AllowAdminToolsForGM` to true in sandbox options.
- Added tweak to set blackout the screen upon death. To enable this tweak set `ScreenBlackoutOnDeath` to true in sandbox options.
- Added tweak to color highlight safehouses for members. To enable this tweak set `HighlightSafehouse` to true in sandbox options. If enabled players can switch this in client panel.
- Added a "satellite" view switch to the map interface (M). It makes the map display closer to the one on the online map (https://map.projectzomboid.com/). To enable this tweak set `AddSatelliteViewToMap` to true in sandbox options.
- Added safehouse area size to Safehouse view interface. To enable this tweak set `DisplaySafehouseAreaSize` to true in sandbox options.
- Added allowing to create custom safezone by Moderator. To enable this tweak set `CustomSafezoneAdminTweaks` to true in sandbox options.
- Added changing min area size to 1 in custom safezone creation interface. To enable this tweak set `CustomSafezoneAdminTweaks` to true in sandbox options.
- Added possibility to set members in custom safezone creation interface. To enable this tweak set `CustomSafezoneAdminTweaks` to true in sandbox options.
- Added fix for safezone size calculation in custom safezone creation interface. To enable this tweak set `CustomSafezoneAdminTweaks` to true in sandbox options.
- Added "YOU'RE IN A NON PVP ZONE" text to right bottom corner. To enable this tweak set `TweakOverlayText` to true in sandbox options.
- Added changing connection info message on right bottom corner to more readable format. To enable this tweak set `TweakOverlayText` to true in sandbox options.
- Added disabling `Show connection info` checkbox in client menu and pinned to `true` value. To enable this tweak set `PinOverlayServerInfoText` to true in sandbox options.
- Added disabling `Show server info` checkbox in client menu and pinned to `false` value. To enable this tweak set `PinOverlayServerInfoText` to true in sandbox options.
- Added disabling `See Server Options` button in client menu. To enable this tweak set `HideServerOptionsFromPlayers` to true in sandbox options.
- Added storage for client options. The values of the checkboxes in the client menu are saved and the player does not need to change options after rejoining the server. To enable this tweak set `SaveClientOptions` to true in sandbox options.
- Added client cache. To enable this tweak set `AddClientCache` to true in sandbox options.
- Added renaming skill books to improve sorting (English). Cannot be disabled.
- Added renaming paints to improve sorting (English). Cannot be disabled.
- Added renaming light bulbs to improve sorting (English). Cannot be disabled.
- Added renaming seeds and seeds packets to improve sorting (English). Cannot be disabled.

[Unreleased]: https://github.com/openzomboid/server-tweaker/compare/v0.1.0...HEAD
[v0.1.0]: https://github.com/openzomboid/server-tweaker/compare/d4868cbb05ad290ba3f0431e82592894d999bd56...v0.1.0
