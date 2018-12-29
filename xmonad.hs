import DBus.Client
import Graphics.X11.Types
import Graphics.X11.ExtraTypes.XF86
import System.Taffybar.XMonadLog ( dbusLog )
import XMonad
import XMonad.Actions.CycleWindows
import XMonad.Actions.GroupNavigation
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout
import XMonad.Layout.Maximize
import XMonad.Util.EZConfig

volumeKeys = [ ((noModMask, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +1.5%")
             , ((noModMask, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -1.5%")
             , ((shiftMask, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +5%")
             , ((shiftMask, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -5%")
              , ((noModMask, xF86XK_AudioMute), spawn "pactl set-sink-mute 0 toggle")]
backlightKeys = [ ((noModMask, xF86XK_MonBrightnessDown), spawn "bash -lc dec_backlight")
                , ((noModMask, xF86XK_MonBrightnessUp), spawn "bash -lc inc_backlight")]
mediaKeys = [ ((noModMask, xF86XK_Tools), spawn "xdotool key XF86AudioPlay")
            , ((noModMask, xF86XK_LaunchA), spawn "xdotool key XF86AudioNext")
            , ((noModMask, xF86XK_Search), spawn "xdotool key XF86AudioPrev")]
others = [ ((noModMask, xK_Print), spawn "sleep 0.2; scrot -s -e 'xclip -t image/png -selection clipboard $f && rm -f $f'")
         , ((shiftMask, xF86XK_MonBrightnessUp), spawn "pkill -USR1 redshift")
         , ((mod4Mask, xK_F7), spawn "slock")
         , ((mod4Mask .|. shiftMask, xK_F7), spawn "slock systemctl suspend")
         , ((mod4Mask, xK_f), withFocused (sendMessage . maximizeRestore))]

cycleWindows = [ ((mod4Mask .|. controlMask, xK_k), cycleRecentWindows [xK_Super_L, xK_Control_L] xK_k xK_k) ]

historyKeys = [ ((mod1Mask, xK_Tab), nextMatch History (return True))]

myKeys = volumeKeys ++ backlightKeys ++ mediaKeys ++ others ++ historyKeys ++ cycleWindows

maximizedDefaultLayout = maximize(tiled) ||| maximize(Mirror tiled) ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

main = do
  client <- connectSession
  xmonad $ def { logHook = dbusLog client >> historyHook
               , manageHook = manageDocks
               , modMask = mod4Mask
               , terminal = "xterm"
               , startupHook = setWMName "LG3D"
               , layoutHook = maximizedDefaultLayout
               } `additionalKeys` myKeys
