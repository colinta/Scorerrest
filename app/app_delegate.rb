TypewriterView = GM::TypewriterView

include SugarCube::Adjust
include SugarCube::CoreGraphics
include SugarCube::Timer


class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    main_menu = MainMenuController.new

    main_nav_ctlr = UINavigationController.alloc.initWithRootViewController(main_menu)
    main_nav_ctlr.navigationBarHidden = true

    player_nav_ctlr = UINavigationController.alloc.initWithRootViewController(PlayerManagerController.new)

    tabbar_controllers = [
      main_nav_ctlr,
      player_nav_ctlr,
    ]
    unless Game.games.empty?
      games_nav_ctlr = UINavigationController.alloc.initWithRootViewController(GamesManagerController.new)
      tabbar_controllers << games_nav_ctlr
    end

    tabbar_ctlr = UITabBarController.new
    tabbar_ctlr.viewControllers = tabbar_controllers

    @delegate = MyApplicationNavigationDelegate.new

    @delegate.tabBarController = tabbar_ctlr
    @delegate.mainMenuController = main_menu

    main_nav_ctlr.delegate = @delegate
    main_menu.delegate = @delegate

    @window.rootViewController = tabbar_ctlr
    @window.makeKeyAndVisible

    start_timer

    true
  end

  def start_timer
    @timer ||= every 10.seconds do
      Player.persist
      Game.persist
    end
  end

  def stop_timer
    if @timer
      @timer.invalidate
      @timer = nil
    end
  end

  def applicationDidEnterBackground(application)
    start_timer && start_timer.fire
    stop_timer
  end

  def applicationWillEnterForeground(application)
    start_timer
  end


  def application(application, supportedInterfaceOrientationsForWindow:window)
    if Device.iphone?
      UIInterfaceOrientationMaskAllButUpsideDown
    else
      UIInterfaceOrientationMaskAll
    end
  end

end
