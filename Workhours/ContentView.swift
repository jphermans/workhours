//
//  ContentView.swift
//  Workhours
//
//  Created by Jean-Pierre Hermans on 29/03/2025.
//

import SwiftUI
import SQLite3

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { self.rawValue }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

extension Color {
    static let atlasTeal = Color(red: 5/255, green: 78/255, blue: 90/255)
    static let atlasGray = Color(red: 161/255, green: 169/255, blue: 180/255)
    static let atlasGold = Color(red: 225/255, green: 183/255, blue: 126/255)
    static let atlasGreen = Color(red: 93/255, green: 120/255, blue: 117/255)
    static let atlasLightGreen = Color(red: 206/255, green: 217/255, blue: 215/255)
    static let atlasBlue = Color(red: 18/255, green: 63/255, blue: 109/255)
    static let atlasBackgroundLight = Color(red: 250/255, green: 249/255, blue: 244/255)
}

extension Color {
    static var atlasBackground: Color {
        Color("AtlasBackground")
    }

    static var atlasPanel: Color {
        let colorScheme = UITraitCollection.current.userInterfaceStyle
        return colorScheme == .dark ? Color(red: 0.1, green: 0.2, blue: 0.25) : Color.white
    }

    static var atlasText: Color {
        let colorScheme = UITraitCollection.current.userInterfaceStyle
        return colorScheme == .dark ? Color.white : Color.atlasTeal
    }
}

struct ContentView: View {
    @AppStorage("colorSchemeChoice") private var colorSchemeChoice: String = "system"
    @State private var isTimerRunning = false
    @State private var startTime: Date?
    @State private var totalSeconds: TimeInterval = 0
    @State private var date = Date()
    @State private var customer = ""
    @State private var isExternal = true
    @State private var customerOrder = ""
    @State private var customerAmount = ""
    @State private var spiritOrder = ""
    @State private var description = ""
    @State private var hoursBooked = ""

    var body: some View {
        TabView {
            WorkEntryView(date: $date, customer: $customer, isExternal: $isExternal, customerOrder: $customerOrder, customerAmount: $customerAmount, spiritOrder: $spiritOrder, description: $description, hoursBooked: $hoursBooked, saveAction: saveOrder)
                .tabItem {
                    Label("Work", systemImage: "clock")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(
            colorSchemeChoice == "light" ? .light :
            colorSchemeChoice == "dark" ? .dark : nil
        )
    }

    func startTimer() {
        startTime = Date()
        isTimerRunning = true
    }

    func stopTimer() {
        if let start = startTime {
            totalSeconds += Date().timeIntervalSince(start)
        }
        isTimerRunning = false
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let hrs = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }

    func setupDatabase() {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Workhours.sqlite")

        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            let createTableQuery = """
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT,
                customer TEXT,
                isExternal INTEGER,
                customerOrder TEXT,
                customerAmount REAL,
                spiritOrder TEXT,
                description TEXT,
                hoursBooked REAL
            );
            """
            if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
                print("Error creating table")
            }
            sqlite3_close(db)
        }
    }

    func saveOrder() {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Workhours.sqlite")

        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            let insertQuery = """
            INSERT INTO orders (date, customer, isExternal, customerOrder, customerAmount, spiritOrder, description, hoursBooked)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
            """
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, date.ISO8601Format().cString(using: .utf8), -1, nil)
                sqlite3_bind_text(statement, 2, customer.capitalized.cString(using: .utf8), -1, nil)
                sqlite3_bind_int(statement, 3, isExternal ? 1 : 0)
                sqlite3_bind_text(statement, 4, customerOrder.uppercased().cString(using: .utf8), -1, nil)
                sqlite3_bind_double(statement, 5, Double(customerAmount) ?? 0.0)
                sqlite3_bind_text(statement, 6, spiritOrder.uppercased().cString(using: .utf8), -1, nil)
                sqlite3_bind_text(statement, 7, description.cString(using: .utf8), -1, nil)
                sqlite3_bind_double(statement, 8, Double(hoursBooked) ?? 0.0)

                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Order saved successfully")
                } else {
                    print("Failed to save order")
                }
            }

            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
    }
}

struct WorkEntryView: View {
    @Binding var date: Date
    @Binding var customer: String
    @Binding var isExternal: Bool
    @Binding var customerOrder: String
    @Binding var customerAmount: String
    @Binding var spiritOrder: String
    @Binding var description: String
    @Binding var hoursBooked: String
    @AppStorage("hourRate") private var hourRate: String = ""
    var saveAction: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    private var calculatedHoursText: Text {
        let net = Double(customerAmount) ?? 0
        let percentage = Double(UserDefaults.standard.string(forKey: "netPercentage") ?? "") ?? 0
        let rate = Double(UserDefaults.standard.string(forKey: "hourRate") ?? "") ?? 0
        let calculatedHours = floor((net - (net * percentage / 100)) / (rate == 0 ? 1 : rate))
        return Text(String(format: "%.0f hours book", calculatedHours))
            .foregroundColor(colorScheme == .dark ? .atlasGold : .green)
            .bold()
    }
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.atlasTeal : Color.atlasBackgroundLight)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Workhours Booker")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.atlasTeal)
                    .foregroundColor(colorScheme == .dark ? .atlasGold : .white)
                    .clipShape(Capsule())

                VStack(spacing: 16) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    TextField("Customer", text: $customer)
                        .onChange(of: customer) { newValue in
                            customer = newValue.capitalized
                        }
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                        )
                        .cornerRadius(6)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .environment(\.colorScheme, colorScheme)

                    Toggle(isExternal ? "External Order" : "Internal Order", isOn: $isExternal)

                    if isExternal {
                        TextField("Customer Order", text: $customerOrder)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                            )
                            .cornerRadius(6)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .environment(\.colorScheme, colorScheme)

                        TextField("Customer Amount", text: $customerAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                            )
                            .cornerRadius(6)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .environment(\.colorScheme, colorScheme)

                        TextField("Spirit Order", text: $spiritOrder)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                            )
                            .cornerRadius(6)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .environment(\.colorScheme, colorScheme)

                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .padding(10)
                            .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                            )
                            .cornerRadius(6)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .environment(\.colorScheme, colorScheme)
                        if !customerAmount.isEmpty {
                            calculatedHoursText
                        }

                        Button("Save External Order") {
                            saveAction()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.atlasGold)
                    } else {
                        TextField("Hours Booked", text: $hoursBooked)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                            )
                            .cornerRadius(6)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .environment(\.colorScheme, colorScheme)

                    TextField("Spirit Order", text: $spiritOrder)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                            )
                            .cornerRadius(6)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .environment(\.colorScheme, colorScheme)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                        .padding(10)
                        .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                        )
                        .cornerRadius(6)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .environment(\.colorScheme, colorScheme)

                    if let hours = Double(hoursBooked), let rate = Double(hourRate), hours > 0, rate > 0 {
                        let total = hours * rate
                        Text(String(format: "€ %.2f", total))
                            .foregroundColor(.red)
                            .bold()
                    }

                    Button("Save Internal Order") {
                        saveAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.atlasGold)
                    }
                }
                .padding()
                .background(colorScheme == .dark ? Color.atlasPanel : Color.atlasGray.opacity(0.05))
                .cornerRadius(12)
                .shadow(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0.2 : 0.5), lineWidth: 1)
                )
            }
            .padding()
        }
    }
}

struct SettingsView: View {
    @AppStorage("colorSchemeChoice") private var colorSchemeChoice: String = "system"
    @AppStorage("netPercentage") private var netPercentage: String = ""
    @AppStorage("hourRate") private var hourRate: String = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.atlasTeal : Color.atlasBackgroundLight)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.atlasTeal)
                    .foregroundColor(colorScheme == .dark ? .atlasGold : .white)
                    .clipShape(Capsule())

                Text("Color Settings")
                    .font(.headline)
                    .foregroundColor(Color.atlasText)

                Picker("Appearance", selection: $colorSchemeChoice) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Text("Rates")
                    .font(.headline)
                    .foregroundColor(Color.atlasText)

                VStack(spacing: 16) {
                    Text("Net percentage (%)")
                        .foregroundColor(Color.atlasText)
                        .font(.subheadline)
                    TextField("", text: $netPercentage)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                        )
                        .cornerRadius(6)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .environment(\.colorScheme, colorScheme)

                    Text("Hour rate (€)")
                        .foregroundColor(Color.atlasText)
                        .font(.subheadline)
                    TextField("", text: $hourRate)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(colorScheme == .dark ? Color.atlasGray.opacity(0.2) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0 : 0.4), lineWidth: 1)
                        )
                        .cornerRadius(6)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .environment(\.colorScheme, colorScheme)
                }
                .padding()
                .background(colorScheme == .dark ? Color.atlasPanel : Color.atlasGray.opacity(0.05))
                .cornerRadius(12)
                .shadow(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.atlasGray.opacity(colorScheme == .dark ? 0.2 : 0.5), lineWidth: 1)
                )

            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
