node.default["mouse_locator_download_uri"]="http://homepage.mac.com/douglasn/MouseLocator.dmg"
node.default["mouse_locator_dmg_mnt"]="/Volumes/Mouse Locator v1.1"
node.default["mouse_locator_src"]="#{node['mouse_locator_dmg_mnt']}/Mouse Locator v1.1 Installer.app/Contents/Resources/Distribution/MouseLocator.prefPane"
node.default["mouse_locator_dst"]="#{ENV['HOME']}/Library/PreferencePanes/MouseLocator.prefPane"
node.default["mouse_locator_app"]="#{node['mouse_locator_dst']}/Contents/Resources/MouseLocatorAgent.app"
