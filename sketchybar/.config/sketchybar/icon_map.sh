#!/usr/bin/env bash

function icon_map() {
    case "$1" in
   "Live")
        icon_result=""  # :ableton:
        ;;
   "Activity Monitor")
        icon_result=""  # :activity_monitor:
        ;;
   "Adobe Bridge"*)
        icon_result=""  # :adobe_bridge:
        ;;
   "Affinity Designer")
        icon_result=""  # :affinity_designer:
        ;;
   "Affinity Designer 2")
        icon_result=""  # :affinity_designer_2:
        ;;
   "Affinity Photo")
        icon_result=""  # :affinity_photo:
        ;;
   "Affinity Photo 2")
        icon_result=""  # :affinity_photo_2:
        ;;
   "Affinity Publisher")
        icon_result=""  # :affinity_publisher:
        ;;
   "Affinity Publisher 2")
        icon_result=""  # :affinity_publisher_2:
        ;;
   "Airmail")
        icon_result=""  # :airmail:
        ;;
   "Alacritty")
        icon_result=""  # :alacritty:
        ;;
   "Alfred")
        icon_result=""  # :alfred:
        ;;
   "Android Messages")
        icon_result=""  # :android_messages:
        ;;
   "Android Studio")
        icon_result=""  # :android_studio:
        ;;
   "Anki")
        icon_result=""  # :anki:
        ;;
   "Anytype")
        icon_result=""  # :anytype:
        ;;
   "App Eraser")
        icon_result=""  # :app_eraser:
        ;;
   "App Store")
        icon_result=""  # :app_store:
        ;;
   "Arc")
        icon_result="請"  # :arc:
        ;;
   "Arduino" | "Arduino IDE")
        icon_result=""  # :arduino:
        ;;
   "Atom")
        icon_result=""  # :atom:
        ;;
   "Audacity")
        icon_result=""  # :audacity:
        ;;
   "Bambu Studio")
        icon_result=""  # :bambu_studio:
        ;;
   "MoneyMoney")
        icon_result=""  # :bank:
        ;;
   "Battle.net")
        icon_result=""  # :battle_net:
        ;;
   "Bear")
        icon_result=""  # :bear:
        ;;
   "BetterTouchTool")
        icon_result=""  # :bettertouchtool:
        ;;
   "Bilibili" | "哔哩哔哩")
        icon_result=""  # :bilibili:
        ;;
   "Bitwarden")
        icon_result=""  # :bit_warden:
        ;;
   "Blender")
        icon_result=""  # :blender:
        ;;
   "BluOS Controller")
        icon_result=""  # :bluos_controller:
        ;;
   "Calibre")
        icon_result=""  # :book:
        ;;
   "Brave Browser")
        icon_result=""  # :brave_browser:
        ;;
   "BusyCal")
        icon_result=""  # :busycal:
        ;;
   "Calculator" | "Calculette")
        icon_result=""  # :calculator:
        ;;
   "Calendar" | "日历" | "Fantastical" | "Cron" | "Amie" | "Calendrier" | "カレンダー" | "Notion Calendar")
        icon_result=""  # :calendar:
        ;;
   "calibre")
        icon_result=""  # :calibre:
        ;;
   "Caprine")
        icon_result="蝹"  # :caprine:
        ;;
   "Amazon Chime")
        icon_result=""  # :chime:
        ;;
   "Citrix Workspace" | "Citrix Viewer")
        icon_result=""  # :citrix:
        ;;
   "Claude")
        icon_result="🅒"  # :claude:
        ;;
   "ClickUp")
        icon_result="🅒"  # :click_up:
        ;;
   "Code" | "Code - Insiders")
        icon_result=""  # :code:
        ;;
   "Cold Turkey Blocker")
        icon_result="🦃"  # :cold_turkey_blocker:
        ;;
   "Color Picker" | "数码测色计")
        icon_result="🎨"  # :color_picker:
        ;;
   "Copilot")
        icon_result="🤖"  # :copilot:
        ;;
   "CotEditor")
        icon_result=""  # :coteditor:
        ;;
   "Creative Cloud")
        icon_result="🅲"  # :creative_cloud:
        ;;
   "Cursor")
        icon_result="⭘"  # :cursor:
        ;;
   "Cypress")
        icon_result="🌀"  # :cypress:
        ;;
   "DataGrip")
        icon_result="⚙️"  # :datagrip:
        ;;
   "DBeaver")
        icon_result="⚙️"  # :dbeaver:
        ;;
   "Default")
        icon_result=""  # :default:
        ;;
   "Discord" | "Discord Canary" | "Discord PTB")
        icon_result="🎮"  # :discord:
        ;;
   "Docker" | "Docker Desktop")
        icon_result="🐳"  # :docker:
        ;;
   "Drafts")
        icon_result="📝"  # :drafts:
        ;;
   "draw.io")
        icon_result="🔲"  # :draw_io:
        ;;
   "Dropbox")
        icon_result="📂"  # :dropbox:
        ;;
   "Emacs")
        icon_result="🅴"  # :emacs:
        ;;
   "Finder" | "访达")
        icon_result="🧭"  # :finder:
        ;;
   "Firefox")
        icon_result="🦊"  # :firefox:
        ;;
   "Firefox Developer Edition" | "Firefox Nightly")
        icon_result="🦊"  # :firefox_developer_edition:
        ;;
   "FreeTube")
        icon_result="🎬"  # :freetube:
        ;;
   "Fusion")
        icon_result="🌀"  # :fusion:
        ;;
   "System Preferences" | "System Settings" | "系统设置" | "Réglages Système" | "システム設定")
        icon_result="⚙️"  # :gear:
        ;;
   "Ghostty")
        icon_result="👻"  # :ghostty:
        ;;
   "Chromium" | "Google Chrome" | "Google Chrome Canary")
        icon_result=""  # :google_chrome:
        ;;
   "IntelliJ IDEA")
        icon_result=""  # :idea:
        ;;
   "Insomnia")
        icon_result="😴"  # :insomnia:
        ;;
   "iPhone Mirroring")
        icon_result="📱"  # :iphone_mirroring:
        ;;
   "iTerm2")
        icon_result=""  # :iterm:
        ;;
   "JDownloader")
        icon_result="🔽"  # :jdownloader:
        ;;
   "Jitsi Meet")
        icon_result="🟣"  # :jitsi:
        ;;
   "JetBrains Toolbox")
        icon_result="🔧"  # :jet_brains_toolbox:
        ;;
   "Kap")
        icon_result="🎥"  # :kap:
        ;;
   "Keynote")
        icon_result="📽"  # :keynote:
        ;;
   "Krita")
        icon_result="🖍"  # :krita:
        ;;
   "LastPass")
        icon_result="🔑"  # :lastpass:
        ;;
   "Luna Display")
        icon_result="🌙"  # :luna_display:
        ;;
   "Mail")
        icon_result="📧"  # :mail:
        ;;
   "Mark Text")
        icon_result="📝"  # :mark_text:
        ;;
   "Mastodon")
        icon_result="🦣"  # :mastodon:
        ;;
   "Microsoft Office")
        icon_result="📊"  # :microsoft_office:
        ;;
   "Minecraft")
        icon_result="⛏"  # :minecraft:
        ;;
   "Notion")
        icon_result="📝"  # :notion:
        ;;
   "OmniFocus")
        icon_result="🔨"  # :omnifocus:
        ;;
   "OnlyOffice")
        icon_result="📂"  # :onlyoffice:
        ;;
   "OpenToonz")
        icon_result="🎞"  # :opentoonz:
        ;;
   "Opera")
        icon_result=""  # :opera:
        ;;
   "PDF Expert")
        icon_result="📚"  # :pdf_expert:
        ;;
   "Postman")
        icon_result="📧"  # :postman:
        ;;
   "Preview" | "预览")
        icon_result="👁"  # :preview:
        ;;
   "QuickTime Player")
        icon_result="⏯"  # :quicktime:
        ;;
   "RStudio")
        icon_result="🖥"  # :rstudio:
        ;;
   "Sublime Text")
        icon_result=""  # :sublime_text:
        ;;
   "Skype")
        icon_result="📞"  # :skype:
        ;;
   "Slack")
        icon_result="🛠"  # :slack:
        ;;
   "Spotify")
        icon_result=""  # :spotify:
        ;;
   "Steam")
        icon_result="🎮"  # :steam:
        ;;
   "System Preferences")
        icon_result="⚙️"  # :system_preferences:
        ;;
   "Telegram")
        icon_result="📱"  # :telegram:
        ;;
   "The Unarchiver")
        icon_result="📂"  # :unarchiver:
        ;;
   "Trello")
        icon_result="📋"  # :trello:
        ;;
   "VLC")
        icon_result="📽"  # :vlc:
        ;;
   "Visual Studio")
        icon_result="💻"  # :visual_studio:
        ;;
   "Visual Studio Code")
        icon_result="🔲"  # :vs_code:
        ;;
   "WeChat")
        icon_result="🧧"  # :wechat:
        ;;
   "WhatsApp")
        icon_result="💬"  # :whatsapp:
        ;;
   "Wireshark")
        icon_result="📡"  # :wireshark:
        ;;
   "Zoom")
        icon_result="🎥"  # :zoom:
        ;;
   *)
        icon_result="🖥"  # Default icon
        ;;
    esac
    echo "$icon_result"
}

icon_map "$1"