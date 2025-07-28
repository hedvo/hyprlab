#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GObject
import subprocess
import sys
import signal

class VolumeSlider(Gtk.Window):
    def __init__(self):
        super().__init__(title="Volume Control")
        self.set_decorated(False)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_type_hint(Gdk.WindowTypeHint.POPUP_MENU)
        self.set_keep_above(True)
        self.set_resizable(False)
        
        self.set_default_size(320, 120)
        
        screen = Gdk.Screen.get_default()
        screen_width = screen.get_width()
        self.move(screen_width - 340, 50)
        
        self.apply_css()
        
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(15)
        box.set_margin_bottom(15)
        box.set_margin_left(20)
        box.set_margin_right(20)
        
        self.volume_label = Gtk.Label()
        self.volume_label.set_markup("<b>🔊 Volume Control</b>")
        box.pack_start(self.volume_label, False, False, 0)
        
        self.volume_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.volume_scale.set_hexpand(True)
        self.volume_scale.set_draw_value(True)
        self.volume_scale.set_value_pos(Gtk.PositionType.RIGHT)
        
        current_volume = self.get_current_volume()
        self.volume_scale.set_value(current_volume)
        
        self.volume_scale.connect("value-changed", self.on_volume_changed)
        self.volume_scale.connect("button-release-event", self.on_slider_released)
        
        box.pack_start(self.volume_scale, True, True, 0)
        
        mute_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        
        self.mute_button = Gtk.Button()
        self.update_mute_button()
        self.mute_button.connect("clicked", self.on_mute_clicked)
        mute_box.pack_start(self.mute_button, False, False, 0)
        
        close_button = Gtk.Button.new_with_label("✕")
        close_button.connect("clicked", self.on_close_clicked)
        mute_box.pack_end(close_button, False, False, 0)
        
        box.pack_start(mute_box, False, False, 0)
        
        self.add(box)
        
        self.connect("key-press-event", self.on_key_press)
        self.connect("button-press-event", self.on_window_click)
        
        self.show_all()
        self.present()
        self.grab_focus()
        
        self.timeout_id = GObject.timeout_add_seconds(5, self.auto_close)
        
    def apply_css(self):
        css = """
        window {
            background-color: #1e1e2e;
            border: 2px solid #a6e3a1;
            border-radius: 12px;
        }
        
        label {
            color: #cdd6f4;
            font-family: "JetBrainsMono Nerd Font";
        }
        
        scale trough {
            background-color: #313244;
            border-radius: 6px;
            min-height: 8px;
        }
        
        scale highlight {
            background-color: #a6e3a1;
            border-radius: 6px;
        }
        
        scale slider {
            background-color: #a6e3a1;
            border: 2px solid #94e2d5;
            border-radius: 50%;
            min-width: 20px;
            min-height: 20px;
        }
        
        button {
            background-color: #313244;
            color: #cdd6f4;
            border: 1px solid #585b70;
            border-radius: 6px;
            padding: 8px 12px;
            font-family: "JetBrainsMono Nerd Font";
        }
        
        button:hover {
            background-color: #585b70;
        }
        """
        
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
    
    def get_current_volume(self):
        try:
            result = subprocess.run(['pactl', 'get-sink-volume', '@DEFAULT_SINK@'], 
                                  capture_output=True, text=True)
            volume_line = result.stdout.strip()
            volume = int(volume_line.split()[4].rstrip('%'))
            return volume
        except:
            return 50
    
    def is_muted(self):
        try:
            result = subprocess.run(['pactl', 'get-sink-mute', '@DEFAULT_SINK@'], 
                                  capture_output=True, text=True)
            return 'yes' in result.stdout
        except:
            return False
    
    def update_mute_button(self):
        if self.is_muted():
            self.mute_button.set_label("🔊 Unmute")
        else:
            self.mute_button.set_label("🔇 Mute")
    
    def on_volume_changed(self, scale):
        volume = int(scale.get_value())
        subprocess.run(['pactl', 'set-sink-volume', '@DEFAULT_SINK@', f'{volume}%'])
        
        self.volume_label.set_markup(f"<b>🔊 Volume: {volume}%</b>")
        
        if hasattr(self, 'timeout_id'):
            GObject.source_remove(self.timeout_id)
            self.timeout_id = GObject.timeout_add_seconds(3, self.auto_close)
    
    def on_slider_released(self, scale, event):
        volume = int(scale.get_value())
        subprocess.run(['notify-send', 'Audio', f'🔊 Volume set to {volume}%'])
    
    def on_mute_clicked(self, button):
        if self.is_muted():
            subprocess.run(['pactl', 'set-sink-mute', '@DEFAULT_SINK@', 'false'])
            subprocess.run(['notify-send', 'Audio', '🔊 Unmuted'])
        else:
            subprocess.run(['pactl', 'set-sink-mute', '@DEFAULT_SINK@', 'true'])
            subprocess.run(['notify-send', 'Audio', '🔇 Muted'])
        
        self.update_mute_button()
    
    def on_close_clicked(self, button):
        Gtk.main_quit()
    
    def auto_close(self):
        Gtk.main_quit()
        return False
    
    def on_window_click(self, widget, event):
        GObject.source_remove(self.timeout_id)
        self.timeout_id = GObject.timeout_add_seconds(5, self.auto_close)
        return False
    
    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()
        return False

def signal_handler(sig, frame):
    Gtk.main_quit()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    
    app = VolumeSlider()
    
    try:
        Gtk.main()
    except KeyboardInterrupt:
        pass