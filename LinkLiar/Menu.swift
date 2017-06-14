import Cocoa

class Menu {

  let menu = NSMenu()

  private var interfaces: [Interface] = []
  private let queue: DispatchQueue = DispatchQueue(label: "io.github.halo.LinkLiar.menuQueue")

  init() {
    NotificationCenter.default.addObserver(forName: .softMacIdentified, object:nil, queue:nil, using:softMacIdentified)
  }

  func update() {
    Log.debug("Updating menu...")
    reloadInterfaceItems()
  }

  private func reloadInterfaceItems() {
    queue.sync {
      Log.debug("Reloading Interface menu items")

      // Remove all Interface items
      for item in menu.items {
        if (item.representedObject is Interface) {
         // print(item)

          menu.removeItem(item) }
      }

      // Replenish Interfaces
      interfaces = Interfaces.all(async: true)

      // Replenish corresponding items
      for interface in interfaces {
        let titleItem = NSMenuItem(title: interface.title, action: nil, keyEquivalent: "")
        titleItem.representedObject = interface
        menu.addItem(titleItem)
        menu.addItem(interfaceMenuItem(interface: interface))
      }
      menu.addItem(NSMenuItem.separator())
    }
  }

  func interfaceMenuItem(interface: Interface) -> NSMenuItem {
    let item = NSMenuItem(title: "Loading...", action: nil, keyEquivalent: "")
    item.representedObject = interface
    item.target = Controller.self
    item.tag = 42

    item.title = interface.softMAC.humanReadable;
    item.state = interface.hasOriginalMAC ? 1 : 0
    item.onStateImage = #imageLiteral(resourceName: "InterfaceLeaking")
    item.submenu = interfaceSubMenuItem(interface: interface)
    return item
  }

  func interfaceSubMenuItem(interface: Interface) -> NSMenu {
    let submenu: NSMenu = NSMenu()

    let vendorNameItem = NSMenuItem(title: "Vendor here", action: nil, keyEquivalent: "")
    submenu.addItem(vendorNameItem)
    submenu.addItem(NSMenuItem.separator())

    if (interface.isPoweredOffWifi) {
      let poweredOffItem = NSMenuItem(title: "Powered off", action: nil, keyEquivalent: "")
      submenu.addItem(poweredOffItem)
    } else {

      let forgetItem = NSMenuItem(title: "Do nothing", action: nil, keyEquivalent: "")
      forgetItem.tag = interface.BSDNumber;
      forgetItem.target = Controller.self
      //forgetItem.state = [LinkPreferences modifierOfInterface:interface] == ModifierUnknown;
      submenu.addItem(forgetItem)


    }
    return submenu
  }

  func softMacIdentified(_ notification: Notification) {
    let interface: Interface = notification.object as! Interface

    queue.sync {
      for item in menu.items {
        guard (item.tag == 42) else { continue }
        guard (item.representedObject is Interface) else { continue }
        guard ((item.representedObject as! Interface).hardMAC == interface.hardMAC) else { continue }
        let index = menu.index(of: item)
        menu.insertItem(interfaceMenuItem(interface: interface), at: index)
        menu.removeItem(item)
      }
    }
    NotificationCenter.default.post(name:.menuChanged, object: nil, userInfo: nil)
  }
  





  func load() {

    let item: NSMenuItem = NSMenuItem(title: "Install Helper", action: #selector(Controller.authorize(_:)), keyEquivalent: "")
    item.target = Controller.self
    menu.addItem(item)

    menu.addItem(NSMenuItem.separator())

    let item2: NSMenuItem = NSMenuItem(title: "Helper Version", action: #selector(Controller.helperVersion(_:)), keyEquivalent: "")
    item2.target = Controller.self
    menu.addItem(item2)

    let item3: NSMenuItem = NSMenuItem(title: "Create Config dir", action: #selector(Controller.createConfigDir(_:)), keyEquivalent: "")
    item3.target = Controller.self
    menu.addItem(item3)

    let item4: NSMenuItem = NSMenuItem(title: "Establish daemon", action: #selector(Controller.establishDaemon(_:)), keyEquivalent: "")
    item4.target = Controller.self
    menu.addItem(item4)

    let item5: NSMenuItem = NSMenuItem(title: "Activate daemon", action: #selector(Controller.activateDaemon(_:)), keyEquivalent: "")
    item5.target = Controller.self
    menu.addItem(item5)

    let item6: NSMenuItem = NSMenuItem(title: "Deativate daemon", action: #selector(Controller.deactivateDaemon(_:)), keyEquivalent: "")
    item6.target = Controller.self
    menu.addItem(item6)

    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    // menu.delegate = self

  }



  func test() {
    Log.debug("Refreshing...")


    //menu.removeAllItems()
    // menu.update()

    let item4: NSMenuItem = NSMenuItem(title: "One more...", action: #selector(Controller.establishDaemon(_:)), keyEquivalent: "")
    item4.target = Controller.self
    //self.menu.addItem(item4)

    Intercom.helperVersion(reply: { rawVersion in

      //menu.removeAllItems()
      //self.load()

      if (rawVersion == nil) {
        Log.debug("I miss versino or helper or what!")

        let item5: NSMenuItem = NSMenuItem(title: "Authorize...", action: #selector(Controller.authorize(_:)), keyEquivalent: "")
        item5.tag = 42
        item5.target = Controller.self
        //if (menu.item(withTag: 42) == nil) {
          Log.debug("ADDING")
          //self.menu.insertItem(item5, at: 0)
       // }


      } else {
        Log.debug("yes helper yes")

      }
      NotificationCenter.default.post(name:.menuChanged, object: nil, userInfo: nil)
    })
  }

}
