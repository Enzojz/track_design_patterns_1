local descEN = [[This mod is a revival of the Transport Fever mod of the same name, with Compact Tunnel Entry, paraelle tracks and automatic signalling removed, due to the implementation of better mods.

This mod give you possibility to create kinds of track patterns precisely with parameters, which more alike real life engineering work.
It gives you hand to control separately the following parameters:
* Slope
* Size of switch
* Walls at sides of tracks, including type, height, distance to track, and height variation to avoid Zig-Zags when you want to make a transition of walls of different height 
* Automatically calculated terrain which is impossible to archive by normal constructions

=== Three patterns are found in Asset menu category "track_design_patterns" ===
1. Switch
2. Crossover
3. Track ladders

=== Brief introduction to patterns ===

1. Switch
This pattern create simple a switch, by controlling the size represented by cotangent of the switch frog. You can use it repeatly to quickly construction a diverging section of a depot or station.
This pattern also permits a flat junction quickly, by multiplying number of tracks
You can choose the form of turn out of switches by changing "compactness" option between "Complete" and others.
You can add walls to the sides of switches, which is much easier than adding it manually with assets.

2. Crossover
Two crossovers are supported, the X crossover and N crossover, to get K crossover, please construct two N crossover in opposition.
You have option to construct some parallel N crossovers by choosing 1/2 or 3/4 N crossovers.
You can change the distance between two tracks to fit into different parts of stations.

3. Track ladders
This pattern is destinated to quickly create diverging part of a depot or something similar.
You can change the distance between exit tracks to fit into different parts of stations.
You can add walls to the sides of switches, which is much easier than adding it manually with assets.

1.1
* French translation
* Fix the irremovable terrain under tracks built as free tracks.
1.0 
* Initial port from Transport Fever
]]

local descFR = [[Ce mod est une réédition du mod du même nom intitulé "Transport Fever", sans les fonctionalités de l'entrée de tunnel compacte, des voies parallèles et de la signalisation automatique, car elles existents déjà dans mes autres mods.

Ce mod vous donne la possibilité de créer des types de tracés de voies avec précision à l'aide de paramètres, qui ressemblent davantage à des travaux d'ingénierie réels.
Il vous donne la possibilité de contrôler séparément les paramètres suivants :
* Pente
* Taille de l'aiguillage
* Murs sur les côtés des voies, y compris le type, la hauteur, la distance par rapport à la voie et la variation de hauteur pour éviter les zigzags lorsque vous voulez faire une transition de murs de hauteur différente
* Terrain calculé automatiquement, ce qui est normalement impossible à réaliser.

=== Trois tracés se trouvent dans la catégorie "track_design_patterns" du menu Asset ===
1. Aiguillage
2. Voie jonction
3. "Échelles de voie"

=== Brève présentation des tracés ===

1. Aiguillage
Ce tracé permet de créer un simple interrupteur, en contrôlant la taille représentée par la cotangente de la grenouille de l'interrupteur. Vous pouvez l'utiliser à plusieurs reprises pour construire rapidement une section divergente d'un dépôt ou d'une gare.
Ce tracé permet également de réaliser rapidement une jonction plate, en multipliant le nombre de voies
Vous pouvez choisir la forme des interrupteurs en changeant l'option "compacité" (compactness) entre "Complet" et autres.
Vous pouvez ajouter des murs sur les côtés des interrupteurs, ce qui est beaucoup plus facile que de l'ajouter manuellement avec des assets.

2. Voie jonction
Deux voies jonctions sont proposés : la jonction en X et la jonction en N. Pour obtenir une jonction en K, veuillez construire deux jonctions en N opposée.
Vous avez la possibilité de construire des jonctions N parallèles en choisissant des jonctions N 1/2 ou 3/4.
Vous pouvez modifier la distance entre deux voies pour qu'elles s'adaptent à différentes parties des gares.

3. "Échelles de voie"
Ce tracé est destiné à créer rapidement une partie divergente d'un dépôt ou quelque chose de similaire.
Vous pouvez modifier la distance entre les voies de sortie pour qu'elles s'adaptent aux différentes parties des gares.
Vous pouvez ajouter des murs sur les côtés des aiguillages, ce qui est beaucoup plus facile que de l'ajouter manuellement avec des assets.

1.1
* Ajoute de traduction française
* Correction de terrain non supprimable si la voie est libre à modifier
1.0
* Conversion initiale de Transport Fever 1
]]

local descZH = [[
本模组为去除了已经实现的自动信号机放置、平行轨道和紧凑隧道入口的Transport Fever同名模组的转换。

本模组赋予你以参数形式精确创建各种轨道的能力，让你的基础设施更像是精确工程计算的结果。
他让你能够控制下列参数：
* 坡度
* 道岔号数
* 轨道侧的墙，比如类型、高度、到轨道的距离，又比如你希望在不同高度的墙之间过渡时需要的高度渐变等等
* 一些通过正常手法无法获得的地形改变

=== 在资产菜单中可以找到的三种模式轨道 ===
1. 道岔
2. 渡线
3. 梯线
    
=== 轨道模式的简单介绍 ===

1. 道岔
这个模式通过控制以岔心余切值表示的道岔号数创建一个或多个道岔。你可以连续使用这个模式构造一个车辆段或车站的分叉部分。
这个模式同样允许你以增加轨道数量的方式快速地创建一个平线路所。
你可以通过切换道岔的“紧凑度”选项修改道岔的外观，其中的“完整”选项可以产生一个平行的分叉区段。
可以在道岔的两侧添加墙，相比游戏中在同样的位置操作要简便很多。

2. 渡线
这个模式支持两类渡线：交叉渡线和单渡线，连续建造两个相反的单渡线可以构成一个双渡线。
你可以通过选择1/2或者3/4单渡线的选项去建造多个并排的渡线组。
可以通过修改轨道间距选项让这些渡线匹配车站的不同部分。

3. 梯线
这个模式用来快速创建车辆段或者车站的分叉部分。
你可以修改分叉轨道之间的距离去匹配车站的不同部分
可以你在梯线的两侧添加墙，相比游戏中在同样的位置操作要简便很多。

1.1
* 法语翻译
* 修正了建造了自由轨道后，地形无法移除的问题
1.0 
* 自Transport Fever转换而来
]]

local descTC = [[
本模組為去除了已經實現的自動信號機放置、平行軌道和緊湊隧道入口的Transport Fever同名模組的轉換。

本模組賦予你以參數形式精確創建各種軌道的能力，讓你的基礎設施更像是精確工程計算的結果。
他讓你能夠控制下列參數：
* 坡度
* 道岔號數
* 軌道側的牆，比如類型、高度、到軌道的距離，又比如你希望在不同高度的牆之間過渡時需要的高度漸變等等
* 一些通過正常手法無法獲得的地形改變

=== 在資產功能表中可以找到的三種模式軌道 ===
1. 道岔
2. 渡線
3. 梯線
    
=== 軌道模式的簡單介紹 ===

1. 道岔
這個模式通過控制以岔心餘切值表示的道岔號數創建一個或多個道岔。你可以連續使用這個模式構造一個車輛段或車站的分叉部分。
這個模式同樣允許你以增加軌道數量的方式快速地創建一個平線路所。
你可以通過切換道岔的“緊湊度”選項修改道岔的外觀，其中的“完整”選項可以產生一個平行的分叉區段。
可以在道岔的兩側添加牆，相比遊戲中在同樣的位置操作要簡便很多。

2. 渡線
這個模式支援兩類渡線：交叉渡線和單渡線，連續建造兩個相反的單渡線可以構成一個雙渡線。
你可以通過選擇1/2或者3/4單渡線的選項去建造多個並排的渡線組。
可以通過修改軌道間距選項讓這些渡線匹配車站的不同部分。

3. 梯線
這個模式用來快速創建車輛段或者車站的分叉部分。
你可以修改分叉軌道之間的距離去匹配車站的不同部分
可以你在梯線的兩側添加牆，相比遊戲中在同樣的位置操作要簡便很多。

1.1
* 法語翻譯
* 修正了建造了自由軌道後，地形無法移除的問題
1.0 
* 自Transport Fever轉換而來
]]

function data()
    return {
        en = {
            ["name"] = "Track Design Patterns",
            ["desc"] = descEN,
        },
        fr = {
            ["name"] = "Tracés de voies",
            ["desc"] = descFR,
            ["Pattern"] = "Mode",
            ["Orientaion"] = "Oriéntaion",
            ["Left"] = "Gauche",
            ["Right"] = "Droit",
            ["Wye"] = "Symétrique",
            ["Track Distance"] = "Écart voie",
            ["Slope"] = "Pente",
            ["Wall A"] = "Mur A",
            ["Height"] = "Hauteur",
            ["None"] = "Sans",
            ["Type"] = "Type",
            ["Concrete"] = "Concrète",
            ["Arch"] = "Arc",
            ["Wall B"] = "Mur B",
            ["Sync"] = "Sync",
            ["Last Section"] = "Dernière Section",
            ["Wall-Track distance"] = "Écart voie-mur",
            ["Compactness"] = "Compacité",
            ["Extra loose"] = "Extra-souple",
            ["Loose"] = "Souple",
            ["Standard"] = "Standard",
            ["Medium"] = "Moyen",
            ["Compact"] = "Compact",
            ["Complete"] = "Complet",
            ["Stone brick"] = "Pierre de taille",
            ["Crossover"] = "Voie jonction",
            ["Crossover switch group."] = "Une jonction de voie",
            ["Track ladders"] = "Échelles de voie",
            ["Track ladders used to form a shunting yard or depot."] = "Souvent vu dans un dêpot ou gare de triage",
            ["Switches"] = "Aiguille",
            ["Switch on one track or switch group on many tracks."] = "Aiguilles pour une ou plusieur voies",
            ["Open"] = "Ouvert",
            ["Closed"] = "Fermé",
            ["Turnout #"] = "L'inverse du taille d'aiguille",
            ["Free tracks"] = "Voie modifiable",
            ["Not build"] = "Sans",
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
            ["Wall B"] = "侧墙B",
            ["Sync"] = "同A",
            ["Altitude Adjustment"] = "高度调整",
            ["Last Section"] = "末段",
            ["(m)"] = "米",
            ["Wall-Track distance"] = "轨道-侧墙距离",
            ["Compactness"] = "紧凑度",
            ["Extra loose"] = "特松",
            ["Loose"] = "松",
            ["Standard"] = "标准",
            ["Medium"] = "紧",
            ["Compact"] = "特紧",
            ["Complete"] = "完整",
            ["N"] = "单渡线",
            ["X"] = "交叉渡线",
            ["Stone brick"] = "石砖",
            ["Crossover"] = "渡线",
            ["Crossover switch group."] = "一组渡线",
            ["Track ladders"] = "梯线",
            ["Track ladders used to form a shunting yard or depot."] = "在车辆段和编组场常见的梯线",
            ["Switches"] = "道岔",
            ["Switch on one track or switch group on many tracks."] = "单条轨道或多条轨道的道岔（组）",
            ["Open"] = "开放",
            ["Closed"] = "关闭",
            ["Turnout #"] = "道岔号数",
            ["Free tracks"] = "可以修改的轨道",
            ["Not build"] = "不建造",
        },
        zh_TW = {
            ["name"] = "模式軌道（參數化軌道）",
            ["desc"] = descTC,
            ["Pattern"] = "形式",
            ["Orientaion"] = "指向",
            ["Left"] = "左單開",
            ["Right"] = "右單開",
            ["Wye"] = "雙開",
            ["Track Distance"] = "線間距",
            ["Slope"] = "坡度",
            ["Wall A"] = "側牆A",
            ["Height"] = "高度",
            ["None"] = "無",
            ["Type"] = "類型",
            ["Concrete"] = "混凝土",
            ["Arch"] = "券拱",
            ["Noise barrier"] = "隔音牆",
            ["Wall B"] = "側牆B",
            ["Sync"] = "同A",
            ["Altitude Adjustment"] = "高度調整",
            ["Last Section"] = "末段",
            ["(m)"] = "公尺",
            ["Wall-Track distance"] = "軌道-側牆距離",
            ["Compactness"] = "緊湊度",
            ["Extra loose"] = "特松",
            ["Loose"] = "松",
            ["Standard"] = "標準",
            ["Medium"] = "緊",
            ["Compact"] = "特緊",
            ["Complete"] = "完整",
            ["N"] = "單渡線",
            ["X"] = "交叉渡線",
            ["Stone brick"] = "石磚",
            ["Crossover"] = "渡線",
            ["Crossover switch group."] = "一組渡線",
            ["Track ladders"] = "梯線",
            ["Track ladders used to form a shunting yard or depot."] = "在車輛段和編組場常見的梯線",
            ["Switches"] = "道岔",
            ["Switch on one track or switch group on many tracks."] = "單條軌道或多條軌道的道岔（組）",
            ["Open"] = "開放",
            ["Closed"] = "關閉",
            ["Turnout #"] = "道岔號數",
            ["Free tracks"] = "可以修改的軌道",
            ["Not build"] = "不建造",
        }
    
    
    }
end
