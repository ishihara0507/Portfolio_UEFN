using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation/Tags }

axis_enum := enum: # 軸
    X
    Y
    Z

direction_enum := enum: # 方向
    positive
    negative
(DE:direction_enum).ToInt():int=
    case(DE):
        direction_enum.positive => 1
        direction_enum.negative => -1

distance_data := class:
    @editable
    Meter:int = 0

    @editable
    Trigger:trigger_device = trigger_device{}

    var Axis:axis_enum = axis_enum.X
    var Direction:int = 1
    var BasePos:vector3 = vector3{}
    var MoveProp:creative_prop = creative_prop{}

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?, player[Agent]):
            Print("トリガー")
            ChangeDistance()
        
    ChangeDistance():void=
        MovePropPos := MoveProp.GetTransform().Translation
        NewPos := vector3:
            X := if(Axis = axis_enum.X). BasePos.X + 100.0 * Meter * Direction else. MovePropPos.X
            Y := if(Axis = axis_enum.Y). BasePos.Y + 100.0 * Meter * Direction else. MovePropPos.Y
            Z := if(Axis = axis_enum.Z). BasePos.Z + 100.0 * Meter * Direction else. MovePropPos.Z

        if. MoveProp.TeleportTo[NewPos, MoveProp.GetTransform().Rotation]
        else. Print("プロップの移動に失敗しました。")

change_distance_device := class(creative_device):

    @editable
    DistaceDatas:[]distance_data = array{}
    
    @editable
    Axis:axis_enum = axis_enum.X # 軸

    @editable
    Direction:direction_enum = direction_enum.positive # 方向

    @editable
    BasePosProp:creative_prop = creative_prop{} # 距離の原点となるプロップ
    
    @editable
    MoveProp:creative_prop = creative_prop{} # 動かすプロップ（動かしたいプロップの親要素を指定する）

    OnBegin<override>()<suspends>:void=
        BasePos := BasePosProp.GetTransform().Translation
        for(DistaceData:DistaceDatas):
            DistaceData.Trigger.TriggeredEvent.Subscribe(DistaceData.OnTriggered)
            set DistaceData.Axis = Axis
            set DistaceData.Direction = Direction.ToInt()
            set DistaceData.BasePos = BasePos
            set DistaceData.MoveProp = MoveProp

        BasePosProp.Dispose() # 基準プロップを削除する