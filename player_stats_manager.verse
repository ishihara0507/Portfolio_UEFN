using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# 統計データを更新するためのクラス
player_stats_manager := class():

    # プレイヤーの統計データを返す関数
    GetPlayerStats(Agent:agent):?player_stat=
        var PlayerStat:?player_stat = false
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            set PlayerStat = option{CurrentPlayerStat}
        return PlayerStat

    # すべてのプレイヤーの統計データを初期化する関数（あまり使い時はないかも？）
    InitializeAllPlayers(Players:[]player):void=
        for (Player : Players):
            InitializePlayerStat(Player)

    # 特定のプレイヤーの統計データを初期化する関数
    InitializePlayerStat(Agent:agent):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            not PlayerStatMap[Player]
            set PlayerStatMap[Player] = player_stat{}

    # プレイヤーの持続データのVersionの値を変更する関数
    UpdateVersionStat(Agent:agent, Value:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                Version := CurrentPlayerStat.Version + Value
            if. set PlayerStatMap[Player] = NewStat

    UpdatePointStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                Point := CurrentPlayerStat.Point + 1
            if. set PlayerStatMap[Player] = NewStat

    # プレイヤーの統計データを初期値にリセットする関数
    ResetPlayerStat(Agent:agent):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatMap[Player]
            set PlayerStatMap[Player] = player_stat{}