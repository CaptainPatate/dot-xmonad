{-# LANGUAGE GeneralizedNewtypeDeriving, DeriveDataTypeable #-}

import Data.Monoid
import XMonad
import XMonad.StackSet
import XMonad.Util.EZConfig
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.Util.Timer
import XMonad.Hooks.SetWMName
import Graphics.X11.Types
import Graphics.X11.ExtraTypes.XF86

newtype LockTimerIdSt = LockTimerIdSt TimerId deriving (Eq, Typeable)
instance ExtensionClass LockTimerIdSt where
  initialValue = LockTimerIdSt 0

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
         , ((mod4Mask, xK_s), toggleLock lockToggleCmd (45*60)) ]

lockToggleCmd = "xautolock -toggle"
toggleLock spawnAction delay = do
  tid <- XS.get :: X LockTimerIdSt
  if tid == initialValue then
    spawn spawnAction >> startTimer delay >>= XS.put . LockTimerIdSt
  else
    return ()
toggleLockEventHook e = do
  (LockTimerIdSt t) <- XS.get
  handleTimer t e $ do
    spawn lockToggleCmd
    XS.remove (LockTimerIdSt t)
    return Nothing
  return $ All True

winKeys = [ ((modMask, xK_y), shiftAndFollow)]

myKeys = volumeKeys ++ backlightKeys ++ mediaKeys ++ others

shiftAndFollow :: WorkspaceId -> X ()
shiftAndFollow = windows . (\i -> view i . shift i)

main = do
  xmonad $ def { modMask = mod4Mask
               , terminal = "urxvt"
               , startupHook = setWMName "LG3D"
               , handleEventHook = toggleLockEventHook
               } `additionalKeys` myKeys
