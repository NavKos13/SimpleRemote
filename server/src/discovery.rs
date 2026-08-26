use eframe::wgpu::TextureAspect::Plane1;
use mdns_sd::{ServiceDaemon, ServiceInfo};

pub fn start_mdns_broadcast(port: u16) -> ServiceDaemon {
    let mdns = ServiceDaemon::new().expect("Failed to create mDNS daemon");

    let service_type = "_simpleremote._udp.local.";
    let instance_name = "SimpleRemote_Server";
    let host_name = "simpleremote.local.";

    let my_properties: [(&str, &str); 0] = [];
    let service_info = ServiceInfo::new(
        service_type,
        instance_name,
        host_name,
        "0.0.0.0",
        port,
        &my_properties[..],
    )
    .expect("Failed to build ServiceInfo");

    mdns.register(service_info)
        .expect("Failed to register mDNS service");

    println!("Broadcasting SimpleRemote service on port {}...", port);

    mdns
}
