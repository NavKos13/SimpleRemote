#![allow(unused)]
use enigo::*;
use std::{
    io::{BufRead, BufReader, Error, Read},
    net::{TcpListener, TcpStream, UdpSocket},
    sync::mpsc,
    thread,
};

use eframe::{App, NativeOptions, egui::CentralPanel, run_native};

use serde::{Deserialize, Serialize};

use server::examples_for_learning::*;
use server::executor::*;
use server::protocol::*;

struct SimpleRemoteServer;

impl App for SimpleRemoteServer {
    fn ui(&mut self, ui: &mut eframe::egui::Ui, frame: &mut eframe::Frame) {
        CentralPanel::default().show(ui, |ui| {
            ui.heading("Hello from SimpleRemote Server!");
        });
    }
}

fn main() {
    // let app = SimpleRemoteServer;
    // let window_options = NativeOptions::default();
    // run_native("SimpleRemote Server", window_options, Box::new(app));
    core_loop();
}

fn core_loop() {
    print_command_examples();
    enigo::set_dpi_awareness().unwrap();

    let mut executor = InputExecutor::new();

    let (tx, rx) = mpsc::channel();
    let tcp_tx = tx.clone();

    let tcp_handle = thread::spawn(move || {
        let listener =
            TcpListener::bind("127.0.0.1:8080").expect("Tcp socket failed to bind to address.");

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
                            let _ = tcp_tx.send(cmd);
                        }
                    }
                    Err(e) => {
                        eprintln!("Could not read line from stream: {e}");
                        break;
                    }
                }
            }
        }
    });

    let udp_tx = tx.clone();
    let udp_handle = thread::spawn(move || {
        let socket = UdpSocket::bind("127.0.0.1:8080").expect("Failed to bind to address.");
        println!("UDP socket listening on 127.0.0.1:8080");

        let mut buf = [0; 1024];

        loop {
            match socket.recv_from(&mut buf) {
                Ok((num_of_bytes, src_address)) => {
                    if let Ok(message) = std::str::from_utf8(&buf[..num_of_bytes]) {
                        println!("{message}");
                        match serde_json::from_str::<RemoteCommand>(message) {
                            Ok(command) => udp_tx.send(command).unwrap_or_else(|err| {
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
    });

    println!("Server listening for commands...");

    for command in rx {
        executor.execute(command);
    }
}
