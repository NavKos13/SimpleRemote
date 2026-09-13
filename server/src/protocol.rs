use enigo::{Button, Direction, Key};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum RemoteCommand {
    MouseMove {
        dx: f32,
        dy: f32,
    },
    MouseClick {
        button: Button,
        direction: Direction,
    },
    MouseScroll {
        dx: f32,
        dy: f32,
    },
    TextInput {
        text: String,
    },
    SpecialKey {
        key: SpecialKey,
        direction: Direction,
    },
}

#[derive(Debug, Deserialize, Serialize)]
pub enum SpecialKey {
    Control,
    Alt,
    Shift,
    Meta,
    Backspace,
    Enter,
    Tab,
    Escape,
    Space,
    Delete,
    Home,
    End,
    PageUp,
    PageDown,
    ArrowUp,
    ArrowDown,
    ArrowLeft,
    ArrowRight,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
}

// Map to Enigo in src/executor.rs
impl From<SpecialKey> for enigo::Key {
    fn from(key: SpecialKey) -> Self {
        match key {
            SpecialKey::Control => enigo::Key::Control,
            SpecialKey::Alt => enigo::Key::Alt,
            SpecialKey::Shift => enigo::Key::Shift,
            SpecialKey::Meta => enigo::Key::Meta,
            SpecialKey::Backspace => enigo::Key::Backspace,
            SpecialKey::Enter => enigo::Key::Return,
            SpecialKey::Tab => enigo::Key::Tab,
            SpecialKey::Escape => enigo::Key::Escape,
            SpecialKey::Space => enigo::Key::Space,
            SpecialKey::Delete => enigo::Key::Delete,
            SpecialKey::Home => enigo::Key::Home,
            SpecialKey::End => enigo::Key::End,
            SpecialKey::PageUp => enigo::Key::PageUp,
            SpecialKey::PageDown => enigo::Key::PageDown,
            SpecialKey::ArrowUp => enigo::Key::UpArrow,
            SpecialKey::ArrowDown => enigo::Key::DownArrow,
            SpecialKey::ArrowLeft => enigo::Key::LeftArrow,
            SpecialKey::ArrowRight => enigo::Key::RightArrow,
            SpecialKey::F1 => enigo::Key::F1,
            SpecialKey::F2 => enigo::Key::F2,
            SpecialKey::F3 => enigo::Key::F3,
            SpecialKey::F4 => enigo::Key::F4,
            SpecialKey::F5 => enigo::Key::F5,
            SpecialKey::F6 => enigo::Key::F6,
            SpecialKey::F7 => enigo::Key::F7,
            SpecialKey::F8 => enigo::Key::F8,
            SpecialKey::F9 => enigo::Key::F9,
            SpecialKey::F10 => enigo::Key::F10,
            SpecialKey::F11 => enigo::Key::F11,
            SpecialKey::F12 => enigo::Key::F12,
        }
    }
}

pub fn print_command_examples() {
    //     let mouse_move = RemoteCommand::MouseMove {
    //         dx: 100.0,
    //         dy: 100.0,
    //     };

    //     println!(
    //         "Mouse move example: {}",
    //         serde_json::to_string::<RemoteCommand>(&mouse_move).unwrap_or_default()
    //     );

    //     let mouse_click = RemoteCommand::MouseClick {
    //         button: Button::Left,
    //         direction: Direction::Click,
    //     };

    //     println!(
    //         "Mouse click example: {}",
    //         serde_json::to_string::<RemoteCommand>(&mouse_click).unwrap_or_default()
    //     );

    //     // let key_press = RemoteCommand::SpecialKey {
    //     //     key: Key::Space,
    //     //     direction: Direction::Click,
    //     // };

    //     println!(
    //         "Key click example: {}",
    //         serde_json::to_string::<RemoteCommand>(&key_press).unwrap_or_default()
    //     )
}
