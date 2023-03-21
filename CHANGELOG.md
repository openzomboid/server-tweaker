# Changelog
All notable changes to this project will be documented in this file.

**ATTN**: This project uses [semantic versioning](http://semver.org/).

## [Unreleased]
### Fixed
- Fixed safezone size calculation in custom safezone creation interface.

### Added
- Added coordinates displaying to character info screen (needs Digital Watch in main inventory). To enable this tweak set `DisplayCharacterCoordinates` to true in sandbox options.
- Added `DisableAimOutline` option to sandbox configuration. If enabled it disables AimOutline option to every client.
- Added `TweakFirearmsSoundRadius` option to sandbox configuration. It returns ranged weapons sound radius to b41.56 values if enabled.
- Added protection for Vehicles in safehouses. Hided Radial Menu, Forbidden to enter and click on "Vehicles Mechanics". To enable this tweak set `ProtectVehicleInSafehouse` to true in sandbox options.
- Added possibility to teleport on world map to Moderators and GM. To enable this tweak set `AllowAdminToolsForGM` to true in sandbox options.
- Added admin tools context menu for GM users. To enable this tweak set `AllowAdminToolsForGM` to true in sandbox options.
- Added blackout the screen upon death. To enable this tweak set `ScreenBlackoutOnDeath` to true in sandbox options.
- Added safehouses highlight. To enable this tweak set `HighlightSafehouse` to true in sandbox options.
- Added possibility to create custom safezone by Moderator.
- Added possibility to add members when create safezone.
- Added possibility to create safezone with area=1.
- Added safehouse area to Safehouse view interface.
- Added a "satellite" view switch to the map interface (M). It makes the map display closer to the one on the online map (https://map.projectzomboid.com/).

# Changed
- Changed default chat stream to /all instead /say. To enable this tweak set `SetGeneralChatStreamAsDefault` to true in sandbox options.
- Recolored "YOU'RE IN A NON PVP ZONE" text from red to green.
- Renamed skill books to improve sorting by Vol. (English).
- Renamed paints to improve sorting (English).
- Renamed light bulbs to improve sorting (English).
- Renamed seeds and seeds packets to improve sorting (English).
- Disabled `See Server Options` button in client menu.
- Disabled `Show connection info` checkbox in client menu and pinned to `true` value.
- Disabled `Show server info` checkbox in client menu and pinned to `false` value.
- Changed connection info message to more readable format.

[Unreleased]: https://github.com/openzomboid/server-tweaker/compare/d4868cbb05ad290ba3f0431e82592894d999bd56...HEAD
