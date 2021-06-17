import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';

Future<MqttClient> connect() async {
  MqttServerClient client =
      MqttServerClient.withPort('io.adafruit.com', 'flutter_client', 1883);
  client.logging(on: true);
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onUnsubscribed = onUnsubscribed;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier("flutter_client")
      .authenticateAs("Igna72", "aio_jpKk48AsJGPt1Q4scYx28cQfa34k")
      .keepAliveFor(60)
      .withWillTopic('willtopic')
      .withWillMessage('My mensaje')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;
  try {
    print('Conectando');
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus.state == MqttConnectionState.connected) {
    print('Adafruit Conectado!');
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Mensaje recibido:$payload del feed: ${c[0].topic}>');
    });

    client.published.listen((MqttPublishMessage message) {
      print('Publicado');
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print(
          'Mensaje publicado: $payload al feed: ${message.variableHeader.topicName}');
    });
  } else {
    print('Adafruit desconectado:  ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }

  return client;
}

void onConnected() {
  print('Conectado');
}

void onDisconnected() {
  print('Desconectado');
}

void onSubscribed(String topic) {
  print('Fedd Suscrito: $topic');
}

void onSubscribeFail(String topic) {
  print('Fallo al suscribir al Feed: $topic');
}

void onUnsubscribed(String topic) {
  print('Feed no suscrito: $topic');
}

void pong() {
  print('Ping');
}
