# Drudomancer Custom Cards

This folder contains the Drudomancer custom card expansion for MDPro3/Omega.

## Download

Direct `.ypk` link:

```link
https://github.com/nello0b/my-cards/raw/refs/heads/main/Drudomancer/Drudomancer.ypk
```

## Install

1. Download `Drudomancer.ypk` using the link above.
2. Place it in your MDPro3 `Expansions` folder.
3. Launch the game and enable the expansion if necessary.

## Build

From the repository root, run:

```powershell
python .\Drudomancer\create_ypk.py
```

This rebuilds `Drudomancer/Drudomancer.ypk` using the card database, Lua
scripts, artwork, and `test-strings.conf` in this folder.
