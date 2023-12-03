# frozen_string_literal: true

module BCDice
  module GameSystem
    class SkynautsBouken < Base
      # ゲームシステムの識別子
      ID = 'SkynautsBouken'

      # ゲームシステム名
      NAME = '歯車の塔の探空士（冒険企画局）'

      # ゲームシステム名の読みがな
      SORT_KEY = 'はくるまのとうのすかいのおつ2'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~MESSAGETEXT
        ・行為判定（nSNt#f） n:ダイス数(省略時2)、t:目標値(省略時7)、f:ファンブル値(省略時1)
            例）SN6#2　3SN
        ・ダメージチェック (Dx/y@m) x:ダメージ範囲、y:攻撃回数
        　　m:《弾道学》（省略可）上:8、下:2、左:4、右:6
        　　例） D/4　D19/2　D/3@8　D[大揺れ]/2
        ・回避(AVO@mダメージ)
        　　m:回避方向（上:8、下:2、左:4、右:6）、ダメージ：ダメージチェック結果
        　　例）AVO@8[1,4],[2,6],[3,8]　AVO@2[6,4],[2,6]
        ・FT ファンブル表(p76)
        ・NV 航行表
        ・航行イベント表
        　・NEN 航行系
        　・NEE 遭遇系
        　・NEO 船内系
        　・NEH 困難系
        　・NEL 長旅系

        ■ 判定セット
        ・《回避運動》判定+回避（nSNt#f/AVO@ダメージ）
        　　nSNt#f → 成功なら AVO@m
        　　例）SN/AVO@8[1,4],[2,6],[3,8]　3SN#2/AVO@2[6,4],[2,6]
        ・砲撃判定+ダメージチェック　(nSNt#f/Dx/y@m)
        　　行為判定の出目変更タイミングを逃すので要GMの許可
        　　nSNt#f → 成功なら Dx/y@m
        　　例）SN/D/4　3SN#2/D[大揺れ]/2
      MESSAGETEXT

      TABLES = {
        'FT' => DiceTable::Table.new(
          'ファンブル表',
          '1D6', [
            "なんとか大事にはいたらなかった。通常の失敗と同様の処理を行うこと。",
            "転んでしまった。キミは[転倒](p107)する。",
            "失敗にイライラしてしまった。キミは獲得している【キズナ】1つの「支援チェック」にチェックを入れる。",
            "自身のいるマスを[破損](p104)させる。この[破損]によって、キミの【生命点】は減少しない。",
            "頭をぶつけてしまった。キミの【生命点】を「1d6点」減少する。",
            "奇跡的な結果。 この行為判定は成功となる。",
          ]
        ),
        'NV' => DiceTable::Table.new(
          '航海表',
          '1d6',
          [
            'スポット1つ分進む',
            'スポット1つ分進む',
            'スポット1つ分進む',
            'スポット2つ分進む',
            'スポット2つ分進む',
            'スポット3つ分進む',
          ]
        ),
        "NEN" => DiceTable::Table.new(
          "航行イベント表　航行系",
          "2D6",
          [
            "フナ酔い\nバッドステータス。キミは次のクエスト終了フェイズまで、【移動力】が「1点」なくなり、「ダッシュ」(p101)を行うことができない。\n　空の上で風に揺さぶられていると、まるで自分と世界が混ざったような感覚がするんだ。それを思い出すだけで……ウプッ。",
            "乱流\n次のシーンでは、航行表の結果にかかわらず、航行チェックで飛空艇駒が進む距離がスポット1つ分になる。\n　このあたりの風の流れはデタラメだ。これじゃ、風に乗ってフネを進めることなんてできやしない。焦らず、慎重に進むべきだ。",
            "急変\nGMは、フライトエリア上の任意のスポット2つを選択する。そのスポットのイベントタイプは「困難系」に変更される。\n　空の天気はきまぐれだ。天気が変わることを止めることは出来ない。けれども、こういう変わり方はしてほしくなかったな……。",
            "シケ\n次のシーンでは、シーンプレイヤーは航行チェックを行うことができず、「操舵に専念する」を宣言することもできない。\n　ぽつり、ぽつりと窓に雨粒が滴り落ちる。こうなってしまえば、フネを進めることはできない。この間に紅茶を1杯、というのもいいだろう。……ティータイムには生憎の空模様だがね。",
            "気流-1\n飛空艇コマを1スポット分戻す。\n　飛空艇に吹く気流は、常に探空士たちの味方をするとは限らない。誰かの追い風は、誰かの向かい風となってしまうこともあるだろう。",
            "穏やかな空\nこの航行イベントには、特に効果はない。\n　見通しのいい空域。風向きも安定しており、舵を取られるようなこともないだろう。気持ちのいい青空の中、白い雲の合間を縫うようにして、フネは進んでいく。",
            "気流+1\n飛空艇コマを+1スポット分進める。\n　他の空域よりも、比較的強い流れが一定の方向に吹き続けている空域。ときに探空士たちの手助けになり、ときに探空士たちに立ちはだかる。どの空域にどんな風が流れているかを見極めて進むのが、空の旅での基本だ。",
            "進路良好！\n飛空艇は【手がかり】を「1つ」得る。\n　このあたりはとても見晴らしがいい。雲海から上には雲ひとつ見当たらず、邪魔な浮遊生物たちもいない。",
            "突風+1\n飛空艇コマを1スポット分進める。その後、飛空艇コマのいるスポットのイベントタイプを確認し、そのイベントタイプの航行表を振って、出たイベントの効果を適用する。\n　突然、フネに強風が吹き付ける。なんとか転覆することなく持ち直したけれども、予定していたコースを外れてしまったようだ。なにか起こるかもしれない。警戒を強めたほうがいいだろう。",
            "貿易風\n次のシーンの航行チェックでは、ダイスを振らずに、航行表の結果の中から好きなものを選んで適用することができる。\n　気流が吹く空域の中でも、特に風向きが安定していて、飛空艇乗りたちに空路として好まれている空域。飛翔イカ等の小さな浮遊生物なんかも、よく群がっている。",
            "気流+2\n飛空艇コマを2スポット分進める。\n　うまい具合に気流に乗ることが出来れば、飛空艇はその性能以上の働きを見せてくれる。進路良好、この分なら、予定よりも早く目的地につくことができるだろう。"
          ]
        ),
        "NEE" => DiceTable::Table.new(
          "航行イベント表　遭遇系",
          "2D6",
          [
            "風邪\nバッドステータス。キミは次のクエストフェイズ終了時まで、すべての[得意]な【能力】が[得意]でないもとして扱われる。\n　寒空の中見張りをしたのが悪かったのだろうか。 それとも食事？ せめて風邪を引くのなら、 旅立つ前にしておいてほしかったな。",
            "敵対的なソラクジラ\n飛空艇は「D46[大揺れ]/1」のダメージを受ける。\n　飛空艇乗りに人気のソラクジラにも、機嫌が悪いときがある。 こんなときに近づいてしまったのなら、運が悪かったとしか言いようがない。 ご愁傷さま。",
            "トラブルメーカー\nキミの【生命点】を「3点」減少させる。\n　えへへ、 じゃないよ！　なんてことしてくれたんだ！",
            "敵対的な浮遊生物\n飛空艇は「D/3」のダメージを受ける。\n　浮遊生物は 飛空艇に友好的とは限らない。 彼らの生態系に飛び込んでしまったフネには、 彼らなりの出迎え方があるというものだ。",
            "検問\nこのシーンでは、キミはアクションを行うことができない。\n　キミたちのフネの上に巨大な影が落ちる。 キミたちのフネの数倍はあろうかという、 王立空軍の巡空 艦だ。「女王陛下万歳！」 赤い服の兵士たちが、 敬礼とともにキミたちの書類仕事を増やしていく。 ……やりたいことだってあったのに。",
            "風光明媚\n船内マップ上にいるすべてのキャラクターは、【生命点】を「1点」回復させる。\n　空を旅していると、 想像を絶するような絶景に恵まれることもある。夕日を受けて茜色に染まる雲海 や、雲を跳ねるソライルカの群れ。 そんな光景を目に焼き付けたとき、 探空士たちは、自分たちが空を旅する意味に気づくんだ。",
            "ソラクジラ\n船内マップ上にいるすべてのキャラクターは、【生命点】を「1D6点」回復させる。\n　雲の中から、 巨大なソラクジラが浮かび上がる。きゅうんという独特の鳴き声をあげて、ゆっくりと、落ちるように雲の下へ戻っていくソラクジラの雄大な姿は、なかなか見られるものじゃない。 息を呑む圧巻の光景に、しばし目を奪われよう。",
            "大漁\n船内マップ上にいるすべてのキャラクターの【生命点】の最大値を「2点」増加する。この効果は重複しない。\n　飛翔イカの群れだ！　どうも、 窓から漏れる明かりにつられてやってきたらしい。網をはろう。今夜は新鮮なイカがたらふく食べられそうだ。",
            "気流+1\n飛空艇コマを1スポット分進める。\n　他の空域よりも、比較的強い流れが一定の方向に吹き続けている空域。ときに探空士たちの手助けになり、ときに探空士たちに立ちはだかる。どの空域にどんな風が流れているかを見極めて進むのが、空の旅での基本だ。",
            "ケセランパセラン\nキミは任意の船内マップ上に配置されてるパーツ1つを選択する。そのパーツが【快適度】のキーワード効果がある場合、このセッションの間、その数値は「1点」高いものとして扱う。\n　ふわふわとした大きな綿毛のような浮遊生物。その毛のさわり心地は、上級階級のソファにも使われるほど柔らかい。捕まえて飼うことができれば、一服の癒やしをあたえてくれることだろう。",
            "うさこぷたー\nキミの【生命点】を「3点」回復する。\n　ふたつの耳を回転させて空を飛ぶうさぎのような浮遊生物が、ずっとこちらを見つめている。かわいいはかわいいのだが、こいつは一体なんなんだろう……。"
          ]
        ),
        "NEO" => DiceTable::Table.new(
          "航行イベント表　船内系",
          "2D6",
          [
            "二日酔い\nバッドステータス。キミは次のクエストフェイズ終了時まで、すべての行為判定の【ファンブル値】が「1」高いものとして扱う。\n　仲間との楽しい時間、まだ見ぬ素晴らしい景色。空での旅路は、ビールを美味しくするものにあふれている。だからこれは、 空の旅で出くわす様々な危険のひとつだともいえるんだ。嵐や空賊みたいにさ。頭の痛い存在だよ。",
            "イメージダウン\n船内マップ上にいるすべてのキャラクターは、キミに対して獲得している【キズナ】の「支援チェック」にチェックを入れる。\n　お前、本当に何したんだよ……。",
            "白熱\nキミは、任意の船内マップ上のキャラクターを1人選ぶ。その後、キミは船内マップ上の、キャラクターが居ない底面マスが2つ以上あるパーツを選び、そのパーツのキャラクターが居ない任意の底面マスにキミと選んだキャラクターを移動させる。このシーン、キミは「交流」以外のアクションを行うことはできない。（パーツを選ぶことができなかった場合、キャラクターの移動は行われず、キミはこのシーン中、アクションを行うことができない）\n　ちょっとした暇つぶしのはずだった。キミがカードを取り出したから、相手も乗っただけだ。でも、勝ったほうは嬉しいし、負けた方は悔しい。それだけのことを、キミたちは忘れてはいけなかったんだ。",
            "見てしまった\nキミは、自身が獲得している任意の【キズナ】1つを選ぶ。その【キズナ】は失われる。\n　誰にだって、隠したい秘密のひとつやふたつはあるものだ。それを咎めるのはよくない。偶然それを目にしてしまったキミが悪いわけでもない。運が悪かっただけなんだ。な?",
            "ケンカ\nキミは、自身が獲得している任意の【キズナ】1つを選んで、その「支援チェック」にチェックを入れる。もし、キミが獲得しているすべての【キズナ】に「支援チェック」が入っている場合、かわりにキミの【生命点】を「1D6点」減少させる。\n　些細ないさかいで、チームワークにひびが入ってしまうことはよくあることだ。人の仲は、ときに人生に影を落とす。 もっとも、ケンカする相手もいないよりは、よっぽどましな人生だと思うけどね。",
            "おしゃべり\nこのシーン中、キミが「交流」のアクションを行うとき、キミのいるパーツ内のキャラクター以外のキャラクターも選ぶことができる。\n　船内に張り巡らされた伝声管を通せば、船内の誰とでも連絡をとることができる。いざというときのための設備だが、何気ないおしゃべりに花を咲かせるのもいいものだ。",
            "月が綺麗ですね\nキミは、任意の船内マップ上のキャラクター1人を選ぶ。キミは、そのキャラクターに対する【キズナ】を獲得する。\n　綺麗ですね 夜空に黄色い月が、まんまるな月が輝いている。フネの中はいつだって機関室の音で騒々しいが、月を眺めるときだけはなぜか、しぃんとした静けさを感じるんだ。",
            "プレゼント\nキミは、任意の船内マップ上のキャラクター1人を選ぶ。そのキャラクターは、キミに対する【キズナ】を獲得する。\n　ちょっといい感じの包み紙に包まれたチョコレートや、普段は飲まない銘柄の茶葉。特段意味のあるわけでもない置物。幸福とはつまるところ、そういったものと、誰かの思いでできている。",
            "気流+1\n飛空艇コマを1スポット分進める。\n　他の空域よりも、比較的強い流れが一定の方向に吹き続けている空域。ときに探空士たちの手助けになり、ときに探空士たちに立ちはだかる。どの空域にどんな風が流れているかを見極めて進むのが、空の旅での基本だ。",
            "記念日\n船内マップ上にいるすべてのキャラクターは、キミに対して【キズナ】を獲得する。\n　今朝起きてから、みんながどこかよそよそしい。話しかけても要領を得ないし、自分だけのけものにして、なにかの話し合いをしているらしい。いやだな。なにかしたっけな。あれ、そういえば今日って……。",
            "パーティ\n船内マップ上にいるすべてのキャラクターは、それぞれ、任意のキャラクター1人を選ぶ。それぞれのキャラクターは、選んだキャラクターへの【キズナ】を獲得する。\n　この日ばっかりは仕事はよそう！　樽いっぱいのビールに、船長秘蔵のワイン。テーブルの上にはとにかく、飲むものと、つまむものでいっぱいだ。"
          ]
        ),
        "NEH" => DiceTable::Table.new(
          "航行イベント表　困難系",
          "2D6",
          [
            "ケガ\nバッドステータス。キミは次のクエストフェイズ終了時まで、【生命点】の最大値が「5点」となる。すでに5点以上の【生命点】があった場合は、あわせて【生命点】が「5点」になる。\n　ケガのひとつやふたつが、旅を終える理由になるわけがない。だが、何をするにしてもキミの身に走る激痛は、確実にキミの行く手を阻むだろう。これまで通りの穏やかな旅路とかいかなくなるはずだ。",
            "大災害\n飛空艇は「D/5」のダメージを受ける。このダメージに《回避運動》のスキル効果を使用することはできない。\n　空で旅を続けていれば、どうしようもない状況に出くわすなんてしょっちゅうだ。そんなときどうするのかって？　どうしようもないからただ祈る？　決まってるさ。それでもなんとかするんだよ。",
            "自然の猛威\n飛空艇は「D/4」のダメージを受ける。このダメージに《回避運動》のスキル効果を使用することはできない。\n　『塔』の上の人間は、いつか自然を人間が支配するときが来ると思っている。自然の力を身を以て体感する探空士に、そんな考えをもっているヤツはいない。",
            "シケ\n次のシーンでは、シーンプレイヤーは航行チェックを行うことができず、「操舵に専念する」を宣言することもできない。\n　ぽつり、ぽつりと窓に雨粒が滴り落ちる。こうなってしまえば、フネを進めることはできない。この間に紅茶を1杯、というのもいいだろう。……ティータイムには生憎の空模様だがね。",
            "落雷\n飛空艇は「D/3」のダメージを受ける。このダメージに《回避運動》のスキル効果を使用することはできない。\n　突如、飛空艇を轟音と、閃光が包む。何事か、とキミが周囲を確認するより先に、フネに稲妻がほとばしり、どこかが焼ける焦げ臭い匂いが、キミの鼻腔をつく。これはまずいぞ。はやくこの空域を抜けるんだ！",
            "ゲリラ豪雨\n飛空艇は「D/3」のダメージを受ける。\n　暴風に呑まれまいと、出力最大で風雨を振り切る。エンジンは赤熱し、吐き出す蒸気が機関室を白く染める。……もってくれよ。こんなところで空に放り出されるのはゴメンだ。",
            "嵐の前触れ\n次のシーンでは、スポットのイベントタイプや、「その場に留まる」を宣言したかどうかにかかわらず、航行イベントを「航行イベント表：困難系」を使用して決定する。\n　突然目の前に現れたどす黒い雲。気圧計の針がみるみるうちに下がっていき、キミたちに不穏な前触れを告げる。これは、覚悟を決めなければならないかもしれない……。",
            "シケ\n次のシーンでは、シーンプレイヤーは航行チェックを行うことができず、「操舵に専念する」を宣言することもできない。\n　ぽつり、ぽつりと窓に雨粒が滴り落ちる。こうなってしまえば、フネを進めることはできない。この間に紅茶を1杯、というのもいいだろう。……ティータイムには生憎の空模様だがね。",
            "気流+2\n飛空艇コマを2スポット分進める。\n　このあたりは危険な空域らしいが、このくらいの風を則こなせなければ、プロとは言えない。事実、キミはそれをやってのけた。これが、探空士の仕事ぶりというものさ。",
            "荒れ狂う空\nキミは「身体・感覚:7」の行為判定を3回行う。失敗した回数だけ、飛空艇は「D/3」のダメージを受ける。\n　うっかりしてるにしても、これはひどすぎだ！　気づけばフネは暴風域のど真ん中。これを抜けるのは、ただの乱気流と避けるのとはワケが違うんだぞ！",
            "低気圧の中心\nキミは「身体・感覚:9」の行為判定を行う。この判定に成功しない限り、飛空艇コマはフライトエリア上を移動することできず、次のシーンの航行イベントも、自動的に「低気圧の中心」となる。行為判定に成功したかどうかにかかわらず、その後の飛空艇は「D/4」のダメージを受ける。このダメージに《回避運動》のスキル効果を使用することはできない。\n　巨大な渦巻きのような雲。近づくだけでフネは引き寄せられ、一瞬でも舵をはなせば呑み込まれてしまう。その圧倒的な力はさながら、巨大な竜に襲われているかのようだ。"
          ]
        ),
        "NEL" => DiceTable::Table.new(
          "航行イベント表　長旅系",
          "2D6",
          [
            "フィーバー\nバッドステータス。キミは次のクエストフェイズ終了時まで、何らかの行為判定を行うたびに、【生命点】を「1点」減少させる。\n　一周回って、というやつさ。なんだか楽しくなってきてしまった。今なら何をやってもうまくいく気がするし、うまくいかなくても気にならない気がするんだ。",
            "ギスギスした雰囲気\n船内マップ上のキャラクター全員は、自身が獲得している【キズナ】すべての「支援チェック」にチェックを入れなければならない。\n　誰のせいでもない。いうなれば全員のせいなんだ。でも、誰かのせいにせずにはいられなかったのさ。",
            "エンジントラブル\nキミは船内マップ上の、任意の「機関室」カテゴリのパーツ1つを選び、さらにそのパーツ内の任意の、[破損]していないマス1つを選ぶ。そのマスは[破損]する。\n　……ボンッ!",
            "食糧難\n船内マップ上のキャラクター全員の【生命点】が「2点」減少する。\n　キミたちの前には、缶詰がひとつだけ。キミたちは顔を突き合わせ、お互いをにらみつける。どのみち、こんなものを奪いあっても、何にもならないというのに。",
            "老朽化\nキミのいるマスが[破損]する。この[破損]によって、キミの【生命点】は減少しない。\n　最近ミシミシというようになってきたな。とは思ったんだ。いつか修理しなきゃ、と思っていたさ。でも、こう、パキッといきなりいっちゃうとは思わなかったんだ。本当だよ。",
            "まだ大丈夫……\nこの航行イベントには、特に効果はない。\n　今の所、このフネにはまだ安全な空の旅を続けるだけの余裕はある。だが、キミたちの脳裏には不安がよぎる。安全はあっても、安心はできないのだ。",
            "先を急ぐ\nこのシーン中、キミはアクションを行うことができない。その代わりに、飛空艇コマを1スポット分移動させる。\n　先を急ごう。焦燥に苛まれる中、キミたち全員がそう思っていた。のんびりと旅を楽しんでいる時間はない。そんな時間は、とっくの昔に過ぎ去っている。",
            "パンデミック\nキミは「フナ酔い」(p91)、「二日酔い」(p93)、「ケガ」(p94)から1つを選ぶ。船内マップ上にいるキャラクター全員は、選ばれた航行イベントに記載されているバッドステータスを受ける。\n　悪いことに、病気というものはときとして人から人へと伝染する。地上の流行り病も大変だというのに、空の上でこうなってしまったらとんでもない。ああ、天はキミたちを見放したのだろうか。",
            "気流+1\n飛空艇コマを1スポット分移動させる。\n　しめた！追い風となっている気流を見つける。一刻も早く目的地までたどり着かなければならないキミたちにとって、まさに願ってもないことだ。",
            "こんなときに\nシーンプレイヤーは、「航行イベント表：困難系」(p94)を振ること。振って出た航行イベント表の効果が適用される。\n　いくらキミたちが困っていても、自然はそんなことかまいやしない。困難は見境なく訪れ、キミたちをさらに困らせる。",
            "遭難\nこの航行イベント表が発生した時点で、セッションは終了となる。お疲れ様。\n　その後、キミたちが再び「塔」へと戻ってくることはなかった。嵐にのまれたのだろうか、空賊や、浮遊生物に襲われたのだろうか。それを知る者は、もうどこにもいない。"
          ]
        ),
      }.freeze

      register_prefix('D', '\d?SN', 'AVO', TABLES.keys)

      def initialize(command)
        super(command)
        @round_type = RoundType::FLOOR # 端数切り捨て
      end

      def eval_game_system_specific_command(command)
        command_sn(command) || command_d(command) || command_avo(command) || command_snavo(command) ||
          command_snd(command) || roll_tables(command, TABLES)
      end

      private

      DIRECTION_INFOS = {
        0 => {name: "", position_diff: [0, 0]},
        1 => {name: "左下", position_diff: [-1, +1]},
        2 => {name: "下", position_diff:  [0, +1]},
        3 => {name: "右下", position_diff: [+1, +1]},
        4 => {name: "左", position_diff: [-1, 0]},
        5 => {name: "", position_diff: [0, 0]},
        6 => {name: "右", position_diff: [+1, 0]},
        7 => {name: "左上", position_diff: [-1, -1]},
        8 => {name: "上", position_diff:  [0, -1]},
        9 => {name: "右上", position_diff: [+1, -1]},
      }.freeze

      D_REGEXP = %r{^D([1-46-9]{0,8})(\[.+\]|S|F|SF|FS)?/(\d{1,2})(@([2468]))?$}.freeze

      def command_sn(command)
        debug("SN", command)
        cmd = Command::Parser.new(/[1-9]?SN(\d{0,2})/, round_type: round_type)
                             .restrict_cmp_op_to(nil)
                             .enable_fumble.parse(command)
        return nil unless cmd

        # [dice_count]SN[target]
        dice_count, target = cmd.command.split("SN", 2).map(&:to_i)
        dice_count = 2 if dice_count == 0
        target = 7 if target == 0
        fumble = cmd.fumble.nil? ? 1 : cmd.fumble

        debug("SN Parsed", dice_count, target, fumble)

        dice_list = @randomizer.roll_barabara(dice_count, 6)
        dice_top_two = dice_list.sort[-2..-1]
        res = if dice_top_two == [6, 6]
                Result.critical("スペシャル（【生命点】1d6回復）")
              elsif dice_list.max <= fumble
                Result.fumble("ファンブル（ファンブル表FT）")
              elsif dice_top_two.sum >= target
                Result.success("成功")
              else
                Result.failure("失敗")
              end

        if dice_count == 2
          res.text = ["(#{dice_count}SN#{target}##{fumble})", "#{dice_top_two.sum}[#{dice_list.join(',')}]", res.text]
                     .compact.join(" ＞ ")
        else
          res.text = ["(#{dice_count}SN#{target}##{fumble})", "[" + dice_list.join(",") + "]", "#{dice_top_two.sum}[#{dice_top_two.join(',')}]", res.text]
                     .compact.join(" ＞ ")
        end
        res
      end

      def command_d(command)
        m = D_REGEXP.match(command)
        return nil unless m

        fire_count = m[3].to_i # 砲撃回数
        fire_range = m[1].to_s # 砲撃範囲
        ballistics = m[5].to_i # 《弾道学》

        points = get_fire_points(fire_count, fire_range)
        command = command.sub("SF/", "[大揺れ,火災]/").sub("FS/", "[火災,大揺れ]/").sub("F/", "[火災]/").sub("S/", "[大揺れ]/")
        result = ["(#{command})", get_points_text(points, 0, 0)]
        if ballistics != 0
          dir = DIRECTION_INFOS[ballistics]
          diff_x, diff_y = dir[:position_diff]
          result[-1] += "\n"
          result << "《弾道学》#{dir[:name]}"
          result << get_points_text(points, diff_x, diff_y)
        end

        result.compact.join(" ＞ ")
      end

      def command_avo(command)
        debug("AVO", command)
        dmg = command.match(/^AVO@([2468])(.*?)$/)
        return nil unless dmg

        dir = DIRECTION_INFOS[dmg[1].to_i]
        diff_x, diff_y = dir[:position_diff]
        "《回避運動》#{dir[:name]} ＞ " + dmg[2].gsub(/\(?\[(\d),(\d{1,2})\]\)?/) do
          y = Regexp.last_match(1).to_i + diff_y
          x = Regexp.last_match(2).to_i + diff_x
          get_xy_text(x, y)
        end
      end

      def command_snavo(command)
        sn, avo = command.split(%r{/?AVO}, 2)
        debug("SNAVO", sn, avo)
        am = /^@([2468])(.*?)$/.match(avo)
        return nil unless am

        res = command_sn(sn)
        return nil unless res

        if res.success?
          res.text += "\n ＞ " + command_avo("AVO" + avo)
        end
        res
      end

      def command_snd(command)
        sn, d = command.split(%r{/?D}, 2)
        debug("SND", sn, d)
        m = D_REGEXP.match("D#{d}")
        return nil unless m

        res = command_sn(sn)
        return nil unless res

        if res.success?
          res.text += "\n ＞ #{command_d('D' + d)}"
        end
        res
      end

      def get_points_text(points, diff_x, diff_y)
        "[縦,横]=" + points.map do |list|
          list.map do |x, y|
            get_xy_text(x + diff_x, y + diff_y)
          end.join()
        end.join(",")
      end

      # 範囲内なら[y,x]、範囲外なら([y,x])と表示
      def get_xy_text(x, y)
        if (2..12).include?(x) && (1..6).include?(y)
          "[#{y},#{x}]"
        else
          "([#{y},#{x}])"
        end
      end

      # 命中場所と範囲から、ダメージ位置を割り出す
      def get_fire_points(fire_count, fire_range)
        range = fire_range.chars.map(&:to_i)
        fire_count.times.map do
          y = @randomizer.roll_once(6) # 縦
          x = @randomizer.roll_sum(2, 6) # 横

          [[x, y]] + range.map do |r|
            xdiff, ydiff = DIRECTION_INFOS[r][:position_diff]
            [x + xdiff, y + ydiff]
          end
        end
      end
    end
  end
end
