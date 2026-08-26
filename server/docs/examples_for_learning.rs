use serde::{Deserialize, Serialize};
use std::{
    net::UdpSocket,
    sync::{Arc, Mutex, mpsc},
    thread,
    time::Duration,
};

pub fn receive_bytes_ex() {
    // env_logger::try_init().ok();

    #[cfg(target_os = "windows")]
    enigo::set_dpi_awareness().unwrap();

    let handle = thread::spawn(|| {
        let socket = UdpSocket::bind("127.0.0.1:8080").expect("Failed to bind to address");

        println!("UDP socket listening on 127.0.0.1:8080");

        let mut buf = [0; 1024];

        loop {
            match socket.recv_from(&mut buf) {
                Ok((amt, src)) => {
                    if let Ok(message) = std::str::from_utf8(&buf[..amt]) {
                        // TODO: implement a message parser
                        println!("Recieved from {}: {} ", src, message);
                    }
                }
                Err(e) => {
                    eprintln!("Error recieving data: {}", e);
                    break;
                }
            }
        }
    });

    for i in 1..=5 {
        println!("Main thread working: {}", i);
    }

    handle.join().expect("Handle thread panicked");
}

pub fn parse_json_ex() {
    let json_data = r#"
        {
            "host": "localhost",
            "port": 8080,
            "feature_enabled": true
        }
    "#;

    let config: Config = serde_json::from_str(json_data).unwrap();
    println!("Parsed config: {:?}", config);

    let my_config = Config {
        host: "127.0.0.1".to_string(),
        port: 3000,
        feature_enabled: true,
    };

    let serialized = serde_json::to_string_pretty(&my_config).unwrap();
    println!("JSON output: \n{}", serialized);
}

#[derive(Serialize, Deserialize, Debug)]
struct Config {
    host: String,
    port: u16,
    feature_enabled: bool,
}

pub fn multithreading_ex() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {i} from the spawned thread!");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("hi number {i} from the main thread!");
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();
}

pub fn channel_ex() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread"),
        ];
        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    for received in rx {
        println!("Got: {received}");
    }
}

pub fn multiple_producer_ex() {
    let (tx, rx) = mpsc::channel();

    let tx1 = tx.clone();
    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread"),
        ];

        for val in vals {
            tx1.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    thread::spawn(move || {
        let vals = vec![
            String::from("more"),
            String::from("messages"),
            String::from("for"),
            String::from("you"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    for rec in rx {
        println!("Got: {rec}");
    }
}

pub fn mutex_ex() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();

            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
