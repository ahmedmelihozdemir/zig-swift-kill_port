# Zig Port Kill

Rust ile yazılmış port-kill uygulamasının Zig 0.15.1 ile yeniden implementasyonu.

## Özellikler

- **Real-time Port Monitoring**: Port 2000-6000 aralığındaki gelişim süreçlerini izler
- **Process Management**: Tespit edilen süreçleri güvenli şekilde sonlandırır
- **GUI ve Console Modu**: Hem sistem çubuğu entegrasyonu hem de konsol modu
- **Esneki Port Konfigürasyonu**: Port aralığı veya spesifik portlar izlenebilir
- **macOS Entegrasyonu**: Native Cocoa API kullanarak sistem çubuğu entegrasyonu

## Gereksinimler

- macOS 10.15 veya üzeri
- Zig 0.15.0 veya üzeri
- `lsof` komutu (macOS ile birlikte gelir)

## Kurulum ve Çalıştırma

### Hızlı Başlangıç

```bash
# Projeyi klonlayın
cd zig-port_kill

# Uygulamayı build edin ve çalıştırın (kolay yol)
./run.sh
```

### Manuel Build

```bash
# Build
zig build

# GUI modunda çalıştır
./zig-out/bin/port-kill

# Console modunda çalıştır
./zig-out/bin/port-kill-console
```

## Kullanım Örnekleri

### Temel Kullanım
```bash
# Varsayılan: port 2000-6000 (GUI modu)
./run.sh

# Console modunda çalıştır
./run.sh --console

# Verbose logging ile
./run.sh --verbose
```

### Port Konfigürasyonu
```bash
# Port aralığı belirle
./run.sh --start-port 3000 --end-port 8080

# Spesifik portları izle
./run.sh --ports 3000,8000,8080,5000

# Console modunda spesifik portlar
./run.sh --console --ports 3000,8000,8080
```

### Komut Satırı Seçenekleri

- `--start-port, -s`: Başlangıç portu (varsayılan: 2000)
- `--end-port, -e`: Bitiş portu (varsayılan: 6000)
- `--ports, -p`: Spesifik portlar (virgülle ayrılmış)
- `--console, -c`: Console modunda çalıştır
- `--verbose, -v`: Detaylı loglama
- `--help, -h`: Yardım bilgisi
- `--version, -V`: Versiyon bilgisi

## Test Etme

```bash
# Test serverları başlat
./test_ports.sh

# Başka bir terminalde uygulamayı çalıştır
./run.sh --console
```

## Rust Versiyonundan Farklar

### Zig 0.15.1 Özellikleri Kullanıldı

1. **Yeni std.Io.Writer API**: Writergate sonrası yeni I/O arayüzü
2. **ArrayList Unmanaged**: Varsayılan olarak unmanaged ArrayList
3. **Compile-time String Formatting**: Zig'in güçlü compile-time özellikleri
4. **Error Handling**: Zig'in error union sistemi
5. **Memory Management**: Manual memory management ile güvenlik

### Mimari Farklar

**Rust Versiyonu:**
- Tokio async runtime
- Crossbeam channels
- Tray-icon crate
- Clap argument parsing

**Zig Versiyonu:**
- Single-threaded event loop
- Direct Cocoa API integration
- Custom CLI parsing
- Manual memory management

### Performans

- **Compilation Speed**: Zig versiyonu çok daha hızlı compile oluyor
- **Runtime Performance**: Minimal memory overhead
- **Binary Size**: Daha küçük binary boyutu

## Teknik Detaylar

### Modül Yapısı

```
src/
├── main.zig              # GUI modunun entry point'i
├── main_console.zig      # Console modunun entry point'i
├── types.zig            # Veri yapıları ve tipler
├── process_monitor.zig  # Process monitoring logic
├── console_app.zig      # Console uygulaması
├── tray_app.zig        # Sistem çubuğu uygulaması
└── cli.zig             # Komut satırı parsing
```

### Process Detection

Süreç tespiti için macOS'un `lsof` komutu kullanılır:
```bash
lsof -ti :PORT -sTCP:LISTEN
```

### Process Termination

1. **SIGTERM**: Önce nazik sonlandırma
2. **SIGKILL**: 500ms sonra hala çalışıyorsa zorla sonlandırma

### macOS Entegrasyonu

Sistem çubuğu entegrasyonu için doğrudan Cocoa API'leri kullanılır:
- NSStatusBar ile sistem çubuğu öğesi
- NSMenu ile context menu
- NSApplication ile event loop

## Zig 0.15.1 Specific Features

Bu implementasyon Zig 0.15.1'in yeni özelliklerini kullanır:

- **Format Methods**: `{f}` formatter ile custom format methods
- **New std.Io**: Writergate sonrası yeni I/O API
- **De-genericified Collections**: Generic olmayan ArrayList
- **Improved Error Handling**: Daha iyi error propagation

## Debugging

```bash
# Console modunda verbose logging ile debug
./run.sh --console --verbose

# Build ile test çalıştır
zig build test
```

## Bilinen Limitasyonlar

1. **GUI Mode**: Sistem çubuğu menu callbacks basitleştirildi
2. **Error Recovery**: Bazı edge case'lerde daha iyi error handling gerekli
3. **Icon Support**: Şu an text-based icon, gelecekte image support eklenebilir

## Rust vs Zig Karşılaştırması

| Özellik | Rust Versiyonu | Zig Versiyonu |
|---------|---------------|---------------|
| Compile Time | ~30 saniye | ~3 saniye |
| Binary Size | ~15MB | ~2MB |
| Memory Safety | Borrow checker | Manual + safety checks |
| Async Support | Tokio runtime | Single-threaded loop |
| Dependencies | ~20 crate | Sadece sistem libs |
| macOS Integration | Third-party crate | Direct Cocoa API |

## Gelecek Planları

1. **Icon Support**: PNG/ICO image support
2. **Menu Callbacks**: Daha robust menu item handling
3. **Event System**: Daha sophisticated event system
4. **Configuration File**: TOML/JSON config support
5. **Process Details**: Daha detaylı process bilgileri

## Katkı

1. Fork repository
2. Feature branch oluştur
3. Değişiklikleri yap
4. Test ekle
5. Pull request gönder

## Lisans

Bu proje Rust versiyonu ile aynı lisans altındadır.
