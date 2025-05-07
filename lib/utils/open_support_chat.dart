import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openSupportChat() async {
  final link = WhatsAppUnilink(
    phoneNumber: '+527204278812',
    text: 'Hola, soy usuario Pro y tengo una duda:',
  );
  await launchUrl(link.asUri(), mode: LaunchMode.externalApplication);
}
