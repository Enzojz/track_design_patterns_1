local descEN = [[
    This mod give you possibility to create kinds of track patterns precisely with parameters, which more alike real life engineering work.
    It gives you hand to control separately the following parameters:
    * Slope
    * Horizontal curves, presented by radius
    * Vertical curves, presented by two different slopes at two ends of the track
    * Size of switch
    * Relative height of the whole construction
    * Signal spacing, or emulated moving block
    * Walls at sides of tracks, including type, height, distance to track, and height variation to avoid Zig-Zags when you want to make a transition of walls of different height 
    * Automatically calculated terrain which is impossible to archive by normal constructions
    
    === Six patterns are found in Railway depot menu ===
    1. Parallel tracks
    2. Underground parallel tracks
    3. Compact tunnel entry
    4. Switch
    5. Crossover
    6. Track ladders
    
    === Brief introduction to patterns ===
    
    1. Parallel tracks
    This pattern permits you created tracks with all parameters mentioned above. You can create groups of tracks with signals automatically installed, an emulation of moving block is supported.
    
    2. Underground parallel tracks
    The underground version of parallel tracks, by removing wall related options
    
    3. Tunnel entry
    This pattern permits you create a concrete looking tunnel entry, which is frequently used worldwide. No signal option exists in this pattern.
    Use the parallel tracks to complete the vertical curves at the beginning of the entry, otherwise you can use native construction to make it (but less easy to control).
    
    4. Switch
    This pattern create simple a switch, by controlling the size represented by cotangent of the switch frog. You can use it repeatly to quickly construction a diverging section of a depot or station.
    This pattern also permits a flat junction quickly, by multiplying number of tracks
    You can choose the form of turn out of switches by changing "compactness" option between "Complete" and others.
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
    1. The minimal radius of the track can be as small as 50m, which exists in the real world (Paris Bastille has a curve as minimal to 38m) but impossible to get via the game construction tool.
    2. The maximal slope can be at 10%, which overpasses the maximal value permit by the in-game construction tool (7.5%).
    3. The minimal switch turn out is #1/4, while with the game you can has as much as #1/5. This permits you construct smaller switch and crossovers on the map.
    4. You can build crossover where the game says impossible to construction in some places.
    5. The walls can be auto placed with all patterns, which is more elegant and quick than manually placing.
    6. The signaling can be placed automatically, so does the emulation of moving block
    
    === What's yet there ===
    I have been working on this mod since about two months, at first I though it would be simple, but soon I got many other ideas to make it more rich.
    However I expect to start work on my ultimate curved station soon, so the first release of this mod is done though some planned features are not done:
    1. The superposed road over track (like rue de rome in Paris.) This missing pattern will be added later.
    2. Signals on switch, crossover and track ladders, I am heisted to add them since it seems not a big problem not to have them
    3. Double slip and single slips are planned first, however it seems impossible to get it since some related track parameters are totally done by the game itself, and no mod interfaces opened to modder.
    4. Three way switch is not possible neither
    
    === What may be buggy for some players ===
    The automatically generated signals are not indicated in the map, and not visible in the preview before the construction. They are can only visible after construction, and moving blocks doesn't have anyway graphically way to present them.
    The ordinary signals are place at each 1/2 place of the distance choose, for example, if you have chosen to have signal each 500m, you will see the first signal at 250m, and the second at 750m. I did this just because the way to calculate it is easier than putting the signals at the extremes, and if I have time I will rework on this calculate.
    This distance is also not counted further that the length of the track, that means between the position of signals are only calculated within each piece of tracks.
    
    Some terrain may recalculated wrongly after joining two pieces of tracks together, this is caused by the game mechanism and I have no way to correct it.
    
    === Translations ===
    Cette version manque encore la traduction française, parce que le français n'est pas mon langue maternel, il faut prendre un peu plus du temps pour en finir.
    English | Chinese: Enzojz
    German: RPGFabi

    === Changelog ===
    1.3
    * Reimplementation of models and model positioning algorithm to have non-overlapping, non-flickering walls or bricks
    1.2
    * CommonAPI support
    1.1 
    * Fixed the problem that #5 Crossover can't be build under some sitiations.
    * Fixed crash when length is set to 0.
    * German and Chinese translation
    1.0 
    * First release 
]]

local descZH = [[
    本MOD赋予你以参数形式精确创建各种轨道的能力，让你的基础设施更像是精确工程计算的结果。
    他让你能够控制下列参数：
    * 坡度
    * 以半径表示的平曲线
    * 以轨道两端不同坡度表示的竖曲线
    * 道岔号数
    * 整个建造部分的相对高度
    * 信号间隔，或者是模拟的移动闭塞
    * 轨道侧的墙，比如类型、高度、到轨道的距离，又比如你希望在不同高度的墙之间过渡时需要的高度渐变等等
    * 一些通过正常手法无法获得的地形改变


    === 在铁路车库菜单中可以找到的六种模式轨道 ===
    1. 平行轨道
    2. 地下平行轨道
    3. 紧凑隧道入口
    4. 道岔
    5. 渡线
    6. 梯线
        
    === 轨道模式的简单介绍 ===
    
    1. 平行轨道
    这个模式可以让你一次性创建多条上面提及的参数构造的轨道。你可以创建自动安装了信号机的轨道组，并且支持模拟的移动闭塞。
    
    2. 地下平行轨道
    平行轨道的地下版本，去掉了墙有关的选项。
    
    3. 紧凑隧道入口
    这个模式允许你建造一个混凝土外观的隧道入口，这种隧道入口在世界范围内都非常常见。在这个模式中没有信号机的选项。
    请配合使用平行轨道完成隧道入口和出口的竖曲线设置，或者你可以使用原生的轨道工具完成这一步（但这样并不容易控制参数）
    
    4. 道岔
    这个模式通过控制以岔心余切值表示的道岔号数创建一个或多个道岔。你可以连续使用这个模式构造一个车辆段或车站的分叉部分。
    这个模式同样允许你以增加轨道数量的方式快速地创建一个平线路所。
    你可以通过切换道岔的“紧凑度”选项修改道岔的外观，其中的“完整”选项可以产生一个平行的分叉区段。
    可以在道岔的两侧添加墙，相比游戏中在同样的位置操作要简便很多。
    
    5. 渡线
    这个模式支持两类渡线：交叉渡线和单渡线，连续建造两个相反的单渡线可以构成一个双渡线。
    你可以通过选择1/2或者3/4单渡线的选项去建造多个并排的渡线组。
    可以通过修改轨道间距选项让这些渡线匹配车站的不同部分。
    
    6. 梯线
    这个模式用来快速创建车辆段或者车站的分叉部分。
    你可以修改分叉轨道之间的距离去匹配车站的不同部分
    可以你在梯线的两侧添加墙，相比游戏中在同样的位置操作要简便很多。
    
    === 本MOD可以，而游戏本身尚未实现的功能 ===
    除了特殊的地面计算功能，这个MOD还可以实现一些游戏尚未做到的功能.
    1. 最小半径可达50米（真实世界最小的准轨弯道是巴黎巴士底地铁站一个38米半径的弯道）
    2. 10%的最大坡度，游戏中只允许你建造最大7.5%的坡。
    3. 最小道岔是4号道岔，游戏里你最小只能建造5号道岔。在一些狭窄的空间内建造渡线也许有帮助。
    4. 你可以在游戏中认为不可能的位置建造交叉渡线。
    5. 在各种模式中可以自动建造侧墙，比游戏中快速并且更美观。
    6. 可以自动放置信号机，并且可以模式移动闭塞。
    
    === 还没实现的 ===
    在这个MOD上我花费了大约两个月的时间，起初我认为这个MOD应该比较简单，但是在制作过程中我有了很多其他的想法导致这个MOD变得越来越丰富。
    然而我打算开始“终极弯道车站”MOD这个项目，因此本MOD第一版在没有包含以下特性的情况下发布了：
    1. 类似巴黎罗马路那样的悬空在轨道上方的马路，这个模式将在以后的版本中添加进来。
    2. 我犹豫是否要增加道岔的防护信号机的选项，因为我觉得没有这个选项问题也不是很大。
    3. 起初复式交分和单式交分是打算做在这个MOD里面的，然而游戏中有一些内部计算的参数导致这个模式没法实现。
    4. 因为同样的原因三开道岔也没法实现。
    
    === 一些BUG ===
    自动生成的信号机不会在游戏中显示出图标
    信号机防止在每个长度区段的1/2位置中，比如，如果你选择了每500米安装一个信号机，那么你会在250米和750米的位置看到这个信号机，我这样做是因为这样的情况下计算最简便。如果轨道比信号机间隔短的话，那么信号机就不会被安装。
    一些地形在连接两段轨道后会被错误地重新计算，这是由于游戏内部机制引起的错误，我没有认为办法去修复。
    
    === Changelog ===
    1.3
    * 重写了模型和模型放置算法，消除了前后墙或者砖的模型之间的重叠和闪烁现象
    1.2
    * 支持CommonAPI
    1.1 
    * 修复了一些情况下5号渡线无法被建造的问题
    * 修复了长度为零的情况下游戏崩溃的问题 
    * 德语翻译和中文翻译
    1.0 
    * 首次发布
]]

local descDE = [[
       Dieser Mod fügt die Möglichkeiten ein, mit der man verschiedene Arten von Gleisbauten mithilfe von Parametern bauen kann, was mehr der Gleisplanung in der Realen Welt entspricht.
       Man kann folgende Einstellunge vornehmen.
       - Steigung
       - Horizionale Kurven ( Mithilfe des Radius ) 
       - Verticale Kurven ( Mithilfe 2er unterschiedlichen Steigungen am Anfang und am Ende )
       - größe der Weichen
       - Relative Höhe der Konstruktion
       - Signalabstand oder simulierter "Beweglicher Block"
       - Wände an den Seiten der Gleise mit folgenden Einstellungen
            - Typ
            - Höhe
            - Abstand zum Gleis
            - Höhenunterschied um Spitzen zu vermeiden ( wenn man Übergänge zwischen verschiedenen Wänden baut )
        - Automatisch berechnetes Terrain, welches unmöglich zu Erreichen ist, wenn man normale Konstruktionen hat
    
        === Sechs verschiedene Möglichkeiten werden von dem Mod unterstützt ===
        1. Parallel liegende Gleise
        2. Unterierdische Parallel liegende Gleise
        3. Kompakter Tunneleingang
        4. Weichen
        5. Übergänge
        6. Gleisharfen
    
      === Einführung in die Mod ===
    
        1. Parallele Gleise
              Diese Vorlage lässt dich parallel liegende Gleise mit den oben genannten Parametern erstellen. Du kannst Gruppen aus Gleisen mit automatisch installierten Signalen und simulierten "beweglichen Blöcken" erstellen.
    
        2. Unterierdische Parallel liegende Gleise
              Die Untergrund-Version der Parallelen Gleise, die durch das entfernen der Wand bezogenen Optionen entsteht.
    
        3. Kompakter Tunneleingang
              Diese Vorlage lässt dich einen betoniert aussehenden Tunneleingang erstellen, welcher weltweit genutzt wird. Bei dieser Vorlage existiert keine Option für Signale.
             Nutze die Parallelen Gleise um die vertikalen Kurven am Anfang des Tunnel zu vervollständigen, ansonsten cann man normale Konstruktionen nutzen, welches aber schwerer zu kontrollieren ist.
    
        3. Weichen
              Mit dieser Vorlage kann man  Weichen erstellen, indem man die Größe  der Co-tangens switch. Man kann es wiederhohlt nutzen um schnell Konstruktionen an abweichenden Stellen von Depots oder Stationen zu bauen.
              Außerdem bietet sie die option einer flachen Kreuzung, indem man die Gleisanzahl erhöht.
              Du kannst die Form der abzweigenden Weichen ändern, indem du die Option "Kompaktheit" zwischen "Komplett" und anderen änderst.
             Dazu kann man Wände an beiden Seiten hinzufügen, welches leichter ist, als es später von Hand zu tun.
        
        5. Übergänge
              Zwei Übergänge werden unterstützt, einmal das "X" und einmal das "N". Um einen "K" Übergang zu bekommen, einfach zwei "N" Übergänge bauen.
              Du hast die Option mehrere Parallele Übergänge zu bauen, indem du die option "1/2" oder "3/4" nutzt.
              Außerdem kannst du die Distanz zwischen zwei Gleisen ändern um die Konstukrion an verschiedene Bahnhöfe anzupassen.
    
        6. Gleisharfen
             Diese Vorlage ist für die schnelle Erstellung von Gleisharfen für z.B. Depots oder ähnliches zu bauen.
             Du kannst die Distanz zwischen den ausgehenden Gleisen ändern, um sie so passen für verschiedene Stationen zu bauen.
             Außerdem kannst du Wände an die Seiten der Weiche bauen, was leichter ist, als es später von Hand hinzuzufügen.
    
        === Was fügt der Mod hinzu, was mit dem Spiel selber nicht gemacht werden kann? ===
    
        Erwarte eine spezielle Art, das Terrain zu berechnen, mitsamt den Wandkonfigurationen. Manch andere Sachen können mit der Mod machen, was nicht mit dem Original-Spiel gemacht werden kann.
        1. Der Minimale Raddius der Gleise kann 50 Meter betragen, welcher der Realen Welt entspricht. ( Paris Bastille hat einen kleinsten Kurvenradius von 38 Metern, was unmögloch ist, via dem Ingame Bauwerkzeug )
        2. Die maximale Steigung kann 10% betragen, welches die 7,5% des Ingame Bauwerkzeuges übersteigen.
        3. Der minimale Weichenradius ist #1/4, wärend der Wert des Originalspiels nur #1/5 hinbekommt. Dadurch lassen sich kleiner Weichenkonstruktionen und -Übergänge bauen.
        4. Du kannst Übergänge bauen, wo das Spiel normalerweise sagt, "Bau nicht möglich"
        5. Die Wände werden automatisch gebaut, was die elegantere und schnellere Lösung ist, als sie selbst zu platzieren
        6. Die Signale können, genau wie der simulierte "Bewegte Block", automatisch eingebaut werden.
    
        == Was ist aktuell dabei? ==
        Ich habe an diesem Mod seit 2 Monaten gearbeitet, wobei ich anfangs dachte, er ist sehr einfach gehalten, aber dann habe ich viele andere Ideen bekommen, um den Mod weiter zu bereichern.
        Entgegen meiner Erwartung starte ich bald den Bau des "Ultimativen gebogenen Bahnhof". Die Erstveröffentlichung des Mods ist fertig, weitere Möglichkeiten sind geplant, aber noch nicht erledigt:
        1. Die überlagerte Straße über Gleise ( wie in rue de rome in Paris ). Diese Vorlage wird später hinzugefügt.
        2. Signale auf Weichen, Übergänge und Gleisharfen. Ich werde mich weiter daran setzen, seitdem es so aussieht, als wäre es kein großes Problem.
        3. Doppelbelegte und Einzelbelegte Gleise waren erst geplant, was aber unmöglich erscheint, seit das Spiel wichtige Gleis Parameter selbst bestimmt und kein mod interface für die Modder eröffnet.
        4. Drei-Wege Weichen sind leider genauso unmöglich.
    
        === Was für manche Spieler komisch rüberkommen kann ===
        Die automatisch generierten Signale werden auf der Karte nicht dargestellt und nicht sichtbar wärend des erstellens der Konstruktion. Sie werden erst nach dem Bau der Konstruktion angezeigt, simulierte "Bewegte Blöcke" werden gar nicht Graphisch angezeigt.
        Die Signale werden nach der halben Länge des eingestellten Abstandes gebaut, z.B. wenn du einen Abstand von 500 Meter einstellst, wird das erste Signal bei 250 Meter gebaut, das zweite bei 750 Meter. Dies habe ich gemacht, weil es leichter zu kalkulieren ist, als die Signale an den Anfang zu setzen. Sobald ich zeit habe, werde ich die Berechnung überarbeiten.
        Die Distanz wird außerdem nicht weiter berechnet als die Länge der Gleise, heißt der Abstand der Signale ist nur innerhalb der Konstruktion berechnet.
    
        Manch Terrain-Berechnung wird falsch nachgerechnet, wenn man zwei Gleisstücke zusammenbaut. Dies liegt an der Terrain Berechnung des Spieles und ich habe keinen Weg gefunden dies zu umgehen.
    
      
        === Translations ===
        English | Chinese: Enzojz
        German: RPGFabi
        
        ]]

function data()
    return {
        en = {
            ["name"] = "Track Design Patterns",
            ["desc"] = descEN,
        },
        zh_CN = {
            ["name"] = "模式轨道（参数化轨道）",
            ["desc"] = descZH,
            ["Pattern"] = "形式",
            ["Orientaion"] = "指向",
            ["Left"] = "左单开",
            ["Right"] = "右单开",
            ["Wye"] = "双开",
            ["Track Distance"] = "线间距",
            ["Slope"] = "坡度",
            ["Wall A"] = "侧墙A",
            ["Height"] = "高度",
            ["None"] = "无",
            ["Type"] = "类型",
            ["Concrete"] = "混凝土",
            ["Arch"] = "券拱",
            ["Noise barrier"] = "隔音墙",
            ["Wall B"] = "侧墙B",
            ["Sync"] = "同A",
            ["Altitude Adjustment"] = "高度调整",
            ["Last Section"] = "末段",
            ["Wall-Track distance"] = "轨道-侧墙距离",
            ["Compactness"] = "紧凑度",
            ["Extra loose"] = "特松",
            ["Loose"] = "松",
            ["Standard"] = "标准",
            ["Medium"] = "紧",
            ["Compact"] = "特紧",
            ["Complete"] = "完整",
            ["Radius"] = "半径",
            ["Begin"] = "起点",
            ["End"] = "终点",
            ["Length"] = "长度",
            ["N"] = "单渡线",
            ["X"] = "交叉渡线",
            ["Signal Spacing"] = "信号间隔",
            ["Signal Pattern"] = "信号布置",
            ["Variance"] = "高度变化",
            ["Surface"] = "地面部分",
            ["Underground"] = "地下部分",
            ["Parellal tracks"] = "平行轨道",
            ["General Slope"] = "整体坡度",
            ["Stone brick"] = "石砖",
            ["Crossover"] = "渡线",
            ["Crossover switch group."] = "一组渡线",
            ["Track ladders"] = "梯线",
            ["Track ladders used to form a shunting yard or depot."] = "在车辆段和编组场常见的梯线",
            ["Switches"] = "道岔",
            ["Switch on one track or switch group on many tracks."] = "单条轨道或多条轨道的道岔（组）",
            ["Parallel tracks"] = "平行线",
            ["One or many tracks with fix radious and signaling spacing."] = "一组或一条带有固定半径和信号机间距的轨道",
            ["Underground tracks"] = "地下线",
            ["Underground tracks with fix radious and signaling spacing."] = "一组或一条带有固定半径和信号机间距的地下轨道",
            ["Moving Block"] = "移动闭塞",
            ["Compact Tunnel entry"] = "紧凑隧道入口",
            ["A compact tunnel entry"] = " 一个紧凑的隧道入口",
            ["Both"] = "两侧",
            ["Open"] = "开放",
            ["Closed"] = "关闭",
            ["Turnout #"] = "道岔号数",
            ["↕↕↕↕"] = "双向自闭"
        },
        de = {
            ["name"] = "Track Design Patterns",
            ["desc"] = descDE,
            
            ["Turnout"] = "Weichenradius",
            ["Pattern"] = "Vorlage",
            ["Orientaion"] = "Richtung",
            ["Left"] = "Links",
            ["Right"] = "Rechts",
            ["Track Distance"] = "Gleisabstand",
            ["Slope"] = "Steigung",
            ["Wall A"] = "Wand A",
            ["Height"] = "Höhe",
            ["None"] = "Nichts",
            ["Type"] = "Typ",
            ["Concrete"] = "Beton",
            ["Arch"] = "Bogen",
            ["Noise barrier"] = "Schallschutzmauer",
            ["Wall B"] = "Wand B",
            ["Sync"] = "Synchron",
            ["Altitude Adjustment"] = "Höhenanpassung",
            ["Last Section"] = "Letztes Segment",
            ["Wall-Track distance"] = "Wandabstand zu Gleis",
            ["Compactness"] = "Kompaktheit",
            ["Extra loose"] = "Extra weit",
            ["Loose"] = "weit",
            ["Standard"] = "Standart",
            ["Medium"] = "Medium",
            ["Compact"] = "Kompakt",
            ["Complete"] = "Komplett",
            ["Radius"] = "Radius",
            ["Begin"] = "Anfangssteigung",
            ["End"] = "Endsteigung",
            ["Length"] = "Länge",
            ["×100m"] = "×100m",
            ["×10m"] = "×10m",
            ["Signal Spacing"] = "Signalabstand",
            ["Signal Pattern"] = "Signalmuster",
            ["Variance"] = "Variante",
            ["Surface"] = "Oberfläche",
            ["Underground"] = "Unterierdisch",
            ["Parellal tracks"] = "Parallele Gleise",
            ["General Slope(‰)"] = "Allgemeine Steigung(‰)",
            ["Stone brick"] = "Steinziegel",
            ["Crossover"] = "Weichenübgergang",
            ["Crossover switch group."] = "Weichenübergangsgruppe",
            ["Track ladders"] = "Gleisharfen",
            ["Track ladders used to form a shunting yard or depot."] = "Gleisharfen zum bauen von Depot- und Wartungsanlagen",
            ["Switches"] = "Weichen",
            ["Switch on one track or switch group on many tracks."] = "Weiche mit einem Gleis oder Weichengruppe mit mehreren Gleisen",
            ["Parallel tracks"] = "Parallele Gleise",
            ["One or many tracks with fix radious and signaling spacing."] = "Ein oder mehrere Gleise mit festem Radius und Signalabstand.",
            ["Underground tracks"] = "Unterierdische Gleise",
            ["Underground tracks with fix radious and signaling spacing."] = "Ein oder mehrere unterierdische Gleise mit festem Radius und Signalabstand.",
            ["Moving Block"] = "simulierter Beweglicher Block",
            ["Compact Tunnel entry"] = "Kompakter Tunneleingang",
            ["A compact tunnel entry"] = "Ein kompakter Tunneleingang",
            ["Both"] = "Beide",
            ["Open"] = "Offen",
            ["Closed"] = "Geschlossen",
            ["Turnout #"] = "Weichenradius #",
        }
    }
end
