import SwiftUI

struct ContentView: View {
    @StateObject var vm = AstroViewModel()
    @State var showSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color("bgTop"), Color("bgBottom")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top controls
                    VStack(spacing: 12) {
                        DatePicker("Fecha", selection: $vm.selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                            .padding(.horizontal)
                        
                        Picker("Perspectiva", selection: $vm.isGeocentric) {
                            Text("Geocéntrico").tag(true)
                            Text("Heliocéntrico").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        Button(action: { vm.compute() }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Calcular Posiciones")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(Color.black.opacity(0.3))
                    
                    if vm.isLoading {
                        Spacer()
                        ProgressView("Calculando...")
                            .foregroundColor(.white)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                // Angles section
                                SectionHeader(title: "Ángulos de la Carta")
                                PlanetRow(planet: vm.ascendantPosition, isAngle: true)
                                PlanetRow(planet: vm.midheavenPosition, isAngle: true)
                                PlanetRow(planet: vm.descendantPosition, isAngle: true)
                                PlanetRow(planet: vm.imumCoeliPosition, isAngle: true)
                                
                                SectionHeader(title: "Planetas")
                                ForEach(vm.planets) { planet in
                                    PlanetRow(planet: planet, isAngle: false)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Grados Planetarios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "location.circle")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                LocationSettingsView(vm: vm)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: vm.selectedDate) { _ in vm.compute() }
        .onChange(of: vm.isGeocentric) { _ in vm.compute() }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.yellow.opacity(0.8))
                .tracking(2)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
}

struct PlanetRow: View {
    let planet: PlanetPosition
    let isAngle: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Symbol
            ZStack {
                Circle()
                    .fill(symbolColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Text(planet.symbol)
                    .font(.system(size: 20))
                    .foregroundColor(symbolColor)
            }
            
            // Name
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(planet.name)
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    if planet.isRetrograde {
                        Text("℞")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                Text(planet.sign.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Position
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Text(planet.sign.glyph)
                        .font(.title3)
                        .foregroundColor(signColor(planet.sign))
                    Text("\(Int(planet.degreeInSign))°\(Int(planet.minuteInSign))'\(Int(planet.secondInSign))\"")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                if !isAngle && planet.distance > 0 {
                    Text(String(format: "%.3f AU", planet.distance))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isAngle ? 0.07 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    var symbolColor: Color {
        if isAngle { return .yellow }
        switch planet.name {
        case "Sol": return .yellow
        case "Luna": return .white
        case "Mercurio": return .mint
        case "Venus": return .pink
        case "Marte": return .red
        case "Júpiter": return .orange
        case "Saturno": return .brown
        case "Urano": return .cyan
        case "Neptuno": return .blue
        case "Plutón": return .purple
        case "Nodo Norte": return .green
        case "Nodo Sur": return .green.opacity(0.7)
        default: return .gray
        }
    }
    
    func signColor(_ sign: ZodiacSign) -> Color {
        switch sign {
        case .aries, .leo, .sagittarius: return .red
        case .taurus, .virgo, .capricorn: return .green
        case .gemini, .libra, .aquarius: return .yellow
        case .cancer, .scorpio, .pisces: return .blue
        }
    }
}
