using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_stats_device := class(creative_device):

    @editable
    InitMutator:mutator_zone_device = mutator_zone_device{}

    @editable
    AddBtn:button_device = button_device{}

    @editable
    RoundBtn:button_device = button_device{}

    @editable
    RoundDevice:round_settings_device = round_settings_device{}

    @editable
    Billboard:billboard_device = billboard_device{}

    PlayerStatsManager:player_stats_manager = player_stats_manager{}

    var PlayerValueMap:[player]int = map{}

    S2M<localizes>(S:string):message = "{S}"
    
    OnBegin<override>()<suspends>:void=
        InitMutator.AgentEntersEvent.Subscribe(EnterInitMutator)
        AddBtn.InteractedWithEvent.Subscribe(PressAddBtn)
        RoundBtn.InteractedWithEvent.Subscribe(PressRoundBtn)

    EnterInitMutator(Agent:agent):void=
        PlayerStatsManager.InitializePlayerStat(Agent)
        if:
            Player := player[Agent]
            not PlayerValueMap[Player]
            set PlayerValueMap[Player] = 0
        UpdateBillboard(Agent)
        Print("持続データの初期化完了")

    PressAddBtn(Agent:agent):void=
        PlayerStatsManager.UpdatePointStat(Agent)
        OCurrentPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if(CurrentPlayerStats := OCurrentPlayerStats?, Point := CurrentPlayerStats.Point):
            Print("現在の持続データ: {Point}")
        if(Player := player[Agent], set PlayerValueMap[Player] += 1, Value := PlayerValueMap[Player]):
            Print("現在の通常データ: {Value}")
        UpdateBillboard(Agent)

    PressRoundBtn(Agent:agent):void=
        Print("ラウンドを終了する")
        RoundDevice.EndRound(Agent)

    UpdateBillboard(Agent:agent):void=
        OCurrentPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if:
            Player := player[Agent]
            CurrentPlayerStats := OCurrentPlayerStats?
            Point := CurrentPlayerStats.Point
            Value := PlayerValueMap[Player]
        then:
            Billboard.SetText(S2M("持続データ: {Point}\n通常データ: {Value}"))