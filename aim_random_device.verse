using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation/Tags }

MovementModulator_SG := class(tag){}
ArrowProps_SG := class(tag){}

MovementModulator_ARSMG := class(tag){}
ArrowProps_ARSMG := class(tag){}

MovementModulator_ARSR := class(tag){}
ArrowProps_ARSR := class(tag){}

mode_enum := enum:
    SG
    ARSMG
    ARSR
(ME:mode_enum).ToArrowTag():tag=
    case(ME):
        mode_enum.SG => ArrowProps_SG{}
        mode_enum.ARSMG => ArrowProps_ARSMG{}
        mode_enum.ARSR => ArrowProps_ARSR{}
(ME:mode_enum).ToMovementModulatorTag():tag=
    case(ME):
        mode_enum.SG => MovementModulator_SG{}
        mode_enum.ARSMG => MovementModulator_ARSMG{}
        mode_enum.ARSR => MovementModulator_ARSR{}

aim_ramdom_device := class(creative_device):

    @editable
    Mode:mode_enum = mode_enum.SG

    # @editable
    var ArrowProps:[]creative_prop = array{} # 位置と向きを使う

    # @editable
    var MovementModulators:[]movement_modulator_device = array{}

    @editable
    ShouldFaceCenter:logic = true
    @editable
    CenterProp:creative_prop = creative_prop{} # このプロップに位置に向かってNPCが飛んでいくようにする

    @editable
    NPCSpawner:npc_spawner_device = npc_spawner_device{}
   
    @editable
    Teleporter:teleporter_device = teleporter_device{} # 動的に移動するテレポーター
    
    @editable
    MutatorZone:mutator_zone_device = mutator_zone_device{}

    @editable
    ClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # このコースに入ったときになるクラスのセレクター    
    @editable
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{}

    EliminatedEvent:event() = event(){}
    StopEvent:event() = event(){}
    
    OnBegin<override>()<suspends>:void=
        ArrowTag := Mode.ToArrowTag()
        set ArrowProps += 
            for:
                Actor:FindCreativeObjectsWithTag(ArrowTag)
                ArrowProp := creative_prop[Actor]
            do:
                ArrowProp
        if(ShouldFaceCenter?):
            SetArrowProps()

        MovementModulatorTag := Mode.ToMovementModulatorTag()
        set MovementModulators += 
            for:
                Actor:FindCreativeObjectsWithTag(MovementModulatorTag)
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
        CenterPos := CenterProp.GetTransform().Translation
        for(ArrowProp:ArrowProps):
            ArrowPos := ArrowProp.GetTransform().Translation
            ArrowForward := ArrowProp.GetTransform().Rotation.GetLocalForward()
            ToCenter := vector3:
                X := CenterPos.X - ArrowPos.X
                Y := CenterPos.Y - ArrowPos.Y
                Z := 0.0
            if(NewForwardNorm := ToCenter.MakeUnitVector[]):
                ToCenterLength := Sqrt(ToCenter.X * ToCenter.X + ToCenter.Y * ToCenter.Y)
                var ToCenterNorm:vector3 = vector3{}
                if(ToCenterLength > 0.0):
                    set ToCenterNorm = vector3:
                        X := ToCenter.X / ToCenterLength
                        Y := ToCenter.Y / ToCenterLength
                        Z := 0.0
                else:
                    set ToCenterNorm = vector3:
                        X := 1.0
                        Y := 0.0
                        Z := 0.0
                XZLength := Sqrt(ArrowForward.X * ArrowForward.X + ArrowForward.Y * ArrowForward.Y)
                NewForwardXZ := ToCenterNorm * XZLength

                NewForward := vector3:
                    X := NewForwardXZ.X
                    Y := NewForwardXZ.Y
                    Z := ArrowForward.Z
                
                NewRotation := MakeShortestRotationBetween(ArrowForward, NewForward).RotateBy(ArrowProp.GetTransform().Rotation)
                if. ArrowProp.TeleportTo[ArrowPos, NewRotation]
                CenterProp.Dispose()
            else:
                Print("ベクトルの計算に失敗しました。")
        
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
                        NPCSpawner.Spawn()
                    else:
                        Print("エラー：デバイスのテレポートに失敗しました。")
                        break
                    EliminatedEvent.Await()
                else:
                    Print("エラー：アロープロップまたはムーブメントモジュレーターが見つかりませんでした。")
                    break