-- See https://xmonad.org/TUTORIAL.html
import XMonad

import XMonad.Actions.RotSlaves

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Loggers

import XMonad.Layout.Magnifier
import XMonad.Layout.ThreeColumns

main :: IO ()
main = xmonad
    . ewmhFullscreen 
    . ewmh 
--    . xmobarProp
    . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
    $ myConfig

myConfig = def
    { terminal = "kitty"
    , modMask = mod1Mask
    , borderWidth = 1
--    , workspaces = myWorkspaces
    , layoutHook = myLayout
    }
   `additionalKeysP`
   [ ("M-'", spawn "qutebrowser")
   , ("M-s", spawn "scrot -s")
   , ("M-a", rotAllUp)
   , ("M-f", rotAllDown)
   ]

myLayout = tiled ||| Mirror tiled ||| Full ||| threeCol
  where
    --threeCol = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    threeCol = ThreeColMid nmaster delta ratio
    tiled    = Tall nmaster delta ratio
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""

--myWorkspaces = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=" ]