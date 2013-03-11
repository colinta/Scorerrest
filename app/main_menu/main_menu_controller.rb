
class MainMenuController < UIViewController
  attr_accessor :delegate

  def init
    super.tap do
      self.tabBarItem = UITabBarItem.alloc.initWithTitle('Games',
                                                         image:'tabbar_mainmenu'.uiimage,
                                                         tag:0)
      GamesChangedNotification.add_observer(self, :gamesChanged)
    end
  end

  stylesheet :main_menu

  layout :root do
    subview(GM::GradientView, :bg)
    @typewriter = subview(TypewriterView, :apps) do
      @tally = subview(AppLauncherView.new('Tally', 'TallyIcon'))
      @timer = subview(AppLauncherView.new('Timer', 'TimerIcon'))
    end

    # create a new setup controller everytime, don't save in memory
    @tally.on(:touch) {
      self.navigationController << TallySetupController.new
    }

    @timer.on(:touch) {
      self.navigationController << TimerSetupController.new
    }
  end

  def viewWillAppear(animated)
    super
  end

  def gamesChanged
    if Game.games.empty? && self.tabBarController.viewControllers.length == 3
      self.tabBarController.selectedIndex = 0
      self.tabBarController.setViewControllers(self.tabBarController.viewControllers[0..1], animated:true)
    elsif ! Game.games.empty? && self.tabBarController.viewControllers.length == 2
      self.tabBarController << UINavigationController.alloc.initWithRootViewController(GamesManagerController.new)
    end
  end

end


class MyApplicationNavigationDelegate
  attr_accessor :mainMenuController
  attr_accessor :tabBarController

  def navigationController(nav_ctlr, willShowViewController:ctlr, animated:is_animated)
    if ctlr.respondsToSelector('navigationController:willShowViewController:animated:')
      return ctlr.navigationController(nav_ctlr, willShowViewController:ctlr, animated:is_animated)
    elsif ctlr == self.mainMenuController
      nav_ctlr.setNavigationBarHidden(true, animated:true)
      # App.shared.setStatusBarStyle(UIStatusBarStyleBlackTranslucent, animated:true)
    else
      nav_ctlr.setNavigationBarHidden(false, animated:true)
      App.shared.setStatusBarStyle(UIStatusBarStyleDefault, animated:true)
    end
  end

  def navigationController(nav_ctlr, didShowViewController:ctlr, animated:is_animated)
    if ctlr.respondsToSelector('navigationController:didShowViewController:animated:')
      return ctlr.navigationController(nav_ctlr, didShowViewController:ctlr, animated:is_animated)
    end
  end

end
