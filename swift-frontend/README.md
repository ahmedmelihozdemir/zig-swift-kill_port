# Port Kill Monitor - Swift Frontend

Modern MVVM mimarisiyle geliştirilmiş macOS menu bar uygulaması. Belirtilen portlarda çalışan işlemleri izler ve bunları güvenli bir şekilde sonlandırmanızı sağlar.

## 🚀 Özellikler

- **Menu Bar Entegrasyonu**: Sistem menu bar'ında sürekli çalışan küçük ikon
- **Gerçek Zamanlı İzleme**: Portları 2 saniyede bir tarayarak güncel durumu gösterir
- **Modern Swift UI**: SwiftUI ile oluşturulmuş kullanıcı dostu arayüz
- **MVVM Mimarisi**: Temiz kod prensipleri ve test edilebilir yapı
- **Process Management**: Güvenli SIGTERM/SIGKILL işlem sonlandırma
- **Sandbox Desteği**: macOS güvenlik gereksinimlerine uygun

## 🏗️ Mimari

### MVVM (Model-View-ViewModel) Pattern
```
Models/
├── ProcessInfo.swift          # Process veri modeli
└── StatusBarInfo.swift        # Status bar bilgi modeli

ViewModels/
└── MenuBarViewModel.swift     # Business logic ve state management

Views/
└── MenuBarView.swift          # SwiftUI arayüz bileşenleri

Services/
└── PortKillService.swift      # Backend iletişim katmanı

Managers/
└── MenuBarManager.swift       # macOS menu bar entegrasyonu
```

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler
- **SwiftUI**: Modern UI framework
- **Combine**: Reactive programming için data binding
- **Foundation Process**: Sistem komutlarını çalıştırma
- **AppKit**: macOS menu bar entegrasyonu

### İzlenen Portlar (Varsayılan)
- 3000, 3001 (Development sunucuları)
- 8000, 8080 (HTTP alternatif portları)
- 5000, 9000 (Genel uygulama portları)

### Güvenlik
- Sandbox desteği devre dışı (sistem komutları için gerekli)
- Network client/server yetkisi
- Dosya erişim izinleri

## 🚦 Kurulum ve Çalıştırma

### Gereksinimler
- macOS 15.5+
- Xcode 16.0+
- Swift 5.0+

### Build
```bash
cd swift-frontend
xcodebuild -project swift-frontend.xcodeproj -scheme swift-frontend -configuration Debug build
```

### Çalıştırma
```bash
open /Users/melih.ozdemir/Library/Developer/Xcode/DerivedData/swift-frontend-*/Build/Products/Debug/swift-frontend.app
```

## 🎯 Kullanım

1. **Uygulama Başlatma**: Menu bar'da ⚡ ikonunu arayın
2. **Port İzleme**: İkon üzerine tıklayarak popover açın
3. **Process Listesi**: Aktif işlemleri port bilgileriyle birlikte görün
4. **Tekil Sonlandırma**: Her işlemin yanındaki ❌ butonuna tıklayın
5. **Toplu Sonlandırma**: "Kill All Processes" butonunu kullanın

## 📋 Özellik Detayları

### Process Monitoring
- `lsof` komutu ile port taraması
- `ps` komutu ile process detaylarını alma
- 2 saniyede bir otomatik güncelleme
- Efficient scanning (sadece değişiklik varsa UI güncelleme)

### Process Termination
1. **SIGTERM (15)**: Nezaketen sonlandırma
2. **500ms bekleme**: Process'in temiz şekilde kapanması için
3. **SIGKILL (9)**: Gerekirse zorla sonlandırma

### UI Components

#### MenuBarView
- Header: Uygulama adı ve refresh butonu
- Status: Durum bilgisi ve tooltip
- Process List: Aktif işlemler listesi
- Kill All: Toplu sonlandırma butonu
- Footer: Settings ve Quit butonları

#### ProcessRowView
- Port badge: Port numarası
- Process info: İsim ve PID
- Command path: Tam dosya yolu
- Kill button: Tekil sonlandırma

### Error Handling
- Process bulunamadı durumları
- Komut çalıştırma hataları
- Kill işlemi başarısızlıkları
- Network erişim sorunları

## 🔄 State Management

### ObservableObject Pattern
```swift
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var processes: [ProcessInfo] = []
    @Published var isScanning: Bool = false
    @Published var statusInfo: StatusBarInfo
    // ...
}
```

### Combine Bindings
- Service layer'dan ViewModel'e otomatik data akışı
- UI'da reactive güncellemeler
- Error state management

## 🧪 Test Senaryoları

### Manual Testing
1. **Port 3000'de server başlat**:
   ```bash
   python3 -m http.server 3000
   ```

2. **Uygulamayı çalıştır** ve menu bar'dan popover aç

3. **Process görünürlüğünü kontrol et**

4. **Kill functionality test et**

## 📁 Dosya Yapısı

```
swift-frontend/
├── swift-frontend/
│   ├── swift_frontendApp.swift       # Ana uygulama entry point
│   ├── ContentView.swift             # Placeholder view
│   ├── Models/
│   │   ├── ProcessInfo.swift         # Process veri yapısı
│   │   └── StatusBarInfo.swift       # Status bilgi yapısı
│   ├── ViewModels/
│   │   └── MenuBarViewModel.swift    # Ana business logic
│   ├── Views/
│   │   └── MenuBarView.swift         # UI bileşenleri
│   ├── Services/
│   │   └── PortKillService.swift     # Backend haberleşme
│   ├── Managers/
│   │   └── MenuBarManager.swift      # Menu bar yönetimi
│   └── Assets.xcassets/              # UI assets
└── swift-frontend.xcodeproj/         # Xcode proje dosyaları
```

## 🔮 Gelecek Geliştirmeler

- [ ] **Ayarlar Sayfası**: Port listesi özelleştirme
- [ ] **Notification Desteği**: Process kill bildirimleri
- [ ] **Zig Backend Entegrasyonu**: Doğrudan backend kullanımı
- [ ] **Auto-start**: Sistem açılışında otomatik başlatma
- [ ] **Keyboard Shortcuts**: Hızlı erişim tuşları
- [ ] **Filtering**: Process filtreleme ve arama
- [ ] **History**: Sonlandırma geçmişi
- [ ] **Dark Mode**: Tema desteği

## 🐛 Bilinen Sorunlar

- Sandbox kısıtlamaları nedeniyle bazı sistem komutları kısıtlı olabilir
- Process kill işlemi admin yetkisi gerektirebilir
- Menu bar icon tema değişikliklerinde güncelleme gecikmesi

## 📄 Lisans

Bu proje açık kaynak kodludur ve MIT lisansı altında dağıtılmaktadır.

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

**Not**: Bu uygulama Zig backend ile birlikte çalışacak şekilde tasarlanmıştır. Backend entegrasyonu için `zig-backend` klasöründeki projeyi de build etmeniz gerekebilir.
