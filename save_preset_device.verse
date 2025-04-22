using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Assets }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }

#####################################
### プリセットの登録を行うプログラム ###
#####################################

save_preset_device := class(creative_device):

    @editable
    WeaponsSelectDevice:weapons_select_device = weapons_select_device{}

    @editable
    SaveBtn:button_device = button_device{}

    var PlayerPresetsUIMap:[player]presets_ui = map{}

    var PlayerPresetsMap:[player][][]weapon_enum = map{}

    S2M<localizes>(S:string):message = "{S}"

    OnBegin<override>()<suspends>:void=
        SaveBtn.InteractedWithEvent.Subscribe(OnTriggered)

    OnTriggered(Agent:agent):void=
        if(Player := player[Agent]):
            spawn{MakePresetsUI(Player)}

    # プリセットUIを作成する関数        
    MakePresetsUI(Player:player)<suspends>:void=
        if(not PlayerPresetsMap[Player]):
            NewArray := array:
                array{weapon_enum.SideArmPistol_L1, weapon_enum.SubmachineGun_L1, weapon_enum.AssaultRifle_L1, weapon_enum.RocketLauncher_L1}
                array{}
                array{}
                array{}
                array{}
            if. set PlayerPresetsMap[Player] = NewArray

        Print("UI作成")
        if(HoldingWeapons := WeaponsSelectDevice.WeaponsPlayerMap[Player]):
            NewPresetsUI := presets_ui{Player := Player, WeaponsSelectDevice := WeaponsSelectDevice, HoldingWeapons := HoldingWeapons, SavePresetDevice := Self}
            NewPresetsUI.Init()

            if(set PlayerPresetsUIMap[Player] = NewPresetsUI, PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(NewPresetsUI.Widget, player_ui_slot{InputMode := ui_input_mode.All})
                NewPresetsUI.KillEvent.Await()
                PlayerUI.RemoveWidget(NewPresetsUI.Widget)
        else:
            Print("連携エラー")

    # すべてのプレイヤーからプリセット登録UIを削除する関数
    KillAllPresetsUI():void=
        for(PlayerPresetsUI:PlayerPresetsUIMap):
            PlayerPresetsUI.KillEvent.Signal()

presets_ui := class:

    var Widget:widget = canvas{}

    # インスタンス作成時に設定する
    Player:player
    WeaponsSelectDevice:weapons_select_device
    HoldingWeapons:[]weapon_enum
    SavePresetDevice:save_preset_device
    
    var MaxPage:int = 0 # プリセット登録できる最大値
    var PageNum:int = 0 # 最初のページを０ページ目と考える

    WeaponSlotsNum:int = 5
    var Presets:[][]weapon_enum = array{} # 持続データに登録されているプリセットを保持する

    # ウィジェット
    var BackBtn:button_loud = button_loud{}
    var SaveBtn:button_loud = button_loud{}
    var NextBtn:button_loud = button_loud{}
    var ExitBtn:button_regular = button_regular{}

    var PagiNationBlocks:[]color_block = array{}
    var PagiNationBorders:[]color_block = array{}

    var HoldingWeaponTextures:[]texture_block = array{}
    var PresetWeaponTextures:[]texture_block = array{}

    # イベント
    KillEvent:event() = event(){}
    UpdateEvent:event() = event(){}

    S2M<localizes>(S:string):message = "{S}"

    # 初期化関数（インスタンス作成時に一度だけ呼び出す）
    Init():void=

        PlayerPresetsMap := SavePresetDevice.PlayerPresetsMap
        if(PlayerPresets := PlayerPresetsMap[Player]):
            set Presets = PlayerPresets

        set MaxPage = Presets.Length # 最大ページ数を設定

        # 各ウィジェットの設定
        set BackBtn = button_loud{DefaultText:=S2M("<")}
        set SaveBtn = button_loud{DefaultText:=S2M("Save")}
        set NextBtn = button_loud{DefaultText:=S2M(">")}
        set ExitBtn = button_regular{DefaultText:=S2M("Exit")}
        for(Index := 0 .. MaxPage - 1):
            set PagiNationBorders += array{color_block{DefaultColor := color{R := 0.8, G := 0.0, B := 0.0}, DefaultDesiredSize := vector2{X := 50.0, Y := 50.0}}} # 赤
            set PagiNationBlocks += array{color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}, DefaultDesiredSize := vector2{X := 38.0, Y := 38.0}}} # 白 
        for(Index := 0 .. WeaponSlotsNum - 1):
            set HoldingWeaponTextures += array{texture_block{DefaultImage := weapon_enum.SideArmPistol_L1.ToTexture(), DefaultDesiredSize := vector2{X := 150.0, Y := 150.0}}}
            set PresetWeaponTextures += array{texture_block{DefaultImage := weapon_enum.SideArmPistol_L1.ToTexture(), DefaultDesiredSize := vector2{X := 150.0, Y := 150.0}}}

        CreateUI()
        spawn{HandleBtn()}

    # UIを作成する関数（一度だけ呼び出す）
    CreateUI():void=
        var NewSlots:[]canvas_slot = array{}

        # ボタン系を追加
        set NewSlots += array:
            canvas_slot:
                Widget := BackBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := -150.0, Top := 250.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
            canvas_slot:
                Widget := SaveBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 250.0, Right := 200.0, Bottom := 80.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := false
            canvas_slot:
                Widget := NextBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 150.0, Top := 250.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
            canvas_slot:
                Widget := ExitBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 350.0, Right := 200.0, Bottom := 80.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := false
            
        # ページネーションを追加
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 150.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := stack_box:
                    Orientation := orientation.Horizontal
                    Slots := for(Index := 0 .. MaxPage - 1):
                        var PagiNationBorder:color_block = color_block{}
                        var PagiNationBlock:color_block = color_block{}
                        var PaddingLeft:float = 0.0

                        if(not Index = 0):
                            set PaddingLeft = 20.0
                        if(Border := PagiNationBorders[Index], Block := PagiNationBlocks[Index]):
                            set PagiNationBorder = Border
                            set PagiNationBlock = Block

                        stack_box_slot:
                            Padding := margin{Left := PaddingLeft}
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := overlay:
                                Slots := array:
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Center
                                        VerticalAlignment := vertical_alignment.Center
                                        Widget := PagiNationBorder
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Center
                                        VerticalAlignment := vertical_alignment.Center
                                        Widget := PagiNationBlock
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Center
                                        VerticalAlignment := vertical_alignment.Center
                                        Widget := text_block{DefaultText := S2M("{Index + 1}")}

        # 手持ちの武器リストを追加
        # 具体的な武器なUpdateUI()で設定する。（ここではとりあえずデフォルト画像を設定）
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := -300.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := overlay:
                    Slots := array:
                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := color_block{DefaultColor := color{R := 1.0, G := 0.3, B := 0.0}}
                        overlay_slot:
                            Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment := vertical_alignment.Center
                            Widget := stack_box:
                                Orientation := orientation.Horizontal
                                Slots := for(Index := 0 .. WeaponSlotsNum - 1):
                                    var WeaponTexture:texture_block = texture_block{DefaultImage := weapon_enum.SideArmPistol_L1.ToTexture()}
                                    var PaddingLeft:float = 0.0

                                    if(Texture := HoldingWeaponTextures[Index]):
                                        set WeaponTexture = Texture
                                    if(not Index = 0):
                                        set PaddingLeft = 10.0

                                    stack_box_slot:
                                        Padding := margin{Left := PaddingLeft}
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment := vertical_alignment.Fill
                                        Widget := overlay:
                                            Slots := array:
                                                overlay_slot:
                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                    VerticalAlignment := vertical_alignment.Fill
                                                    Widget := color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}}
                                                overlay_slot:
                                                    Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                    VerticalAlignment := vertical_alignment.Fill
                                                    Widget := WeaponTexture

        # 持続データのそのページに登録しているプリセットを追加
        # 具体的な武器なUpdateUI()で設定する（ここではとりあえずデフォルト画像を設定）
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 0.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := overlay:
                    Slots := array:
                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := color_block{DefaultColor := color{R := 1.0, G := 0.3, B := 0.0}}
                        overlay_slot:
                            Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment := vertical_alignment.Center
                            Widget := stack_box:
                                Orientation := orientation.Horizontal
                                Slots := for(Index := 0 .. WeaponSlotsNum - 1):
                                    var WeaponTexture:texture_block = texture_block{DefaultImage := weapon_enum.SideArmPistol_L1.ToTexture()}
                                    var PaddingLeft:float = 0.0

                                    if(Texture := PresetWeaponTextures[Index]):
                                        set WeaponTexture = Texture
                                    if(not Index = 0):
                                        set PaddingLeft = 10.0

                                    stack_box_slot:
                                        Padding := margin{Left := PaddingLeft}
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment := vertical_alignment.Fill
                                        Widget := overlay:
                                            Slots := array:
                                                overlay_slot:
                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                    VerticalAlignment := vertical_alignment.Fill
                                                    Widget := color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}}
                                                overlay_slot:
                                                    Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                    VerticalAlignment := vertical_alignment.Fill
                                                    Widget := WeaponTexture

        # 手持ち武器リストとプリセットの間に表示する矢印の追加
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := -150.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := texture_block{DefaultImage := Textures.Arrow, DefaultDesiredSize := vector2{X := 80.0, Y := 80.0}}

        set Widget = canvas{Slots := NewSlots}

        UpdateUI() # 表示・非表示を設定する


    # UIの更新処理を行う関数
    UpdateUI():void=
        # ページネーションの更新
        for(Index->PagiNationBorder:PagiNationBorders):
            if(Index = PageNum):
                PagiNationBorder.SetVisibility(widget_visibility.Visible)
            else:
                PagiNationBorder.SetVisibility(widget_visibility.Hidden)

        # 手持ちの武器リストの画像の更新
        for(Index->HoldingWeaponTexture:HoldingWeaponTextures):
            if(Weapon := HoldingWeapons[Index]):
                HoldingWeaponTexture.SetImage(Weapon.ToTexture())
                HoldingWeaponTexture.SetVisibility(widget_visibility.Visible)
            else:
                HoldingWeaponTexture.SetVisibility(widget_visibility.Hidden)

        # そのページに登録しているプリセットの画像を更新
        for(Index->PresetWeaponTexture:PresetWeaponTextures):
            if(Weapon := Presets[PageNum][Index]):
                PresetWeaponTexture.SetImage(Weapon.ToTexture())
                PresetWeaponTexture.SetVisibility(widget_visibility.Visible)
            else:
                PresetWeaponTexture.SetVisibility(widget_visibility.Hidden)

    # ボタン入力を管理する関数
    HandleBtn()<suspends>:void=
        var SelectedBtn:string = ""
        SaveEvent:event(logic) = event(logic){}

        race:
            block:
                KillEvent.Await()
            loop:
                race:
                    block:
                        BackBtn.OnClick().Await()
                        set SelectedBtn = "Back"
                    block:
                        SaveBtn.OnClick().Await()
                        set SelectedBtn = "Save"
                    block:
                        NextBtn.OnClick().Await()
                        set SelectedBtn = "Next"
                    block:
                        ExitBtn.OnClick().Await()
                        set SelectedBtn = "Exit"

                if(SelectedBtn = "Back"):
                    Print("Backボタンが押された")
                    if(PageNum = 0):
                        set PageNum = MaxPage - 1
                    else:
                        set PageNum -= 1
                else if(SelectedBtn = "Save"):
                    Print("Saveボタンが押された")
                    SaveConfirmed := true
                    # spawn{ShowSaveConfirmation(SaveEvent)}
                    # SaveConfirmed := SaveEvent.Await()
                    if(SaveConfirmed?):
                        # 手持ちの武器がゴールドの最大枚数を超えていないかを確認（不正がないかを確認）
                        var Sum:int = 0
                        for(HoldingWeapon:HoldingWeapons):
                            for(WeaponData:WeaponsSelectDevice.WeaponDatas, HoldingWeapon = WeaponData.Weapon):
                                set Sum += WeaponData.RequireGolds
                        Print("合計ゴールド枚数: {Sum}")
                        if(Sum <= WeaponsSelectDevice.MaxGolds):
                            if(set SavePresetDevice.PlayerPresetsMap[Player][PageNum] = HoldingWeapons):
                                Print("セーブしました")
                        else:
                            Print("不正な武器プリセットを検知")

                        # 直前で持続データを更新したので取り直す
                        PlayerPresetsMap := SavePresetDevice.PlayerPresetsMap
                        if(PlayerPresets := PlayerPresetsMap[Player]):
                            set Presets = PlayerPresets

                    else:
                        Print("セーブがキャンセルされました")
                else if(SelectedBtn = "Next"):
                    Print("Nextボタンが押された")
                    if(PageNum = MaxPage - 1):
                        set PageNum = 0
                    else:
                        set PageNum += 1
                else if(SelectedBtn = "Exit"):
                    Print("Exitボタンが押された")
                    KillEvent.Signal()
                    break

                UpdateUI()

        Print("ボタン待ち処理終了")