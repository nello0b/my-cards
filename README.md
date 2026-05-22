# OmegaCustom (MDPro3 / Omega)

This folder contains a custom card pack (database + scripts) and a built `.ypk` expansion.

## Download

- Direct `.ypk` link:

```link
https://github.com/nello0b/my-cards/raw/refs/heads/main/OmegaCustom.ypk
```

## Install

1. Download `OmegaCustom.ypk` from the link above.
2. Put it in your MDPro3 expansions folder (example):
   - `MDPro3/Expansions/`
3. Launch the game and enable the expansion if needed.

## Build / Update the `.ypk`

If you’re editing cards/scripts in this workspace, rebuild the pack with:

```powershell
python .\create_ypk.py
```

This will (re)generate `OmegaCustom.ypk` from the current workspace contents.

## What’s inside

- `Custom-Cards.cdb` — card database (SQLite)
- `script/` — custom scripts
- `tcg-scripts/` — reference scripts used during development/testing
- `OmegaCustom.ypk` — built expansion output
