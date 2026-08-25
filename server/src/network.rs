use std::{
    io::{BufRead, BufReader},
    net::{TcpListener, UdpSocket},
    sync::mpsc::Sender,
    thread::{self, JoinHandle},
};

use crate::protocol::RemoteCommand;

const UDP_BUF_SIZE: usize = 1024;

pub fn spawn_tcp_listener(bind_addr: &'static str, tx: Sender<RemoteCommand>) -> JoinHandle<()> {
    thread::spawn(move || {
        let listener = TcpListener::bind(bind_addr).expect("Tcp socket failed to bind to address.");

        'listener_loop: for stream_result in listener.incoming() {
            let stream = match stream_result {
                Ok(s) => s,
                Err(e) => {
                    eprintln!("TCP connection failed: {e}");
                    continue;
                }
            };

            println!("Remote device connected via TCP.");

            let mut reader = BufReader::new(stream);
            let mut line = String::new();

            'inner_loop: loop {
                line.clear();

                match reader.read_line(&mut line) {
                    Ok(0) => {
                        println!("Client disconnected from TCP");
                        break;
                    }
                    Ok(_) => {
                        let message = line.trim();

                        println!("{line}");

                        if let Ok(cmd) = serde_json::from_str::<RemoteCommand>(message) {
                            let _ = tx.send(cmd);
                        }
                    }
                    Err(e) => {
                        eprintln!("Could not read line from stream: {e}");
                        break;
                    }
                }
            }
        }
    })
}

pub fn spawn_udp_listener(bind_addr: &'static str, tx: Sender<RemoteCommand>) -> JoinHandle<()> {
    thread::spawn(move || {
        let socket = UdpSocket::bind(bind_addr).expect("Failed to bind to address.");
        println!(
            "UDP socket listening on {}",
            &socket.local_addr().unwrap().to_string()
        );

        let mut buf = [0; UDP_BUF_SIZE];

        loop {
            match socket.recv_from(&mut buf) {
                Ok((num_of_bytes, src_address)) => {
                    if let Ok(message) = std::str::from_utf8(&buf[..num_of_bytes]) {
                        println!("{message}");
                        match serde_json::from_str::<RemoteCommand>(message) {
                            Ok(command) => tx.send(command).unwrap_or_else(|err| {
                                eprintln!("Could not send command to main thread.");
                            }),
                            Err(e) => {
                                eprintln!("Failed to parse JSON command: {} | Raw: {}", e, message)
                            }
                        }
                    }
                }
                Err(e) => {
                    eprintln!("Error recieving data: {}", e);
                    continue;
                }
            }
        }
    })
}
