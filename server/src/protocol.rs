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
    KeyPress {
        key: Key,
        direction: Direction,
    },
}

pub fn print_command_examples() {
    let mouse_move = RemoteCommand::MouseMove {
        dx: 100.0,
        dy: 100.0,
    };

    println!(
        "Mouse move example: {}",
        serde_json::to_string::<RemoteCommand>(&mouse_move).unwrap_or_default()
    );

    let mouse_click = RemoteCommand::MouseClick {
        button: Button::Left,
        direction: Direction::Click,
    };

    println!(
        "Mouse click example: {}",
        serde_json::to_string::<RemoteCommand>((&mouse_click)).unwrap_or_default()
    );

    let key_press = RemoteCommand::KeyPress {
        key: Key::Space,
        direction: Direction::Click,
    };

    println!(
        "Key click example: {}",
        serde_json::to_string::<RemoteCommand>(&key_press).unwrap_or_default()
    )
}
