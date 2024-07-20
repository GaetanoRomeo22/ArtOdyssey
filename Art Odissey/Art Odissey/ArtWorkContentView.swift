import SwiftUI

struct ArtWorkContentView: View {
    let artWork: ArtWork // art work to show

    var body: some View {
        ScrollView {
            Text("🎉 Congratulazioni! Hai trovato la soluzione! 🎉")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding()
            VStack(alignment: .center, spacing: 10) {
                Text(artWork.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                Image(artWork.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Artista:")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .fontWeight(.bold)
                        Spacer()
                        Text(artWork.artist)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding([.leading, .trailing])
                    HStack {
                        Text("Data:")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .fontWeight(.bold)
                        Spacer()
                        Text(artWork.date)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding([.leading, .trailing])
                    HStack {
                        Text("Tecnica di pittura:")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .fontWeight(.bold)
                        Spacer()
                        Text(artWork.technique)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding([.leading, .trailing])
                    Text("Descrizione:")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fontWeight(.bold)
                        .padding([.leading, .trailing, .bottom])
                    Text(artWork.description)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding([.leading, .trailing])
                }
            }
        }
        .navigationBarTitle(artWork.title)
    }
}
