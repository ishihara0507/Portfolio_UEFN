using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

timer := class:
    Player:player
    LimitTime:float
    HudDevice:hud_message_device
    Teleporter:teleporter_device

    StopEvent:event() = event(){}

    S2M<localizes>(S:string):message = "{S}"

    StartCountDown()<suspends>:void=
        StartTime := GetSimulationElapsedTime()

        race:
            StopEvent.Await()
            loop:
                ElapsedTime := GetSimulationElapsedTime() - StartTime
                if(ElapsedTime >= LimitTime):
                    HudDevice.Show(Player, S2M("00:00"))
                    TeleportToStart()
                    break
                else:
                    HudDevice.Show(Player, S2M(TimeToString(LimitTime - ElapsedTime)))
                Sleep(0.0)

    TeleportToStart():void=
        HudDevice.Hide(Player)
        Teleporter.Teleport(Player)

    # スタートからの経過時間を00:00の形で返す関数
    TimeToString(ElapsedTime:float):string=
        # 各値を算出
        var TotalSeconds : int = 0 # 合計秒
        var MilliSeconds_ : int = 0 # ミリ秒(3桁) なんかMilliSecondsとSecondsは他のスクリプトで使ってるからダメだった
        var Seconds_ : int = 0 # 秒
        var Minutes : int = 0 # 分
        if:
            # 合計秒
            tmp_tsec := Int[ElapsedTime] # 小数点以下は切り捨てられる
            set TotalSeconds = tmp_tsec 
            # ミリ秒(3桁)
            tmp_mili := Int[(ElapsedTime - TotalSeconds*1.0) * 1000]
            set MilliSeconds_ =  tmp_mili
            # 秒
            tmp_sec := Mod[TotalSeconds, 60] 
            set Seconds_ = tmp_sec 
            # 分
            tmp_min := Int[(TotalSeconds - Seconds_)*1.0 / 60.0]
            set Minutes = tmp_min

        # 文字列に変換するための準備
        var Minutes_zero : string = ""
        var Seconds_zero : string = ""
        var MilliSeconds_zero : string = ""
        if(Minutes < 10):
            set Minutes_zero = "0"
        if(Seconds_ < 10):
            set Seconds_zero = "0"
        if(MilliSeconds_ < 10):
            set MilliSeconds_zero = "00"
        else if(MilliSeconds_ < 100):
            set MilliSeconds_zero = "0"

        return "{Seconds_zero}{Seconds_}.{MilliSeconds_zero}{MilliSeconds_}"


count_down_device := class(creative_device):

    @editable
    LimitTime:float = 3.0

    @editable
    StartMutator:mutator_zone_device = mutator_zone_device{}
    @editable
    GoalMutator:mutator_zone_device = mutator_zone_device{}

    @editable
    DmgVolume:damage_volume_device = damage_volume_device{}

    @editable
    Teleporter:teleporter_device = teleporter_device{}

    @editable
    HudDevice:hud_message_device = hud_message_device{}

    @editable
    EreaMutator:mutator_zone_device = mutator_zone_device{}

    var PlayerTimerMap:[player]timer = map{}

    OnBegin<override>()<suspends>:void=
        StartMutator.AgentEntersEvent.Subscribe(EnterStartMutator)
        GoalMutator.AgentEntersEvent.Subscribe(EnterEndMutator)
        DmgVolume.AgentEntersEvent.Subscribe(EnterDmgVolume)
        EreaMutator.AgentExitsEvent.Subscribe(ExitMutator)

    EnterDmgVolume(Agent:agent):void=
        if(Player := player[Agent], Timer := PlayerTimerMap[Player]):
            Timer.TeleportToStart()
            Timer.StopEvent.Signal()

    EnterStartMutator(Agent:agent):void=
        if(Player := player[Agent]):
            NewTimer := timer:
                Player := Player
                LimitTime := LimitTime
                HudDevice := HudDevice
                Teleporter := Teleporter

            spawn{NewTimer.StartCountDown()} # タイマー開始

            if. set PlayerTimerMap[Player] = NewTimer

    EnterEndMutator(Agent:agent):void=
        if(Player := player[Agent], Timer := PlayerTimerMap[Player]):
            Timer.StopEvent.Signal()

    ExitMutator(Agent:agent):void=
        HudDevice.Hide(Agent)