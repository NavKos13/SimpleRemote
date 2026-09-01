#![allow(unused)]
use enigo::*;
use std::{
    io::{BufRead, BufReader, Error, Read},
    net::{SocketAddr, TcpListener, TcpStream, UdpSocket},
    sync::mpsc,
    thread,
};

use serde::{Deserialize, Serialize};

pub mod discovery;
pub mod executor;
pub mod network;
pub mod protocol;
pub mod ui;

use executor::InputExecutor;
use protocol::{RemoteCommand, print_command_examples};

const SERVER_IP: &str = "0.0.0.0:8080";
const SERVER_PORT: u16 = 8080;

fn main() {
    enigo::set_dpi_awareness().unwrap();

    let _mdns_daemon = discovery::start_mdns_broadcast(SERVER_PORT);

    let mut executor = executor::InputExecutor::new();

    let (tx, rx) = mpsc::channel();

    // TCP THREAD
    let tcp_handle = network::spawn_tcp_listener(SERVER_IP, tx.clone());

    // UDP THREAD
    let udp_handle = network::spawn_udp_listener(SERVER_IP, tx);

    println!("Server listening for commands...");
    for command in rx {
        executor.execute(command);
    }
}
