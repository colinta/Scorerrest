
class GamesManagerController < UIViewController

  stylesheet :game_manager

  def init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(
        "Games",
        image:"tabbar_mainmenu".uiimage,
        tag:1)
    self.navigationItem.backBarButtonItem =
      UIBarButtonItem.alloc.initWithTitle("Games",
                style:UIBarButtonItemStyleBordered,
               target:nil,
               action:nil)
    super
  end

  layout :root do
    @table_view = subview(UITableView.plain, :table,
      dataSource: self,
      delegate: self
      )
  end

  def viewDidLoad
    super

    self.title = "In Progress"

    self.navigationItem.leftBarButtonItem = self.editButtonItem
  end

  def viewWillAppear(is_animated)
    super
    @table_view.reloadData
  end

  def viewWillDisappear(is_animated)
    super

    setEditing(false, animated:false)
    @table_view.setEditing(false, animated:false)
  end

  def tableView(table_view, cellForRowAtIndexPath:index_path)
    cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier) ||
          UITableViewCell.alloc.initWithStyle(:subtitle.uitablecellstyle,
                              reuseIdentifier:cell_identifier)
    cell.textLabel.text = Game.games[index_path.row].name
    cell.detailTextLabel.text = Game.games[index_path.row].subtitle
    cell.accessoryType = :disclosure.uitablecellaccessory

    return cell
  end

  def tableView(table_view, numberOfRowsInSection: section)
    case section
    when 0
      Game.games.length
    else
      0
    end
  end

  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated:true)

    game = Game.games[index_path.row]

    self.navigationController << Game.controller_for_game(game)
  end

  ##|
  ##|  EDITING TABLE
  ##|
  def tableView(table_view, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
    if editing_style == UITableViewCellEditingStyleDelete
      Game.delete_game_at(index_path.row)
      @table_view.deleteRowsAtIndexPaths([index_path], withRowAnimation:UITableViewRowAnimationAutomatic)
    end
  end

  def tableView(table_view, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    @move = Game.games[from_index_path.row]
    Game.games.delete_at(from_index_path.row)
    if @move
      Game.games.insert(to_index_path.row, @move)
    end
  end

  def setEditing(is_editing, animated:is_animated)
    @table_view.setEditing(is_editing, animated:is_animated)
    super
  end

  ##|
  ##|  uninteresting stuff:
  ##|
  def cell_identifier
    @@cell_identifier ||= 'GameCell'
  end

end