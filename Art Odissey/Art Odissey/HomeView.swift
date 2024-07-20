import SwiftUI

struct HomeView: View {
    @State private var selectedFloorIndex: Int = 0 // index to select the floor
    @State private var selectedFloor: Floor = Floor(name: "Piano Terra", artWorks: [crocifissioneMasaccio])
    var selectedFloorImage: String { // selects the image to show depending on selected floor
            switch selectedFloorIndex {
            case 0:
                return "PianoTerra"
            case 1:
                return "PrimoPiano"
            case 2:
                return "SecondoPiano"
            default:
                return ""
            }
        }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("In quale piano ti trovi?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                    .padding(.top, 100)
                Image(selectedFloorImage) // shows floor's map
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 500)
                    .padding(.horizontal)
                Picker("Piano", selection: $selectedFloorIndex) { // floor's selection
                    ForEach(0..<floors.count, id: \.self) { index in
                        Text(floors[index].name)
                            .font(.headline)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, -50)
                NavigationLink(destination: GameContentView(floor: floors[selectedFloorIndex])) { // button to press to confirm floor's selection
                    Text("Conferma")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 50)
                        .padding(.bottom, 100)
                }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
            }
            .padding()
        }
    }
}
