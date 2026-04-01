import 'package:http/http.dart' as http;
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

http.Client createAppHttpClient() {
  return SecureHttpClient.build(_pinnedSha256TrustAnchors);
}

/// Full-certificate SHA-256 (DER) fingerprints. The vendored plugin matches any cert in the server chain.
/// sobersteps.app → Go Daddy chain; api.elevenlabs.io → Google Trust Services; LE roots for other TLS endpoints.
const String _sha256GoDaddyRootG2 =
    '45:14:0B:32:47:EB:9C:C8:C5:B4:F0:D7:B5:30:91:F7:32:92:08:9E:6E:5A:63:E2:74:9D:D3:AC:A9:19:8E:DA';
const String _sha256GoDaddySecureCaG2 =
    '97:3A:41:27:6F:FD:01:E0:27:A2:AA:D4:9E:34:C3:78:46:D3:E9:76:FF:6A:62:0B:67:12:E3:38:32:04:1A:A6';
const String _sha256IsrgRootX1 =
    '96:BC:EC:06:26:49:76:F3:74:60:77:9A:CF:28:C5:A7:CF:E8:A3:C0:AA:E1:1A:8F:FC:EE:05:C0:BD:DF:08:C6';
const String _sha256IsrgRootX2 =
    '69:72:9B:8E:15:A8:6E:FC:17:7A:57:AF:B7:17:1D:FC:64:AD:D2:8C:2F:CA:8C:F1:50:7E:34:45:3C:CB:14:70';
const String _sha256GtsRootR1 =
    'D9:47:43:2A:BD:E7:B7:FA:90:FC:2E:6B:59:10:1B:12:80:E0:E1:C7:E4:E4:0F:A3:C6:88:7F:FF:57:A7:F4:CF';

const List<String> _pinnedSha256TrustAnchors = [
  _sha256GoDaddyRootG2,
  _sha256GoDaddySecureCaG2,
  _sha256IsrgRootX1,
  _sha256IsrgRootX2,
  _sha256GtsRootR1,
];
