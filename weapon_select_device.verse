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
using { /Verse.org/Colors/NamedColors }

#########################################################
### 武器の購入や返却、手持ちの武器などを管理するプログラム ###
#########################################################

weapon_enum := enum<persistable>:
    # サイドアームピストル
    SideArmPistol_L1
    SideArmPistol_L2
    SideArmPistol_L3
    SideArmPistol_L4
    SideArmPistol_L5
    # サブマシンガン
    SubmachineGun_L1
    SubmachineGun_L2
    SubmachineGun_L3
    SubmachineGun_L4
    SubmachineGun_L5
    # アサルトライフル
    AssaultRifle_L1
    AssaultRifle_L2
    AssaultRifle_L3
    AssaultRifle_L4
    AssaultRifle_L5
    # ロケットランチャー
    RocketLauncher_L1
    RocketLauncher_L2
    RocketLauncher_L3
    RocketLauncher_L4
    RocketLauncher_L5

(WE:weapon_enum).ToTexture():texture= #フォルダ名.テクスチャ名
    case(WE):
        # サイドアームピストル
        weapon_enum.SideArmPistol_L1 => WeaponTextures.SideArmPistol_L1
        weapon_enum.SideArmPistol_L2 => WeaponTextures.SideArmPistol_L2
        weapon_enum.SideArmPistol_L3 => WeaponTextures.SideArmPistol_L3
        weapon_enum.SideArmPistol_L4 => WeaponTextures.SideArmPistol_L4
        weapon_enum.SideArmPistol_L5 => WeaponTextures.SideArmPistol_L5
        # サブマシンガン
        weapon_enum.SubmachineGun_L1 => WeaponTextures.SubmachineGun_L1
        weapon_enum.SubmachineGun_L2 => WeaponTextures.SubmachineGun_L2
        weapon_enum.SubmachineGun_L3 => WeaponTextures.SubmachineGun_L3
        weapon_enum.SubmachineGun_L4 => WeaponTextures.SubmachineGun_L4
        weapon_enum.SubmachineGun_L5 => WeaponTextures.SubmachineGun_L5
        # アサルトライフル
        weapon_enum.AssaultRifle_L1 => WeaponTextures.AssaultRifle_L1
        weapon_enum.AssaultRifle_L2 => WeaponTextures.AssaultRifle_L2
        weapon_enum.AssaultRifle_L3 => WeaponTextures.AssaultRifle_L3
        weapon_enum.AssaultRifle_L4 => WeaponTextures.AssaultRifle_L4
        weapon_enum.AssaultRifle_L5 => WeaponTextures.AssaultRifle_L5
        # ロケットランチャー
        weapon_enum.RocketLauncher_L1 => WeaponTextures.RocketLauncher_L1
        weapon_enum.RocketLauncher_L2 => WeaponTextures.RocketLauncher_L2
        weapon_enum.RocketLauncher_L3 => WeaponTextures.RocketLauncher_L3
        weapon_enum.RocketLauncher_L4 => WeaponTextures.RocketLauncher_L4
        weapon_enum.RocketLauncher_L5 => WeaponTextures.RocketLauncher_L5

(WE:weapon_enum).ToIndex():int= #フォルダ名.テクスチャ名
    case(WE):
        # サイドアームピストル
        weapon_enum.SideArmPistol_L1 => 0
        weapon_enum.SideArmPistol_L2 => 1
        weapon_enum.SideArmPistol_L3 => 2
        weapon_enum.SideArmPistol_L4 => 3
        weapon_enum.SideArmPistol_L5 => 4
        # サブマシンガン
        weapon_enum.SubmachineGun_L1 => 5
        weapon_enum.SubmachineGun_L2 => 6
        weapon_enum.SubmachineGun_L3 => 7
        weapon_enum.SubmachineGun_L4 => 8
        weapon_enum.SubmachineGun_L5 => 9
        # アサルトライフル
        weapon_enum.AssaultRifle_L1 => 10
        weapon_enum.AssaultRifle_L2 => 11
        weapon_enum.AssaultRifle_L3 => 12
        weapon_enum.AssaultRifle_L4 => 13
        weapon_enum.AssaultRifle_L5 => 14
        # ロケットランチャー
        weapon_enum.RocketLauncher_L1 => 15
        weapon_enum.RocketLauncher_L2 => 16
        weapon_enum.RocketLauncher_L3 => 17
        weapon_enum.RocketLauncher_L4 => 18
        weapon_enum.RocketLauncher_L5 => 19

# weapon_enumの文字列をstringに変換して返すプロパティ（デバッグ用）
(WE:weapon_enum).ToString():string=
    case(WE):
        # サイドアームピストル
        weapon_enum.SideArmPistol_L1 => "SideArmPistol_L1"
        weapon_enum.SideArmPistol_L2 => "SideArmPistol_L2"
        weapon_enum.SideArmPistol_L3 => "SideArmPistol_L3"
        weapon_enum.SideArmPistol_L4 => "SideArmPistol_L4"
        weapon_enum.SideArmPistol_L5 => "SideArmPistol_L5"
        # サブマシンガン
        weapon_enum.SubmachineGun_L1 => "SubmachineGun_L1"
        weapon_enum.SubmachineGun_L2 => "SubmachineGun_L2"
        weapon_enum.SubmachineGun_L3 => "SubmachineGun_L3"
        weapon_enum.SubmachineGun_L4 => "SubmachineGun_L4"
        weapon_enum.SubmachineGun_L5 => "SubmachineGun_L5"
        # アサルトライフル
        weapon_enum.AssaultRifle_L1 => "AssaultRifle_L1"
        weapon_enum.AssaultRifle_L2 => "AssaultRifle_L2"
        weapon_enum.AssaultRifle_L3 => "AssaultRifle_L3"
        weapon_enum.AssaultRifle_L4 => "AssaultRifle_L4"
        weapon_enum.AssaultRifle_L5 => "AssaultRifle_L5"
        # ロケットランチャー
        weapon_enum.RocketLauncher_L1 => "RocketLauncher_L1"
        weapon_enum.RocketLauncher_L2 => "RocketLauncher_L2"
        weapon_enum.RocketLauncher_L3 => "RocketLauncher_L3"
        weapon_enum.RocketLauncher_L4 => "RocketLauncher_L4"
        weapon_enum.RocketLauncher_L5 => "RocketLauncher_L5"

weapon_data := class<concrete>:
    @editable
    Weapon:weapon_enum = weapon_enum.SideArmPistol_L1

    @editable
    RequireGolds:int = 0

    @editable
    VendingMachine:vending_machine_device = vending_machine_device{}

    @editable
    WeaponCondBtn:conditional_button_device = conditional_button_device{}

    var GoldCondBtn:conditional_button_device = conditional_button_device{} # ゴールドの枚数を取得するためのやつ
    var GoldHudDevice:hud_message_device = hud_message_device{}

    var GoldsGranter:item_granter_device = item_granter_device{} # 武器返却時にゴールドを返すためのグランター
    var GoldsIndexArray:[]int = array{} # GoldsGranterの何番目が何枚ゴールドを返すのかを特定するための整数配列

    var WeaponsSelectDevice:weapons_select_device = weapons_select_device{}

    S2M<localizes>(S:string):message = "{S}"

    # WeaponsSelectDeviceのWeaponPlayerMapに、このインスタンスの武器を追加する関数
    AddWeaponsPlayerMap(Agent:agent):void=
        if(Player := player[Agent]):
            if(not WeaponsSelectDevice.WeaponsPlayerMap[Player]): # 初期化されていなかったら、mapにプレイヤーを登録する
                if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] = array{}
            if(WeaponsSelectDevice.WeaponsPlayerMap[Player].Length < 5):
                if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] += array{Weapon}

            WeaponsSelectDevice.ChangePlayerClass(Agent)
            spawn{ShowGoldHud(Agent)}
    
    # WeaponsSelectDeviceのWeaponPlayerMapから、このインスタンスの武器を削除する関数
    RemoveWeaponsPlayerMap(Agent:agent):void=
        if(Player := player[Agent]):
            var NewWeaponsPreset:[]weapon_enum = array{}
            var IsRemoved:logic = false
            for(W:WeaponsSelectDevice.WeaponsPlayerMap[Player]):
                if(not W = Weapon or IsRemoved?):
                    set NewWeaponsPreset += array{W}
                else if(IsRemoved = false):
                    set IsRemoved = true
            if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] = NewWeaponsPreset

            WeaponsSelectDevice.ChangePlayerClass(Agent)

    # プレイヤーにゴールドを返す関数
    ReturnGolds(Agent:agent):void=
        for(Index -> GoldsNum : GoldsIndexArray, GoldsNum = RequireGolds):
            GoldsGranter.GrantItemIndex(Agent, Index)
            
    # プレイヤーのゴールド枚数を表示・更新する関数
    ShowGoldHud(Agent:agent)<suspends>:void=
        Sleep(0.0)
        GoldNum := GoldCondBtn.GetItemCount(Agent, 0)
        GoldHudDevice.Show(Agent, S2M("{GoldNum}"))

    # CondBtnが押されたときに実行する処理（上の３つの関数）をひとつにまとめた関数
    ActivateCondBtn(Agent:agent):void=
        ReturnGolds(Agent)
        RemoveWeaponsPlayerMap(Agent)
        spawn{ShowGoldHud(Agent)}

weapons_select_device := class(creative_device):

    @editable
    InitMutator:mutator_zone_device = mutator_zone_device{}

    @editable
    WeaponDatas:[]weapon_data = array{} # このゲームで使用できる武器の情報を保持する配列

    @editable
    HoldingWeaponsReturnBtn:button_device = button_device{}
    
    @editable
    AllWeaponsReturnBtn:button_device = button_device{}

    @editable
    GoldsGranter:item_granter_device = item_granter_device{} # 武器返却時にゴールドを返すためのグランター
    @editable
    GoldsIndexArray:[]int = array{} # GoldsGranterの何番目が何枚ゴールドを返すのかを特定するための整数配列

    @editable
    MaxGoldsGranter:item_granter_device = item_granter_device{} # ゴールドを初期値に戻すため

    @editable
    ItemRemover:item_remover_device = item_remover_device{} # すべての武器を削除するため

    @editable
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 「クラスなし」に変更するクラスセレクター（クラスなしは自販機を実行できる）
    
    @editable
    OneClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 「クラス１」に変更するクラスセレクター（クラス１は自販機を実行できない）

    @editable
    GoldHudDevice:hud_message_device = hud_message_device{} # 所持ゴールドの枚数を表示するHUDデバイス
    @editable
    GoldCondBtn:conditional_button_device = conditional_button_device{} # プレイヤーの所持ゴールドの枚数を取得するための条件付きボタン
    
    var WeaponsPlayerMap:[player][]weapon_enum = map{} # 各プレイヤーが現在保持している武器を記憶しておくmap

    MaxGolds:int = 1000 # ゴールドの最大枚数（最初に与えられるゴールドの枚数）

    S2M<localizes>(S:string):message = "{S}"

    OnBegin<override>()<suspends>:void=
        InitMutator.AgentEntersEvent.Subscribe(EnterInitMutator)
        InitMutator.AgentExitsEvent.Subscribe(ExitInitMutator)

        for(WeaponData:WeaponDatas):
            set WeaponData.GoldCondBtn = GoldCondBtn
            set WeaponData.GoldHudDevice = GoldHudDevice
            set WeaponData.GoldsGranter = GoldsGranter
            set WeaponData.GoldsIndexArray = GoldsIndexArray
            set WeaponData.WeaponsSelectDevice = Self
            WeaponData.WeaponCondBtn.ActivatedEvent.Subscribe(WeaponData.ActivateCondBtn)
            WeaponData.VendingMachine.ItemSpawnedEvent.Subscribe(WeaponData.AddWeaponsPlayerMap)

        HoldingWeaponsReturnBtn.InteractedWithEvent.Subscribe(HoldingWeaponReturn)
        AllWeaponsReturnBtn.InteractedWithEvent.Subscribe(AllWeaponsReturn)

    EnterInitMutator(Agent:agent):void=
        if:
            Player := player[Agent]
            not WeaponsPlayerMap[Player]
            set WeaponsPlayerMap[Player] = array{}
        MaxGoldsGranter.GrantItem(Agent)
        spawn{ShowGoldHud(Agent)}

    ExitInitMutator(Agent:agent):void=
        GoldHudDevice.Hide(Agent)

    # プレイヤーのゴールド枚数を表示・更新する関数
    ShowGoldHud(Agent:agent)<suspends>:void=
        Sleep(0.0) # 一瞬待たないとGrantItemの処理が完了するまえに以下の処理が実行されちゃう
        GoldNum := GoldCondBtn.GetItemCount(Agent, 0)
        GoldHudDevice.Show(Agent, S2M("{GoldNum}"))

    # 特定の武器（プレイヤーが手に持っている武器）を返却するための関数
    HoldingWeaponReturn(Agent:agent):void=
        for(WeaponData:WeaponDatas):
            WeaponData.WeaponCondBtn.Activate(Agent)

    # プレイヤーが持っているすべての武器を返却する関数
    AllWeaponsReturn(Agent:agent):void=
        if(Player := player[Agent]):
            ItemRemover.Remove(Agent)
            MaxGoldsGranter.GrantItem(Agent)
            if. set WeaponsPlayerMap[Player] = array{}
            spawn{ShowGoldHud(Agent)}
            
            ChangePlayerClass(Agent)

    # プレイヤーのクラスを変更する関数（クラスなし: 自販機を使える, クラス１: 自販機を使えない）
    ChangePlayerClass(Agent:agent):void=
        if(Player := player[Agent], Len := WeaponsPlayerMap[Player].Length):
            if(Len < 5):
                NoneClassSelector.ChangeClass(Agent) # クラスなしに設定
                Print("購入できるようになった")
            else:
                OneClassSelector.ChangeClass(Agent) # クラス１に設定
                Print("購入できなくなった")