class Map
    # インスタンス変数の読み取り専用メソッドを定義できる
    attr_reader :start_xy, :goal_xy, :field

    START, GOAL = "S", "G"
    WALL = "#"

    # 初期化処理をintializeメソッドでしている
    def initialize
        # 地図フィールド情報読み取り
        @field = DATA.read.split.map{|r|r.split("")}
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
    def display(route=[])
        # 経路座標に "*" を表示する
        route.each do |x,y|
            # 色をつけてる
            @field[y][x] = "\e[32m*\e[0m"
        end

        # 区切りのキリトリ線
        puts "-" * 30
        @field.each do |ar|
            puts ar.join
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

# 実行するファイル名と実行中のファイル名が一緒だったら
if __FILE__ == $0 then
    map = Map.new
    map.description
    map.display
    p map.distance2goal(0,0)
    p map.distance2goal(0,4)
    p map.distance2goal(4,4)
end

# __END__から始まる座標を呼び出してただ表示しているだけ
puts DATA.read

__END__
S.#.G
..#..
.....
..#..
..#..