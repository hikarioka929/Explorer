class Map
    # インスタンス変数の読み取り専用メソッドを定義できる
    attr_reader :start_xy, :goal_xy, :field

    START, GOAL = "S", "G"
    WALL = "#"

    # 初期化処理をintializeメソッドでしている
    def initialize
        # 地図フィールド情報読み取り
        @field = DATA.read.split.map{|r|r.split("")}
        @field_init = Marshal.load(Marshal.dump(@field))
        #地図の縦横サイズ
        @height = @field.size
        @width = @field[0].size
        #スタート地点・ゴール地点の座標
        @start_xy = find_xy(START)
        @goal_xy = find_xy(GOAL)
    end

    # 指定の記号を検索して、その座標を返す
    def find_xy(char)
        @field.each_with_index do |ar, y|
            if ar.include?(char) then
                # 探しているcharの要素の順番がxに格納されている(横軸)
                x = ar.index(char)
                return [x, y]
            end
        end
    end

    # 地図の詳細情報を出力する
    def description
        puts "地図の縦横サイズは#{@height} x #{@width}です"
        puts "スタート座標は #{@start_xy} です"
        puts "ゴール座標は #{@goal_xy} です"
    end

    # 地図のフィールド情報を出力する
    def display(route=[],goal=nil)
        @field = Marshal.load(Marshal.dump(@field_init))
        # 経路座標に "*" を表示する
        route.each do |x,y|
            # 色をつけてる
            @field[y][x] = "\e[32m*\e[0m"
        end
        @field.each do |ar|
            puts ar.join
        end

        # 標準出力をフラッシュして書き換える
        if goal.nil? then
            printf "\e[#{@height}A"
            STDOUT.flush
            sleep 0.2
        end
    end

    # 指定の座標が移動可能かどうかを判定する
    def valid?(x, y)
        return false if x < 0
        return false if y < 0
        return false if x >= @width
        return false if y >= @height
        return false if @field[y][x] == WALL
        return true
    end

    # 指定の座標からゴール座標までの直線距離を算出する(三平方の定理を使う　c² = a² + b²)
    def distance2goal(x, y)
        hen1 = (@goal_xy[0] - x).abs ** 2
        hen2 = (@goal_xy[1] - y).abs ** 2
        ans = Math.sqrt( hen1 + hen2 )
        return ans
    end
end

# 探検家クラス
class Explorer
        #     UP    RIGHT  DOWN  LEFT
        V = [ [0,1], [1,0], [0,-1], [-1,0] ]

    def initialize
        # 地図を手に入れる
        @map = Map.new
        @map.description
        @map.display

        # スタート地点をメモして訪問先リストを登録する
        @memo = {
            @map.start_xy => [
                0, # スタート地点からの実歩数
                0, # ゴールに近いかどうかの評価(スコア)
                true, # 移動予定か(移動済みならfalse)
                [nil, nil] # 移動元座標
            ]
        }
    end

    # メモからゴールに近い座標を一つ取り出して
    # その座標に移動する(移動済みとしてクローズする)
    def move
        arr = @memo.select{|_,v|v[2]}.sort_by{|_,v|v[1]}
        xy = arr.to_h.keys.shift
        @memo[xy][2] = false
        return xy
    end

    def look_around(xy)
        # 東西南北の座標を一覧にしてnext_xy_listに渡す
        x,y = xy
        next_xy_list = []
        V.each do |vx,vy|
            next_x = x + vx
            next_y = y + vy
            next_xy_list << [next_x, next_y]
        end

        # 移動可能な座標だけを抽出する
        # すでにメモしてある座標は除外する
        next_xy_list.select! do |x,y|
            @map.valid?(x,y) and !@memo[[x,y]]
        end

        return next_xy_list
    end

    # 指定の座標一覧に対してメモを記入する(一歩進んだか,評価,訪問済みかどうか,今いる座標)
    def piyo_memo(xy_list, pxy)
        step = @memo[pxy][0] + 1
        xy_list.each do |x,y|
            score = @map.distance2goal(x,y) + step
            memo = [step, score, true, pxy]
            @memo[[x,y]] = memo
        end
        return @memo
    end

    # ゴールしたかどうか判定する
    def goal?(xy)
        return true if xy.nil?
        return true if xy == @map.goal_xy
        return false
    end

    # 指定の座標からスタート座標までの経路までの経路を返す
    def check_route(xy,goal=nil)
        route = []
        until xy == @map.start_xy do
            route << xy
            xy = @memo[xy][3]
        end
        route.shift if route[0] == @map.goal_xy
        route.pop if route[-1] == @map.start_xy

        @map.display(route,goal)
    end
end

if __FILE__ == $0 then
    piyoppa = Explorer.new
    xy = piyoppa.move

    until piyoppa.goal?(xy) do
        next_xy_list = piyoppa.look_around(xy)
        piyoppa.piyo_memo(next_xy_list, xy)
        xy = piyoppa.move
        piyoppa.check_route(xy)
    end
    piyoppa.check_route(xy,true)
    puts "piyoppa,ゴールしたってよ"
end

# __END__から始まる座標を呼び出してただ表示しているだけ
puts DATA.read

__END__

S#..#.#.##.#.....
...##......##.#..
.###G.###.###.#..
....###.#..#.....
#.#......#...#...
##..#.##.#..#..#.
##.###...#.#..##.
##....#.#...#...#
##.####.#.#####.#
###.....##..#....
##..#.#.##.#..##.
##.##.........#..