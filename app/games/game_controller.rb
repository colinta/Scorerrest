class GameController < UIViewController
  attr_accessor :game

  def initWithGame(game)
    init.tap do
      @game = game
      setHidesBottomBarWhenPushed(true)
    end
  end

end
