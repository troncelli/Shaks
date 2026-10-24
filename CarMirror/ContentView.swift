import SwiftUI
import ReplayKit

/// Botão nativo do iOS que abre o seletor de transmissão já filtrado para a nossa extensão.
struct BroadcastPicker: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        picker.preferredExtension = "com.shaks.carmirror.broadcast"
        picker.showsMicrophoneButton = false
        for case let button as UIButton in picker.subviews {
            button.imageView?.tintColor = .white
        }
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}

struct ContentView: View {
    @ObservedObject private var model = MirrorModel.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("CarMirror").font(.largeTitle.bold())

                VStack(alignment: .leading, spacing: 10) {
                    statusRow("CarPlay conectado", ok: model.carPlayConnected)
                    statusRow("Recebendo tela (\(model.fps) fps)", ok: model.receiving)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                ZStack {
                    Circle().fill(Color.red).frame(width: 96, height: 96)
                    BroadcastPicker().frame(width: 96, height: 96)
                }
                Text("Toque no botão, escolha “CarMirror” e “Iniciar transmissão”.")
                    .font(.footnote).foregroundColor(.secondary).multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Como usar").font(.headline)
                    Text("1. Conecte o iPhone ao CarPlay do carro.")
                    Text("2. Toque no botão vermelho e inicie a transmissão.")
                    Text("3. No CarPlay, abra o app CarMirror.")
                    Text("4. Volte à tela inicial e abra o vídeo (YouTube, galeria…). Gire o iPhone para paisagem para preencher a tela do carro.")
                    Text("Obs.: apps com proteção de conteúdo (Netflix, Disney+, etc.) aparecem em preto — é bloqueio do iOS.")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }

    private func statusRow(_ text: String, ok: Bool) -> some View {
        HStack {
            Circle().fill(ok ? Color.green : Color.gray).frame(width: 12, height: 12)
            Text(text)
        }
    }
}
