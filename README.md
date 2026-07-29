# rx-core

**RX Framework Core** — the main framework resource for RX servers on FiveM.

## Description

Contains player management, shared data (jobs, items, vehicles, gangs), callbacks, commands, notifications, and compatibility bridges for legacy scripts.

## Documentation

- [RX Framework / RXCore Docs](https://docs.rxcore.org)

## Requirements

- **oxmysql**
- OneSync enabled (recommended)

## Compatibility bridges

| Bridge | Convar | Purpose |
|--------|--------|---------|
| `bridge/qbcore` | `setr rx:bridge:qbcore true` | QBCore scripts (`qb-core`, `QBCore`, `QBCore:` events) |
| `bridge/qbox` | `setr rx:bridge:qbox true` | Qbox / `qbx_core` style scripts (`exports.qbx_core`, `QBX`) |
| `bridge/esx` | `setr rx:bridge:esx true` | ESX Legacy scripts (`es_extended`, `ESX`, `esx:` events) |
| `bridge/ndcore` | `setr rx:bridge:ndcore true` | ND Framework scripts (`ND_Core`, `ND:` events) |
| `bridge/vrp` | `setr rx:bridge:vrp true` | vRP-style scripts (`vrp`, `vRP:` events; limited Proxy/Tunnel support) |

`rx-core` also provides `qb-core`, `qbx_core`, `es_extended`, `ND_Core`, and `vrp` via FiveM `provide` so dependencies resolve without a separate core resource.

Enable only the bridges you need. QBCore and Qbox default to on; ESX, ND Core, and vRP default to off.

## Server configuration

In `server.cfg`:

```cfg
ensure rx-core
setr rx_locale "en"
setr rx:bridge:qbcore true
setr rx:bridge:qbox true
# setr rx:bridge:esx true
# setr rx:bridge:ndcore true
# setr rx:bridge:vrp true
```

## Database

Import `rxcore.sql` into your MySQL database on first setup.

## License

    RX Framework
    Copyright (C) RX Framework Contributors

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>