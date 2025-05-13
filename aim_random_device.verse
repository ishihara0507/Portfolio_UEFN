using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }



aim_ramdom_device := class(creative_device):

    # @editable
    var ArrowProps:[]creative_prop = array{} # 位置と向きを使う

    # @editable
    var MovementModulators:[]movement_modulator_device = array{}

    @editable
    CenterProp:creative_prop = creative_prop{} # このプロップに位置に向かってNPCが飛んでいくようにする

    @editable
    NPCSpawner:npc_spawner_device = npc_spawner_device{}
   
    @editable
    Teleporter:teleporter_device = teleporter_device{} # 動的に移動するテレポーター
    
    @editable
    MutatorZone:mutator_zone_device = mutator_zone_device{}

    @editable
    ClassSelector:class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{}

    EliminatedEvent:event() = event(){}
    StopEvent:event() = event(){}
    
    OnBegin<override>()<suspends>:void=
        set ArrowProps += 
            for:
                Actor:FindCreativeObjectsWithTag(ArrowProps_1{})
                ArrowProp := creative_prop[Actor]
            do:
                ArrowProp
        SetArrowProps()

        set MovementModulators += 
            for:
                Actor:FindCreativeObjectsWithTag(MovementModulator_1{})
                MovementModulator := movement_modulator_device[Actor]
            do:
                MovementModulator
        for(MovementModulator:MovementModulators):
            MovementModulator.Disable()

        Print("{ArrowProps.Length}")
        Print("{MovementModulators.Length}")

        MutatorZone.AgentEntersEvent.Subscribe(InitMutator)
        MutatorZone.AgentExitsEvent.Subscribe(ExitMutator)
        NPCSpawner.SpawnedEvent.Subscribe(SpawnedNPC)
        NPCSpawner.EliminatedEvent.Subscribe(EliminatedNPC)

    InitMutator(Agent:agent):void=
        if(player[Agent]):
            ClassSelector.ChangeClass(Agent)
            StopEvent.Signal()
            spawn{SpawnNPC()}

    ExitMutator(Agent:agent):void=
        if(player[Agent]):
            NoneClassSelector.ChangeClass(Agent)
            StopEvent.Signal()

    SpawnedNPC(Agent:agent):void=
        Teleporter.Teleport(Agent)
 
    EliminatedNPC(Result:device_ai_interaction_result):void=
        Print("キル")
        EliminatedEvent.Signal()

    # 矢オブジェクトの方向を中心オブジェクトの方向に回転させる
    SetArrowProps():void=
        return
        
    SpawnNPC()<suspends>:void=
        race:
            block:
                Print("停止")
                StopEvent.Await()
                NPCSpawner.DespawnAll(false)
            loop:
                for(MovementModulator:MovementModulators):
                    MovementModulator.Disable()

                if(ArrowProp := Shuffle(ArrowProps)[0], MovementModulator := Shuffle(MovementModulators)[0]):
                    MovementModulator.Enable()
                    Transform := ArrowProp.GetTransform()
                    if:
                        MovementModulator.TeleportTo[Transform.Translation, Transform.Rotation]
                        Teleporter.TeleportTo[Transform.Translation, Transform.Rotation]
                    then:
                        Print("o")
                        NPCSpawner.Spawn()
                    else:
                        Print("エラー：デバイスのテレポートに失敗しました。")
                        break
                    Print("あ")
                    EliminatedEvent.Await()
                else:
                    Print("エラー：アロープロップまたはムーブメントモジュレーターが見つかりませんでした。")
                    break