# 地図クラス

class Map

    attr_reader :start_xy, :goal_xy, :field
  
  
  
    START,GOAL = "S","G"
  
    WALL = "#"
  
  
  
    def initialize
  
      # 地図フィールド情報
  
      @field = DATA.read.split.map{|r|r.split("")}
  
      # 地図の縦横サイズ
  
      @h = @field.size
  
      @w = @field[0].size
  
      # スタート地点・ゴール地点の座標
  
      @start_xy = find_xy(START)
  
      @goal_xy = find_xy(GOAL)
  
    end
  
  
  
    # 指定の記号を検索して、その座標を返す
  
    def find_xy(char)
  
      @field.each_with_index do |ar,y|
  
        if ar.include?(char) then
  
          x = ar.index(char)
  
          return [x,y]
  
        end
  
      end
  
    end
  
  
  
    # 地図の詳細情報を出力する
  
    def description
  
      puts "地図の縦横サイズは #{@h} x #{@w} です"
  
      puts "スタート座標は #{@start_xy} です"
  
      puts "ゴール座標は #{@goal_xy} です"
  
    end
  
  
  
    # 地図のフィールド情報を出力する
  
    def display(route=[])
  
      # 経路座標に "*" を表示する
  
      route.each do |x,y|
  
        @field[y][x] = "\e[32m*\e[0m"
  
      end
  
      puts "-" * 30
  
      @field.each do |ar|
  
        puts ar.join
  
      end
  
    end
  
  
  
    # 指定の座標が移動可能かどうかを判定する
  
    def valid?(x,y)
  
      return false if x < 0
  
      return false if y < 0
  
      return false if x >= @w
  
      return false if y >= @h
  
      return false if @field[y][x] == WALL
  
      return true
  
    end
  
  
  
    # 指定の座標からゴール座標までの直線距離を算出する
  
    def distance2goal(x,y)
  
      hen1 = (@goal_xy[0] - x).abs ** 2
  
      hen2 = (@goal_xy[1] - y).abs ** 2
  
      ans = Math.sqrt( hen1 + hen2 )
  
      return ans
  
    end
  
  end
  
  
  
  
  
  # 探検家クラス
  
  class Explorer
  
    #     UP     RIGHT  DOWN    LEFT
  
    V = [ [0,1], [1,0], [0,-1], [-1,0] ]
  
  
  
    def initialize
  
      # 地図を手に入れる
  
      @map = Map.new
  
      @map.description
  
      @map.display
  
  
  
      # スタート地点をメモして訪問先リストに登録する
  
      @memo = {
  
        @map.start_xy => [
  
          0, # スタート地点からの実歩数
  
          0, # ゴールに近いかどうかの評価(スコア)
  
          true, # 移動予定か(移動済みならfalse)
  
          [nil,nil] # 移動元座標
  
        ]
  
      }
  
    end
  
  
  
    # メモからゴールに近い座標をひとつ取り出して
  
    # その座標に移動する(移動済みとしてクローズする)
  
    def move
  
      arr = @memo.select{|_,v|v[2]}.sort_by{|_,v|v[1]}
  
      xy = arr.to_h.keys.shift
  
      @memo[xy][2] = false
  
      return xy
  
    end
  
  
  
  end
  
  
  
  
  
  if __FILE__ == $0 then
  
    takashi = Explorer.new
  
    p takashi.move
  
  end
  
  
  
  # ここから下は実行されない
  
  # DATA から読み出すことが出来る
  puts DATA.read

__END__
S.#.G
..#..
.....
..#..
..#..