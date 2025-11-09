import MapKit
import CoreData
import SwiftUI
import LocalAuthentication
import CoreLocation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

struct ContentView: View {
    @State private var locked: Bool = true
    @State private var request: URLRequest = URLRequest(url: URL(string: "http://192.168.30.13:8080")!)
    @State private var lights: Bool = true
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var appState = AppState.shared
    @State private var isMenuOpen = false
    @State private var NetworkStatsEnabled: Bool
    @State private var CameraFeedEnabled: Bool
    @State private var tracking: MapUserTrackingMode = .none
    @State private var mainBatteryVoltage: Double = 12.6
    @State private var auxBatteryVoltage: Double = 12.8
    @State private var longitude: Double = 138.59275
    @State private var latitude: Double = -34.907222
    @State private var connectionType = "Direct LAN"
    private let interneturl = URL(string: "http://168.138.13.233:8080")!
    private let lanurl = "http://192.168.30.13:8080"
    let context = CoreDataStack.shared.viewContext
    
    
    init() {
        let fetchRequest: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        if let settings = try? context.fetch(fetchRequest).first {
            _NetworkStatsEnabled = State(initialValue: settings.showltestat)
            _CameraFeedEnabled = State(initialValue: settings.showcamera)
        } else {
            _CameraFeedEnabled = State(initialValue: false)
            _NetworkStatsEnabled = State(initialValue: false)
        }
    }
    
    
    @State private var MapLocations = [
        MapLocation(name: "Car", latitude: -34.907222, longitude: 138.59275),
                        ]
    
    
    //"http://192.168.1.84:8080"
    // degault""
 
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -34.907222, longitude: 138.59275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        Group {
            if (appState.settingOpen == true)
            {
                Settings()
            }
            else {
                if(appState.logsOpen == true)
                {
                    Logs()
                }
                else
                {
                    mainView
                }
            }
        }.onAppear{
            locationManager.requestPermission()
            fetchData(argslocation: "/api/data")
//            Lilo.show(loaderStyle: .solid(.systemBackground),
//                      cornerStyle: .rounded(16),
//                      backgroundStyle: .translucent(.black),
//                      width: 75,
//                      height: 75,
//                      animated: true)
        }
    }
    
    private var mainView: some View {
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    // Add state variables for both batteries
                    // Status Card
                    VStack(spacing: 12) {
                        // Left side - Lock Status
                        HStack(spacing: 8) {
                            if(locked) {
                                Image(systemName: "car.side.lock")
                                    .imageScale(.large)
                            } else {
                                Image(systemName: "car.side.lock.open")
                                    .imageScale(.large)
                            }
                            Text(locked ? "Vehicle Locked" : "Vehicle Unlocked")
                                .font(.headline)
                            
                            
                            // Lock/Unlock Button
                            Spacer()
                            Button {
                                authenticateAndToggleLock()
                            } label: {
                                HStack(spacing: 12) {
                                    if(locked) {
                                        Image(systemName: "lock.open")
                                        Text("Unlock")
                                            .fontWeight(.semibold)
                                    } else {
                                        Image(systemName: "lock")
                                        Text("Lock")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: locked ? [.green, .cyan.opacity(0.4)] : [.red, .orange.opacity(0.4)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                            }
                            .padding(.horizontal)
                        }
                        
                        
                        Spacer()
                        
                        // Right side - Battery Status
                        HStack(spacing: 12) {
                            Image(systemName: "minus.plus.batteryblock")
                            Text("Batteries")
                            Spacer()
                                
                            // Main Battery
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text("Main")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "bolt.circle")
                                        .imageScale(.medium)
                                        .foregroundColor(.yellow)
                                }
                                Text(String(format: "%.2fV", mainBatteryVoltage))
                                    .font(.subheadline)
                                    .bold()
                            }
                            
                            // Auxiliary Battery
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text("Aux")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "bolt.circle.fill")
                                        .imageScale(.medium)
                                        .foregroundColor(.yellow)
                                }
                                Text(String(format: "%.2fV", auxBatteryVoltage))
                                    .font(.subheadline)
                                    .bold()
                            }
                        }
                        
                        // Right side - Battery Status
                        if(NetworkStatsEnabled){
                            Spacer()
                            HStack(spacing: 12) {
                                // Image(systemName: "antenna.radiowaves.left.and.right.circle")
                                HStack(spacing: 4) {
                                    Image(systemName: "cellularbars")
                                        .imageScale(.medium)
                                        .foregroundColor(.green)
                                    Text("Telstra 4G")
                                    
                                }
                                
                                
                                Spacer()
                                
                                
                                // Auxiliary Battery
                                VStack(alignment: .trailing, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text("Down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "arrowshape.down.circle")
                                            .imageScale(.medium)
                                            .foregroundColor(.yellow)
                                    }
                                    Text("0GB")
                                        .font(.subheadline)
                                        .bold()
                                }
                                
                                // Auxiliary Battery
                                VStack(alignment: .trailing, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text("Upload")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "arrowshape.up.circle")
                                            .imageScale(.medium)
                                            .foregroundColor(.yellow)
                                    }
                                    Text("0GB")
                                        .font(.subheadline)
                                        .bold()
                                }
                                
                                // Main Battery
                                
                            }}
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    
                    
                    // Horn Button
                    // Controls Row
                    HStack(spacing: 16) {
                        // Horn Button
                        Button {
                            fetchData(argslocation: "/api/honkhorn")
                            
                           // sendHonkCommand()
                        } label: {
                            VStack {
                                Image(systemName: "horn.blast")
                                    .imageScale(.large)
                                Text("Horn")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.yellow, .orange.opacity(0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        }
                        
                        // Windows Button
                        Button {
                            // Add windows command
                        } label: {
                            VStack {
                                Image(systemName: "arrowtriangle.up.arrowtriangle.down.window.left")
                                    .imageScale(.large)
                                Text("Windows")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .cyan.opacity(0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        }
                        
                        // Lights Button
                        Button {
                            // Add lights command
                            fetchData(argslocation: "/api/lights")
                        } label: {
                            VStack {
                                if lights {
                                Image(systemName: "headlight.high.beam.fill")
                                    .imageScale(.large)
                                Text("Lights")
                                    .font(.caption)
                                } else {
                                Image(systemName: "headlight.high.beam")
                                    .imageScale(.large)
                                Text("Lights")
                                    .font(.caption)
                                }
                              
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .indigo.opacity(0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        }
                        // Hazard Button
                            Button {
                                fetchData(argslocation: "/api/hazard")
                                // Add hazard command
                            } label: {
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .imageScale(.large)
                                    Text("Hazard")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [.red, .orange.opacity(0.4)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                            }
                        }
                    
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial))
                    
                    // Location Section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "location.circle")
                            Text("Live Location")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Map(coordinateRegion: $region,
                            interactionModes: MapInteractionModes.all,
                               showsUserLocation: true,
                               userTrackingMode: $tracking,
                               annotationItems: MapLocations,
                               annotationContent: { location in
                            MapMarker(coordinate: location.coordinate, tint: .red)
                               }
                        
                        )
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            openInMaps()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "map")
                                Text("Open in Maps")
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    // Location Section
                    if(CameraFeedEnabled){
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "camera.metering.center.weighted")
                                Text("Video Feed")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            
                            
                            Button {
                                // openInMaps()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "hand.pinch")
                                    Text("Enlarge")
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }}
                    
                }
                .padding()
            }
            .navigationTitle("Vehicle Overview")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        if(connectionType.contains("Pajero") || connectionType.lowercased().contains("wifi")){
                            Image(systemName: "wifi")
                                .imageScale(.large)
                            Text(connectionType)
                        }else{
                            if(connectionType.contains("LTE")){
                                Image(systemName: "link.icloud.fill")
                                    .imageScale(.large)
                                Text(connectionType)
                            }else{
                                Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                                .imageScale(.large)}
                            Text(connectionType)
                                .font(.headline)
                        }}
                    Text(connectionType)
                    
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.primary)
                            .font(.system(size: 20))
                            .padding(8)
                            .background(Color.clear)
                    }
                
                    .popover(isPresented: $isMenuOpen, attachmentAnchor: .point(.topTrailing), arrowEdge: .top) {
                        VStack(alignment: .leading, spacing: 12) {
                            MenuOption(
                                title: "Vehicle Settings",
                                icon: "car.fill",
                                action: {
                                    AppState.shared.settingOpen = true
                                    isMenuOpen = false
                                }
                            )
                            MenuOption(
                                title: "Vehicle Logs",
                                icon: "info.circle",
                                action: {
                                    // Your action here
                                    AppState.shared.logsOpen = true
                                    isMenuOpen = false
                                }
                            )
                            MenuOption(
                                title: "Feedback",
                                icon: "pencil.line",
                                action: {
                                    // Your action here
                                    if let url = URL(string: "https://aidenwood.me/feedback") {
                                           UIApplication.shared.open(url)
                                       }
                                    isMenuOpen = false
                                }
                            )
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .presentationCompactAdaptation(.popover)
                    }                }
            }
        }
    }
    
    private func fetchData(argslocation: String) {
        
        if let ssid = Helper.shared.getWiFiSSID() {
            if(Helper.shared.checkVPNStatus())
            {
                connectionType = "VPN LAN"
                let requestlink = lanurl+argslocation
                getData(argslocation: argslocation, requestURL: requestlink)
            }else{
                if(ssid == "PAJ-NET"){
                    let requestlink = "http://192.168.0.209:8080"+argslocation
                    connectionType = "Pajero WiFi"
                    getData(argslocation: argslocation, requestURL: requestlink)
                }else{
                    if(ssid == "Pajero-WiFi") {
                        
                        let requestlink = "http://192.168.1.130:8080"+argslocation
                        connectionType = "Pajero WiFi"
                        getData(argslocation: argslocation, requestURL: requestlink)
                    }else{
                        
                        connectionType = "WiFI LAN"
                        let requestlink = lanurl+argslocation
                        getData(argslocation: argslocation, requestURL: requestlink)
                        
                    }
                }
            }
        } else {
            if(Helper.shared.checkVPNStatus())
            {
                connectionType = "VPN LAN"
                let requestlink = lanurl+argslocation
                getData(argslocation: argslocation, requestURL: requestlink)
            }
        }
        
    }
    private func getData(argslocation: String, requestURL: String){
        var request = URLRequest(url: URL(string: requestURL)!)
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
        //request.setValue("", forHTTPHeaderField: "")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error took place \(error.localizedDescription)")
                if(error.localizedDescription.contains("Could not connect to the server")){
                   // connectionType = "Cloud Connection - LTE"
                    //retry the attemp with cloud server
//                    Lilo.hide(animated: true)

                    
                }
              //  return error
            }
            
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(VehicleResponse.self, from: data)
                print("Received response: \(response)")
                
                if(response.lock_status == "true"){
                    locked = true
                }else{
                    locked = false
                }
                if(response.lightstat == "on"){
                    lights = true
                }else
                    {
                    lights = false
                }
                mainBatteryVoltage = Double(response.mainBat)!
                auxBatteryVoltage = Double(response.secondBat)!
                longitude = Double(response.longitude)!
                latitude = Double(response.latitude)!
                
                //close Lilo
//                Lilo.hide(animated: true)
                
                
                MapLocations = [
                    MapLocation(name: "Car", latitude: latitude, longitude: longitude),
                        ]
            
                
                if let latitude = Double(response.latitude),
                   let longitude = Double(response.longitude) {
                    region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                
        } catch {
               print("Decoding error: \(error)")
           }
            
        }.resume()
    }



    
    private func authenticateAndToggleLock() {
        if locked {
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                    localizedReason: "Authenticate to unlock vehicle") { success, error in
                    guard success, error == nil else { return }
                    locked = false
                   // sendLockCommand(unlock: true)
                }
            }
            
            //post to server for lock/unlock
            fetchData(argslocation: "/api/locktoggle")
            
        } else {
            locked = true
           fetchData(argslocation: "/api/locktoggle")
        }
    }

    private func openInMaps() {
       // https://www.google.com/maps/place/0.19351+119.62767/@0.19351,119.62767,2z/data=!3m1!1e3
        let url = URL(string: "https://www.google.com/maps/place/\(latitude)+\(longitude)/@\(latitude),\(longitude),2z/data=!3m1!1e3")!
        UIApplication.shared.open(url)
    }
}
          
struct VehicleResponse: Codable {
    let lock_status: String
    let longitude: String
    let latitude: String
    let speed_kmh: String
    let altitude: String
    let nearbylocking: String
    let lightstat: String
    let mainBat: String
    let secondBat: String
}


struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
struct MenuOption: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        
        
        
//        Button {
//            authenticateAndToggleLock()
//        } label: {
//            HStack(spacing: 12) {
//                if(locked) {
//                    Image(systemName: "lock.open")
//                    Text("Unlock")
//                        .fontWeight(.semibold)
//                } else {
//                    Image(systemName: "lock")
//                    Text("Lock")
//                        .fontWeight(.semibold)
//                }
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 56)
//            .background(
//                LinearGradient(
//                    colors: locked ? [.green, .cyan.opacity(0.4)] : [.red, .orange.opacity(0.4)],
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//            )
//            .foregroundColor(.white)
//            .clipShape(RoundedRectangle(cornerRadius: 28))
//            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
//        }
//        .padding(.horizontal)
//        
        
        Button{
            action()
       // Call the action that was passed in
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ContentView()
}
