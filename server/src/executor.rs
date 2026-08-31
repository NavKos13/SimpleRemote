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
            RemoteCommand::KeyPress { key, direction } => {
                self.enigo
                    .key(key, direction)
                    .unwrap_or_else(|err| eprintln!("Could not process key press command: {err}"));
            }
            RemoteCommand::MouseScroll { dx, dy } => {
                self.enigo.scroll(dy as i32, Axis::Vertical);
                self.enigo.scroll(dx as i32, Axis::Horizontal);
            }
        }
    }
}

impl Default for InputExecutor {
    fn default() -> Self {
        Self::new()
    }
}
