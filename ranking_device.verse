using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }

ToolTip4<localizes>:message = "残り何人になったらポイントを与えるのか"
ToolTip5<localizes>:message = "何ポイント与えるのか"

reword_struct := struct<concrete>:
    @editable{ToolTip := ToolTip4}
    PlayerCount:int = 1
    @editable{ToolTip := ToolTip5}
    Point:int = 5

ToolTip<localizes>:message = "残り何人になったら生存プレイヤーに何ポイント与えるのかを設定します。\n\n例） PlayerCount：1, Point：5 と設定した場合\n残りプレイヤー人数が１人になったら、生存プレイヤーに５ポイントを渡します。"
ToolTip2<localizes>:message = "チェックを入れたらデバッグモードで実行します。\nマップを公開するときはチェックを外した状態でお願いします！（おそらくどっちでも大丈夫だと思いますが、念のため）"
ToolTip3<localizes>:message = "ここに設定したトリガーを実行すると、全プレイヤーに撃破イベントが登録されます。"
ToolTip6<localizes>:message = "敵をキルしたときに、キルしたプレイヤーに何ポイント与えるか。"
ToolTip7<localizes>:message = "撃破マネージャーを設定してください。中身は特に変更する必要はありません！"
ToolTip8<localizes>:message = "スコアマネージャーを設定してください。中身は特に変更する必要はありません！\n敵をキルしたときに与えられるポイントを変更したい場合は、スコアマネージャーのオプションではなく、\nKillPointの値を変更してください！"
ToolTip9<localizes>:message = "KillScoreDeviceと異なるスコアマネージャーを設定してください。中身は特に変更する必要はありません！"

ranking_device := class(creative_device):
    @editable{ToolTip := ToolTip}
    var RewordTable:[]reword_struct = array{}

    @editable{ToolTip := ToolTip2}
    IsDebugMode:logic = false
    
    @editable{ToolTip := ToolTip6}
    KillPoint:int = 1

    @editable{ToolTip := ToolTip3}
    InitTrigger:trigger_device = trigger_device{}

    @editable{ToolTip := ToolTip7}
    EliminationDevice:elimination_manager_device = elimination_manager_device{}
    @editable{ToolTip := ToolTip8}
    KillScoreDevice:score_manager_device = score_manager_device{}
    @editable{ToolTip := ToolTip9}
    AliveScoreDevice:score_manager_device = score_manager_device{}

    var IsNotStarted:logic = true
    var AlivePlayerNum:int = 0
    var ProcessNum:int = 0
    var EliminatedAIs:[]agent = array{}

    OnBegin<override>()<suspends>:void=
        InitTrigger.TriggeredEvent.Subscribe(OnInitTriggered)
        return

    OnInitTriggered(OAgent:?agent):void=
        if(IsNotStarted?):
            Print("初期化開始")
            set IsNotStarted = false

            if(IsDebugMode?):
                set AlivePlayerNum = GetPlayspace().GetParticipants().Length
            else:
                set AlivePlayerNum = GetPlayspace().GetPlayers().Length
            for(Index->Reword:RewordTable, AlivePlayerNum <= Reword.PlayerCount): # 初期化時点で条件に達しているリワードは削除する
                if(NewTable := RewordTable.RemoveElement[Index]):
                    set RewordTable = NewTable

            KillScoreDevice.SetScoreAward(KillPoint)
            EliminationDevice.EliminationEvent.Subscribe(OnPlayerKill)
            EliminationDevice.EliminatedEvent.Subscribe(OnPlayerDeath)

            Print("初期状態の生存プレイヤー数: {AlivePlayerNum}")
            spawn{GivePointToAlivePlayers()}
            spawn{CheckPlayerLeaved()}

    OnPlayerKill(OEliminator:?agent):void=
        Print("キル発生")

        if(Eliminator := OEliminator?):
            KillScoreDevice.Activate(Eliminator)

        set ProcessNum += 1
        
    OnPlayerDeath(EliminatedAgent:agent):void=
        if(not player[EliminatedAgent]):
            set EliminatedAIs += array{EliminatedAgent}

    GetAliveAgents():[]agent=
        var AliveAgents:[]agent = array{}

        var Agents:[]agent = array{}
        if(IsDebugMode?):
            set Agents = GetPlayspace().GetParticipants()
        else:
            set Agents = GetPlayspace().GetPlayers()

        for(Agent:Agents, not Agent.IsSpectator[], not EliminatedAIs.Find[Agent]):
            set AliveAgents += array{Agent}
            
        Print("現在の生存プレイヤー数: {AlivePlayerNum}")

        return AliveAgents

    GivePointToAlivePlayers()<suspends>:void=
        loop:
            if(ProcessNum > 0):
                set AlivePlayerNum -= 1
                Agents := GetAliveAgents()
                for(Index->Reword:RewordTable, AlivePlayerNum <= Reword.PlayerCount):
                    AliveScoreDevice.SetScoreAward(Reword.Point)
                    for(Agent:Agents):
                        AliveScoreDevice.Activate(Agent)
                    if(NewTable := RewordTable.RemoveElement[Index]):
                        set RewordTable = NewTable
                
                set ProcessNum -= 1
            Sleep(0.0)
        
    CheckPlayerLeaved()<suspends>:void=
        loop:
            LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
            Print("プレイヤーの退出を検知")
            set ProcessNum += 1
            Sleep(0.0)