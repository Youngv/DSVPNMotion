class AppDelegate
  attr_accessor :app_name, :dsvpn_running, :start_button, :stop_button, :scrollView, :text_view, 
                :statusBarItem, :mainWindow, :text_fields, :serverInput, :portInput, :keyFileInput,
                :defaultPath, :defaultPort, :defaultServer, :selectFileButton, :getProcessTimer,
                :getIPAddressTimer

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleName']
    checkApp
    @dsvpn_running = false
    @text_fields = []

    loadDefaults
    buildMenu
    buildLogView
    buildServerLabel
    buildServerInput
    buildPortLabel
    buildPortInput
    buildKeyFileLabel
    buildKeyFileInput
    buildKeyFileSelect
    buildStartButton
    buildStopButton
    buildStatusBar
    buildStatusBarMenu
    setStatusBarIcon
    buildWindow
    mainWindow.contentView.addSubview(scrollView)
    text_fields.each { |text_field| mainWindow.contentView.addSubview(text_field) }
    serverInput.nextKeyView = portInput
    portInput.nextKeyView = keyFileInput
    mainWindow.contentView.addSubview(start_button)
    mainWindow.contentView.addSubview(stop_button)
    mainWindow.orderFrontRegardless
    setupTimer
  end

  def setupTimer
    getProcessTimer.invalidate unless getProcessTimer.nil?
    @getProcessTimer = NSTimer.scheduledTimerWithTimeInterval 0.5, target: self, selector: 'getProcesses', userInfo: nil, repeats: true
    getIPAddressTimer.invalidate unless getIPAddressTimer.nil?
    @getIPAddressTimer = NSTimer.scheduledTimerWithTimeInterval 10, target: self, selector: 'getIPAddress', userInfo: nil, repeats: true
  end

  def loadDefaults
    userDefaults = NSUserDefaults.standardUserDefaults()
    @defaultPath = userDefaults.URLForKey('DefaultPath')
    @defaultServer = userDefaults.stringForKey('DefaultServer')
    @defaultPort = userDefaults.stringForKey('DefaultPort')
  end

  def checkApp
    apps = NSRunningApplication.runningApplicationsWithBundleIdentifier NSBundle.mainBundle.bundleIdentifier
    NSApp.terminate(nil) if apps.count > 1
  end

  def buildWindow
    screen_height = NSScreen.mainScreen.frame.size.height
    screen_width = NSScreen.mainScreen.frame.size.width
    @mainWindow = NSWindow.alloc.initWithContentRect([[(screen_width - 250)/2, (screen_height - 50)/2], [250, 300]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    mainWindow.title = app_name
    mainWindow.orderFrontRegardless
    mainWindow.styleMask &= ~NSWindowStyleMaskResizable
    mainWindow.delegate = self
  end

  def buildLogView
    # https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html
    @scrollView = NSScrollView.alloc.initWithFrame CGRectMake(0, 100, 250, 200)
    contentSize = scrollView.contentSize
    scrollView.setBorderType NSNoBorder
    scrollView.setHasVerticalScroller false
    scrollView.setHasHorizontalScroller false
    scrollView.setAutoresizingMask NSViewWidthSizable | NSViewHeightSizable

    theTextView = NSTextView.alloc.initWithFrame NSMakeRect(0, 0, contentSize.width, contentSize.height)
    theTextView.setMinSize NSMakeSize(0.0, contentSize.height)
    theTextView.setMaxSize NSMakeSize(Float::MAX, Float::MAX)
    theTextView.setVerticallyResizable true
    theTextView.setHorizontallyResizable false
    theTextView.setAutoresizingMask NSViewHeightSizable
    theTextView.setBackgroundColor NSColor.whiteColor
    theTextView.drawsBackground = true
    theTextView.setEditable false

    theTextView.textContainer.setContainerSize NSMakeSize(contentSize.width, Float::MAX)
    theTextView.textContainer.setWidthTracksTextView true

    @text_view = theTextView
    scrollView.setDocumentView theTextView
  end

  def buildServerLabel
    textField = NSTextField.alloc.initWithFrame CGRectMake(8, 70, 50, 16)
    textField.setBezeled false
    textField.setDrawsBackground false
    textField.setEditable false
    textField.setSelectable false
    textField.setStringValue 'Server'
    textField.font = NSFont.systemFontOfSize(12)
    @text_fields << textField
  end

  def buildServerInput
    @serverInput = NSTextField.alloc.initWithFrame CGRectMake(54, 70, 90, 16)
    serverInput.setBezeled false
    serverInput.drawsBackground = true
    serverInput.font = NSFont.systemFontOfSize(12)
    serverInput.maximumNumberOfLines = 1
    serverInput.cell.setWraps(false)
    serverInput.cell.setScrollable(true)
    serverInput.setStringValue defaultServer if defaultServer
    @text_fields << serverInput
  end

  def buildPortLabel
    textField = NSTextField.alloc.initWithFrame CGRectMake(155, 70, 40, 16)
    textField.setBezeled false
    textField.setDrawsBackground false
    textField.setEditable false
    textField.setSelectable false
    textField.setStringValue 'Port'
    textField.font = NSFont.systemFontOfSize(12)
    @text_fields << textField
  end

  def buildPortInput
    @portInput = NSTextField.alloc.initWithFrame CGRectMake(190, 70, 50, 16)
    portInput.setBezeled false
    portInput.drawsBackground = true
    portInput.font = NSFont.systemFontOfSize(12)
    portInput.maximumNumberOfLines = 1
    portInput.cell.setWraps(false)
    portInput.cell.setScrollable(true)
    portInput.setStringValue defaultPort if defaultPort
    @text_fields << portInput
  end

  def buildKeyFileLabel
    textField = NSTextField.alloc.initWithFrame CGRectMake(8, 50, 50, 16)
    textField.setBezeled false
    textField.setDrawsBackground false
    textField.setEditable false
    textField.setSelectable false
    textField.setStringValue 'Key'
    textField.font = NSFont.systemFontOfSize(12)
    @text_fields << textField
  end

  def buildKeyFileInput
    @keyFileInput = NSTextField.alloc.initWithFrame CGRectMake(35, 50, 150, 16)
    keyFileInput.setBezeled false
    keyFileInput.drawsBackground = true
    keyFileInput.font = NSFont.systemFontOfSize(12)
    keyFileInput.maximumNumberOfLines = 1
    keyFileInput.cell.setWraps(false)
    keyFileInput.cell.setScrollable(true)
    keyFileInput.setStringValue defaultPath.path if defaultPath
    @text_fields << keyFileInput
  end

  def buildKeyFileSelect
    @selectFileButton = NSButton.alloc.initWithFrame(CGRectMake(190, 50, 50, 16))
    selectFileButton.setBezelStyle(NSTexturedRoundedBezelStyle)
    selectFileButton.setTitle('Select')
    selectFileButton.setButtonType(NSTexturedSquareBezelStyle)

    selectFileButton.setAlignment(NSTextAlignmentCenter)
    selectFileButton.setFont(NSFont.systemFontOfSize(12))
    selectFileButton.setSound(NSSound.soundNamed("Pop"))
    selectFileButton.setTarget(self)
    selectFileButton.setAction('select_dir:')
    @text_fields << selectFileButton
  end

  def select_dir(sender)
    currentPath = defaultPath ? defaultPath.path : '~'.stringByExpandingTildeInPath
    panel = NSOpenPanel.openPanel
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false
    panel.message = 'Choose your dsvpn key file'
    panel.prompt = 'Select'
    panel.setDirectoryURL(NSURL.fileURLWithPath(currentPath));
    panel.beginSheetModalForWindow sender.window, completionHandler: ->(result) do
      if result == NSModalResponseOK
        path = panel.URLs[0].path
        keyFileInput.setStringValue path

        userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setURL(panel.URLs[0], forKey: 'DefaultPath')
        @defaultPath = panel.URLs[0]
      end
    end
  end

  def buildStartButton
    btn = NSButton.alloc.initWithFrame(CGRectMake(12.5, 12.5, 100, 25))
    btn.setBezelStyle(NSRegularSquareBezelStyle)
    btn.setTitle('Connect')
    btn.setButtonType(NSMomentaryLightButton)
    btn.setAlignment(NSTextAlignmentCenter)
    btn.setFont(NSFont.systemFontOfSize(10))
    btn.setSound(NSSound.soundNamed("Pop"))
    btn.setTarget(self)
    btn.setAction('start_dsvpn')
    @start_button = btn
  end

  def buildStopButton
    btn = NSButton.alloc.initWithFrame(CGRectMake(137.5, 12.5, 100, 25))
    btn.setBezelStyle(NSRegularSquareBezelStyle)
    btn.setTitle('Disconnect')
    btn.setButtonType(NSMomentaryLightButton)
    btn.setAlignment(NSTextAlignmentCenter)
    btn.setFont(NSFont.systemFontOfSize(10))
    btn.setSound(NSSound.soundNamed("Pop"))
    btn.setTarget(self)
    btn.setAction('stop_dsvpn')
    @stop_button = btn
  end

  def buildStatusBar
    @statusBarItem = NSStatusBar.systemStatusBar.statusItemWithLength(NSSquareStatusItemLength)
    statusBarItem.setHighlightMode(true)
    statusBarItem.setTitle(app_name)
    unless button = statusBarItem.button
      appendLog("add status bar item failed. Try removing some menu bar item.")
      NSApp.terminate(nil)
      return
    end

    button.target = self
  end

  def setStatusBarIcon
    statusBarItem.button.image = statusBarIcon
  end

  def statusBarIcon
    image = NSImage.imageNamed(dsvpn_running ? 'up.png' : 'down.png')
    image.template = true
    image.size = NSMakeSize(18, 18)
    image
  end

  def buildStatusBarMenu
    menu = NSMenu.new
    if dsvpn_running
      menu.addItem createMenuItem("🟢 DSVPN: On", '')
    else
      menu.addItem createMenuItem("🟡 DSVPN: Off", '')
    end
    menu.addItem createMenuItem("IP Address: #{Api.ip || 'fetching'}", '')
    menu.addItem createMenuItem("VPN Details...", 'showMainWindow:')
    menu.addItem createMenuItem("About #{app_name}", 'showAboutWindow:')
    menu.addItem createMenuItem("Quit", 'terminate:')
    statusBarItem.setMenu(menu)
  end

  def showMainWindow(sender)
    setupTimer
    NSApp.activateIgnoringOtherApps true
    mainWindow.orderFrontRegardless
  end

  def showAboutWindow(sender)
    NSApp.hide(nil)
    NSApp.activateIgnoringOtherApps true
    NSApp.orderFrontStandardAboutPanel self
  end

  def pressAction
    alert = NSAlert.alloc.init
    alert.setMessageText "Action triggered from status bar menu"
    alert.addButtonWithTitle "OK"
    alert.runModal
  end

  def createMenuItem(name, action)
    menuItem = NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
    attributes = { NSFontAttributeName => NSFont.menuBarFontOfSize(12) }
    attributedTitle = NSAttributedString.alloc.initWithString menuItem.title, attributes: attributes
    menuItem.setAttributedTitle attributedTitle
    menuItem
  end

  def start_dsvpn
    server = serverInput.stringValue
    port = portInput.stringValue
    key_path = keyFileInput.stringValue
    if server.empty? || port.empty? || key_path.empty?
      alert = NSAlert.alloc.init
      alert.setMessageText "Server, Port, Key should not be blank"
      alert.addButtonWithTitle "OK"
      alert.runModal
      return
    end

    userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(server, forKey: 'DefaultServer')
    userDefaults.setObject(port, forKey: 'DefaultPort')

    task = STPrivilegedTask.alloc.init
    bin_path = NSBundle.mainBundle.pathForResource('sbin/dsvpn', ofType: '')
    task.launchPath = '/usr/bin/script'
    task.arguments = ["-q", "/dev/null", bin_path, "client", key_path, server, port]
    statusCode = task.launch
    if statusCode == 0
      appendLog("Connect task successfully launched\n")
    elsif statusCode == -60006
      appendLog("User cancelled")
      return
    else
      appendLog("Something went wrong")
      return
    end
    readHandle = task.outputFileHandle
    NSNotificationCenter.defaultCenter.addObserver self, selector: 'getOutputData:', name: NSFileHandleReadCompletionNotification, object: readHandle
    readHandle.readInBackgroundAndNotify
    NSApp.activateIgnoringOtherApps true
    mainWindow.orderFrontRegardless
  end

  def stop_dsvpn
    task = STPrivilegedTask.alloc.init
    task.launchPath = '/usr/bin/pkill'
    task.arguments = ['dsvpn']
    statusCode = task.launch
    if statusCode == 0
      appendLog("Disconnect task successfully launched\n")
    elsif statusCode == -60006
      appendLog("User cancelled")
      return
    else
      appendLog("Something went wrong")
      return
    end
    readHandle = task.outputFileHandle
    NSNotificationCenter.defaultCenter.addObserver self, selector: 'getOutputData:', name: NSFileHandleReadCompletionNotification, object: readHandle
    readHandle.readInBackgroundAndNotify
    NSApp.activateIgnoringOtherApps true
    mainWindow.orderFrontRegardless
  end

  def getProcesses
    task = NSTask.alloc.init
    task.launchPath = '/bin/ps'
    task.arguments = ['-ao', 'pid,command']
    pipe = NSPipe.pipe
    task.standardOutput = pipe
    fileHandle = pipe.fileHandleForReading
    NSNotificationCenter.defaultCenter.addObserver self, selector: 'thereIsData:', name: NSFileHandleReadToEndOfFileCompletionNotification, object: fileHandle
    fileHandle.readToEndOfFileInBackgroundAndNotify
    task.launch
    setStatusBarIcon
    buildStatusBarMenu
  end

  def getIPAddress
    Api.getIPAddress
  end

  def thereIsData(notification)
    processes = NSString.alloc.initWithData notification.userInfo.objectForKey(NSFileHandleNotificationDataItem), encoding: NSUTF8StringEncoding
    @dsvpn_running = processes.each_line.to_a.any? do |line|
      next if %w[PID COMMAND].all? { |column| line.include?(column) }
      pid, process = line.split(" ", 2)
      process.include?('dsvpn client')
    end
    start_button.setEnabled !dsvpn_running
    stop_button.setEnabled dsvpn_running
    serverInput.setEditable !dsvpn_running
    portInput.setEditable !dsvpn_running
    keyFileInput.setEditable !dsvpn_running
    selectFileButton.setEnabled !dsvpn_running
  end

  def getOutputData(notification)
    data = notification.userInfo.objectForKey(NSFileHandleNotificationDataItem)
    if data.length > 0
      outputString = NSString.alloc.initWithData data, encoding: NSUTF8StringEncoding
      appendLog(outputString)
    end
    notification.object.readInBackgroundAndNotify if dsvpn_running
  end

  def appendLog(string)
    text = NSAttributedString.alloc.initWithString string
    text_view.textStorage.appendAttributedString text
    text_view.scrollRangeToVisible NSMakeRange(text_view.string.length - 1, 1)
  end

  def windowShouldClose(sender)
    NSApp.hide(nil)
    false
  end
end
