using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_stat := class<final><persistable>:
    
    Version:int = 0 # 現在の統計テーブルのバージョン
    
    Point:int = 0

# 前の player_stats_table と同じ値を持つ新しい player_stats_table を作成するコンストラクタ関数
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat)<transacts> := player_stat:
    Version := OldStats.Version
    Point := OldStats.Point

# プレイヤーを、そのプレイヤーの統計テーブルにマッピングします。
var PlayerStatMap : weak_map(player, player_stat) = map{}