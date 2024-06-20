;; -*-lisp-*-
;;
;; Miro's StumpWM init.el

(in-package :stumpwm)

(ql:quickload :clx-truetype)
(load-module "ttf-fonts")

(set-prefix-key (kbd "C-z"))

(setf *startup-message* "^5    Stump Window Manager ^0has initialized!
Press ^2Ctrl+z ? ^0for Help. ^5Never Stop Hacking!^n
          Powered with ^02 Common Lisp ")

;; prompt the user for an interactive command. The first arg is an
;; optional initial contents.
(defcommand colon1 (&optional (initial "")) (:rest)
  (let ((cmd (read-one-line (current-screen) ": " :initial-input initial)))
    (when cmd
      (eval-command cmd t))))

;; fix colors in quit message
(defcommand quit-confirm () ()
  "Prompt the user to confirm quitting StumpWM."
  (if (y-or-n-p (format nil "~@{~a~^~%~}"
			"You are about to quit the window manager."
			"         Really ^2quit^n ^4StumpWM^n?"
			"^5           Confirm?^n "))
      (quit)
      (xlib:unmap-window (screen-message-window (current-screen)))))

(defcommand suspend-confirm () ()
  "Prompt the user to confirm suspending."
  (if (y-or-n-p (format nil "~@{~a~^~%~}"
			"You are about to suspend your system."
			"          Really ^2suspend^n?"
			"^5         Confirm?^n "))
      (run-shell-command "systemctl suspend")
      (xlib:unmap-window (screen-message-window (current-screen)))))

(defcommand shutdown-confirm () ()
  "Prompt the user to confirm shutdown."
  (if (y-or-n-p (format nil "~@{~a~^~%~}"
			"You are about to halt your system."
			"        Really ^2shutdown^n?"
			"^5       Confirm?^n "))
      (run-shell-command "systemctl poweroff")
      (xlib:unmap-window (screen-message-window (current-screen)))))

(defcommand reboot-confirm () ()
  "Prompt the user to confirm rebooting."
  (if (y-or-n-p (format nil "~@{~a~^~%~}"
			"You are about to reboot your system."
			"           Really ^2reboot^n?"
			"^5          Confirm?^n "))
      (run-shell-command "systemctl reboot")
      (xlib:unmap-window (screen-message-window (current-screen)))))

(defcommand stump-screenshot () ()
  (run-shell-command "exec scrot")
  (sleep 0.5)
  (message "Screenshot taken!"))

(define-key *root-map* (kbd "C-p") "exec i3lock-fancy")
(define-key *root-map* (kbd "C-s") "suspend-confirm")
(define-key *root-map* (kbd "C-q") "shutdown-confirm")
(define-key *root-map* (kbd "C-r") "reboot-confirm")
(define-key *root-map* (kbd "C-e") "exec emacsclient -c")
(define-key *root-map* (kbd "C-c") "exec emacsclient --eval '(vterm)' -c")
(define-key *root-map* (kbd "C-f") "float-this")
(define-key *root-map* (kbd "C-u") "unfloat-this")
(define-key *root-map* (kbd ".") "gnext")
(define-key *root-map* (kbd ",") "gprev")
(define-key *root-map* (kbd "s-Right") "gnext-with-window")
(define-key *root-map* (kbd "s-Left") "gprev-with-window")
(define-key *top-map* (kbd "Print") "stump-screenshot")
(define-key *top-map* (kbd "C-Print") "exec flameshot gui")
(define-key *top-map* (kbd "M-1") "gselect 1")
(define-key *top-map* (kbd "M-2") "gselect 2")
(define-key *top-map* (kbd "M-3") "gselect 3")
(define-key *top-map* (kbd "M-4") "gselect 4")
(define-key *top-map* (kbd "M-5") "gselect 5")
(define-key *top-map* (kbd "M-6") "gselect 6")
(define-key *top-map* (kbd "M-7") "gselect 7")
(define-key *top-map* (kbd "M-8") "gselect 8")
(define-key *top-map* (kbd "M-9") "gselect 9")
(define-key *top-map* (kbd "XF86AudioPlay") "exec mpc toggle")
(define-key *top-map* (kbd "XF86AudioStop") "exec mpc stop")
(define-key *top-map* (kbd "XF86AudioPrev") "exec mpc prev")
(define-key *top-map* (kbd "XF86AudioNext") "exec mpc next")
(define-key *top-map* (kbd "XF86AudioRaiseVolume") "exec pamixer -i 2")
(define-key *top-map* (kbd "XF86AudioLowerVolume") "exec pamixer -d 2")
(define-key *top-map* (kbd "XF86AudioMute") "exec pamixer -t")

;; Web jump (works for DuckDuckGo and Imdb)
(defmacro make-web-jump (name prefix)
  `(defcommand ,(intern name) (search) ((:rest ,(concatenate 'string name " search: ")))
    (nsubstitute #\+ #\Space search)
    (run-shell-command (concatenate 'string ,prefix search))))

(make-web-jump "duckduckgo" "firefox https://duckduckgo.com/?q=")
(define-key *root-map* (kbd "M-s") "duckduckgo")

(set-font (list
	   (make-instance 'xft:font
			  :family "Go Mono"
			  :subfamily "Regular"
			  :size 10)
	   (make-instance 'xft:font
			  :family "Go Mono"
			  :subfamily "Bold"
			  :size 10)))

(clear-window-placement-rules)

;;(setf (group-name (car (screen-groups (current-screen)))) "1")
;;(loop for n from 2 to 8
;;      do (gnewbg (format nil "~A" n)))
;;(gnewbg-float "9")

(grename "Main")
(gnewbg "Code")
(gnewbg "Misc")
(gnewbg "Web")
(gnewbg "Virt")
(gnewbg-float "Float")
;(gnewbg ".scratchpad") ; hidden group / scratchpad

(setf *colors*
      '("#cbd2df"        ; ^0 ; White
	"#222226"        ; ^1 : Background
	"#f72f33"        ; ^2 ; Red
	"#689d6a"        ; ^3 ; Light Green
	"#62bfef"        ; ^4 ; Light Blue
        "#fabd2f"        ; ^5 ; Yellow / Help map keys
	"#5D4D7A"        ; ^6 ; Purple
	"#BC6EC5"        ; ^7 ; Magenta
	"#8b929f"))      ; ^8 ; Gray

(update-color-map (current-screen))
(defparameter *fg-color* (nth 0 *colors*))
(defparameter *bg-color* (nth 1 *colors*))
(defparameter *border-color* (nth 6 *colors*))
(defparameter *focus-color* (nth 6 *colors*))

(setf *timeout-wait* 7)
(setf *ignore-wm-inc-hints* t)
(setf *window-format* "%n%s%25t")
(setf *mouse-focus-policy* :click)
(setf *message-window-gravity* :center)
(setf *input-window-gravity* :center)
(set-bg-color *bg-color*)
(set-fg-color *fg-color*)
(set-border-color *border-color*)
(set-focus-color *focus-color*)
(set-msg-border-width 1)
(setf *message-window-padding* 6)

;; autostart applications
(mapc #'run-shell-command
      '("mpd"
	"emacs --daemon"
	"/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
	"xfce4-power-manager"
	"xss-lock --transfer-sleep-lock -- i3lock-fancy --nofork"
	"xautolock -time 10 -locker 'i3lock-fancy'"
	"dunst -conf ~/.config/dunst/dunstrc"
	"nvidia-settings -l"
	"feh --bg-scale ~/Pictures/wallpaper.png"
;;	"picom"
;;	"nm-applet"
;;	"volumeicon"
))

(load-module "cpu")
(load-module "mem")
(load-module "mpd")
(load-module "net")

(require :swank)
(swank-loader:init)

(defparameter *port-number* 4004
  "My default port number for Swank")

(defvar *swank-server-p* nil
  "Keep track of swank server, turned off by default on startup")

(defcommand start-swank () ()
  "Start Swank if it is not already running"
  (if *swank-server-p*
      (message "Swank server is already active on Port^5 ~a^n" *port-number*)
      (progn
	(swank:create-server :port *port-number*
			     :style swank:*communication-style*
			     :dont-close t)
	(setf *swank-server-p* t)
	(message "Swank server is now active on Port^5 ~a^n.
Use^4 M-x slime-connect^n in Emacs.
Type^2 (in-package :stumpwm)^n in Slime REPL." *port-number*))))

(defcommand stop-swank () ()
  "Stop Swank"
  (swank:stop-server *port-number*)
  (setf *swank-server-p* nil)
  (message "Stopping Swank Server! Closing Port^5 ~a^n." *port-number*))

(defcommand toggle-swank () ()
  (if *swank-server-p*
      (run-commands "stop-swank")
      (run-commands "start-swank")))

(define-key *top-map* (kbd "s-s") "toggle-swank")

;; modeline status
(defun get-swank-status ()
  (if *swank-server-p*
      (setf *swank-ml-status* (format nil "^f0^2Swank Port: ~a^n" *port-number*))
      (setf *swank-ml-status* (format nil "^f0^8Swank Port: ~a^n" *port-number*))))

(defun ml-fmt-swank-status (ml)
  (declare (ignore ml))
  (get-swank-status))

(add-screen-mode-line-formatter #\S #'ml-fmt-swank-status)

(setf *mode-line-timeout* 2)
(setf *mode-line-border-width* 1)
(setf *mode-line-pad-y* 0)

(setf *mode-line-background-color* *bg-color*)
(setf *mode-line-border-color* *border-color*)
(setf *mode-line-foreground-color* *fg-color*)

(setf *time-modeline-string* "%a %b %d^f0 %T^n")

(setf cpu::*cpu-modeline-fmt* "%c")
(setf cpu::*cpu-usage-modeline-fmt* "^f1Cpu: ^f0^[~A~2D%^]")

(setf mem::*mem-modeline-fmt* "^f1Mem: ^f0%a")

(setf mpd:*mpd-modeline-fmt* "^f1%a:^f0 %t")
(setf mpd:*mpd-status-fmt* "^f1%a:^f0 %t")

(setf *mode-line-highlight-template* "^f1^01~A^f0^81")

(setf net:*net-modeline-fmt* "^f1Net:^f0%u")

(defparameter *hostname*
  (with-output-to-string (out)
    (uiop:run-program "hostname" :output out)))

(defparameter *username*
  (with-output-to-string (out)
    (uiop:run-program "whoami" :output out)))

(defparameter *kernel-name*
  (with-output-to-string (out)
    (uiop:run-program "uname -s" :output out)))

(defparameter *kernel-version*
  (with-output-to-string (out)
    (uiop:run-program "uname -r" :output out)))

(defparameter *volume-level*
  (with-output-to-string (out)
    (uiop:run-program "amixer get Master | grep 'Front Left' | grep -o '[0-9]*%'" :output out)))

(setf *screen-mode-line-format*
      (list "^f1^7"
	    (remove #\newline *username*)
	    "@"
	    (remove #\newline *hostname*)
	    "^f0^n "
	    "^f0^8[%g]^n"   ; groups
	    "^f0^8(%W)^n"   ; windows
	    "^>"            ; right align
	    "^f0%m ^8^n"    ; mpd
	    "^f1"
	    (remove #\newline *kernel-name*)
	    ": ^f0"
	    (remove #\newline *kernel-version*)
	    "^f0 "
	    "^f0%C ^8^n"    ; cpu
	    "^f0%M ^8^n"    ; mem
	    "^f1Vol:^f0 "
	    (remove #\newline *volume-level*)
	    " "
	    "%l "
	    "^f1%d^f0"      ; time/date
            "^8^n ^f1%S"    ; swank status
;;	    "  %T"          ; stumptray
))

;; turn on the mode line
(if (not (head-mode-line (current-head)))
    (toggle-mode-line (current-screen) (current-head)))

;; overrides StumpWM default behavior of dimming normal colors
(defun update-color-map (screen)
  "Read *colors* and cache their pixel colors for use when rendering colored text."
  (labels ((map-colors (amt)
	     (loop for c in *colors*
		   as color = (lookup-color screen c)
		   do (adjust-color color amt)
		   collect (alloc-color screen color))))
    (setf (screen-color-map-normal screen) (apply #'vector (map-colors 0.00)))))

(update-color-map (current-screen))

;; StumpWM by default treats horizontal and vertical splits as Emacs does.
;; Horizontal splits the current frame into 2 side-by-side frames and Vertical
;; splits the current frame into 2 frames, one on top of the other.
;; I reverse this behavior in my configuration.
(defcommand (vsplit tile-group) (&optional (ratio "1/2")) (:string)
  "Split the current frame into 2 side-by-side frames."
  (split-frame-in-dir (current-group) :column (read-from-string ratio)))
(defcommand (hsplit tile-group) (&optional (ratio "1/2")) (:string)
  "Split the current frame into 2 frames, one on top of the other."
  (split-frame-in-dir (current-group) :row (read-from-string ratio)))

(undefine-key *tile-group-root-map* (kbd "S"))
(undefine-key *tile-group-root-map* (kbd "s"))
(define-key *root-map* (kbd "s") "vsplit")
(define-key *root-map* (kbd "S") "hsplit")

(defcommand (vsplit-equally tile-group) (amt)
  ((:number "Enter the number of frames: "))
  "Split current frame in n columns of equal size."
  (split-frame-eql-parts (current-group) :column amt))

(defcommand (hsplit-equally tile-group) (amt)
  ((:number "Enter the number of frames: "))
  "Split current frame in n rows of equal size."
  (split-frame-eql-parts (current-group) :row amt))

(mpd::mpd-connect)
;;(load-module "stumptray")
;;(stumptray::stumptray)
