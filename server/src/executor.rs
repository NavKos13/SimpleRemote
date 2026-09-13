use crate::protocol::*;
use enigo::*;

pub struct InputExecutor {
    enigo: Enigo,
}

impl InputExecutor {
    pub fn new() -> Self {
        let enigo = Enigo::new(&Settings::default()).expect("Failed to init Enigo");
        Self { enigo }
    }

    pub fn execute(&mut self, command: RemoteCommand) {
        match command {
            RemoteCommand::MouseMove { dx, dy } => {
                self.enigo
                    .move_mouse(dx as i32, dy as i32, Coordinate::Rel)
                    .unwrap_or_else(|err| eprintln!("Could not process mouse move command: {err}"));
            }
            RemoteCommand::MouseClick { button, direction } => {
                self.enigo.button(button, direction).unwrap_or_else(|err| {
                    eprintln!("Could not process mouse click command: {err}")
                });
            }
            RemoteCommand::MouseScroll { dx, dy } => {
                self.enigo.scroll(dy as i32, Axis::Vertical);
                self.enigo.scroll(dx as i32, Axis::Horizontal);
            }
            RemoteCommand::SpecialKey { key, direction } => {
                self.enigo
                    .key(enigo::Key::from(key), direction)
                    .unwrap_or_else(|err| {
                        eprintln!("Could not process special key press command: {err}")
                    });
            }
            RemoteCommand::TextInput { text } => {
                if text.chars().count() == 1 {
                    let c = text.chars().next().unwrap();

                    // Check if the character is safe to use with modifier keys (eg. Ctrl+c, Alt+c)
                    let is_base_key =
                        c.is_ascii_lowercase() || c.is_ascii_digit() || "`-=[]\\;',./".contains(c);

                    if is_base_key {
                        self.enigo
                            .key(enigo::Key::Unicode(c), enigo::Direction::Click)
                            .unwrap_or_else(|err| {
                                eprintln!("Could not process key press command: {err}")
                            })
                    } else {
                        self.enigo.text(&text).unwrap_or_else(|err| {
                            eprintln!("Could not process key press command: {err}")
                        });
                    }
                } else {
                    self.enigo.text(&text).unwrap_or_else(|err| {
                        eprintln!("Could not process text input command: {err}")
                    })
                }
            }
        }
    }
}

impl Default for InputExecutor {
    fn default() -> Self {
        Self::new()
    }
}
