using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

test_ui := class():
    var MainCanvas : canvas = canvas{}

    Image_Test : texture_block = texture_block :
        DefaultImage := Textures.Creative_Coin
        DefaultDesiredSize := vector2{X := 200.0, Y := 200.0}
        
    Image_Test2 : texture_block = texture_block :
        DefaultImage := Textures.Creative_Coin
        DefaultDesiredSize := vector2{X := 200.0, Y := 200.0}

    var Flag:logic = false

    Anim(Agent:agent)<suspends>:void=
        var X:float = 0.0
        var Y:float = 0.0
        var Degree:float = 0.0
        Radius:float = 300.0

        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]) :
            PlayerUI.AddWidget(MainCanvas)

            loop :
                # ウィジェットの削除
                Widget := if(not Flag?). Image_Test else. Image_Test2
                    MainCanvas.RemoveWidget(Widget)

                # ウィジェットの作成・付与
                MainCanvas.AddWidget(
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 0.5}
                            Maximum := vector2{X := 0.5, Y := 0.5}
                        Offsets := margin{Left := X, Top := Y}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := true
                        Widget := if(Flag?). Image_Test else. Image_Test2
                )

                # Flagの反転
                set Flag = if(Flag?). false else. true
                
                # 座標の更新
                set X = 0.0 + Radius * Cos(DegreesToRadians(Degree))
                set Y = 0.0 + Radius * Sin(DegreesToRadians(Degree))
                set Degree += 3.0

                # アニメーションの終了
                if(Degree >= 360.0):
                    MainCanvas.RemoveWidget(Image_Test)
                    break

                Sleep(0.0)

            # アニメーション終了
            PlayerUI.RemoveWidget(MainCanvas)

new_ui_animation_device := class(creative_device):

    @editable Btn : button_device = button_device{}

    TestUI : test_ui = test_ui{}

    OnBegin<override>()<suspends>:void=
        Btn.InteractedWithEvent.Subscribe(OnDebug0)

    OnDebug0(Agent : agent):void=
        Print("ボタンが押された")
        spawn{TestUI.Anim(Agent)}
            
