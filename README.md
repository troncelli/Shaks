# CarMirror — espelhar a tela do iPhone no Apple CarPlay

Espelha o que está na tela do iPhone (vídeos, YouTube, galeria, etc.) no display do CarPlay, sem adaptadores.
Pensado para uso do **passageiro** com o carro em movimento.

## Como funciona
1. **Extensão de transmissão (ReplayKit)** captura a tela do iPhone, comprime cada quadro em JPEG (~24 fps, máx. 1280 px).
2. Os quadros vão por **TCP em loopback** (127.0.0.1:52847) para o app principal.
3. O app tem uma **cena CarPlay de navegação** (`CPMapTemplate` + `CPWindow`) cujo view controller exibe os quadros.
4. Áudio silencioso em loop (mixando com outros apps) evita que o iOS suspenda o app em segundo plano.

## Requisitos (inevitáveis)
- Mac com Xcode 15+ e iPhone com iOS 15+.
- **Apple Developer Program (US$ 99/ano).** Conta gratuita não permite CarPlay.
- **Entitlement CarPlay de navegação** (`com.apple.developer.carplay-maps`): peça em
  https://developer.apple.com/contact/carplay/ (categoria *Navigation*). A Apple aprova caso a caso e pode demorar.
  Sem ele o app não aparece no CarPlay — não há como contornar.
- Defender com Apple CarPlay (com fio ou sem fio). Nada de configuração de Wi-Fi no carro.

## Instalando
```bash
brew install xcodegen
xcodegen generate        # gera CarMirror.xcodeproj
open CarMirror.xcodeproj
```
1. Em `project.yml`, preencha `DEVELOPMENT_TEAM` (ou escolha o time nos dois targets no Xcode).
2. Troque os bundle IDs `com.shaks.carmirror` / `.broadcast` por IDs seus (e atualize `preferredExtension` em `ContentView.swift`).
3. No portal Apple, habilite o entitlement CarPlay no App ID e gere o perfil.
4. Rode no iPhone.

## Usando
1. Conecte o iPhone ao CarPlay.
2. Abra o CarMirror → botão vermelho → **CarMirror → Iniciar transmissão**.
3. No CarPlay, abra o app **CarMirror**.
4. Volte à tela inicial do iPhone e abra o vídeo. Gire para paisagem para preencher a tela do carro.

## Limitações
- Apps com DRM (Netflix, Disney+, Prime…) aparecem pretos: o iOS bloqueia a captura.
- Código escrito sem acesso a um Mac/iPhone: a compilação é verificada no GitHub Actions, mas **o teste em carro real precisa ser feito por você**. Se algo falhar, me diga a mensagem de erro.
- A Apple pode rejeitar o app na App Store (CarPlay não permite vídeo); para uso pessoal, instale direto pelo Xcode.
