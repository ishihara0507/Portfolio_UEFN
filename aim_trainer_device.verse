using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

target_data := class:
    @editable
    Prop:creative_prop = creative_prop{}

    @editable
    PropManipulator:prop_manipulator_device = prop_manipulator_device{}

    var Index:int = 0
    var AimTrainerDevice:aim_trainer_device = aim_trainer_device{}

    OnDameged(Agent:agent):void=
        MoveTarget()

    MoveTarget():void=
        var NewPos:vector3 = vector3{}
        if(AimTrainerDevice.Surfase = surface_enum.XZ):
            loop:
                PosX := GetRandomFloat(AimTrainerDevice.BasePos.X + AimTrainerDevice.TargetRadius, AimTrainerDevice.WidthProp.GetTransform().Translation.X - AimTrainerDevice.TargetRadius)
                PosZ := GetRandomFloat(AimTrainerDevice.BasePos.Z + AimTrainerDevice.TargetRadius, AimTrainerDevice.HeightProp.GetTransform().Translation.Z - AimTrainerDevice.TargetRadius)
                set NewPos = vector3:
                    X := PosX
                    Y := AimTrainerDevice.BasePos.Y
                    Z := PosZ
                IsValid := CheckPos(PosX, PosZ)
                if(IsValid?):
                    break
                # Print("再計算")
        else:
            loop:
                PosY := GetRandomFloat(AimTrainerDevice.BasePos.Y + AimTrainerDevice.TargetRadius, AimTrainerDevice.WidthProp.GetTransform().Translation.Y - AimTrainerDevice.TargetRadius)
                PosZ := GetRandomFloat(AimTrainerDevice.BasePos.Z + AimTrainerDevice.TargetRadius, AimTrainerDevice.HeightProp.GetTransform().Translation.Z - AimTrainerDevice.TargetRadius)
                set NewPos = vector3:
                    X := AimTrainerDevice.BasePos.X
                    Y := PosY
                    Z := PosZ
                IsValid := CheckPos(PosY, PosZ)
                if(IsValid?):
                    break
                # Print("再計算")

        if:
            Prop.TeleportTo[NewPos, Prop.GetTransform().Rotation]
            set AimTrainerDevice.TargetPositions[Index] = NewPos
        else:
            Print("ターゲットの移動に失敗しました。")

    # 他のターゲットと重なる座標じゃなかったら true を返す関数
    CheckPos(NewWidth:float, NewHeight:float):logic=
        var Result:logic = true

        for(TargetPosition:AimTrainerDevice.TargetPositions):
            PosWidth := if(AimTrainerDevice.Surfase = surface_enum.XZ). TargetPosition.X else. TargetPosition.Y
            Dist := Distance(
                vector2{X := NewWidth, Y := NewHeight},
                vector2{X := PosWidth, Y := TargetPosition.Z}
            )
            # Print("距離: {Dist}")
            if(Dist <= AimTrainerDevice.TargetRadius * 2.0):
                set Result = false

        return Result
        
surface_enum := enum:
    XZ
    YZ

aim_trainer_device := class(creative_device):
    @editable
    TargetDatas:[]target_data = array{}

    @editable
    TargetRadius:float = 50.0

    @editable
    BaseProp:creative_prop = creative_prop{}
    @editable
    WidthProp:creative_prop = creative_prop{} # 基準と比べて正の座標に配置する
    @editable
    HeightProp:creative_prop = creative_prop{} # 基準と比べて正の座標に配置する

    @editable
    Surfase:surface_enum = surface_enum.XZ

    var TargetPositions:[]vector3 = array{}
    var BasePos:vector3 = vector3{}

    OnBegin<override>()<suspends>:void=
        set BasePos = BaseProp.GetTransform().Translation

        for(Index->TargetData:TargetDatas):
            set TargetPositions += array{vector3{}}
            set TargetData.Index = Index
            set TargetData.AimTrainerDevice = Self
            TargetData.PropManipulator.DamagedEvent.Subscribe(TargetData.OnDameged)
            TargetData.MoveTarget()