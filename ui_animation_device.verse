using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }

ui_animation_device := class(creative_device):

    @editable
    Btn:button_device = button_device{}

    var MainCanvas:canvas = canvas{}

    var Flag:logic = false

    Image:texture_block = texture_block{DefaultImage := Textures.Creative_Coin, DefaultDesiredSize := vector2{X := 200.0, Y := 200.0}}
    Image2:texture_block = texture_block{DefaultImage := Textures.Creative_Coin, DefaultDesiredSize := vector2{X := 200.0, Y := 200.0}}

    OnBegin<override>()<suspends>:void=
        Btn.InteractedWithEvent.Subscribe(PressBtn)
        return

    PressBtn(Agent:agent):void=
        Print("ボタンが押された")

        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = canvas{}
            PlayerUI.AddWidget(MainCanvas)
            spawn{Anim(PlayerUI)}

    Anim(PlayerUI:player_ui)<suspends>:void=
        var Widget:widget = canvas{}

        var X:float = 0.0
        var Y:float = 0.0
        var Degree:float = 0.0
        Radius:float = 300.0

        loop:
            # ウィジェットの削除
            MainCanvas.RemoveWidget(Widget)
            
            # ウィジェットの作成・付与
            set Widget = CreateUI(X, Y)
            MainCanvas.AddWidget(
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := -0.0, Bottom := -0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Widget
            )
            
            # 座標の更新
            set X = 0.0 + Radius * Cos(DegreesToRadians(Degree))
            set Y = 0.0 + Radius * Sin(DegreesToRadians(Degree))
            set Degree += 3.0
            
            # アニメーションの終了
            if(Degree >= 360.0):
                MainCanvas.RemoveWidget(Widget)
                PlayerUI.RemoveWidget(MainCanvas)
                break
                
            Sleep(0.0)

    CreateUI(X:float, Y:float):widget=
        var NewWidget:widget = canvas{}

        set NewWidget = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := X, Top := Y, Right := -0.0, Bottom := -0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := if(Flag?). Image else. Image2

        set Flag = if(Flag?). false else. true # Flagの反転

        return NewWidget