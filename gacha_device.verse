using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org }
using { /Verse.org/Random }

# アイテムグランターと設定されたアイテムの数を紐づけるための構造体
granter_item_num := struct<concrete>:
    @editable
    ItemGranter:item_granter_device = item_granter_device{}

    @editable
    ItemCount:int = 0 # そのアイテムグランターに設定されているアイテムの数


gacha_device := class(creative_device):
    @editable
    EreaMutator:mutator_zone_device = mutator_zone_device{}
    @editable
    GachaBtn:button_device = button_device{}
    @editable
    AddGoldBtn:button_device = button_device{}
    @editable
    PonAudioDevice:audio_player_device = audio_player_device{}
    @editable
    MawasuAudioDevice:audio_player_device = audio_player_device{}
    var PlayerGoldMap:[player]int = map{}


    # 配列の長さはレアリティの数と同じ（現時点では７）で、レアリティを昇順に追加していく
    # コモン → アンコモン → レア → エピック → レジェンダリー → ミシック → エキゾチック
    @editable
    ItemGranters_Pistol:[]granter_item_num = array{} # ピストル
    @editable
    ItemGranters_ShutGun:[]granter_item_num = array{} # ショットガン
    @editable
    ItemGranters_SMG:[]granter_item_num = array{} # SMG
    @editable
    ItemGranters_AR:[]granter_item_num = array{} # AR
    @editable
    ItemGranters_Sniper:[]granter_item_num = array{} # スナイパー
    @editable
    ItemGranters_Marksman:[]granter_item_num = array{} # マークスマンライフル
    @editable
    ItemGranters_Bow:[]granter_item_num = array{} # 弓
    @editable
    ItemGranters_Crossbow:[]granter_item_num = array{} # クロスボウ
    @editable
    ItemGranters_BombWeapon:[]granter_item_num = array{} # 爆弾武器
    @editable
    ItemGranters_OtherWeapon:[]granter_item_num = array{} # その他の武器
    @editable
    ItemGranters_Item:[]granter_item_num = array{} # アイテム

    # HUD
    @editable
    ShowGoldHud:hud_message_device = hud_message_device{}
    @editable
    AnimGoldHud:hud_message_device = hud_message_device{}
    @editable
    NotEnoughGoldHud:hud_message_device = hud_message_device{}
    @editable
    AnimGachaHuds:[]hud_message_device = array{}

    GachaCost:int = 1000 # ガチャを一回引くのに必要な金額

    var AllItemGranters:[]granter_item_num = array{} # すべてのアイテムグランターを保持
    var AllItemCount:int = 0 # すべてのアイテムグランターに設定されているアイテムの総数

    RarityCount:int = 7 # レアリティの数
    RarityProbs:[]int = array: # リアリティごとに出る確率を変える
        38 # Common
        25 # Uncommon
        15 # Rare
        10 # Epic
        6  # Legendary
        2  # Mythic
        4  # Exotic
    var ProbArray:[]int = array{}

    var RarityGranters:[][]granter_item_num = array:
        array{} # Common
        array{} # Uncommon
        array{} # Rare
        array{} # Epic
        array{} # Legendary
        array{} # Mythic
        array{} # Exotic
    var RarityItemCounts:[]int = array:
        0 # Common
        0 # Uncommon
        0 # Rare
        0 # Epic
        0 # Legendary
        0 # Mythic
        0 # Exotic

    var PullingGachaPlayers:[]player = array{} # 現在進行形でガチャを引いているプレイヤーを保持する（ガチャアニメーションが終了するまでは次のガチャを引けないようにするため）
    
    S2M<localizes>(S:string):message = "{S}"

    OnBegin<override>()<suspends>:void=
        GachaBtn.InteractedWithEvent.Subscribe(TriggerSpinGacha)
        AddGoldBtn.InteractedWithEvent.Subscribe(PressAddGoldBtn)
        EreaMutator.AgentEntersEvent.Subscribe(EnterMutator)
        EreaMutator.AgentExitsEvent.Subscribe(ExitMutator)

        ItemGrantersArray := array:
            ItemGranters_Pistol
            ItemGranters_ShutGun
            ItemGranters_SMG
            ItemGranters_AR
            ItemGranters_Sniper
            ItemGranters_Marksman
            ItemGranters_Bow
            ItemGranters_Crossbow
            ItemGranters_BombWeapon
            ItemGranters_OtherWeapon
            ItemGranters_Item

        for(Index->Prob:RarityProbs):
            for(Index2 := 0..Prob - 1):
                set ProbArray += array{Index}
        
        for(ItemGranters:ItemGrantersArray):
            for(RarityIndex := 0..RarityCount - 1):
                if:
                    ItemGranter := ItemGranters[RarityIndex]
                    set RarityGranters[RarityIndex] += array{ItemGranter}
                    set RarityItemCounts[RarityIndex] += ItemGranter.ItemCount

    EnterMutator(Agent:agent):void=
        if(Player := player[Agent]):
        if:
            Player := player[Agent]
            not PlayerGoldMap[Player]
            set PlayerGoldMap[Player] = 0
        ShowGold(Agent)
        
    PressAddGoldBtn(Agent:agent):void=
        AddGold:int = 1000
        if:
            Player := player[Agent]
            set PlayerGoldMap[Player] += AddGold
        then:
            ShowGold(Agent) # 所持金HUDの更新
            AnimGold(Agent, AddGold) # 所持金変動アニメを表示

    ExitMutator(Agent:agent):void=
        ShowGoldHud.Hide(Agent)
        AnimGoldHud.Hide(Agent)
        NotEnoughGoldHud.Hide(Agent)
        for(AnimGachaHud:AnimGachaHuds):
            AnimGachaHud.Hide(Agent)

    # 所持金表示HUDの更新を行う関数
    ShowGold(Agent:agent):void=
        if(Player := player[Agent], Gold := PlayerGoldMap[Player]):
            ShowGoldHud.Show(Agent, S2M("{Gold}"))

    # 所持金が変動する際のアニメーションを表示する関数
    AnimGold(Agent:agent, Gold:int):void=
        AnimGoldHud.Hide(Agent)
        var Str:string = ""
        if(0 <= Gold):
            set Str = "+{Gold}"
        else:
            set Str = "{Gold}"
        AnimGoldHud.Show(Agent, S2M(Str))

    # 入力トリガーの仕掛けに登録する関数。AddShopUIを呼び出すだけ
    TriggerSpinGacha(Agent:agent):void=
        Print("入力を感知した")
        if(Player := player[Agent]):
            if(PullingGachaPlayers.Find[Player]):
                Print("現在のガチャが引き終わるまで待ってね！")
            else:
                Print("ガチャを引く")
                set PullingGachaPlayers += array{Player}
                spawn{SpinGacha(Agent)}

    # レアリティごとに重みをつけたガチャを引く処理を実行する関数
    SpinGacha(Agent:agent)<suspends>:void=
        NotEnoughGoldHud.Hide(Agent)

        if(Player := player[Agent], GachaCost <= PlayerGoldMap[Player]):
            RandomArray := Shuffle(ProbArray)

            var Str:string = ""
            for(Index->a:RandomArray):
                set Str += "{a} "
                if(Mod[Index, 10] = 0):
                    set Str += "\n"
            Print(Str)

            if:
                SelectedRarity := RandomArray[0]
                RandomNum := Random.GetRandomInt(1, RarityItemCounts[SelectedRarity])
                ItemGranters := RarityGranters[SelectedRarity]
                AnimGachaHud := AnimGachaHuds[SelectedRarity]
            then:
                Print("{SelectedRarity}番目のレアリティが選ばれた")
                var CurrentItemCount:int = 0
                for(Index->ItemGranter:ItemGranters):
                    if(RandomNum <= (CurrentItemCount + ItemGranter.ItemCount)):
                        if. set PlayerGoldMap[Player] -= GachaCost # 所持金データの更新
                        ShowGold(Agent) # 所持金HUDの更新
                        AnimGold(Agent, -GachaCost) # 所持金変動アニメを表示

                        # ガチャアニメーションを流す
                        AnimGachaHud.Show(Agent)
                        Sleep(0.6)
                        MawasuAudioDevice.Play(Agent)
                        Sleep(1.0)
                        MawasuAudioDevice.Play(Agent)
                        Sleep(1.0)
                        PonAudioDevice.Play(Agent)
                        Sleep(0.55) # アニメーションでカプセルが排出されるまでの時間
                        ItemGranter.ItemGranter.GrantItemIndex(Agent, (RandomNum - CurrentItemCount) - 1) # アイテムを与える
                        Sleep(0.85) # アニメーションが終わるまで待機
                        AnimGachaHud.Hide(Agent)

                        Print("{Index}個目の種類の{(RandomNum - CurrentItemCount) - 1}番目のアイテムを渡した！！")

                        # ガチャ引いているプレイヤーを保持する配列から削除する
                        if:
                            RemoveIndex := PullingGachaPlayers.Find[Player]
                            NewArray := PullingGachaPlayers.RemoveElement[RemoveIndex]
                        then:
                            set PullingGachaPlayers = NewArray

                        return
                    else:
                        set CurrentItemCount += ItemGranter.ItemCount
        else:
            NotEnoughGoldHud.Show(Agent)

        # ガチャ引いているプレイヤーを保持する配列から削除する
        if:
            Player := player[Agent]
            RemoveIndex := PullingGachaPlayers.Find[Player]
            NewArray := PullingGachaPlayers.RemoveElement[RemoveIndex]
        then:
            set PullingGachaPlayers = NewArray
