import 'tcp_client.dart';

TCPClient tcpClient = TCPClient();
void main() async {
  // Example usage
  await tcpClient.createConnection('localhost', 65432);
}
