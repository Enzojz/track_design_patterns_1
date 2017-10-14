local descEN = [[
This mod give you possibility to create kinds of track patterns precisely with parameteres, which more alike real life enginnering work.
It gives you hand to control seperately the following parameteres:
* Slope
* Horizontal curves, presented by radius
* Vertical curves, presented by two different slopes at two ends of the track
* Size of switch
* Relative height of the whole construction
* Signal spacing, or enumlated moving block
* Walls at sides of tracks, including type, height, distance to track, and heigh variation to avoid Zig-Zags when you want to make a transition of walls of different height 
* Automatically calculated terrain which is impossible to archive by normal constructions

=== Six patterns are supplied in this mod ===
1. Parallel tracks
2. Underground parallel tracks
3. Compact tunnel entry
4. Switch
5. Crossover
6. Track ladders

=== Brief introduction to patterns ===

1. Parallel tracks
This pattern permets you created tracks with all parameters mentioned above. You can create groups of tracks with singals automatically installed, an enumlation of moving block is supported.

2. Underground parallel tracks
The underground version of parallel tracks, by removing wall related options

3. Tunnel entry
This pattern permets you create a concrete looking tunnel entry, which is frequently used worldwide. No signal option exists in this pattern.
Use the parellel tracks to complete the vertical curves at the beginning of the entry, otherwise you can use native contruction to make it (but less easy to control).

4. Switch
This pattern create simple a switch, by controling the size represented by cotangent of the switch frog. You can use it repeatly to quickly construction a diverging section of a depot or station.
This pattern also permts a flat junction quickly, by multiplying number of tracks
You can choose the form of turn out of switches bu changing "compactness" option between "Complete" and others.
You can add walls to the sides of switches, which is much easier than adding it manually with assets.

5. Crossover
Two crossovers are supported, the X crossover and N crossover, to get K crossover, please construct two N crossover in opposition.
You have option to construct some parallel N crossovers by choosing 1/2 or 3/4 N crossovers.
You can change the distance between two tracks to fit into different parts of stations.

6. Track ladders
This pattern is destinated to quickly create diverging part of a depot or something similar.
You can change the distance between exit tracks to fit into different parts of stations.
You can add walls to the sides of switches, which is much easier than adding it manually with assets.

=== What's there that can't be done with game itself ===
Expect the special terrain calculating acting with wall configurations, some other things that can be done with mod are unique to the game.
1. The minimal radious of the track can be as small as 50m, which exists in the real world (Paris Bastille has a curve as minimal to 38m) but impossible to get via the game construction tool.
2. The maximal slope can be at 10%, which overpasses the maximal value permet by the in-game construction tool (7.5%).
3. The mimimal switch turn out is #1/4, while with the game you can has as much as #1/5. This permets you construct smaller switch and crossovers on the map.
4. You can build crossover where the game says impossible to construction in some places.
5. The walls can be auto placed with all patterns, which is more elegante and quick than manually placing.
6. The signalling can be placed automatically, so does the enumlation of moving block

=== What's yet there ===
I have been working on this mod since about two months, at first I though it would be simple, but soon I got many other ideas to make it more rich.
However I expect to start work on my ultimated curved station soon, so the first release of this mod is done though some planned features are not done:
1. The superposed road over track (like rue de rome in Paris.) This missing pattern will be added later.
2. Signals on switch, crossover and track ladders, I am hesited to add them since it seems not a big problem not to have them
3. Double slip and single slips are planned first, however it seems impossible to get it since some related track parameteres are totlly done by the game itself, and no mod interfaces opened to modder.
4. Three way switch is not possible neither

=== What may be buggy for some players ===
The automatically generated signals are not indicated in the map, and not visible in the preview before the constrcution. They are can only visible after construction, and moving blocks doesn't have anyway graphically way to present them.
The ordinary signals are place at each 1/2 place of the distance choose, for example, if you have chosen to have signal each 500m, you will see the first signal at 250m, and the second at 750m. I did this just because the way to calculate it is easier than putting the signals at the extremes, and if I have time I will rework on this calculate.
This distance is also not counted further that the length of the track, that means between the position of signals are only calculated within each piece of tracks.

Some terrain may recalculated wrongly after joinning two pieces of tracks together, this is caused by the game mechanism and I have no way to correct it.

=== Translations ===
This version is currently in English only, toooooooooo much to translate.
Cette version est qu'en anglais pour le moment, parce que les traductions à faire sont énormes. :p
目前只有英文版本，因为要翻译的东西多到炸 XD

]]

function data()
    return {
        en = {
            ["name"] = "Track Design Patterns",
            ["desc"] = descEN,
        },
        fr = {
            ["name"] = "Voies paramétrés",
            -- ["desc"] = descFR,
        },
        zh_CN = {
            ["name"] = "参数化轨道",
            -- ["desc"] = descCN,
        },
    }
end
