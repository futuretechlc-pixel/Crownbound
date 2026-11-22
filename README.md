# Crownbound

Godot 4.7 source prototype for a 3D turn-based strategy board game.

## Current source snapshot
This repository is being populated file-by-file from the **Crownbound Prototype v2.2** source package.

The prototype includes:
- 10×10 board with a central crown, 2–4 players, movement, barriers, and route-safety checks.
- Four heroes with signature abilities: Flare, Frost, Vine, and Phantom.
- Campaign progression across 30 stages and three worlds, AI opponent profiles, and multiple terrain/map mechanics.
- World boss encounters, boss phases, control-point objectives, daily challenge data, stars, achievements, player statistics, and progression rewards.

## Validation status
The accompanying Python reference/source-wiring test suite has 16 passing tests.

**Important:** these Python tests do not parse or execute GDScript. Godot 4.7 runtime validation, Android device testing, and APK export have not yet been completed. This repository is source code, not an installable APK.

## Project entry point
Open this folder in Godot 4.7 and run `project.godot`.
