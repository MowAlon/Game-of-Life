class Cell
  attr_reader :x, :y

  def initialize(x,y)
  	@x = x
    @y = y
  end
end

class World

  attr_reader :live_cells

  def initialize(live_map)
    @live_cells = load_world(live_map)
  end

  def load_world(live_map)
  	live_map.map {|location| Cell.new(location[0], location[1])}
  end

  def cell(location)
    x,y = location[0], location[1]
    live_cells.find {|cell| cell.x == x && cell.y == y}
  end

  def alive?(location)
  	!!cell(location)
  end

  def local_grid_locations(location)
    x, y = location[0], location[1]
    base = [x - 1, y - 1]
    0.upto(8).map {|index| [base[0] + (index % 3), base[1] + (index / 3)]}
  end

  def investigation_locations
  	live_cells.map {|cell| local_grid_locations([cell.x, cell.y])}.flatten(1).uniq
  end

  def neighbors(location)
  	local_grid_locations(location) - [location]
  end

  def live_neighbors(location)
    neighbors(location).count {|location| alive?(location)}
  end

  def alive_next_time?(location)
    live_neighbor_count = live_neighbors(location)
    live_neighbor_count == 3 || (alive?(location) && live_neighbor_count == 2)
  end

  def new_world
    investigation_locations.select {|location| location if alive_next_time?(location)}
  end

end

class Printer
  def draw_map(locations, width, height, speed, alive_character, dead_character)
    horizontal_line = ''.ljust(width,'-')

    system("clear")
    screen = horizontal_line + "\n"
  	lines = locations.group_by{|location|location[1]}
    (height - 1).downto(0) do |index|
      line = ''.ljust(width, dead_character)
      lines[index].each {|location| line[location[0]] = alive_character if location[0].between?(0,width - 1)} if lines[index]
      screen += line + "\n"
    end
    screen += horizontal_line
    puts screen
    sleep(1.0/speed)
  end
end

  ##################################################
  ### Change these things to change behavior ###
          alive_character = '💩'
          dead_character = ' ' # <-- emoji no bueno
          iterations = 200
          width = 100
          height = 30
          speed = 1000  # <-- higher means faster
  ##################################################

# famous example --> [[1, 5], [2, 5], [1, 6], [2, 6], [14, 3], [13, 3], [12, 4], [11, 5], [11, 6], [11, 7], [12, 8], [13, 9], [14, 9], [16, 4], [17, 5], [15, 6], [17, 6], [18, 6], [17, 7], [16, 8], [25, 1], [25, 2], [23, 2], [21, 3], [22, 3], [21, 4], [22, 4], [21, 5], [22, 5], [23, 6], [25, 6], [25, 7], [35, 3], [36, 3], [35, 4], [36, 4]]
starter_map = [[1, 5], [2, 5], [1, 6], [2, 6], [14, 3], [13, 3], [12, 4], [11, 5], [11, 6], [11, 7], [12, 8], [13, 9], [14, 9], [16, 4], [17, 5], [15, 6], [17, 6], [18, 6], [17, 7], [16, 8], [25, 1], [25, 2], [23, 2], [21, 3], [22, 3], [21, 4], [22, 4], [21, 5], [22, 5], [23, 6], [25, 6], [25, 7], [35, 3], [36, 3], [35, 4], [36, 4]]
new_map = starter_map
world = World.new(starter_map)
printer = Printer.new
continue = true

while continue do
  iterations.times do
    printer.draw_map(new_map, width, height, speed, alive_character, dead_character)
    new_map = world.new_world
    world = World.new(new_map)
  end
  puts "Do you want more? ('y' to continue)"
  continue = false if gets[0].downcase != 'y'
end
