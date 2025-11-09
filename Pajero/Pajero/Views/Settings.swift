import SwiftUI
import CoreData

import SwiftUI

// Add this struct to your file
struct AppIconPicker: View {
    let icons = ["defaultIcon", "Mitsubishi", "Toyota", "GreenIcon"]
    @State private var selectedIcon = UIApplication.shared.alternateIconName ?? "AppIcon"
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(icons, id: \.self) { icon in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedIcon == icon ? Color.blue : Color.clear, lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedIcon == icon ? Color.blue.opacity(0.1) : Color.clear)
                                )
                                .frame(width: 70, height: 70)
                            
                            Image(icon == "AppIcon" ? "AppIcon60x60" : icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                        }
                        
                        Text(icon.replacingOccurrences(of: "Icon", with: ""))
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 70)
                    .onTapGesture {
                        changeAppIcon(to: icon)
                    }
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
        }
        .frame(height: 110)
    }
    
    private func changeAppIcon(to iconName: String) {
        let name = iconName == "AppIcon" ? nil : iconName
        
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error = error {
                print("Error changing app icon: \(error.localizedDescription)")
            } else {
                print("Successfully changed app icon to \(iconName)")
                self.selectedIcon = iconName
            }
        }
    }
}

struct Settings: View {
    @Environment(\.dismiss) private var dismiss
    @State private var headunit = true
    @State private var turnonalarm = true
    @State private var ShowNetInfo: Bool
    @State private var ShowCamera: Bool
    @State private var nearbycentralcontrol = true
    @State private var alarmusernotify = false
    @State private var serverAddress = "192.168.1.1"
    let context = CoreDataStack.shared.viewContext
    
    
    init() {
        let fetchRequest: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        if let settings = try? context.fetch(fetchRequest).first {
            _ShowNetInfo = State(initialValue: settings.showltestat)
            _ShowCamera = State(initialValue: settings.showcamera)
        } else {
            _ShowCamera = State(initialValue: false)
            _ShowNetInfo = State(initialValue: false)
        }
    }
    
    
    var body: some View {
        Group {
                mainView
        }.onAppear {
            fetchSettings()
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AppSettings")
            do {
                let settings = try context.fetch(fetchRequest)
                print(settings)
                // Use 'tasks' array to work with fetched data
            } catch {
                print("Error fetching tasks: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchSettings() {
        //lanurl+
        var request = URLRequest(url: URL(string: "/api/fetchsettings")!)
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
            
        // Add authkey to form data
        let authkey = "817jACz@!*@9idnaCADlCOK237%@f^!7dDA2@d@dDACd6^c&VG*"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"authkey\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(authkey)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error took place \(error.localizedDescription)")
                if(error.localizedDescription.contains("Could not connect to the server")){
                    //   return "Cloud Connection - LTE"
                    //retry the attemp with cloud server
                }
                //  return error
            }
            
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(VehicleResponse.self, from: data)
                print("Received response: \(response)")
                
            } catch {
                print("Decoding error: \(error)")
            }
            
        }.resume()
    }
    
    private var mainView: some View {
        NavigationStack {
            List {
                Section("Server Connection") {
//                    HStack(spacing: 12) {
//                        Image(systemName: "wifi")
//                            .imageScale(.medium)
//                            .frame(width: 24, height: 24)
//                            .foregroundStyle(.blue)
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Wi-Fi SSID")
//                                .font(.body)
//                            Text(Helper.shared.getWiFiSSID() ?? "Not Connected")
//                                .font(.body.monospaced())
//                            
//                        }
//                        
//                    }
                    HStack(spacing: 12) {
                       
                        Image(systemName: "network")
                            .imageScale(.medium)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Server IP Address")
                                .font(.body)
                            
                            TextField("192.168.1.1", text: $serverAddress)
                                .keyboardType(.decimalPad)
                                .font(.body.monospaced())
                            
                        }
                        
                        
                    }
                    Button {
                                  } label: {
                        HStack(spacing: 12) {
                                 // Error handling usage
                            if(Helper.shared.checkVPNStatus() ?? false){
                                Image(systemName: "network.badge.shield.half.filled")
                                Text("Set for VPN connection")
                            }else{
                                switch Helper.shared.getWiFiSSIDWithError() {
                                case .success(let ssid):
                                    Image(systemName: "wifi")
                                    Text("Set for WiFi '\(ssid)'")
                                case .failure(let error):
                                    Image(systemName: "wifi")
                                    Text("Set Network Settings")
                                }
                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Button {
                        if let url = URL(string: "https://remotecar.app/") {
                               UIApplication.shared.open(url)
                           }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "link")
                            Text("Setup a server")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                   
                }
                
                
                Section("App Appearance") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "app.badge")
                                .imageScale(.medium)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.blue)
                            
                            Text("App Icon")
                                .font(.body)
                        }
                        AppIconPicker()
                    }
                }
                
                Section("General Settings") {
                    SettingToggleRow(
                        icon: "antenna.radiowaves.left.and.right",
                        title: "Show network info",
                        subtitle: "LTE signal, data usage, etc",
                        onChange: {
                            saveSettings(keyPath: \.showltestat, value: ShowNetInfo)
                        }, isOn: $ShowNetInfo)
                    
                    SettingToggleRow(
                        icon: "web.camera",
                        title: "Show Camera Feed",
                        subtitle: "View a camera feed from server",
                        onChange: {
                            saveSettings(keyPath: \.showcamera, value: ShowCamera)
                        },
                    isOn: $ShowCamera)
                }
                
                Section("Proximity Settings") {
                    SettingToggleRow(
                        icon: "radio",
                        title: "Auto Headunit",
                        subtitle: "Turn on headunit when nearby",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $headunit
                    )
                    
                    SettingToggleRow(
                        icon: "lock.rotation",
                        title: "Auto Lock/Unlock",
                        subtitle: "Control locks based on device proximity",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $nearbycentralcontrol
                    )
                }

                Section("Security Settings") {
                    SettingToggleRow(
                        icon: "bell.and.waves.left.and.right",
                        title: "Override Alarm",
                        subtitle: "Activate hazards and horn during alarm",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $turnonalarm
                    )
                    
                    SettingToggleRow(
                        icon: "light.beacon.max",
                        title: "Notify on alarm",
                        subtitle: "Rings/notifies user on alarm activation",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $alarmusernotify
                    )
                    
                    SettingToggleRow(
                        icon: "steeringwheel.and.key",
                        title: "Lock while driving",
                        subtitle: "Locks the vehicle at a certain speed",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $alarmusernotify
                    )
                }

                Section("Keyfob Settings") {
                    SettingToggleRow(
                        icon: "key.car.radiowaves.forward",
                        title: "Allow custom keyfob settings",
                        subtitle: "custom actions on remote unlock/lock",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $turnonalarm
                    )
                    
                    SettingToggleRow(
                        icon: "radio",
                        title: "Turn on/off radio with remote",
                        subtitle: "custom actions on remote unlock/lock",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $turnonalarm
                    )
                    
                    SettingToggleRow(
                        icon: "horn.blast",
                        title: "Honk on lock/unlock",
                        subtitle: "Honk when locked or unlocked or both",
                        onChange: {
                            // Add your code here to handle changes
                        },
                        isOn: $turnonalarm
                    )
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
               
                        Text("Device Information")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text("\(UIDevice.current.model) - iOS \(UIDevice.current.systemVersion)")
                                .font(.caption)
        
                                                        
                                                }
                        Spacer()
                        Text("App Information")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Vehicle Controller v2.1")
                            .font(.caption)
                        Text("Author: Aiden Wood")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                    
                        AppState.shared.settingOpen = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .imageScale(.medium)
                            Text("Back")
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
}

private func saveSettings<T>(keyPath: WritableKeyPath<AppSettings, T>, value: T) {
    let context = CoreDataStack.shared.viewContext
    let fetchRequest: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
    
    do {
        var settings = try context.fetch(fetchRequest).first ?? AppSettings(context: context)
        settings[keyPath: keyPath] = value
        try context.save()
    } catch {
        print("Error saving setting: \(error)")
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let onChange: () -> Void
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .imageScale(.medium)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }.onChange(of: isOn) { newValue in
            onChange()
        }
    }
}

#Preview {
    Settings()
}
